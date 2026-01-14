#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

GPX_NS = {"gpx": "http://www.topografix.com/GPX/1/1"}
EARTH_RADIUS_M = 6371000.0

DIFF_ORDER = {"easy": 0, "moderate": 1, "hard": 2}

CITY_DASH_RE = re.compile(r"\s*(?:-|–|—|−)\s*")  # -, en dash, em dash, minus


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


def slugify(s: str) -> str:
    s = s.strip().lower()
    s = re.sub(r"[^a-z0-9]+", "_", s)
    s = re.sub(r"_+", "_", s).strip("_")
    return s or "route"


def infer_props_from_filename(gpx_file: Path) -> Dict[str, Any]:
    """
    id   = имя файла без расширения (slug)
    name = человекочитаемое имя из файла (underscores -> spaces)
    route_number = если в имени есть число, берём первое
    """
    stem = gpx_file.stem
    rid = slugify(stem)

    pretty = stem.replace("_", " ").replace("-", " ").strip()
    name = pretty[:1].upper() + pretty[1:] if pretty else "Route"

    m = re.search(r"(\d+)", stem)
    route_number = int(m.group(1)) if m else 0

    return {"id": rid, "name": name, "description": "", "route_number": route_number}


def extract_cities_from_name(name: str) -> List[str]:
    """
    Пример:
      '001: Saint-Brevin-les-Pins – Le Pellerin (DEVELOPED_WITH_SIGNS)'
    -> ['Saint-Brevin-les-Pins', 'Le Pellerin']

    Логика:
      1) срезаем префикс 'число:'
      2) срезаем суффикс '(...)'
      3) делим по тире/эн-даш/эм-даш
    """
    if not name:
        return []

    s = name.strip()

    # Убираем префикс "001:" если есть
    m = re.match(r"^\s*\d+\s*:\s*(.*)$", s)
    if m:
        s = m.group(1).strip()

    # Убираем суффикс "(...)" если есть
    s = re.sub(r"\s*\([^)]*\)\s*$", "", s).strip()

    parts = [p.strip() for p in CITY_DASH_RE.split(s) if p.strip()]
    return parts


def build_geojson(
    tracks: List[Dict[str, Any]],
    collection_props: Dict[str, Any],
    difficulty_mode: str,
    fixed_difficulty: Optional[str],
) -> Dict[str, Any]:
    features: List[Dict[str, Any]] = []
    stage_difficulties: List[str] = []
    total_distance_km = 0.0

    # Collection-level city aggregation (unique, stable order)
    collection_cities: List[str] = []
    seen_cities: set[str] = set()

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

        # NEW: cities per feature, and aggregate into collection
        cities = extract_cities_from_name(name)
        for c in cities:
            if c not in seen_cities:
                seen_cities.add(c)
                collection_cities.append(c)

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
                    "cities": cities,  # NEW
                },
                "geometry": geometry,
            }
        )

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
        "cities": collection_cities,  # NEW
    }

    return {"type": "FeatureCollection", "properties": out_props, "features": features}


def convert_one(
    gpx_path: Path,
    out_path: Path,
    difficulty_mode: str,
    fixed_difficulty: Optional[str],
) -> None:
    tracks = parse_gpx_tracks(str(gpx_path))
    if not tracks:
        raise RuntimeError("No usable tracks found in GPX (or segments have <2 points).")

    props = infer_props_from_filename(gpx_path)
    props["total_stages"] = len(tracks)

    geojson = build_geojson(
        tracks=tracks,
        collection_props=props,
        difficulty_mode=difficulty_mode,
        fixed_difficulty=fixed_difficulty,
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_text = json.dumps(geojson, ensure_ascii=False, indent=2)
    out_path.write_text(out_text + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description="Batch convert GPX files to GeoJSON FeatureCollection.")
    ap.add_argument("--in-dir", default="assets/routes/gpx", help="Input directory with .gpx files")
    ap.add_argument("--out-dir", default="assets/routes/geojson", help="Output directory for .geojson files")
    ap.add_argument(
        "--difficulty-mode",
        choices=["heuristic", "fixed"],
        default="heuristic",
        help="How to set difficulty (both stage + collection)",
    )
    ap.add_argument("--difficulty", default=None, help='When fixed mode: "easy" | "moderate" | "hard"')
    ap.add_argument("--overwrite", action="store_true", help="Overwrite existing .geojson files")

    args = ap.parse_args()

    in_dir = Path(args.in_dir)
    out_dir = Path(args.out_dir)

    if not in_dir.exists():
        print(f"Input dir not found: {in_dir}", file=sys.stderr)
        return 2

    gpx_files = sorted(in_dir.glob("*.gpx"))
    if not gpx_files:
        print(f"No .gpx files found in: {in_dir}", file=sys.stderr)
        return 2

    ok = 0
    fail = 0

    for gpx in gpx_files:
        out = out_dir / (gpx.stem + ".geojson")

        if out.exists() and not args.overwrite:
            print(f"SKIP (exists): {out}")
            continue

        try:
            convert_one(gpx, out, args.difficulty_mode, args.difficulty)
            print(f"OK: {gpx.name} -> {out}")
            ok += 1
        except Exception as e:
            print(f"FAIL: {gpx.name}: {e}", file=sys.stderr)
            fail += 1

    print(f"\nDone. OK={ok}, FAIL={fail}")
    return 0 if fail == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
