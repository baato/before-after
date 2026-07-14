<template>
  <div class="row no-gutters">
    <SuccessfullyProvisioned
      v-if="successfullyProvisioned"
      :instanceName="instance.uuid"
    />
    <WhyPersonalDetails
      :showDialog="showPersonalDetailsRequirement"
      :closeDialogHandler="closePersonalDetailsRequirement"
    />
    <InstanceRequested
      :showDialog="showInstanceRequested"
      :closeDialogHandler="closeInstanceRequestedDialog"
    />
    <Loader
      :showLoading="showLoading"
      :country="instance.country"
      :progressMessage="provisioningStateMappings[provisioningState]"
    />

    <div class="col-md-3 p-4 brand-panel">
      <v-form ref="form" v-model="valid" lazy-validation>
        <div class="brand-panel-title">Create a map</div>
        <div class="brand-panel-desc mt-1 mb-4">
          Pick an area, choose a year to compare against, and we&rsquo;ll build
          the before&ndash;after maps for you.
        </div>

        <span class="brand-section-label">Location</span>

        <div class="loc-switch mt-2 mb-3">
          <button
            type="button"
            class="loc-opt"
            :class="{ active: locationMode === 'search' }"
            @click="setMode('search')"
          >
            <v-icon small>mdi-magnify</v-icon>
            <span>Search a place</span>
          </button>
          <button
            type="button"
            class="loc-opt"
            :class="{ active: locationMode === 'bbox' }"
            @click="setMode('bbox')"
          >
            <v-icon small>mdi-vector-rectangle</v-icon>
            <span>Draw a box</span>
          </button>
        </div>

        <!-- Search mode -->
        <v-autocomplete
          v-if="locationMode === 'search'"
          dark
          class="v-step-0 app-combobox"
          v-model="place"
          :loading="isLoading"
          :items="items"
          item-text="name"
          flat
          filled
          :search-input.sync="search"
          cache-items
          hide-no-data
          hide-details
          label="City, state, county, etc."
          solo-inverted
          @change="selectPlace"
          return-object
          dense
          color="blue-grey lighten-2"
        ></v-autocomplete>

        <!-- Bounding box mode -->
        <div v-else class="v-step-0">
          <div class="d-flex" style="gap: 8px">
            <v-btn
              outlined dark small
              class="text-none flex-grow-1"
              style="border-color: rgba(255, 255, 255, 0.4)"
              @click="startDraw"
            >
              <v-icon left small>mdi-select-drag</v-icon>
              {{ drawing ? "Drawing\u2026" : "Draw box on map" }}
            </v-btn>
            <v-btn
              text dark small
              class="text-none px-2"
              :disabled="!hasBbox"
              @click="clearBboxSelection"
            >
              <v-icon left small>mdi-close-circle-outline</v-icon>
              Clear
            </v-btn>
          </div>

          <v-row dense class="mt-1">
            <v-col cols="6">
              <v-text-field
                dark dense outlined hide-details type="number" step="0.0001"
                label="West (min lng)" color="white"
                v-model.number="bbox.west" @change="applyBbox"
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                dark dense outlined hide-details type="number" step="0.0001"
                label="South (min lat)" color="white"
                v-model.number="bbox.south" @change="applyBbox"
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                dark dense outlined hide-details type="number" step="0.0001"
                label="East (max lng)" color="white"
                v-model.number="bbox.east" @change="applyBbox"
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                dark dense outlined hide-details type="number" step="0.0001"
                label="North (max lat)" color="white"
                v-model.number="bbox.north" @change="applyBbox"
              ></v-text-field>
            </v-col>
          </v-row>

          <div v-if="detectedRegion" class="brand-detect mt-3">
            <v-icon small>mdi-map-check</v-icon>
            <span>Region: <strong>{{ detectedRegion }}</strong></span>
          </div>
          <div v-else-if="detectError" class="brand-detect is-error mt-3">
            <v-icon small color="#e5734e">mdi-alert-outline</v-icon>
            <span>{{ detectError }}</span>
          </div>
          <div v-else-if="resolving" class="brand-hint mt-3">
            <v-progress-circular
              indeterminate size="14" width="2" color="white" class="mr-2"
            />
            Detecting region&hellip;
          </div>
          <div v-else class="brand-hint mt-3">
            Draw a box or enter coordinates. We&rsquo;ll match it to the right
            data region automatically.
          </div>
        </div>

        <div class="mt-5"></div>
        <span class="brand-section-label">Map details</span>
        <v-text-field
          dark outlined dense class="v-step-1 mt-3" color="white"
          label="Name of this map"
          v-model="instance.name"
          :rules="requiredRules"
          required
        ></v-text-field>

        <v-select
          dark class="v-step-2 mt-0" outlined dense
          label="Compare against (year)"
          :items="years" color="white"
          v-model="instance.beforeYear"
          :rules="requiredRules"
          required
        ></v-select>

        <div style="line-height: 1rem" class="mt-2">
          <span class="brand-section-label"
            >Personal details
            <a
              @click="giveReasonForAskingPersonalDetails"
              class="font-weight-light float-right"
              style="text-transform: lowercase; color: rgba(255, 255, 255, 0.7)"
              ><i> Why personal info? </i>
            </a>
          </span>
        </div>

        <v-text-field
          dark outlined dense class="v-step-1 mt-3" color="white"
          label="Enter your full name"
          v-model="instance.fullName"
          :rules="requiredRules"
          required
        ></v-text-field>
        <v-text-field
          dark outlined class="v-step-1 mt-0" color="white"
          label="Enter your email address"
          v-model="instance.email"
          :rules="emailRules.concat(requiredRules)"
          required
          dense
        ></v-text-field>

        <v-btn
          large block
          class="v-step-3 brand-generate mt-2"
          :disabled="!canGenerate"
          @click="validate"
        >
          Generate map
          <v-icon right small>mdi-arrow-right</v-icon>
        </v-btn>
      </v-form>
    </div>

    <div class="col-md-9 p-0">
      <div class="brand-map-wrap">
        <div v-if="drawing" class="brand-draw-hint">
          <v-icon small color="white">mdi-select-drag</v-icon>
          Click and drag on the map to draw a bounding box
        </div>
        <MapView ref="mapView" :theme="theme" @bbox-drawn="onBboxDrawn" />
      </div>
    </div>
  </div>
