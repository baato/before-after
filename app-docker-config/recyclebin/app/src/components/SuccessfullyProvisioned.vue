<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="headline green lighten-2">
        Instance successfully provisioned
      </v-card-title>

      <v-card-text>
        A new instance is successfuly provisioned at
        <a
          target="_blank"
          :href="'http://localhost:5678/provision/' + instanceName"
          >http://localhost:5678/provision/{{ instanceName }}</a
        >
      </v-card-text>

      <v-divider></v-divider>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="primary" text @click="dialog = false"> OK </v-btn>
      </v-card-actions>
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
    instanceName: String,
  },
};
</script>