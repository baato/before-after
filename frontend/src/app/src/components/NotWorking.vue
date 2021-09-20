<template>
  <v-dialog persistent v-model="dialog" color="green" width="500">
    <v-card>
      <v-card-title style="background-color: #47889d; color: #ffffff">
        The service is temporarily unavailable!
      </v-card-title>

      <v-card-text class="pt-4">
        <p>
          We are currently having some issues with the before-after maps
          provisioning system. Our technical team is working on it and it should
          be resolved soon.
        </p>

        <p>Please do come back later. Sorry for the inconvenience.</p>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
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
  methods: {},
  props: {
    instanceName: String,
  },
};
</script>