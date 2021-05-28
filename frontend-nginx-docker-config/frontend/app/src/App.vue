<template>
  <v-app>
    <v-app-bar app color="#2c3e50" dark>
      <img :src="'logo.png'" style="padding: 5px" />
      Provision before-after map with ease
      <v-spacer></v-spacer>
      <v-switch
        class="text-right"
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
      <v-col class="text-center">
        <strong
          >Powered by
          <a href="https://baato.io" target="_blank">baato.io</a></strong
        >
      </v-col>
      <v-btn @click="aboutDialog = true" text
        >About <v-icon right dark> mdi-information </v-icon></v-btn
      >
    </v-footer>
  </v-app>
</template>

<script>
import ProvisionInstance from "./components/ProvisionInstance";
import About from "./components/About";

export default {
  name: "App",

  components: {
    ProvisionInstance,
    About,
  },

  data: () => ({
    aboutDialog: false,
  }),
  methods: {
    closeAboutDialog() {
      this.aboutDialog = false;
    },
  },
};
</script>