</template>

<script>
import SuccessfullyProvisioned from "./SuccessfullyProvisioned";
import WhyPersonalDetails from "./WhyPersonalDetails.vue";
import InstanceRequested from "./InstanceRequested.vue";
import MapView from "./MapView";
import Loader from "./Loader";
import axios from "axios";
import countryCodes from "../configs/countryCodes.json";
import countryContinents from "../configs/countryContinents.json";
import provisioningStates from "../configs/provisioningStates.json";
import { uuid } from "vue-uuid";
import { generateYears } from "../utils/helpers.js";
import { bboxPolygon, centroid, booleanPointInPolygon } from "@turf/turf";

import USMidWest from "../utils/us_subregions/us-midwest.json";
import USNorthEast from "../utils/us_subregions/us-northeast.json";
import USPacific from "../utils/us_subregions/us-pacific.json";
import USSouth from "../utils/us_subregions/us-south.json";
import USWest from "../utils/us_subregions/us-west.json";

export default {
  name: "Test",
  components: {
    MapView,
    Loader,
    SuccessfullyProvisioned,
    WhyPersonalDetails,
    InstanceRequested,
  },
  watch: {
    search(val) {
      val && val !== this.place && this.querySelections(val);
    },
  },
  data: () => ({
    instance: {
      style: "retro",
    },
    items: [],
    isLoading: false,
    place: null,
    search: null,
    years: generateYears(),
    styles: ["retro", "breeze"],
    showLoading: false,
    successfullyProvisioned: false,
    valid: true,
    ws: null,
    provisioningState: null,
    requiredRules: [(v) => !!v || "This field is required"],
    emailRules: [
      (v) =>
        !v ||
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(v) ||
        "E-mail must be valid",
    ],
    provisioningStateMappings: provisioningStates,
    keepAliveCounter: null,
    showPersonalDetailsRequirement: false,
    showInstanceRequested: false,
    // --- bounding-box mode ---
    locationMode: "search",
    bbox: { west: null, south: null, east: null, north: null },
    drawing: false,
    resolving: false,
    detectedRegion: null,
    detectError: null,
  }),
  computed: {
    bboxValid() {
      const b = this.bbox;
      const nums = [b.west, b.south, b.east, b.north];
      if (nums.some((n) => n === null || n === "" || isNaN(Number(n))))
        return false;
      return (
        Number(b.west) < Number(b.east) && Number(b.south) < Number(b.north)
      );
    },
    hasBbox() {
      const b = this.bbox;
      return (
        b.west !== null ||
        b.south !== null ||
        b.east !== null ||
        b.north !== null
      );
    },
    canGenerate() {
      if (!this.valid) return false;
      if (this.locationMode === "bbox") {
        return this.bboxValid && !!this.instance.country && !this.detectError;
      }
      return !!this.instance.bbox && !!this.instance.country;
    },
  },
  methods: {
    giveReasonForAskingPersonalDetails() {
      this.$gtag.event("click", {
        event_category: "Viewed personal details info",
        event_label: "User viewed personal details",
        value: 12,
      });
      this.showPersonalDetailsRequirement = true;
    },
    closePersonalDetailsRequirement() {
      this.showPersonalDetailsRequirement = false;
    },
    closeInstanceRequestedDialog() {
      this.showInstanceRequested = false;
    },
    connectToWebsocket() {
      const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
      this.ws = new WebSocket(`${protocol}//${window.location.hostname}/ws`);
      this.ws.addEventListener("message", (e) => {
        this.provisioningState = e.data;
        if (this.provisioningState == "done") {
          this.showLoading = false;
          this.successfullyProvisioned = true;
          this.disableNavigationPrompt();
          clearInterval(this.keepAliveCounter);
        }
      });
    },

    keepSocketConectionAlive() {
      this.ws.onopen = () => {
        this.ws.send(
          JSON.stringify({
            message: "keepalive",
          })
        );
      };
    },

    querySelections(query) {
      this.isLoading = true;
      const filteringValues = [
        "state",
        "city",
        "district",
        "county",
        "suburb",
      ];
      axios
        .get("https://photon.komoot.io/api/", {
          params: {
            q: query,
            limit: 15,
          },
          timeout: 1000 * 60 * 10,
        })
        .then((res) => {
          const adminBoundaries = res.data.features
            .filter((r) => {
              return (
                r.properties.extent &&
                filteringValues.includes(r.properties.type)
              );
            })
            .map((r) => {
              return {
                name: `${r.properties.name} (${r.properties.type}) - ${r.properties.country}`,
                extent: r.properties.extent,
                countrycode: r.properties.countrycode,
                geometry: r.geometry,
              };
            });
          this.isLoading = false;
          this.items = adminBoundaries;
        })
        .catch((error) => {
          this.isLoading = false;
          console.log(error);
        });
    },
    selectPlace() {
      if (!this.place) return;
      this.$refs.mapView.applySource(this.place.geometry, this.place.extent);
      this.instance.bbox = this.place.extent.join(",");
      this.instance.country =
        countryCodes[this.place.countrycode.toLowerCase()];
    },

    // ---------------- bounding-box mode ----------------
    setMode(mode) {
      if (this.locationMode === mode) return;
      this.locationMode = mode;
      this.onModeChange();
    },
    clearBboxSelection() {
      this.bbox = { west: null, south: null, east: null, north: null };
      this.instance.bbox = null;
      this.instance.country = null;
      this.detectedRegion = null;
      this.detectError = null;
      this.resolving = false;
      this.drawing = false;
      if (this.$refs.mapView) {
        this.$refs.mapView.disableBboxDraw();
        this.$refs.mapView.clearBbox();
      }
    },
    onModeChange() {
      this.detectError = null;
      this.detectedRegion = null;
      this.resolving = false;
      this.drawing = false;
      if (this.$refs.mapView) {
        this.$refs.mapView.disableBboxDraw();
        this.$refs.mapView.clearBbox();
      }
      if (this.locationMode === "search") {
        this.bbox = { west: null, south: null, east: null, north: null };
      } else {
        this.place = null;
        this.instance.bbox = null;
        this.instance.country = null;
      }
    },
    startDraw() {
      if (!this.$refs.mapView) return;
      this.drawing = true;
      this.$refs.mapView.enableBboxDraw();
    },
    onBboxDrawn(b) {
      this.drawing = false;
      this.bbox = {
        west: this.round(b.west),
        south: this.round(b.south),
        east: this.round(b.east),
        north: this.round(b.north),
      };
      this.applyBbox();
    },
    round(n) {
      return Math.round(Number(n) * 1e6) / 1e6;
    },
    applyBbox() {
      if (!this.bboxValid) {
        this.detectedRegion = null;
        this.detectError = null;
        this.instance.country = null;
        this.instance.bbox = null;
        return;
      }
      const w = Number(this.bbox.west);
      const s = Number(this.bbox.south);
      const e = Number(this.bbox.east);
      const n = Number(this.bbox.north);

      // Keep the SAME extent order the search flow uses (photon: [W, N, E, S]),
      // so the value flows identically through drawing, turf and osmium.
      const extent = [w, n, e, s];
      this.instance.bbox = extent.join(",");

      const centroidGeom = {
        type: "Point",
        coordinates: [(w + e) / 2, (s + n) / 2],
      };
      this.$refs.mapView.applySource(centroidGeom, extent);

      this.resolveCountryFromBbox((w + e) / 2, (s + n) / 2);
    },
    resolveCountryFromBbox(lng, lat) {
      this.resolving = true;
      this.detectError = null;
      this.detectedRegion = null;
      axios
        .get("https://photon.komoot.io/reverse", {
          params: { lon: lng, lat: lat, limit: 1 },
          timeout: 1000 * 30,
        })
        .then((res) => {
          this.resolving = false;
          const feats = (res.data && res.data.features) || [];
          const props = feats.length ? feats[0].properties : null;
          const cc =
            props && props.countrycode
              ? props.countrycode.toLowerCase()
              : null;
          const region = cc ? countryCodes[cc] : null;
          if (!cc || !region) {
            this.instance.country = null;
            this.detectError =
              "Couldn't match this area to a data region. Try nudging the box or use search.";
            return;
          }
          this.instance.country = region;
          const countryName = (props && props.country) || cc.toUpperCase();
          const continent = countryContinents[region] || "";
          this.detectedRegion = continent
            ? `${countryName} (${continent})`
            : countryName;
        })
        .catch((error) => {
          this.resolving = false;
          this.instance.country = null;
          this.detectError =
            "Region lookup failed. Check your connection or use search.";
          console.log(error);
        });
    },
    // ---------------------------------------------------

    openBaatoSite() {
      window.open("https://baato.io", "_blank");
    },
    invokeSocket() {
      const signalToSendToSocket = {
        message: "provision",
        name: this.instance.name,
        uuid: this.instance.uuid,
        year: this.instance.year.toString(),
        bbox: this.instance.bbox,
        style: this.instance.style,
        country: this.instance.country,
        continent: countryContinents[this.instance.country],
      };
      this.connectToWebsocket();
      this.showLoading = true;
      this.successfullyProvisioned = false;
      this.enableNavigationPrompt();
      this.ws.onopen = () => this.ws.send(JSON.stringify(signalToSendToSocket));

      const self = this;
      this.keepAliveCounter = setInterval(
        self.keepSocketConectionAlive,
        15 * 1000
      );
    },
    invokeAPI() {
      this.$gtag.event("click", {
        event_category: "New Instance",
        event_label: `New instance was requested for ${
          this.instance.country
        },${this.instance.year.toString()}`,
        value: 11,
      });
      const protocol =
        window.location.protocol === "https:" ? "https:" : "http:";
      const data = {
        name: this.instance.name,
        uuid: this.instance.uuid,
        year: this.instance.year.toString(),
        bbox: this.instance.bbox,
        style: this.instance.style,
        country: this.instance.country,
        continent: countryContinents[this.instance.country],
        fullName: this.instance.fullName,
        email: this.instance.email,
      };

      // handle data extracts in Geofabrik as exception for the US regions
      if (data.country == "us") {
        const poly = bboxPolygon(data.bbox.split(","));
        const centroidPoint = centroid(poly);

        if (
          booleanPointInPolygon(
            centroidPoint.geometry,
            USMidWest.features[0].geometry
          )
        ) {
          data.country = "us-midwest";
        } else if (
          booleanPointInPolygon(
            centroidPoint.geometry,
            USNorthEast.features[0].geometry
          )
        ) {
          data.country = "us-northeast";
        } else if (
          booleanPointInPolygon(
            centroidPoint.geometry,
            USPacific.features[0].geometry
          )
        ) {
          data.country = "us-pacific";
        } else if (
          booleanPointInPolygon(
            centroidPoint.geometry,
            USSouth.features[0].geometry
          )
        ) {
          data.country = "us-south";
        } else if (
          booleanPointInPolygon(
            centroidPoint.geometry,
            USWest.features[0].geometry
          )
        ) {
          data.country = "us-west";
        }
      }

      this.showLoading = true;
      axios
        .post(`${protocol}//${window.location.hostname}/api/v1/instance`, data)
        .then((res) => {
          if (res.status == 200) {
            this.showInstanceRequested = true;
            this.showLoading = false;
          }
        })
        .catch((error) => {
          this.isLoading = false;
          console.log(error);
        });
    },
    enableNavigationPrompt() {
      window.onbeforeunload = function () {
        return true;
      };
    },
    disableNavigationPrompt() {
      window.onbeforeunload = null;
    },
    provisionInstanceAPICall() {
      this.instance.year = this.instance.beforeYear.toString().substring(2);
      this.instance.uuid = uuid.v4();

      this.invokeAPI();
    },
    submitForm() {
      this.provisionInstanceAPICall();
    },
    validate() {
      const isFormValid = this.$refs.form.validate();
      if (this.locationMode === "bbox" && !this.canGenerate) return;
      if (isFormValid && this.canGenerate) this.submitForm();
    },
  },
  props: {
    theme: Boolean,
  },
};
</script>
