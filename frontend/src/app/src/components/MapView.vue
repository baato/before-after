<template>
  <div id="mapContainer" class="basemap"></div>
</template>

<style lang="scss" scoped>
.basemap {
  // position: absolute;
  // top: 0;
  // bottom: 0;
  height: 81vh;
  width: 100%;
  // border-radius: 5px;
  // box-shadow: 0 20px 50px rgba(0, 0, 0, 0.1);
  // z-index: 10;
}
</style>


<script>
import mapboxgl from "mapbox-gl";
import MapboxDraw from "@mapbox/mapbox-gl-draw";
import { bboxPolygon, bbox } from "@turf/turf";
import ScaleMode from "mapbox-gl-draw-scale-mode";

class extendDrawBar {
  constructor(opt) {
    let ctrl = this;
    ctrl.draw = opt.draw;
    ctrl.buttons = opt.buttons || [];
    ctrl.onAddOrig = opt.draw.onAdd;
    ctrl.onRemoveOrig = opt.draw.onRemove;
  }
  onAdd(map) {
    let ctrl = this;
    ctrl.map = map;
    ctrl.elContainer = ctrl.onAddOrig(map);
    ctrl.buttons.forEach((b) => {
      ctrl.addButton(b);
    });
    return ctrl.elContainer;
  }
  onRemove(map) {
    let ctrl = this;
    ctrl.buttons.forEach((b) => {
      ctrl.removeButton(b);
    });
    ctrl.onRemoveOrig(map);
  }
  addButton(opt) {
    let ctrl = this;
    var elButton = document.createElement("button");
    elButton.className = "mapbox-gl-draw_ctrl-draw-btn";
    elButton.title = opt.title || "";
    if (opt.classes instanceof Array) {
      opt.classes.forEach((c) => {
        elButton.classList.add(c);
      });
    }
    elButton.addEventListener(opt.on, opt.action);
    ctrl.elContainer.appendChild(elButton);
    opt.elButton = elButton;
  }
  removeButton(opt) {
    opt.elButton.removeEventListener(opt.on, opt.action);
    opt.elButton.remove();
  }
}

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
      this.mapView.fitBounds(
        [
          [extent[0], extent[1]], // southwestern corner of the bounds
          [extent[2], extent[3]], // northeastern corner of the bounds
        ],
        { padding: 200 }
      );

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
      console.log("extent", extent);
      this.drawView.add(bboxPolygon(extent));
    },
    activateSelectMode() {
      this.drawView.changeMode("simple_select");
    },
    activateScaleMode() {
      this.drawView.changeMode("ScaleMode");
    },
  },

  props: {
    theme: Boolean,
    updateBbox: Function,
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

    ScaleMode.scaleend = (e) => {
      if (e) {
        this.updateBbox(bbox(e));
      }
    };

    this.drawView = new MapboxDraw({
      modes: Object.assign({ ScaleMode: ScaleMode }, MapboxDraw.modes),
      controls: {
        point: false,
        combine_features: false,
        uncombine_features: false,
        line_string: false,
        trash: false,
        polygon: false,
      },
    });

    this.drawBar = new extendDrawBar({
      draw: this.drawView,
      buttons: [
        {
          on: "click",
          action: this.activateSelectMode,
          classes: ["fa", "fa-hand-pointer"],
          title: "Select mode",
        },
        {
          on: "click",
          action: this.activateScaleMode,
          classes: ["fa", "fa-expand"],
          title: "Scale mode",
        },
      ],
    });

    this.mapView.addControl(this.drawBar);

    this.mapView.on("draw.update", (e) => {
      this.updateBbox(bbox(e.features[0]));
    });
  },
};
</script>