


<template>
  <div class="row">
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

    <div class="col-md-3 p-4 provision-panel" style="background-color: #47889d">
      <v-form ref="form" v-model="valid" lazy-validation>
        <div class="brand">
          <img class="brand-logo" :src="'logo.png'" alt="logo" />
          <div class="brand-text">
            GENERATE<br />
            <span>BEFORE-AFTER MAPS</span><br />
            WITH EASE
          </div>
        </div>
        <p class="panel-sub">
          Pick an area, choose a year to compare against, and we'll build the
          before-after maps for you.
        </p>
        <div class="section-label" style="margin-top: 0">Location</div>

        <div class="loc-toggle">
          <button
            type="button"
            :class="{ 'loc-on': locationMode === 'search' }"
            @click="locationMode = 'search'"
          >
            <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
            Search a place
          </button>
          <button
            type="button"
            :class="{ 'loc-on': locationMode === 'draw' }"
            @click="locationMode = 'draw'"
          >
            <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="1"/><circle cx="4" cy="4" r="2" fill="currentColor"/><circle cx="20" cy="4" r="2" fill="currentColor"/><circle cx="4" cy="20" r="2" fill="currentColor"/><circle cx="20" cy="20" r="2" fill="currentColor"/></svg>
            Draw a box
          </button>
        </div>

        <!-- SEARCH mode -->
        <v-autocomplete
          v-show="locationMode === 'search'"
          dark
          class="v-step-0 mt-1 app-combobox"
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

        <!-- DRAW mode -->
        <div v-if="locationMode === 'draw'">
          <div class="draw-row">
            <button type="button" class="draw-btn" @click="startDraw">
              <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="1" stroke-dasharray="3 2"/><path d="M12 8v8M8 12h8"/></svg>
              Draw box on map
            </button>
            <button type="button" class="draw-btn draw-clear" @click="clearDraw" :disabled="!hasBox">
              Clear
            </button>
          </div>

          <div class="coord-grid">
            <input class="coord-in" type="number" step="any" v-model.number="coords.w" placeholder="West (min lng)" @change="onCoordEdit" />
            <input class="coord-in" type="number" step="any" v-model.number="coords.s" placeholder="South (min lat)" @change="onCoordEdit" />
            <input class="coord-in" type="number" step="any" v-model.number="coords.e" placeholder="East (max lng)" @change="onCoordEdit" />
            <input class="coord-in" type="number" step="any" v-model.number="coords.n" placeholder="North (max lat)" @change="onCoordEdit" />
          </div>

          <div class="draw-hint">
            Click "Draw box on map", then press and drag on the map to draw a
            rectangle. Or type coordinates. We'll match it to the right data
            region automatically.
          </div>
          <div v-if="regionStatus" class="region-status">{{ regionStatus }}</div>
        </div>
        <br />

        <span
          style="
            color: rgba(255, 255, 255, 0.7);
            text-transform: uppercase;
            font-size: 0.8rem;
            font-weight: 600;
          "
          >MAP DETAILS</span
        >
        <br />
        <v-text-field
          dark
          outlined
          dense
          class="v-step-1 mt-3"
          color="white"
          label="Name of this map"
          v-model="instance.name"
          :rules="requiredRules"
          required
        ></v-text-field>

        <div class="section-label mt-2">Comparison</div>
        <v-btn-toggle
          v-model="compareMode"
          mandatory
          dense
          class="mode-toggle v-step-2 mb-3"
        >
          <v-btn small value="year">Year</v-btn>
          <v-btn small value="range">Date range</v-btn>
        </v-btn-toggle>

        <!-- YEAR — the standard flow (year vs latest) -->
        <template v-if="compareMode === 'year'">
          <v-select
            dark
            outlined
            dense
            label="Compare against (year)"
            :items="years"
            color="white"
            v-model="beforeYear"
            :rules="requiredRules"
            required
          ></v-select>
          <div class="time-note mb-3">
            Compares that year against the latest map — the standard, fastest option.
          </div>
        </template>

        <!-- DATE RANGE — history-based, pick two dates -->
        <template v-else>
          <div class="field-label">From date</div>
          <v-menu
            v-model="fromMenu"
            :close-on-content-click="false"
            transition="scale-transition"
            offset-y
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                dark outlined dense readonly
                label="From"
                color="white"
                v-model="fromDate"
                v-bind="attrs"
                v-on="on"
                :rules="requiredRules"
                required
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="fromDate"
              :max="pickerMax"
              :min="pickerMin"
              :allowed-dates="dateAllowed"
              @input="fromMenu = false"
            ></v-date-picker>
          </v-menu>

          <div class="field-label">To date</div>
          <v-menu
            v-model="toMenu"
            :close-on-content-click="false"
            transition="scale-transition"
            offset-y
            min-width="auto"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                dark outlined dense readonly
                label="To"
                color="white"
                v-model="toDate"
                v-bind="attrs"
                v-on="on"
                :rules="requiredRules"
                required
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="toDate"
              :max="pickerMax"
              :min="fromDate || pickerMin"
              :allowed-dates="dateAllowed"
              @input="toMenu = false"
            ></v-date-picker>
          </v-menu>

          <v-alert dense text type="info" color="white" class="time-note mt-1 mb-3">
            Compares two dates using Geofabrik's dated map extracts. Only dates
            Geofabrik actually publishes for this region are selectable — pick a
            location first, and the calendar will highlight the available dates
            (yearly snapshots back to 2014, plus recent months).
          </v-alert>
        </template>

        <v-alert
          v-if="dateError"
          dense
          text
          type="error"
          class="time-note mt-1 mb-2"
        >{{ dateError }}</v-alert>

        <div style="line-height: 1rem">
          <span
            style="
              color: rgba(255, 255, 255, 0.7);
              text-transform: uppercase;
              font-size: 0.8rem;
              font-weight: 600;
            "
            >PERSONAL DETAILS
            <a
              @click="giveReasonForAskingPersonalDetails"
              class="font-weight-light float-right"
              style="text-transform: lowercase; color: rgba(255, 255, 255, 0.7)"
              ><i> Why personal info? </i>
            </a>
          </span>
        </div>

        <v-text-field
          dark
          outlined
          dense
          class="v-step-1 mt-3"
          color="white"
          label="Enter your full name"
          v-model="instance.fullName"
          :rules="requiredRules"
          required
        ></v-text-field>
        <v-text-field
          dark
          outlined
          class="v-step-1 mt-0"
          color="white"
          label="Enter your email address"
          v-model="instance.email"
          :rules="emailRules.concat(requiredRules)"
          required
          dense
        ></v-text-field>

        <br />
        <v-btn
          large
          class="v-step-3 white--text float-right"
          :disabled="!valid"
          color="#2c3e50"
          @click="validate"
          style="padding: 10px"
        >
          GENERATE MAP
        </v-btn>
      </v-form>
    </div>
    <div class="col-md-9 p-0" style="">
      <MapView ref="mapView" :theme="theme" @draw-bbox="onDrawBbox" />
    </div>
    <!-- <div class="col-md-12" style="background-color: #fff; min-height: 400px">
      Holla
    </div> -->
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
    // comparison selection
    compareMode: "year", // 'year' (standard flow) | 'range' (history flow)
    beforeYear: null,
    fromDate: null, // 'YYYY-MM-DD'
    toDate: null, // 'YYYY-MM-DD'
    availableDates: [], // dates Geofabrik actually publishes for the region
    availableDatesSet: {},
    fromMenu: false,
    toMenu: false,
    today: new Date().toISOString().substr(0, 10),
    minDate: new Date(Date.now() - 89 * 864e5).toISOString().substr(0, 10), // Geofabrik keeps ~90 days of dated extracts
    dateError: "",
    resolvedMode: "standard",
    resolvedBefore: null,
    resolvedAfter: null,
    locationMode: "search", // 'search' | 'draw'
    coords: { w: null, s: null, e: null, n: null },
    hasBox: false,
    regionStatus: "",
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
  }),
  computed: {
    pickerMin() {
      return this.availableDates.length
        ? this.availableDates[this.availableDates.length - 1]
        : this.minDate;
    },
    pickerMax() {
      return this.availableDates.length ? this.availableDates[0] : this.today;
    },
  },
  methods: {
    dateAllowed(d) {
      // when we know Geofabrik's list, only those dates are selectable
      return this.availableDates.length ? !!this.availableDatesSet[d] : true;
    },
    loadAvailableDates() {
      const country = this.instance.country;
      const continent = country ? countryContinents[country] : null;
      if (!country || !continent) {
        this.availableDates = [];
        this.availableDatesSet = {};
        return;
      }
      const protocol = window.location.protocol;
      axios
        .get(
          `${protocol}//${window.location.hostname}/api/v1/available-dates`,
          { params: { continent, country } }
        )
        .then((res) => {
          const dates = (res.data && res.data.dates) || [];
          this.availableDates = dates;
          const set = {};
          dates.forEach((d) => (set[d] = true));
          this.availableDatesSet = set;
          // drop any already-picked date that isn't actually available
          if (dates.length) {
            if (this.fromDate && !set[this.fromDate]) this.fromDate = null;
            if (this.toDate && !set[this.toDate]) this.toDate = null;
          }
        })
        .catch(() => {
          this.availableDates = [];
          this.availableDatesSet = {};
        });
    },
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
        // "country",
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
          const resolvesCountry = (r) => {
            const cc = r.properties.countrycode;
            if (cc && countryCodes[cc.toLowerCase()] &&
                countryContinents[countryCodes[cc.toLowerCase()]]) return true;
            const nm = r.properties.country;
            return !!(nm && countryContinents[nm.toLowerCase()]);
          };
          const adminBoundaries = res.data.features
            .filter((r) => {
              return (
                r.properties.extent &&
                filteringValues.includes(r.properties.type) &&
                resolvesCountry(r)
              );
            })
            .map((r) => {
              return {
                name: `${r.properties.name} (${r.properties.type}) - ${r.properties.country}`,
                extent: r.properties.extent,
                countrycode: r.properties.countrycode,
                country: r.properties.country,
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
    normExtent(ext) {
      // [0],[2] = lng ; [1],[3] = lat (order-agnostic) -> [W,S,E,N]
      var lo = [ext[0], ext[2]].map(Number), la = [ext[1], ext[3]].map(Number);
      return [Math.min(lo[0], lo[1]), Math.min(la[0], la[1]), Math.max(lo[0], lo[1]), Math.max(la[0], la[1])];
    },
    resolveRegion() {
      // search mode: derive bbox + country from the selected place
      let p = this.place;
      if (typeof p === "string") p = (this.items || []).find((i) => i.name === p);
      if (!p || !p.extent) return false;
      const ne = this.normExtent(p.extent);
      this.instance.bbox = ne.join(",");
      const cc = p.countrycode ? String(p.countrycode).toLowerCase() : null;
      let country = cc ? countryCodes[cc] : null;
      if (!country || !countryContinents[country]) {
        const nm = p.country ? String(p.country).toLowerCase() : null;
        country = nm && countryContinents[nm] ? nm : null;
      }
      if (!country || !countryContinents[country]) return false;
      this.instance.country = country;
      this.loadAvailableDates();
      return true;
    },
    startDraw() {
      if (this.$refs.mapView && this.$refs.mapView.startDraw) this.$refs.mapView.startDraw();
      const el = document.getElementById("mapContainer");
      if (el && el.scrollIntoView) el.scrollIntoView({ behavior: "smooth", block: "center" });
    },
    clearDraw() {
      if (this.$refs.mapView && this.$refs.mapView.clearDraw) this.$refs.mapView.clearDraw();
      this.coords = { w: null, s: null, e: null, n: null };
      this.hasBox = false;
      this.instance.bbox = "";
      this.instance.country = undefined;
      this.regionStatus = "";
    },
    onDrawBbox(str) {
      if (str) {
        const p = str.split(",").map(Number); // turf bbox = W,S,E,N
        this.coords = { w: p[0], s: p[1], e: p[2], n: p[3] };
        this.instance.bbox = str;
        this.hasBox = true;
        this.locationMode = "draw";
        this.autoResolveRegion();
      } else {
        this.hasBox = false;
      }
    },
    onCoordEdit() {
      const c = this.coords, vals = [c.w, c.s, c.e, c.n];
      if (vals.some((v) => v === null || v === undefined || v === "" || isNaN(Number(v)))) return;
      const W = Math.min(c.w, c.e), E = Math.max(c.w, c.e), S = Math.min(c.s, c.n), N = Math.max(c.s, c.n);
      this.instance.bbox = [W, S, E, N].join(",");
      this.hasBox = true;
      if (this.$refs.mapView) this.$refs.mapView.applySource(null, [W, S, E, N]);
      this.autoResolveRegion();
    },
    autoResolveRegion() {
      if (!this.instance.bbox) return Promise.resolve(false);
      const p = this.instance.bbox.split(",").map(Number);
      const midLng = (p[0] + p[2]) / 2, midLat = (p[1] + p[3]) / 2;
      const self = this;
      self.regionStatus = "Detecting region\u2026";
      return axios
        .get("https://photon.komoot.io/reverse", { params: { lon: midLng, lat: midLat } })
        .then(function (res) {
          const f = res.data && res.data.features && res.data.features[0];
          const cc = f && f.properties && f.properties.countrycode;
          const nm = f && f.properties && f.properties.country;
          let country = cc ? countryCodes[String(cc).toLowerCase()] : null;
          if ((!country || !countryContinents[country]) && nm && countryContinents[String(nm).toLowerCase()]) {
            country = String(nm).toLowerCase();
          }
          if (country && countryContinents[country]) {
            self.instance.country = country;
            self.regionStatus = "Matched region: " + (nm || country);
            self.loadAvailableDates();
            return true;
          }
          self.instance.country = undefined;
          self.regionStatus = "Couldn't match a data region for this area.";
          return false;
        })
        .catch(function () {
          self.instance.country = undefined;
          self.regionStatus = "Couldn't reach the region lookup service.";
          return false;
        });
    },
    selectPlace() {
      if (!this.place) return;
      const ok = this.resolveRegion();
      this.dateError = ok ? "" : "Couldn't determine the country for this location \u2014 pick a city/region that lists a country.";
      if (ok && this.place && this.place.extent && this.$refs.mapView) {
        this.$refs.mapView.applySource(this.place.geometry, this.normExtent(this.place.extent));
      }
    },
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
        mode: this.resolvedMode,
        beforeDate: this.resolvedMode === "history" ? this.resolvedBefore : "",
        afterDate: this.resolvedMode === "history" ? this.resolvedAfter : "",
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
      // Enable navigation prompt
      window.onbeforeunload = function () {
        return true;
      };
    },
    disableNavigationPrompt() {
      // Remove navigation prompt
      window.onbeforeunload = null;
    },
    resolveDates() {
      if (this.compareMode === "year") {
        if (!this.beforeYear) {
          this.dateError = "Choose a year to compare against.";
          return false;
        }
        this.resolvedMode = "standard";
        this.resolvedBefore = `${this.beforeYear}-01-01`;
        this.resolvedAfter = "latest";
        this.dateError = "";
        return true;
      }
      // date range (history)
      if (!this.fromDate || !this.toDate) {
        this.dateError = "Pick both a From and a To date.";
        return false;
      }
      if (this.toDate <= this.fromDate) {
        this.dateError = "The To date must be later than the From date.";
        return false;
      }
      if (
        this.availableDates.length &&
        (!this.availableDatesSet[this.fromDate] ||
          !this.availableDatesSet[this.toDate])
      ) {
        this.dateError =
          "Those dates aren't published by Geofabrik for this region — pick highlighted dates only.";
        return false;
      }
      this.resolvedMode = "history";
      this.resolvedBefore = this.fromDate;
      this.resolvedAfter = this.toDate;
      this.dateError = "";
      return true;
    },
    provisionInstanceAPICall() {
      // 2-digit year of the "before" point, kept for backend back-compat
      this.instance.year = this.resolvedBefore.substring(2, 4);
      this.instance.mode = this.resolvedMode;
      this.instance.uuid = uuid.v4();

      this.invokeAPI();
    },
    submitForm() {
      this.provisionInstanceAPICall();
    },
    async validate() {
      const isFormValid = this.$refs.form.validate();
      if (!isFormValid) return;
      if (this.locationMode === "search") {
        if (!this.resolveRegion()) {
          this.dateError = "Pick a location from the search box (one that lists a country).";
          return;
        }
      } else {
        if (!this.instance.bbox) {
          this.dateError = "Draw a box on the map or enter coordinates.";
          return;
        }
        if (!this.instance.country || !countryContinents[this.instance.country]) {
          const ok = await this.autoResolveRegion();
          if (!ok) {
            this.dateError = "Couldn't match this area to a data region. Try a box inside one country.";
            return;
          }
        }
      }
      if (!this.resolveDates()) return;
      this.submitForm();
    },
  },
  props: {
    theme: Boolean,
  },
};
</script>


<style scoped>
/* fill the full viewport so the map and sidebar are full-height */
.row {
  min-height: 100vh;
  margin: 0;
}
.provision-panel .brand {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 64px;
}
.provision-panel .brand-logo {
  height: 58px;
  width: auto;
  flex: 0 0 auto;
}
.provision-panel .brand-text {
  font-family: "Roboto", sans-serif;
  font-size: 0.82rem;
  line-height: 1.35;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: #ffffff;
}
.provision-panel .brand-text span {
  color: #d7e8ef;
}
/* consistent vertical rhythm + spacing for the request form */
.provision-panel >>> .v-form > * {
  margin-bottom: 2px;
}
.provision-panel .section-label {
  display: block;
  color: rgba(255, 255, 255, 0.7);
  text-transform: uppercase;
  font-size: 0.8rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  margin: 18px 0 10px;
}
.provision-panel .field-label {
  color: #fff;
  font-size: 0.82rem;
  font-weight: 500;
  margin-bottom: 6px;
  opacity: 0.92;
}
/* segmented Year / Date toggle on the teal panel */
.provision-panel .mode-toggle {
  width: 100%;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  overflow: hidden;
}
.provision-panel .mode-toggle .v-btn {
  flex: 1 1 0;
  color: rgba(255, 255, 255, 0.72) !important;
  text-transform: none;
  letter-spacing: 0;
  font-weight: 500;
  border: none !important;
  background: transparent !important;
}
.provision-panel .mode-toggle .v-btn.v-btn--active {
  background: rgba(255, 255, 255, 0.2) !important;
  color: #fff !important;
}
.provision-panel .time-note {
  font-size: 0.72rem;
  line-height: 1.4;
}
.provision-panel .panel-title {
  font-family: "Space Grotesk", Roboto, sans-serif;
  font-weight: 600;
  font-size: 1.55rem;
  color: #fff;
  margin: 0 0 6px;
}
.provision-panel .panel-sub {
  font-size: 0.85rem;
  line-height: 1.5;
  color: rgba(255, 255, 255, 0.8);
  margin: 0 0 18px;
}
.provision-panel .draw-row {
  display: flex;
  gap: 8px;
  margin-top: 10px;
}
.provision-panel .loc-toggle {
  display: flex;
  gap: 6px;
  background: rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  padding: 5px;
  margin: 8px 0 10px;
}
.provision-panel .loc-toggle button {
  flex: 1 1 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  padding: 9px 10px;
  border: 0;
  border-radius: 8px;
  cursor: pointer;
  background: transparent;
  color: rgba(255, 255, 255, 0.85);
  font-family: Roboto, sans-serif;
  font-size: 13px;
  font-weight: 600;
  transition: background 0.15s ease, color 0.15s ease, box-shadow 0.15s ease;
}
.provision-panel .loc-toggle button.loc-on {
  background: #fff;
  color: #2c3e50;
  box-shadow: 0 2px 8px rgba(31, 45, 58, 0.18);
}
.provision-panel .draw-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
  font-family: Roboto, sans-serif;
  font-size: 12.5px;
  font-weight: 600;
  color: #fff;
  background: rgba(255, 255, 255, 0.14);
  border: 1px solid rgba(255, 255, 255, 0.28);
  transition: background 0.15s ease;
}
.provision-panel .draw-btn:first-child {
  flex: 1 1 auto;
}
.provision-panel .draw-btn:hover {
  background: rgba(255, 255, 255, 0.24);
}
.provision-panel .draw-clear {
  background: transparent;
}
.provision-panel .draw-btn:disabled {
  opacity: 0.5;
  cursor: default;
}
.provision-panel .coord-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 10px;
}
.provision-panel .coord-in {
  width: 100%;
  padding: 12px 12px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.35);
  background: rgba(255, 255, 255, 0.06);
  color: #fff;
  font-family: Roboto, sans-serif;
  font-size: 13.5px;
  outline: none;
}
.provision-panel .coord-in::placeholder {
  color: rgba(255, 255, 255, 0.7);
}
.provision-panel .coord-in:focus {
  border-color: #fff;
  background: rgba(255, 255, 255, 0.12);
}
.provision-panel .draw-hint {
  margin-top: 9px;
  font-size: 0.72rem;
  line-height: 1.4;
  color: rgba(255, 255, 255, 0.75);
}
.provision-panel .region-status {
  margin-top: 8px;
  font-size: 0.76rem;
  font-weight: 600;
  color: #eaf3f6;
}
/* keep the generate button clear of the fields above it */
.provision-panel .v-btn.v-step-3 {
  margin-top: 8px;
}
</style>
