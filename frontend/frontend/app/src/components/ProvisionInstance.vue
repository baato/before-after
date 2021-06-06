<template>
  <div>
    <MapView ref="mapView" :theme="theme" />
    <v-container>
      <SuccessfullyProvisioned
        v-if="successfullyProvisioned"
        :instanceName="instance.uuid"
      />
      <Loader
        :showLoading="showLoading"
        :country="instance.country"
        :progressMessage="provisioningStateMappings[provisioningState]"
      />

      <v-container fill-height fluid>
        <v-row align="center" justify="center">
          <v-col style="z-index: 10" cols="12" xs="12" lg="8" xl="6">
            <v-card elevation="20" class="pa-5">
              <v-form ref="form" v-model="valid" lazy-validation>
                <v-autocomplete
                  class="v-step-0"
                  v-model="place"
                  :loading="isLoading"
                  :items="items"
                  item-text="name"
                  flat
                  :search-input.sync="search"
                  cache-items
                  hide-no-data
                  hide-details
                  label="Search for a place where you want to generate the before-after map (eg: Pokhara)"
                  solo-inverted
                  @change="selectPlace"
                  return-object
                  color="blue-grey lighten-2"
                ></v-autocomplete>

                <v-text-field
                  class="v-step-1"
                  label="Enter name for this before-after map (eg: Pokhara 2019 vs Present)"
                  v-model="instance.name"
                  :rules="requiredRules"
                  required
                ></v-text-field>

                <v-select
                  class="v-step-2"
                  label="Select the earlier year to compare with present (eg: 2015)"
                  :items="years"
                  v-model="instance.beforeYear"
                  :rules="requiredRules"
                  required
                ></v-select>
                <v-row align="center" justify="space-around">
                  <v-btn
                    class="v-step-3 white--text"
                    :disabled="!valid"
                    color="#2c3e50"
                    @click="validate"
                  >
                    Provision
                  </v-btn>
                </v-row>
                <v-row
                  v-if="this.instance.bbox"
                  align="center"
                  justify="space-around"
                >
                  <small align="center">
                    <v-icon>mdi-information</v-icon> Selected bounding box:
                    {{ this.instance.bbox }}
                  </small>
                </v-row>
              </v-form>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-container>
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
  name: "ProvisionInstance",
  components: {
    Loader,
    SuccessfullyProvisioned,
    MapView,
  },

  watch: {
    search(val) {
      val && val !== this.place && this.querySelections(val);
    },
  },

  props: {
    theme: Boolean,
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
  created: function () {
    this.ws = new WebSocket(`ws://${window.location.hostname}:8848/ws`);
    this.ws.addEventListener("message", (e) => {
      this.provisioningState = e.data;
      if (this.provisioningState == "done") {
        this.showLoading = false;
        this.successfullyProvisioned = true;
        this.disableNavigationPrompt();
      }
    });
  },
  methods: {
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
    openBboxFinder() {
      window.open("http://bboxfinder.com", "_blank");
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
      this.ws.send(JSON.stringify(signalToSendToSocket));
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
      this.showLoading = true;
      this.instance.year = this.instance.beforeYear.toString().substring(2);
      this.instance.uuid = uuid.v4();
      this.enableNavigationPrompt();
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
};
</script>
