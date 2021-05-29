<template>
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
    <br />
    <v-container fill-height fluid>
      <v-row align="center" justify="space-around">
        <span class="headline font-weight-bold">
          Before-after map generator
        </span>
      </v-row>
      <v-row align="center" justify="center">
        <v-col cols="12" xs="12" lg="8" xl="6">
          <v-card elevation="10" class="pa-5">
            <v-form ref="form" v-model="valid" lazy-validation>
              <v-text-field
                class="v-step-0"
                label="Enter name for the before-after instance (eg: Pokhara before-after map)"
                v-model="instance.name"
                :rules="requiredRules"
                required
              ></v-text-field>
              <v-row>
                <v-col>
                  <v-text-field
                    class="v-step-1"
                    label="Enter bounding box (or select using icon) for the region (eg: 84.715576,26.887167,85.168076,27.250357)"
                    v-model="instance.bbox"
                    :rules="requiredRules"
                    required
                    @blur="getCountryCodeFromNominatim"
                    append-icon="mdi-eyedropper"
                    @click:append="openBboxFinder"
                  ></v-text-field>
                  <div v-if="instance.country">
                    <strong class="teal--text"
                      >This area is identified to be within
                      {{ instance.country.toUpperCase() }}</strong
                    >
                    <p />
                  </div>
                </v-col>
              </v-row>

              <v-select
                class="v-step-2"
                label="Select the earlier year to compare (eg: 2015)"
                :items="years"
                v-model="instance.beforeYear"
                :rules="requiredRules"
                required
              ></v-select>

              <v-text-field
                class="v-step-3"
                label="Enter Baato access token (Registration with Baato.io required)"
                v-model="instance.baato_access_token"
                :rules="requiredRules"
                required
                append-icon="mdi-cursor-pointer"
                @click:append="openBaatoSite"
              ></v-text-field>
              <v-select
                class="v-step-4"
                label="Select Baato map style (Retro is default)"
                :items="styles"
                v-model="instance.style"
                :rules="requiredRules"
                required
              ></v-select>
              <v-row align="center" justify="space-around">
                <v-btn
                  class="v-step-5 white--text"
                  :disabled="!valid"
                  color="#b7a75c"
                  @click="validate"
                >
                  Provision
                </v-btn>
              </v-row>
            </v-form>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-container>
</template>

<script>
import SuccessfullyProvisioned from "./SuccessfullyProvisioned";
import Loader from "./Loader";
import axios from "axios";
import countryCodes from "./countryCodes.json";
import provisioningStates from "./provisioningStates.json";
import { uuid } from "vue-uuid";

function generateYears() {
  const currentYear = new Date().getFullYear();
  const yearsSupportedTill = 2015;
  let years = [];
  for (let i = currentYear - 1; i >= yearsSupportedTill; i--) {
    years.push(i);
  }
  return years;
}

export default {
  name: "ProvisionInstance",
  components: {
    Loader,
    SuccessfullyProvisioned,
  },

  data: () => ({
    instance: {
      style: "retro",
    },
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
    getCountryCodeFromNominatim() {
      const centerCoordinates = this.getBoundingBoxCenter(this.instance.bbox);
      axios
        .get("http://nominatim.openstreetmap.org/reverse", {
          params: {
            format: "json",
            lat: centerCoordinates.lat,
            lon: centerCoordinates.lon,
          },
          timeout: 1000 * 60 * 10,
        })
        .then((res) => {
          const countrycodeWhereCoordinatesBelong =
            res.data.address.country_code;
          this.instance.country =
            countryCodes[countrycodeWhereCoordinatesBelong];
        })
        .catch((error) => {
          this.instance.country = "Invalid bounding box!";
          console.log(error);
        });
    },
    getBoundingBoxCenter(bbox) {
      const bboxCoordinates = bbox.split(",").map((e) => Number(e));
      const centerCoordinates = {
        lat: (bboxCoordinates[1] + bboxCoordinates[3]) / 2,
        lon: (bboxCoordinates[0] + bboxCoordinates[2]) / 2,
      };
      return centerCoordinates;
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
        baato_access_token: this.instance.baato_access_token,
      };
      console.log("signalToSendToSocket", signalToSendToSocket);
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
