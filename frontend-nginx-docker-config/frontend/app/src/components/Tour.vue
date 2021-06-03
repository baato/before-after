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
          target: ".v-step-0",
          header: {
            title: "Search for the place name",
          },
          content: `It can be something like <strong>Pokhara</strong>`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-1",
          header: {
            title: "Enter the name for the before-after map",
          },
          content: `It can be something like <strong>Pokhara 2019 vs Present</strong>`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-2",
          header: {
            title: "Select before-year",
          },
          content: `This is the past year against which you want to compare with`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-3",
          header: {
            title: "Finally, provision this instance",
          },
          content: `It will take some minutes to provision the instance. Please have patience during that`,
          params: {
            placement: "right",
          },
        },
        {
          target: ".v-step-4",
          header: {
            title: "Choose your theme",
          },
          content: `You can choose a light theme or the dark one`,
          params: {
            placement: "bottom",
          },
        },
        {
          target: ".v-step-5",
          header: {
            title: "Learn more about this application",
          },
          content: `Here you can learn more about the application and things that power this`,
          params: {
            placement: "bottom",
          },
        },
      ],
    };
  },
};
</script>