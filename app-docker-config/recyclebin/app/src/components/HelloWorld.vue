<template>
  <v-container>
    <SuccessfullyProvisioned
      v-if="successfullyProvisioned"
      :instanceName="instance.uuid"
    />
    <Loader v-if="showLoading" :country="instance.country" />
    <br />
    <v-card elevation="10">
      <v-row>
        <v-col cols="12" sm="1" />

        <v-col cols="12" sm="8">
          <v-form ref="form" v-model="valid" lazy-validation>
            <!-- <v-text-field
              label="Enter country name (eg: Nepal)"
              v-model="instance.country"
              :rules="requiredRules"
              required
            ></v-text-field> -->
            <v-text-field
              label="Enter bbox (eg: 84.715576,26.887167,85.168076,27.250357)"
              v-model="instance.bbox"
              :rules="requiredRules"
              required
              @blur="getCountryCodeFromNominatim"
            ></v-text-field>
            <strong v-if="instance.country"
              >This area is identified to be within
              {{ instance.country.toUpperCase() }}</strong
            >
            <v-text-field
              label="Enter name for the instance (eg: Pokhara)"
              v-model="instance.uuid"
              :rules="requiredRules"
              required
            ></v-text-field>
            <v-text-field
              label="Enter before-year (eg: 2015)"
              v-model="instance.year"
              :rules="requiredRules"
              required
            ></v-text-field>

            <v-select
              label="Select style"
              :items="styles"
              v-model="instance.style"
              :rules="requiredRules"
              required
            ></v-select>
            <v-text-field
              label="Enter Baato access token"
              v-model="instance.baato_access_token"
              :rules="requiredRules"
              required
            ></v-text-field>

            <v-btn
              :disabled="!valid"
              color="#bdc3c7"
              class="mr-4 text-xs-center"
              @click="validate"
            >
              Provision
            </v-btn>
          </v-form>
        </v-col>
      </v-row>
    </v-card>
  </v-container>
</template>

<script>
import SuccessfullyProvisioned from "./SuccessfullyProvisioned";
import Loader from "./Loader";
import axios from "axios";
import countryCodes from "./countryCodes.json";

export default {
  name: "HelloWorld",
  components: {
    Loader,
    SuccessfullyProvisioned,
  },

  data: () => ({
    instance: {
      uuid: null,
      year: 2015,
      bbox: null,
      style: null,
      country: null,
      baato_access_token: "bpk.whkzK2b4MgeI9s7l-Y9izy11aE6j5sQzd-GrkYzMpkKS",
    },
    styles: ["retro", "breeze"],
    showLoading: false,
    successfullyProvisioned: false,
    valid: true,
    requiredRules: [(v) => !!v || "This field is required"],
  }),
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
    provisionInstanceAPICall() {
      this.showLoading = true;
      this.instance.year = this.instance.year.toString().split("20")[1];
      axios
        .get("http://localhost:8848", {
          params: this.instance,
          timeout: 1000 * 60 * 10,
        })
        .then((res) => {
          console.log(res);
          this.showLoading = false;
          this.successfullyProvisioned = true;
        })
        .catch((error) => {
          console.log(error);
          // error.response.status Check status code
        });
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
