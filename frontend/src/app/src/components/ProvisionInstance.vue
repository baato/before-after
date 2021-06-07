


<template>
  <div class="row">
    <SuccessfullyProvisioned
      v-if="successfullyProvisioned"
      :instanceName="instance.uuid"
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
          label="City, country, etc."
          solo-inverted
          @change="selectPlace"
          return-object
          required
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
          class="v-step-1 mt-3"
          color="white"
          label="Name of this map"
          v-model="instance.name"
          :rules="requiredRules"
          required
        ></v-text-field>

        <v-select
          dark
          class="v-step-2 mt-4"
          outlined
          label="Compare against (year)"
          :items="years"
          color="white"
          v-model="instance.beforeYear"
          :rules="requiredRules"
          required
        ></v-select>

        <v-btn
          x-large
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
import MapView from "./MapView";
import Loader from "./Loader";
import axios from "axios";
import countryCodes from "../configs/countryCodes.json";
import provisioningStates from "../configs/provisioningStates.json";
import { uuid } from "vue-uuid";
import { generateYears } from "../utils/helpers.js";

export default {
  name: "Test",
  components: {
    MapView,
    Loader,
    SuccessfullyProvisioned,
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
    provisioningStateMappings: provisioningStates,
  }),
  methods: {
    connectToWebsocket() {
      const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
      this.ws = new WebSocket(`${protocol}//${window.location.hostname}/ws`);
      this.ws.addEventListener("message", (e) => {
        this.provisioningState = e.data;
        if (this.provisioningState == "done") {
          this.showLoading = false;
          this.successfullyProvisioned = true;
          this.disableNavigationPrompt();
        }
      });
    },

    querySelections(query) {
      this.isLoading = true;
      const filteringValues = [
        "state",
        "city",
        "district",
        "county",
        "suburb",
        "country",
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
      };
      this.connectToWebsocket();
      this.showLoading = true;
      this.enableNavigationPrompt();
      this.ws.onopen = () => this.ws.send(JSON.stringify(signalToSendToSocket));
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

      this.invokeSocket();
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

