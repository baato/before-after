<template>
  <div id="mapContainer" class="basemap"></div>
</template>

<style lang="scss" scoped>
.basemap {
  height: 81vh;
  width: 100%;
}
</style>

<script>
import mapboxgl from "mapbox-gl";
import { bboxPolygon } from "@turf/turf";

export default {
  name: "BaseMap",
  data() {
    return {
      accessToken:
        "pk.eyJ1Ijoic3J2YmgiLCJhIjoiY21yYm1tNzBuMHg0aDMwc2VjY3B3bGZtdSJ9.DzMraI1zpB4c9q0FWTGGpQ",
      mapView: null,
      drawing: false,
      drawStart: null,
      bboxHandlers: null,
    };
  },
  methods: {
    ensureBboxLayers(data) {
      if (this.mapView.getSource("bbox")) {
        this.mapView.getSource("bbox").setData(data);
        return;
      }
      this.mapView.addSource("bbox", { type: "geojson", data });
      this.mapView.addLayer({
        id: "bbox-fill",
        type: "fill",
        source: "bbox",
        paint: {
          "fill-color": "#47889d",
          "fill-opacity": 0.12,
        },
      });
      this.mapView.addLayer({
        id: "bbox",
        type: "line",
        source: "bbox",
        layout: { "line-join": "round" },
        paint: {
          "line-color": "#47889d",
          "line-width": 2.5,
          "line-dasharray": [2, 1],
        },
      });
    },

    applySource(geometry, extent) {
      this.mapView.fitBounds(
        [
          [extent[0], extent[1]], // south-western corner
          [extent[2], extent[3]], // north-eastern corner
        ],
        { padding: 120 }
      );
      this.ensureBboxLayers(bboxPolygon(extent));
    },

    clearBbox() {
      if (!this.mapView) return;
      ["bbox", "bbox-fill"].forEach((id) => {
        if (this.mapView.getLayer(id)) this.mapView.removeLayer(id);
      });
      if (this.mapView.getSource("bbox")) this.mapView.removeSource("bbox");
    },

    // ---- drag-to-draw a bounding box on the map ----
    enableBboxDraw() {
      if (!this.mapView) return;
      this.disableBboxDraw();
      this.drawing = true;
      const map = this.mapView;
      map.getCanvas().style.cursor = "crosshair";
      map.dragPan.disable();

      const onDown = (e) => {
        this.drawStart = e.lngLat;
      };
      const onMove = (e) => {
        if (!this.drawStart) return;
        this.ensureBboxLayers(this.rectFrom(this.drawStart, e.lngLat));
      };
      const onUp = (e) => {
        if (!this.drawStart) return;
        const b = this.boundsOf(this.drawStart, e.lngLat);
        this.drawStart = null;
        this.disableBboxDraw();
        // ignore accidental clicks with no area
        if (b.east - b.west < 1e-6 || b.north - b.south < 1e-6) return;
        this.ensureBboxLayers(bboxPolygon([b.west, b.north, b.east, b.south]));
        this.$emit("bbox-drawn", b);
      };

      this.bboxHandlers = { onDown, onMove, onUp };
      map.on("mousedown", onDown);
      map.on("mousemove", onMove);
      map.on("mouseup", onUp);
    },

    disableBboxDraw() {
      if (!this.mapView) return;
      this.drawing = false;
      const map = this.mapView;
      map.getCanvas().style.cursor = "";
      map.dragPan.enable();
      if (this.bboxHandlers) {
        map.off("mousedown", this.bboxHandlers.onDown);
        map.off("mousemove", this.bboxHandlers.onMove);
        map.off("mouseup", this.bboxHandlers.onUp);
        this.bboxHandlers = null;
      }
    },

    boundsOf(a, b) {
      return {
        west: Math.min(a.lng, b.lng),
        east: Math.max(a.lng, b.lng),
        south: Math.min(a.lat, b.lat),
        north: Math.max(a.lat, b.lat),
      };
    },
    rectFrom(a, b) {
      const bo = this.boundsOf(a, b);
      return bboxPolygon([bo.west, bo.north, bo.east, bo.south]);
    },
  },

  props: {
    theme: Boolean,
  },

  watch: {
    theme: {
      handler(newVal) {
        if (this.mapView) {
          this.mapView.setStyle(
            newVal == false
              ? "mapbox://styles/mapbox/basic-v8"
              : "mapbox://styles/mapbox/dark-v9"
          );
        }
      },
      immediate: true,
    },
  },

  mounted() {
    mapboxgl.accessToken = this.accessToken;

    this.mapView = new mapboxgl.Map({
      container: "mapContainer",
      style:
        this.theme == false
          ? "mapbox://styles/mapbox/basic-v8"
          : "mapbox://styles/mapbox/dark-v9",
      center: [103.811279, 1.345399],
      zoom: 0,
      attributionControl: false,
    });

    const attribution = new mapboxgl.AttributionControl();
    this.mapView.addControl(attribution, "bottom-right");
  },
};
</script>
