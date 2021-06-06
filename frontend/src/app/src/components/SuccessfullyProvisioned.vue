<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="headline grey lighten-2">
        Instance successfully provisioned
      </v-card-title>

      <v-card-text>
        A new instance is successfuly provisioned at
        <a
          target="_blank"
          :href="'http://' + hostName + ':5678/provision/' + instanceName"
          >http://{{ hostName }}:5678/provision/{{ instanceName }}</a
        >
      </v-card-text>

      <v-divider></v-divider>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="#b7a75c" class="white--text" @click="dialog = false">
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