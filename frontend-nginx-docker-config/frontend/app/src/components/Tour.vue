<template>
  <v-tour :options="{ highlight: true }" name="myTour" :steps="steps"></v-tour>
</template>

<script>
export default {
  name: "my-tour",
  data() {
    return {
      steps: [
        {
          target: ".v-step-0", // We're using document.querySelector() under the hood
          header: {
            title: "Enter name for the instance",
          },
          content: `It can be something like <strong>Pokhara before-after map</strong>`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-1",
          header: {
            title: "Enter the bounding box for the area you are interested",
          },
          content:
            "You can use the icon to the right and get bounding box (bbox) from an application. You need to draw a rectangle around the area and copy/paste the <strong>Box</strong> value",
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-2", // We're using document.querySelector() under the hood
          header: {
            title: "Select before-year",
          },
          content: `This is the past year against which you want to compare with`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-3", // We're using document.querySelector() under the hood
          header: {
            title: "Get and enter the Baato access token",
          },
          content: `This is required to get the styles for the map. Register and login at Baato.io to get your token`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-4", // We're using document.querySelector() under the hood
          header: {
            title: "Select the map style",
          },
          content: `Select the map style that you prefer. Retro and Breeze are two beatifully crafted map styles`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-5", // We're using document.querySelector() under the hood
          header: {
            title: "Finally, provision this instance",
          },
          content: `It will take some minutes to provision the instance. Please have patience during that`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-6", // We're using document.querySelector() under the hood
          header: {
            title: "Choose your theme",
          },
          content: `You can choose a light theme or the dark one`,
          params: {
            placement: "bottom",
          },
        },
      ],
    };
  },
};
</script>