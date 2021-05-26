<template>
  <v-app>
    <v-app-bar app color="#2c3e50" dark>
      <img :src="'logo.png'" style="padding: 5px" />
      Provision before-after map with ease</v-app-bar
    >

    <v-main>
      <HelloWorld />
    </v-main>
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
