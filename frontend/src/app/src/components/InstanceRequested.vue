<template>
  <v-dialog v-model="showDialog" persistent width="600">
    <v-card>
      <v-card-title style="background-color: #47889d; color: #ffffff">
        Your maps will be available soon
      </v-card-title>

      <v-card-text>
        Generating before-after maps will take a while. We don't want to keep
        you waiting on this site while it happens.
        <p></p>
        So, we will be sending you an email when your maps are ready with
        details on how you can access them. Thank you for using this service!
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="#47889d" class="text-white" @click="closeDialogHandler">
          OK
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  data: () => ({
    dialog: true,
  }),
  props: {
    showDialog: Boolean,
    closeDialogHandler: Function,
  },
};
</script>
