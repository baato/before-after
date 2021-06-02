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
import { bboxPolygon } from "@turf/turf";

export default {
  name: "BaseMap",
  data() {
    return {
      accessToken:
        "pk.eyJ1Ijoic3J2YmgiLCJhIjoiY2l5bWtwb2ZsMDAwbzJ2cXo4cm0zczU2diJ9.YBNdguBp6N0s5bEDi25uCA",
      mapView: null,
    };
  },
  methods: {
    applySource(geometry, extent) {
      console.log(geometry);
      this.mapView.flyTo({
        center: geometry.coordinates,
        zoom: 10,
        offset: [0, 200],
      });

      if (this.mapView.getSource("bbox")) {
        this.mapView.removeLayer("bbox").removeSource("bbox");
      }

      this.mapView.addSource("bbox", {
        type: "geojson",
        data: bboxPolygon(extent),
      });

      // Add a new layer to visualize the polygon.
      this.mapView.addLayer({
        id: "bbox",
        type: "line",
        source: "bbox", // reference the data source
        layout: {},
        paint: {
          "line-color": "#000000", // blue color fill
          "line-width": 2.5,
          "line-dasharray": [2, 1],
        },
      });
    },
  },
  mounted() {
    mapboxgl.accessToken = this.accessToken;

    this.mapView = new mapboxgl.Map({
      container: "mapContainer",
      style: "mapbox://styles/mapbox/streets-v11",
      center: [103.811279, 1.345399],
      zoom: 0,
    });
  },
};
</script>