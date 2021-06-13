<template>
  <v-dialog persistent v-model="dialog" width="500">
    <v-card>
      <v-card-title class="headline grey lighten-2">
        Before-after maps generated!
      </v-card-title>

      <v-card-text class="pt-4">
        Before-after maps has been successfully generated at
        <a
          target="_blank"
          :href="protocol + '//' + hostName + '/provision/' + instanceName"
          >{{ protocol }}//{{ hostName }}/provision/{{ instanceName }}</a
        >
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="#47889d" class="white--text" @click="dialog = false">
          Close Dialog
        </v-btn>
        <v-btn
          color="#47889d"
          class="white--text"
          @click="closeDialogAndOpenLink"
        >
          Open link
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
      protocol: window.location.protocol,
    };
  },
  methods: {
    closeDialogAndOpenLink() {
      window.open(
        `${window.location.protocol}//${this.hostName}/provision/${this.instanceName}`,
        "_blank"
      );
    },
  },
  props: {
    instanceName: String,
  },
};
</script>