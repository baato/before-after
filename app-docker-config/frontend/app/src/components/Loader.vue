<template>
  <v-dialog v-model="dialog" persistent width="400">
    <v-card color="#d35400" dark>
      <v-card-text>
        Provisioning a new instance for {{ country.toUpperCase() }} with
        specified bounding box
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
  },
};
</script>