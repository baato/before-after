<template>
  <v-dialog v-model="dialog" hide-overlay persistent width="300">
    <v-card color="#e67e22" dark>
      <v-card-text>
        Provisioning a new instance...
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
};
</script>