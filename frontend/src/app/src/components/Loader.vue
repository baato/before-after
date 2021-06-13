<template>
  <v-dialog v-model="showLoading" persistent width="400">
    <v-card color="#47889d" class="pt-2" dark>
      <v-card-text>
        <span v-if="progressMessage">{{ progressMessage }}</span>
        <span v-if="!progressMessage && country">
          Processing request to generate before-after maps
        </span>
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