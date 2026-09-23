<template>
  <v-app>
    <Tour ref="tour" />

    <About :aboutDialog="aboutDialog" :closeAboutDialog="closeAboutDialog" />
    <v-main>
      <SytemNotWorking v-if="systemNotWorking" :theme="$vuetify.theme.dark" />
      <ProvisionInstance
        v-if="!systemNotWorking"
        :theme="$vuetify.theme.dark"
      />
    </v-main>
    <v-footer padless>
      <v-btn class="v-step-5" @click="openAboutDialog" text
        >About <v-icon right dark> mdi-information-outline </v-icon></v-btn
      >
      <span> | </span>
      <v-btn text @click="toggleTour"
        >How to use <v-icon right dark> mdi-help-circle-outline </v-icon></v-btn
      >
      <v-col class="text-right">
        <strong
          >Powered by
          <a rel="noreferrer noopener" href="https://baato.io" target="_blank">
            <img
              src="https://sgp1.digitaloceanspaces.com/baatocdn/images/BaatoLogo.svg"
              alt="Baato"
              width="80px"
            /> </a
        ></strong>
      </v-col>
    </v-footer>
  </v-app>
</template>

<script>
import About from "./components/About";
import ProvisionInstance from "./components/ProvisionInstance";
import SytemNotWorking from "./components/NotWorking.vue";
import Tour from "./components/Tour";

export default {
  name: "App",

  components: {
    ProvisionInstance,
    SytemNotWorking,
    About,
    Tour,
  },

  data: () => ({
    aboutDialog: false,
    systemNotWorking: false,
  }),
  created() {
    this.$gtag.pageview("/");
  },
  methods: {
    closeAboutDialog() {
      this.aboutDialog = false;
    },
    openAboutDialog() {
      this.aboutDialog = true;
      this.$gtag.event("click", {
        event_category: "Viewed about",
        event_label: "User viewed app about ",
        value: 13,
      });
    },
    darkMode() {
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark;
    },
    toggleTour() {
      this.$gtag.event("click", {
        event_category: "Viewed tour",
        event_label: "User viewed app tour ",
        value: 13,
      });
      this.$refs.tour.$tours["myTour"].start();
    },
  },
};
</script>
