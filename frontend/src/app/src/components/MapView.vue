<template>
  <div id="mapContainer" class="basemap"></div>
</template>

<style lang="scss" scoped>
.basemap {
  height: 100vh;
  min-height: 440px;
  width: 100%;
}
</style>

<script>
import mapboxgl from "mapbox-gl";

// Full light base map — light/grey theme that still shows roads, place names,
// water and labels.
const BASE_STYLE = "mapbox://styles/mapbox/light-v11";

export default {
  name: "BaseMap",
  data() {
    return {
      accessToken:
        "pk.eyJ1Ijoic3J2YmgiLCJhIjoiY21yYm1tNzBuMHg0aDMwc2VjY3B3bGZtdSJ9.DzMraI1zpB4c9q0FWTGGpQ",
      mapView: null,
    };
  },
  methods: {
    // draw/update the selection rectangle from a [W,S,E,N] bbox
    drawRectBbox(b) {
      if (!this.mapView) return;
      const W = Number(b[0]), S = Number(b[1]), E = Number(b[2]), N = Number(b[3]);
      const poly = {
        type: "Feature",
        properties: {},
        geometry: {
          type: "Polygon",
          coordinates: [[[W, S], [E, S], [E, N], [W, N], [W, S]]],
        },
      };
      const paint = () => {
        const src = this.mapView.getSource("sel-box");
        if (src) {
          src.setData(poly);
          return;
        }
        this.mapView.addSource("sel-box", { type: "geojson", data: poly });
        this.mapView.addLayer({
          id: "sel-box-fill",
          type: "fill",
          source: "sel-box",
          paint: { "fill-color": "#47889d", "fill-opacity": 0.12 },
        });
        this.mapView.addLayer({
          id: "sel-box-line",
          type: "line",
          source: "sel-box",
          paint: {
            "line-color": "#356b7d",
            "line-width": 2.2,
            "line-dasharray": [2, 1],
          },
        });
      };
      if (this.mapView.isStyleLoaded()) paint();
      else this.mapView.once("styledata", paint);
    },
    removeRect() {
      if (!this.mapView) return;
      ["sel-box-fill", "sel-box-line"].forEach((id) => {
        if (this.mapView.getLayer(id)) this.mapView.removeLayer(id);
      });
      if (this.mapView.getSource("sel-box")) this.mapView.removeSource("sel-box");
    },
    // used by place search + coordinate entry: fit + show the box
    applySource(geometry, extent) {
      if (!this.mapView || !extent) return;
      const b = [Number(extent[0]), Number(extent[1]), Number(extent[2]), Number(extent[3])];
      this.mapView.fitBounds([[b[0], b[1]], [b[2], b[3]]], { padding: 60, duration: 600 });
      this.drawRectBbox(b);
    },
    // Drag-to-draw a rectangle: press and drag on the map (no clicking corners).
    startDraw() {
      const map = this.mapView;
      if (!map || this._drawing) return;
      this._drawing = true;
      const canvas = map.getCanvas();
      canvas.style.cursor = "crosshair";
      map.dragPan.disable();

      let start = null;
      const box = (a, z) => {
        const W = Math.min(a.lng, z.lng), E = Math.max(a.lng, z.lng);
        const S = Math.min(a.lat, z.lat), N = Math.max(a.lat, z.lat);
        return [W, S, E, N];
      };
      const onMove = (e) => {
        if (start) this.drawRectBbox(box(start, e.lngLat));
      };
      const finish = (e) => {
        map.off("mousemove", onMove);
        map.off("touchmove", onMove);
        if (start && e && e.lngLat) {
          const b = box(start, e.lngLat);
          if (Math.abs(b[2] - b[0]) > 1e-6 && Math.abs(b[3] - b[1]) > 1e-6) {
            this.drawRectBbox(b);
            this.$emit("draw-bbox", b.join(","));
          }
        }
        canvas.style.cursor = "";
        map.dragPan.enable();
        this._drawing = false;
      };
      const onDown = (e) => {
        map.off("mousedown", onDown);
        map.off("touchstart", onDown);
        start = e.lngLat;
        if (e.preventDefault) e.preventDefault();
        map.on("mousemove", onMove);
        map.on("touchmove", onMove);
        map.once("mouseup", finish);
        map.once("touchend", finish);
      };
      map.once("mousedown", onDown);
      map.once("touchstart", onDown);
    },
    clearDraw() {
      this.removeRect();
      this.$emit("draw-bbox", null);
    },
  },

  props: {
    theme: Boolean,
  },

  watch: {
    theme: {
      handler() {
        if (this.mapView) this.mapView.setStyle(BASE_STYLE);
      },
      immediate: false,
    },
  },

  mounted() {
    mapboxgl.accessToken = this.accessToken;

    this.mapView = new mapboxgl.Map({
      container: "mapContainer",
      style: BASE_STYLE,
      center: [84.1, 28.3],
      zoom: 4,
      attributionControl: false,
    });

    this.mapView.addControl(new mapboxgl.AttributionControl(), "bottom-right");
    this.mapView.addControl(
      new mapboxgl.NavigationControl({ showCompass: false }),
      "top-right"
    );

    // re-measure once the surrounding layout has settled (full-height fix)
    this.mapView.on("load", () => {
      setTimeout(() => this.mapView && this.mapView.resize(), 120);
    });
    window.addEventListener("resize", this._onWinResize = () => {
      if (this.mapView) this.mapView.resize();
    });
  },

  beforeDestroy() {
    if (this._onWinResize) window.removeEventListener("resize", this._onWinResize);
  },
};
</script>
