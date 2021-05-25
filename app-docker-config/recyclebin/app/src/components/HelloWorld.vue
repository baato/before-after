<template>
  <v-container>
    <SuccessfullyProvisioned
      v-if="successfullyProvisioned"
      :instanceName="instance.uuid"
    />
    <Loader v-if="showLoading" />
    <br />
    <v-card elevation="10">
      <v-row>
        <v-col cols="12" sm="1" />

        <v-col cols="12" sm="8">
          <v-form ref="form" v-model="valid" lazy-validation>
            <v-text-field
              label="Enter country name (eg: Nepal)"
              v-model="instance.country"
              :rules="requiredRules"
              required
            ></v-text-field>
            <v-text-field
              label="Enter bbox (eg: 84.715576,26.887167,85.168076,27.250357)"
              v-model="instance.bbox"
              :rules="requiredRules"
              required
            ></v-text-field>
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

            <v-text-field
              label="Enter stryle (eg: retro OR breeze)"
              v-model="instance.style"
              :rules="requiredRules"
              required
            ></v-text-field>
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

export default {
  name: "HelloWorld",
  components: {
    Loader,
    SuccessfullyProvisioned,
  },

  data: () => ({
    instance: {
      uuid: "bhutani2",
      year: 2015,
      bbox: "89.593506,27.454970,89.666977,27.492131",
      style: "retro",
      baato_access_token: "bpk.whkzK2b4MgeI9s7l-Y9izy11aE6j5sQzd-GrkYzMpkKS",
      country: "bhutan",
    },
    showLoading: false,
    successfullyProvisioned: false,
    valid: true,
    requiredRules: [(v) => !!v || "This field is required"],
  }),
  methods: {
    submitForm() {
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
        })
        .finally(() => {
          //Perform action in always
        });
    },
    validate() {
      const isFormValid = this.$refs.form.validate();
      if (isFormValid) this.submitForm();
    },
  },
};
</script>
