Extract europe polygons:
install!
python3 -m venv .venv
source .venv/bin/activate
pip install geopandas pyogrio shapely
python extract_europe.py