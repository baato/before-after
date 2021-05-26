<template>
  <v-container>
    <SuccessfullyProvisioned
      v-if="successfullyProvisioned"
      :instanceName="instance.uuid"
    />
    <Loader :showLoading="showLoading" :country="instance.country" />
    <br />
    <v-card elevation="10">
      <v-row>
        <v-col cols="12" sm="1" />

        <v-col cols="12" sm="8">
          <v-form ref="form" v-model="valid" lazy-validation>
            <v-row>
              <v-col cols="12" sm="12">
                <v-text-field
                  label="Enter bounding box (or select using icon) for the region (eg: 84.715576,26.887167,85.168076,27.250357)"
                  v-model="instance.bbox"
                  :rules="requiredRules"
                  required
                  @blur="getCountryCodeFromNominatim"
                  append-icon="mdi-eyedropper"
                  @click:append="openBboxFinder"
                  prepend-icon-tooltip="Click here to add a new User Type"
                ></v-text-field>
              </v-col>
              <!-- <v-col>
                <small>
                  You can find the bbox using
                  <a target="_blank" href="http://bboxfinder.com"
                    >this site</a
                  ></small
                >
              </v-col> -->
            </v-row>

            <strong class="teal--text" v-if="instance.country"
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
              v-model="instance.beforeYear"
              :rules="requiredRules"
              required
            ></v-text-field>

            <v-select
              label="Select map style"
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
      year: null,
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
    provisionInstanceAPICall() {
      this.showLoading = true;
      this.instance.year = this.instance.beforeYear.toString().substring(2);
      // axios
      //   .get("http://localhost:8848", {
      //     params: this.instance,
      //     timeout: 1000 * 60 * 10,
      //   })
      //   .then((res) => {
      //     console.log(res);
      //     this.showLoading = false;
      //     this.successfullyProvisioned = true;
      //   })
      //   .catch((error) => {
      //     console.log(error);
      //     // error.response.status Check status code
      //   });
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
