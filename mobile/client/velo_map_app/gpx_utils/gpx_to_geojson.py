#!/usr/bin/env python3
"""
gpx_to_geojson.py

Convert GPX to GeoJSON FeatureCollection.

What you asked for:
- Each GPX <trk> becomes one GeoJSON Feature.
- Each feature has properties exactly like:
  {
    "stage": <int>,
    "name": <trk name or fallback>,
    "description": <trk desc or empty string>,
    "distance_km": <computed from points>,
    "elevation_gain": <computed positive ascent from ele>,
    "difficulty": <heuristic or forced default>
  }

Notes:
- distance_km uses haversine distance over all points in the track (across segments).
- elevation_gain sums only positive elevation deltas (meters). If no elevation -> 0.
- difficulty is a simple heuristic based on distance/elevation, or you can override via CLI.

Usage:
  python gpx_to_geojson.py in.gpx out.geojson
  python gpx_to_geojson.py in.gpx out.geojson --difficulty-mode fixed --difficulty fixed:easy
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


def segments_to_geometry_coords(segments: List[List[Dict[str, Any]]]) -> Tuple[Dict[str, Any], List[Dict[str, Any]]]:
    """
    Returns (geometry, flattened_point_list_in_traversal_order).
    GeoJSON coordinates are [lon, lat, ele?].
    """
    flat: List[Dict[str, Any]] = []

    def pt_to_coord(p: Dict[str, Any]) -> List[float]:
        if p.get("ele") is None:
            return [p["lon"], p["lat"]]
        return [p["lon"], p["lat"], float(p["ele"])]

    if len(segments) == 1:
        seg = segments[0]
        flat = seg[:]
        return {"type": "LineString", "coordinates": [pt_to_coord(p) for p in seg]}, flat

    coords: List[List[List[float]]] = []
    for seg in segments:
        coords.append([pt_to_coord(p) for p in seg])
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
    If elevation missing, skips those pairs.
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
    Simple heuristic:
    - easy: <= 25km and <= 200m gain
    - moderate: <= 60km and <= 800m gain
    - hard: otherwise
    """
    if distance_km <= 25.0 and elevation_gain_m <= 200.0:
        return "easy"
    if distance_km <= 60.0 and elevation_gain_m <= 800.0:
        return "moderate"
    return "hard"


def tracks_to_geojson(
    tracks: List[Dict[str, Any]],
    fixed_difficulty: Optional[str] = None,
    difficulty_mode: str = "heuristic",
) -> Dict[str, Any]:
    features: List[Dict[str, Any]] = []

    for idx, trk in enumerate(tracks, start=1):
        geometry, flat_points = segments_to_geometry_coords(trk["segments"])

        distance_km = round(compute_distance_km(flat_points), 3)
        elevation_gain = round(compute_elevation_gain(flat_points), 1)

        if difficulty_mode == "fixed":
            difficulty = fixed_difficulty or "moderate"
        else:
            difficulty = classify_difficulty(distance_km, elevation_gain)

        name = trk.get("name") or f"Stage {idx}"
        desc = trk.get("desc") or ""

        feature = {
            "type": "Feature",
            "properties": {
                "stage": idx,
                "name": name,
                "description": desc,
                "distance_km": float(distance_km),
                "elevation_gain": float(elevation_gain),
                "difficulty": difficulty,
            },
            "geometry": geometry,
        }
        features.append(feature)

    return {"type": "FeatureCollection", "features": features}


def main() -> int:
    ap = argparse.ArgumentParser(description="Convert GPX tracks to GeoJSON with stage properties.")
    ap.add_argument("input_gpx", help="Input .gpx file")
    ap.add_argument("output_geojson", nargs="?", help="Output .geojson file (omit = stdout)")

    ap.add_argument(
        "--difficulty-mode",
        choices=["heuristic", "fixed"],
        default="heuristic",
        help="How to set feature.properties.difficulty",
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

    geojson = tracks_to_geojson(
        tracks,
        fixed_difficulty=args.difficulty,
        difficulty_mode=args.difficulty_mode,
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
