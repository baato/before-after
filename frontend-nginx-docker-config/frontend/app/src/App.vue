<template>
  <v-app>
    <Tour ref="tour" />
    <v-app-bar app color="#2c3e50" dark>
      <img :src="'logo.png'" style="padding: 5px" />
      Provision before-after map with ease
      <v-spacer></v-spacer>
      <v-switch
        class="text-right v-step-6"
        v-model="$vuetify.theme.dark"
        inset
        prepend-icon="mdi-theme-light-dark"
        align="right"
      >
      </v-switch>
    </v-app-bar>
    <About :aboutDialog="aboutDialog" :closeAboutDialog="closeAboutDialog" />
    <v-main>
      <ProvisionInstance />
    </v-main>
    <v-footer padless>
      <v-btn @click="aboutDialog = true" text
        >About <v-icon right dark> mdi-information-outline </v-icon></v-btn
      >
      <v-col class="text-center">
        <strong
          >Powered by
          <a href="https://baato.io" target="_blank">baato.io</a></strong
        >
      </v-col>
      <v-btn id="v-step-0" text @click="toggleTour"
        >How to use <v-icon right dark> mdi-help-circle-outline </v-icon></v-btn
      >
    </v-footer>
  </v-app>
</template>

<script>
import ProvisionInstance from "./components/ProvisionInstance";
import About from "./components/About";
import Tour from "./components/Tour";

export default {
  name: "App",

  components: {
    ProvisionInstance,
    About,
    Tour,
  },

  data: () => ({
    aboutDialog: false,
  }),
  methods: {
    closeAboutDialog() {
      this.aboutDialog = false;
    },
    toggleTour() {
      this.$refs.tour.$tours["myTour"].start();
    },
  },
};
</script>
