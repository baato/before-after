<template>
  <div class="text-center">
    <v-dialog persistent scrollable v-model="aboutDialog" width="700">
      <v-card>
        <v-card-title class="headline lighten-2"> About </v-card-title>
        <v-divider></v-divider>

        <v-card-text style="font-size: 0.9rem">
          <br />
          <h2 style="font-size: 0.9rem; font-weight: 600">WHY?</h2>
          <p>
            Before - after maps are a good way to demonstrate an organization's
            mapping contribution over time. They provide a visual way to
            demonstrate concretely the roads, buildings, rivers, etc. they have
            contributed to OSM through their organized mapping efforts. However,
            the process is technical, and requires technical knowledge of things
            such as - but not limited to - Maperitive, OSM data formats, tile
            hosting, etc. In our eight years of experience working on the ground
            and interacting with multiple mapping organizations all over the
            world, we have learned that most organizations working in mapping
            lack the technical capacity to create in-house before-after maps as
            an output. A mapping team with in-house tech-teams are usually
            exception, as opposed to being the norm.
          </p>
          <p>
            With this application, we (<a href="https://baato.io">Baato</a>) we
            hope that generating such maps and showcasing impact will be a
            little more easier for the hundreds of small organizations and/or
            volunteer groups working in mapping.
          </p>

          <br />
          <h2 style="font-size: 0.9rem; font-weight: 600">WHO WE ARE?</h2>

          <p>
            <a href="https://baato.io">Baato</a> is is Nepal’s first cloud based
            location services provider. Through our pay-as-you-go REST API
            service, we provide the building blocks to add location features to
            your websites and mobile apps. It was built by a team of Nepali
            social enterpreneurs and OpenStreetMap advocates (read about our
            parent organization:
            <a href="http://kathmandulivinglabs.org">Kathmandu Living Labs</a>
            ) working to make map related services more contextual, and
            responsive to Nepal’s needs. You can read more about Baato's story
            <a
              href="https://baatomaps.medium.com/the-story-of-why-we-built-baato-f8666dded0af"
              >here</a
            >.
          </p>

          <br />
          <h2 style="font-size: 0.9rem; font-weight: 600">CONTRIBUTE</h2>
          <ul>
            <li>
              This is an open-source project. Interested in contributing? Feel
              free to browse through the code and submit your pull requests
              <a href="https://github.com/baato/before-after"
                >through the project's official repository</a
              >.
            </li>
            <li>
              We have also already started gathering feedback and feature
              requests. Feel free to open an issue or send us a feature request
              <a href="">through the project's official repository.</a>
            </li>
            <li>
              Ideally, we want this application to remain free fo anyone to use,
              forever. However, given the fact that this is currently a passion
              project, the servers we have deployed this tool on has a limited
              capacity, and cannot handle large amounts of data. Interested in
              giving this a new home? Reach out to us at
              <a href="mailto:support@baato.io">support@baato.io</a>.
            </li>
          </ul>

          <br />
          <h2 style="font-size: 0.9rem; font-weight: 600">THANK YOU</h2>
          <p>
            This application builds on the amazing work of the following
            entities:
          </p>
          <ul>
            <li>
              This app uses public version of Photon API
              <a href="https://github.com/komoot/photon">
                (https://github.com/komoot/photon)</a
              >
              to search for the places
            </li>
            <li>
              The OSM data is used from Geofabrik (<a
                href="https://download.geofabrik.de/"
                >https://download.geofabrik.de/</a
              >)
            </li>
            <li>
              The vector tiles are generated using Tilemaker (<a
                href="https://github.com/systemed/tilemaker"
                >https://github.com/systemed/tilemaker</a
              >)
            </li>
            <li>
              The map styles for rendering before-after maps are provided free
              of cost by Baato Maps
              <a href="https://baato.io">(https://baato.io)</a>
            </li>
          </ul>
        </v-card-text>

        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="closeAboutDialog"> Ok </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
export default {
  data() {
    return {
      dialog: false,
    };
  },
  props: {
    aboutDialog: Boolean,
    closeAboutDialog: Function,
  },
};
</script>