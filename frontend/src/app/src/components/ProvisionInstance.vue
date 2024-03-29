


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

    <div class="col-md-3 p-4" style="background-color: #47889d">
      <v-form ref="form" v-model="valid" lazy-validation>
        <span
          style="
            color: rgba(255, 255, 255, 0.7);
            text-transform: uppercase;
            font-size: 0.8rem;
            font-weight: 600;
          "
          >Location</span
        >
        <br />

        <v-autocomplete
          dark
          class="v-step-0 mt-2 app-combobox"
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
          required
          dense
          :rules="requiredRules"
          color="blue-grey lighten-2"
        ></v-autocomplete>
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

        <v-select
          dark
          class="v-step-2 mt-0"
          outlined
          dense
          label="Compare against (year)"
          :items="years"
          color="white"
          v-model="instance.beforeYear"
          :rules="requiredRules"
          required
        ></v-select>
        <br />

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
      <MapView ref="mapView" :theme="theme" />
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
      this.$refs.mapView.applySource(this.place.geometry, this.place.extent);
      this.instance.bbox = this.place.extent.join(",");
      this.instance.country =
        countryCodes[this.place.countrycode.toLowerCase()];
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
      if (isFormValid) this.submitForm();
    },
  },
  props: {
    theme: Boolean,
  },
};
</script>

