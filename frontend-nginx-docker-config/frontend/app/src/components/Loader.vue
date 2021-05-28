<template>
  <v-dialog v-model="showLoading" persistent width="400">
    <v-card color="#d35400" dark>
      <v-card-text>
        <span v-if="progressMessage">{{ progressMessage }}</span>
        <span v-if="!progressMessage"
          >Provisioning a new instance for {{ country.toUpperCase() }} with
          specified bounding box</span
        >
        <v-progress-linear
          indeterminate
          color="white"
          class="mb-0"
        ></v-progress-linear>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  data() {
    return {
      dialog: true,
    };
  },
  props: {
    country: String,
    showLoading: Boolean,
    progressMessage: String,
  },
};
</script>