#!/usr/bin/env python3
"""
gpx_to_geojson.py

GPX -> GeoJSON FeatureCollection in the exact shape you showed:

{
  "type": "FeatureCollection",
  "properties": {
    "id": "...",
    "name": "...",
    "description": "...",
    "distance_km": <float>,
    "difficulty": "...",
    "route_number": <int>,
    "total_stages": <int>
  },
  "features": [
    {
      "type": "Feature",
      "properties": {
        "stage": <int>,
        "name": <str>,
        "description": <str>,
        "distance_km": <float>,
        "elevation_gain": <float>,
        "difficulty": <str>
      },
      "geometry": { ... }
    }
  ]
}

- Each GPX <trk> => one Feature.
- Coordinates: [lon, lat, ele?] (ele included if present).
- Feature distance_km is computed from points using haversine.
- Feature elevation_gain sums positive ascent (meters).
- Feature difficulty: heuristic (default) or fixed via CLI.
- Collection distance_km is sum of stage distances.
- Collection difficulty: max difficulty among stages (easy < moderate < hard), or fixed via CLI.
- total_stages: number of tracks found (or you can override via --total-stages).

Usage examples:
  python gpx_to_geojson.py in.gpx out.geojson --id mountain_loop --name "My Route" --description "..." --route-number 14
  python gpx_to_geojson.py in.gpx out.geojson --id r1 --name "Route" --description "..." --difficulty-mode fixed --difficulty moderate
"""

from __future__ import annotations

import argparse
import json
import math
import sys
import xml.etree.ElementTree as ET
from typing import Any, Dict, List, Optional, Tuple

GPX_NS = {"gpx": "http://www.topografix.com/GPX/1/1"}
EARTH_RADIUS_M = 6371000.0

DIFF_ORDER = {"easy": 0, "moderate": 1, "hard": 2}


def _get_text(el: Optional[ET.Element]) -> Optional[str]:
    if el is None:
        return None
    txt = (el.text or "").strip()
    return txt or None


def _float_attr(el: ET.Element, key: str) -> float:
    v = el.get(key)
    if v is None:
        raise ValueError(f"Missing attribute '{key}' on element <{el.tag}>")
    return float(v)


