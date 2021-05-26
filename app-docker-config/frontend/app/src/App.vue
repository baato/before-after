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

    <v-main>
      <HelloWorld />
    </v-main>
    <v-footer padless>
      <v-col class="text-center" cols="12">
        <strong
          >Powered by
          <a href="https://baato.io" target="_blank">baato.io</a></strong
        >
      </v-col>
    </v-footer>
  </v-app>
</template>

<script>
import HelloWorld from "./components/HelloWorld";

export default {
  name: "App",

  components: {
    HelloWorld,
  },

  data: () => ({
    //
  }),
};
</script>
