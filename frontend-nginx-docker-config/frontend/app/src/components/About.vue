<template>
  <div class="text-center">
    <v-dialog v-model="aboutDialog" width="500">
      <v-card>
        <v-card-title class="headline grey lighten-2">
          Before-After map generator
        </v-card-title>

        <v-card-text>
          Creating before-after maps is generally time consuming and also
          requires some technical knowledge. This platform tries to simply this
          process a bit.
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