def haversine_m(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Great-circle distance in meters."""
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlmb = math.radians(lon2 - lon1)

    a = math.sin(dphi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlmb / 2.0) ** 2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return EARTH_RADIUS_M * c


def parse_gpx_tracks(gpx_path: str) -> List[Dict[str, Any]]:
    """
    Returns list of tracks:
    [
      {
        "name": str|None,
        "desc": str|None,
        "segments": [
          [ {"lat":..,"lon":..,"ele": float|None}, ... ],
          ...
        ]
      },
      ...
    ]
    """
    tree = ET.parse(gpx_path)
    root = tree.getroot()

    tracks: List[Dict[str, Any]] = []
    for trk in root.findall("gpx:trk", GPX_NS):
        trk_name = _get_text(trk.find("gpx:name", GPX_NS))
        trk_desc = _get_text(trk.find("gpx:desc", GPX_NS))

        segments: List[List[Dict[str, Any]]] = []
        for trkseg in trk.findall("gpx:trkseg", GPX_NS):
            pts: List[Dict[str, Any]] = []
            for trkpt in trkseg.findall("gpx:trkpt", GPX_NS):
                lat = _float_attr(trkpt, "lat")
                lon = _float_attr(trkpt, "lon")
                ele_el = trkpt.find("gpx:ele", GPX_NS)
                ele_txt = _get_text(ele_el)

                ele: Optional[float] = None
                if ele_txt is not None:
                    try:
                        ele = float(ele_txt)
                    except ValueError:
                        ele = None

                pts.append({"lat": lat, "lon": lon, "ele": ele})

            if len(pts) >= 2:
                segments.append(pts)

        if segments:
            tracks.append({"name": trk_name, "desc": trk_desc, "segments": segments})

    return tracks


def _pt_to_coord(p: Dict[str, Any]) -> List[float]:
    # GeoJSON expects [lon, lat] (and optional 3rd z)
    if p.get("ele") is None:
        return [p["lon"], p["lat"]]
    return [p["lon"], p["lat"], float(p["ele"])]


def segments_to_geometry(segments: List[List[Dict[str, Any]]]) -> Tuple[Dict[str, Any], List[Dict[str, Any]]]:
    """
    Returns (geometry_dict, flat_points_in_traversal_order).
    """
    flat: List[Dict[str, Any]] = []

    if len(segments) == 1:
        seg = segments[0]
        flat = seg[:]
        return {"type": "LineString", "coordinates": [_pt_to_coord(p) for p in seg]}, flat

    coords: List[List[List[float]]] = []
    for seg in segments:
        coords.append([_pt_to_coord(p) for p in seg])
        flat.extend(seg)

    return {"type": "MultiLineString", "coordinates": coords}, flat


def compute_distance_km(points: List[Dict[str, Any]]) -> float:
    if len(points) < 2:
        return 0.0
    dist_m = 0.0
    prev = points[0]
    for p in points[1:]:
        dist_m += haversine_m(prev["lat"], prev["lon"], p["lat"], p["lon"])
        prev = p
    return dist_m / 1000.0


def compute_elevation_gain(points: List[Dict[str, Any]]) -> float:
    """
    Sum of positive elevation deltas in meters.
    Skips pairs where elevation is missing.
    """
    gain = 0.0
    if len(points) < 2:
        return 0.0

    prev_ele = points[0].get("ele")
    for p in points[1:]:
        ele = p.get("ele")
        if prev_ele is not None and ele is not None:
            d = float(ele) - float(prev_ele)
            if d > 0:
                gain += d
        prev_ele = ele
    return gain


def classify_difficulty(distance_km: float, elevation_gain_m: float) -> str:
    """
    Simple heuristic (tweak as you like):
      easy:     <= 25 km and <= 200 m gain
      moderate: <= 60 km and <= 800 m gain
      hard:     otherwise
    """
    if distance_km <= 25.0 and elevation_gain_m <= 200.0:
        return "easy"
    if distance_km <= 60.0 and elevation_gain_m <= 800.0:
        return "moderate"
    return "hard"


def hardest_difficulty(difficulties: List[str]) -> str:
    if not difficulties:
        return "moderate"
    best = "easy"
    best_score = -1
    for d in difficulties:
        score = DIFF_ORDER.get(d, 1)
        if score > best_score:
            best_score = score
            best = d if d in DIFF_ORDER else "moderate"
    return best


def build_geojson(
    tracks: List[Dict[str, Any]],
    collection_props: Dict[str, Any],
    difficulty_mode: str,
    fixed_difficulty: Optional[str],
) -> Dict[str, Any]:
    features: List[Dict[str, Any]] = []
    stage_difficulties: List[str] = []
    total_distance_km = 0.0

    for stage_idx, trk in enumerate(tracks, start=1):
        geometry, flat_points = segments_to_geometry(trk["segments"])

        dist_km = compute_distance_km(flat_points)
        gain_m = compute_elevation_gain(flat_points)

        # Round like typical route data
        dist_km_r = round(dist_km, 3)
        gain_m_r = round(gain_m, 1)

        if difficulty_mode == "fixed":
            stage_diff = fixed_difficulty or "moderate"
        else:
            stage_diff = classify_difficulty(dist_km_r, gain_m_r)

        stage_difficulties.append(stage_diff)
        total_distance_km += dist_km_r

        name = trk.get("name") or f"Stage {stage_idx}"
        desc = trk.get("desc") or ""

        features.append(
            {
                "type": "Feature",
                "properties": {
                    "stage": stage_idx,
                    "name": name,
                    "description": desc,
                    "distance_km": float(dist_km_r),
                    "elevation_gain": float(gain_m_r),
                    "difficulty": stage_diff,
                },
                "geometry": geometry,
            }
        )

    # Fill/override collection properties to match your schema
    out_props: Dict[str, Any] = {
        "id": collection_props.get("id", "route"),
        "name": collection_props.get("name", "Route"),
        "description": collection_props.get("description", ""),
        "distance_km": float(round(total_distance_km, 3)),
        "difficulty": (
            (fixed_difficulty or "moderate") if difficulty_mode == "fixed" else hardest_difficulty(stage_difficulties)
        ),
        "route_number": int(collection_props.get("route_number", 0)),
        "total_stages": int(collection_props.get("total_stages", len(features))),
    }

    return {
        "type": "FeatureCollection",
        "properties": out_props,
        "features": features,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Convert GPX tracks to GeoJSON with collection + stage properties.")
    ap.add_argument("input_gpx", help="Input .gpx file")
    ap.add_argument("output_geojson", nargs="?", help="Output .geojson file (omit = stdout)")

    # FeatureCollection properties (required by your schema; defaults provided if omitted)
    ap.add_argument("--id", dest="fc_id", default="route", help='FeatureCollection properties.id (e.g. "mountain_loop")')
    ap.add_argument("--name", dest="fc_name", default="Route", help="FeatureCollection properties.name")
    ap.add_argument("--description", dest="fc_desc", default="", help="FeatureCollection properties.description")
    ap.add_argument("--route-number", type=int, default=0, help="FeatureCollection properties.route_number")
    ap.add_argument(
        "--total-stages",
        type=int,
        default=None,
        help="FeatureCollection properties.total_stages (default: number of tracks in GPX)",
    )

    # Difficulty controls
    ap.add_argument(
        "--difficulty-mode",
        choices=["heuristic", "fixed"],
        default="heuristic",
        help="How to set difficulty (both stage + collection): heuristic or fixed",
    )
    ap.add_argument(
        "--difficulty",
        default=None,
        help='When --difficulty-mode fixed, use this value (e.g. "easy", "moderate", "hard")',
    )

    args = ap.parse_args()

    tracks = parse_gpx_tracks(args.input_gpx)
    if not tracks:
        print("No usable tracks found in GPX (or segments have <2 points).", file=sys.stderr)
        return 2

    collection_props = {
        "id": args.fc_id,
        "name": args.fc_name,
        "description": args.fc_desc,
        "route_number": args.route_number,
        "total_stages": args.total_stages if args.total_stages is not None else len(tracks),
    }

    geojson = build_geojson(
        tracks=tracks,
        collection_props=collection_props,
        difficulty_mode=args.difficulty_mode,
        fixed_difficulty=args.difficulty,
    )

    out_text = json.dumps(geojson, ensure_ascii=False, indent=2)

    if args.output_geojson:
        with open(args.output_geojson, "w", encoding="utf-8") as f:
            f.write(out_text + "\n")
    else:
        print(out_text)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
