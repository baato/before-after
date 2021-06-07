<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="headline grey lighten-2">
        Map generated!
      </v-card-title>

      <v-card-text class="pt-4">
        Your map has been successfully generated at
        <a
          target="_blank"
          :href="'http://' + hostName + '/provision/' + instanceName"
          >http://{{ hostName }}/provision/{{ instanceName }}</a
        >
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="#47889d" class="white--text" @click="dialog = false">
          OK
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>


<script>
export default {
  data() {
    return {
      dialog: true,
      hostName: window.location.hostname,
    };
  },
  props: {
    instanceName: String,
  },
};
</script>