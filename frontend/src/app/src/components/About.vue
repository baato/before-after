<template>
  <div class="text-center">
    <v-dialog v-model="aboutDialog" width="500">
      <v-card>
        <v-card-title class="headline grey lighten-2"> About </v-card-title>

        <v-card-text>
          Creating before-after maps is generally time consuming and also
          requires some form of technical knowledge. This platform tries to
          simply this process a bit.

          <p />
          This app uses public version of Photon API (<a
            href="https://github.com/komoot/photon"
          >
            https://github.com/komoot/photon </a
          >) to search for the places.

          <p />
          The OSM data is used from Geofabrik (<a
            href="https://download.geofabrik.de/"
            >https://download.geofabrik.de/</a
          >)

          <p />
          The map styles are provided by baato.io (<a href="https://baato.io"
            >https://baato.io</a
          >)
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="closeAboutDialog"> Ok </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
export default {
  data() {
    return {
      dialog: false,
    };
  },
  props: {
    aboutDialog: Boolean,
    closeAboutDialog: Function,
  },
};
</script>