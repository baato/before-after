<template>
  <v-dialog v-model="showDialog" persistent width="600">
    <v-card>
      <v-card-title style="background-color: #47889d; color: #ffffff">
        Why do I need to enter my name and email?
      </v-card-title>

      <v-card-text>
        <br/>
        The process of generating before-after maps can take a while because of
        limited server resources and also that the request might be queued. And
        we don't want to keep you waiting on this site while that happens. So,
        when we have your email, we can notify whenever your maps are
        successfully generated.

        <p></p>
        We will be using the personal details solely for:
        <ul>
          <li>
            Notifying you when before-after maps are generated with details on
            how to access them
          </li>
          <li>
            Possibly to reach out to you for any feedback on improving the
            service
          </li>
          <li>Assist you if there any issues while using the service</li>
        </ul>
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
