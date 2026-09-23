#!/usr/bin/env python3
# compute-changes.py BEFORE.osm.pbf AFTER.osm.pbf OUT_CHANGES.geojson OUT_STATS.json
#
# Accurate, complete change detection between two OSM snapshots, by OSM id.
# Emits every added / modified / removed feature (with geometry) for the
# timelapse, plus exact stats (counts per category + road length changes).
import sys, json, math
import osmium

POLY_CATS = {"buildings", "water", "land"}
def haversine(a, b):
    R = 6371000.0
    dlat = math.radians(b[1] - a[1]); dlon = math.radians(b[0] - a[0])
    la1 = math.radians(a[1]); la2 = math.radians(b[1])
    h = math.sin(dlat/2)**2 + math.cos(la1)*math.cos(la2)*math.sin(dlon/2)**2
    return 2 * R * math.asin(min(1.0, math.sqrt(h)))

def categorize(t):
    if "building" in t: return "buildings"
    if "highway" in t: return "roads"
    if "waterway" in t: return "water"
    if t.get("natural") == "water" or "water" in t: return "water"
    if any(k in t for k in ("amenity","shop","tourism","office","leisure","craft","healthcare")): return "poi"
    if "place" in t: return "places"
    if t.get("aeroway"): return "aero"
    if any(k in t for k in ("landuse","natural","boundary")): return "land"
    return None

def name_of(t):
    return t.get("name") or t.get("name:en") or t.get("name:latin") or ""

class Collector(osmium.SimpleHandler):
    def __init__(self):
        super().__init__()
        self.pt = osmium.geom.GeoJSONFactory()
        self.items = {}   # "n123"/"w456" -> record

    def _rec(self, key, tags, cat, geom, kind, length):
        t = dict(tags)
        self.items[key] = {
            "cat": cat, "name": name_of(t), "kind": kind, "geom": geom,
            "len": length,
            "sig": tuple(sorted(t.items())),
            "gh": geom_hash(geom),
        }

    def node(self, n):
        if not n.tags: return
        t = {k: v for k, v in n.tags}
        cat = categorize(t)
        if cat is None: return
        try: geom = json.loads(self.pt.create_point(n))
        except Exception: return
        self._rec("n%d" % n.id, n.tags, cat, geom, "point", 0.0)

    def way(self, w):
        if not w.tags: return
        t = {k: v for k, v in w.tags}
        cat = categorize(t)
        if cat is None: return
        coords = []
        for nd in w.nodes:
            if nd.location.valid():
                coords.append([nd.lon, nd.lat])
        if len(coords) < 2: return
        closed = coords[0] == coords[-1] and len(coords) >= 4
        kind = "poly" if (cat in POLY_CATS and closed) else "line"
        geom = {"type": "Polygon", "coordinates": [coords]} if kind == "poly" else {"type": "LineString", "coordinates": coords}
        length = 0.0
        if cat == "roads":
            for i in range(1, len(coords)):
                length += haversine(coords[i-1], coords[i])
        self._rec("w%d" % w.id, w.tags, cat, geom, kind, length)

def geom_hash(geom):
    if not geom: return 0
    def rnd(c): return (round(c[0], 6), round(c[1], 6))
    if geom["type"] == "Point":
        return hash(rnd(geom["coordinates"]))
    if geom["type"] == "LineString":
        return hash(tuple(rnd(c) for c in geom["coordinates"]))
    return hash(tuple(rnd(c) for c in geom["coordinates"][0]))

def collect(path):
    c = Collector()
    c.apply_file(path, locations=True, idx="flex_mem")
    return c.items

def main():
    before_p, after_p, out_geo, out_stats = sys.argv[1:5]
    B = collect(before_p)
    A = collect(after_p)

    cats = ["buildings", "roads", "poi", "places", "water", "land", "aero"]
    stats = {c: {"added": 0, "modified": 0, "removed": 0} for c in cats}
    totals = {"added": 0, "modified": 0, "removed": 0}
    road_len_before = sum(v["len"] for v in B.values() if v["cat"] == "roads")
    road_len_after = sum(v["len"] for v in A.values() if v["cat"] == "roads")
    road_added_len = road_removed_len = 0.0
    feats = []

    def add_feat(rec, change):
        feats.append({
            "type": "Feature",
            "geometry": rec["geom"],
            "properties": {"change": change, "cat": rec["cat"], "name": rec["name"], "kind": rec["kind"]},
        })

    for k, a in A.items():
        b = B.get(k)
        cat = a["cat"] if a["cat"] in stats else None
        if b is None:
            if cat: stats[cat]["added"] += 1
            totals["added"] += 1
            if a["cat"] == "roads": road_added_len += a["len"]
            add_feat(a, "add")
        elif a["sig"] != b["sig"] or a["gh"] != b["gh"]:
            if cat: stats[cat]["modified"] += 1
            totals["modified"] += 1
            add_feat(a, "mod")
    for k, b in B.items():
        if k not in A:
            cat = b["cat"] if b["cat"] in stats else None
            if cat: stats[cat]["removed"] += 1
            totals["removed"] += 1
            if b["cat"] == "roads": road_removed_len += b["len"]
            add_feat(b, "rem")

    stats_out = {
        "totals": totals,
        "byCategory": stats,
        "roads": {
            "lengthBeforeKm": round(road_len_before / 1000.0, 2),
            "lengthAfterKm": round(road_len_after / 1000.0, 2),
            "netKm": round((road_len_after - road_len_before) / 1000.0, 2),
            "addedKm": round(road_added_len / 1000.0, 2),
            "removedKm": round(road_removed_len / 1000.0, 2),
        },
        "featureCount": len(feats),
    }
    with open(out_geo, "w") as f:
        json.dump({"type": "FeatureCollection", "features": feats}, f)
    with open(out_stats, "w") as f:
        json.dump(stats_out, f, indent=0)
    print("[compute-changes] %d changes (%da/%dm/%dr), roads %.2f->%.2f km"
          % (len(feats), totals["added"], totals["modified"], totals["removed"],
             stats_out["roads"]["lengthBeforeKm"], stats_out["roads"]["lengthAfterKm"]))

if __name__ == "__main__":
    main()
