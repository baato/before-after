<template>
  <div id="mapContainer" class="basemap"></div>
</template>

<style lang="scss" scoped>
.basemap {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 100%;
  z-index: 10;
}
</style>


<script>
import mapboxgl from "mapbox-gl";
import MapboxDraw from "@mapbox/mapbox-gl-draw";
import { bboxPolygon } from "@turf/turf";

export default {
  name: "BaseMap",
  data() {
    return {
      accessToken:
        "pk.eyJ1Ijoic3J2YmgiLCJhIjoiY2l5bWtwb2ZsMDAwbzJ2cXo4cm0zczU2diJ9.YBNdguBp6N0s5bEDi25uCA",
      mapView: null,
      drawView: null,
    };
  },
  methods: {
    applySource(geometry, extent) {
      this.mapView.flyTo({
        center: geometry.coordinates,
        zoom: 10,
        offset: [0, 200],
      });

      if (this.mapView.getSource("bbox")) {
        this.mapView.removeLayer("bbox").removeSource("bbox");
      }

      // this.mapView.addSource("bbox", {
      //   type: "geojson",
      //   data: bboxPolygon(extent),
      // });

      // // Add a new layer to visualize the polygon.
      // this.mapView.addLayer({
      //   id: "bbox",
      //   type: "line",
      //   source: "bbox", // reference the data source
      //   layout: {},
      //   paint: {
      //     "line-color": "#000000", // blue color fill
      //     "line-width": 2.5,
      //     "line-dasharray": [2, 1],
      //   },
      // });
      this.drawView.deleteAll().getAll();
      this.drawView.add(bboxPolygon(extent));
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
    });

    this.drawView = new MapboxDraw({
      displayControlsDefault: false,
      controls: {
        polygon: true,
        trash: true,
      },
    });

    this.mapView.on("load", () => {
      this.mapView.addControl(this.drawView, "top-left");
    });
  },
};
</script>