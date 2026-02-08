#!/usr/bin/env python3
import sys
import geopandas as gpd

INPUT = "geojsons/ne_50m_admin_0_countries.geojson"
OUT_COUNTRIES = "../assets/europe_polygons/europe_countries.geojson"
OUT_DISSOLVED = "europe_dissolved.geojson"

def find_col(gdf, names):
    for n in names:
        if n in gdf.columns:
            return n
    return None

def main():
    gdf = gpd.read_file(INPUT)

    # Natural Earth обычно в EPSG:4326, но на всякий случай приведём
    if gdf.crs is None:
        # если CRS отсутствует, чаще всего это 4326
        gdf = gdf.set_crs(4326)
    elif gdf.crs.to_epsg() != 4326:
        gdf = gdf.to_crs(4326)

    continent_col = find_col(gdf, ["CONTINENT", "continent", "Continent"])
    if continent_col is None:
        print("Не нашёл колонку континента. Колонки:", list(gdf.columns), file=sys.stderr)
        sys.exit(2)

    europe = gdf[gdf[continent_col].astype(str).str.lower() == "europe"].copy()
    if europe.empty:
        print(f"Фильтр по {continent_col}='Europe' дал 0 строк. Проверь значения в колонке.", file=sys.stderr)
        sys.exit(3)

    # 1) Страны Европы отдельными фичами
    europe.to_file(OUT_COUNTRIES, driver="GeoJSON")

    # 2) Одна общая маска Европы (склеить все страны)
    europe_mask = europe.dissolve().reset_index(drop=True)
    europe_mask.to_file(OUT_DISSOLVED, driver="GeoJSON")

    print(f"OK: {OUT_COUNTRIES} (features: {len(europe)})")
    print(f"OK: {OUT_DISSOLVED} (features: {len(europe_mask)})")

if __name__ == "__main__":
    main()
