<template>
  <v-app>
    <Tour ref="tour" />

    <v-app-bar app color="rgba(255,255,255,0.86)" height="92" elevation="0" class="brand-appbar">
      <img :src="'logo.png'" style="padding: 8px" height="88%" />
      <v-toolbar-title class="brand-title">
        <span class="brand-kicker">Generate</span>
        <span class="brand-name">Before&mdash;After Maps</span>
        <span class="brand-sub">with ease</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
    </v-app-bar>

    <About :aboutDialog="aboutDialog" :closeAboutDialog="closeAboutDialog" />
    <v-main class="brand-main">
      <SytemNotWorking v-if="systemNotWorking" :theme="$vuetify.theme.dark" />
      <ProvisionInstance v-if="!systemNotWorking" :theme="$vuetify.theme.dark" />
    </v-main>

    <v-footer padless class="brand-footer">
      <v-btn class="v-step-5" @click="openAboutDialog" text small
        >About <v-icon right small> mdi-information-outline </v-icon></v-btn
      >
      <span class="brand-footer-sep"> | </span>
      <v-btn text small @click="toggleTour"
        >How to use <v-icon right small> mdi-help-circle-outline </v-icon></v-btn
      >
      <v-col class="text-right">
        <strong class="brand-powered"
          >Powered by
          <a rel="noreferrer noopener" href="https://baato.io" target="_blank">
            <img
              src="https://sgp1.digitaloceanspaces.com/baatocdn/images/BaatoLogo.svg"
              alt="Baato"
              width="76px"
            /> </a
        ></strong>
      </v-col>
    </v-footer>
  </v-app>
</template>

<script>
import About from "./components/About";
import ProvisionInstance from "./components/ProvisionInstance";
import SytemNotWorking from "./components/NotWorking.vue";
import Tour from "./components/Tour";

export default {
  name: "App",

  components: {
    ProvisionInstance,
    SytemNotWorking,
    About,
    Tour,
  },

  data: () => ({
    aboutDialog: false,
    systemNotWorking: false,
  }),
  created() {
    this.$gtag.pageview("/");
  },
  methods: {
    closeAboutDialog() {
      this.aboutDialog = false;
    },
    openAboutDialog() {
      this.aboutDialog = true;
      this.$gtag.event("click", {
        event_category: "Viewed about",
        event_label: "User viewed app about ",
        value: 13,
      });
    },
    darkMode() {
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark;
    },
    toggleTour() {
      this.$gtag.event("click", {
        event_category: "Viewed tour",
        event_label: "User viewed app tour ",
        value: 13,
      });
      this.$refs.tour.$tours["myTour"].start();
    },
  },
};
</script>

<style>
/* ============ Baato premium brand system ============ */
:root {
  --brand-teal: #47889d;
  --brand-teal-deep: #356b7d;
  --brand-teal-light: #6fb3c7;
  --brand-slate: #2c3e50;
  --brand-slate-deep: #1f2d3a;
  --brand-paper: #eef2f4;
  --brand-gold: #f0c15a;
}

html, body { background: var(--brand-paper); }

.brand-appbar {
  border-bottom: 1px solid rgba(31, 45, 58, 0.08) !important;
  -webkit-backdrop-filter: blur(10px);
  backdrop-filter: blur(10px);
}

.brand-appbar .brand-title {
  display: flex;
  flex-direction: column;
  line-height: 1.05;
  overflow: visible;
}
.brand-kicker {
  font-family: "Roboto", sans-serif;
  font-size: 0.62rem;
  letter-spacing: 0.26em;
  text-transform: uppercase;
  font-weight: 600;
  color: var(--brand-teal);
}
.brand-name {
  font-family: "Space Grotesk", "Roboto", sans-serif;
  font-size: 1.18rem;
  font-weight: 600;
  letter-spacing: -0.01em;
  color: var(--brand-slate-deep);
}
.brand-sub {
  font-family: "Roboto", sans-serif;
  font-size: 0.6rem;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  font-weight: 500;
  color: #8a99a5;
}

.brand-main { background: var(--brand-paper); }

.brand-footer {
  background: #ffffff !important;
  border-top: 1px solid rgba(31, 45, 58, 0.08) !important;
}
.brand-footer-sep { color: #c4ccd2; }
.brand-powered { font-weight: 500; color: #7a8792; font-size: 0.7rem; display: inline-flex; align-items: center; gap: 6px; }
.brand-powered img { vertical-align: middle; }

/* --- Premium form panel --- */
.brand-panel {
  background: linear-gradient(165deg, #4f93a8 0%, #47889d 42%, #3c7789 100%);
  position: relative;
  overflow: hidden;
}
.brand-panel::before {
  content: "";
  position: absolute;
  inset: 0;
  background:
    radial-gradient(120% 80% at 100% 0%, rgba(255,255,255,0.10) 0%, rgba(255,255,255,0) 55%),
    radial-gradient(90% 60% at 0% 100%, rgba(0,0,0,0.10) 0%, rgba(0,0,0,0) 60%);
  pointer-events: none;
}
.brand-panel > * { position: relative; z-index: 1; }

.brand-section-label {
  color: rgba(255, 255, 255, 0.72);
  text-transform: uppercase;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.12em;
}
.brand-panel-title {
  font-family: "Space Grotesk", "Roboto", sans-serif;
  color: #fff;
  font-weight: 600;
  font-size: 1.15rem;
  letter-spacing: -0.01em;
}
.brand-panel-desc {
  color: rgba(255,255,255,0.72);
  font-size: 0.78rem;
  line-height: 1.4;
}

/* Location segmented control */
.loc-switch {
  display: flex;
  gap: 4px;
  padding: 4px;
  background: rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 12px;
}
.loc-opt {
  flex: 1 1 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  padding: 9px 10px;
  border: none;
  border-radius: 9px;
  background: transparent;
  color: rgba(255, 255, 255, 0.82);
  font-family: "Roboto", sans-serif;
  font-size: 0.82rem;
  font-weight: 600;
  letter-spacing: 0.01em;
  cursor: pointer;
  transition: background 0.16s ease, color 0.16s ease, box-shadow 0.16s ease;
}
.loc-opt:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #fff;
}
.loc-opt.active {
  background: #ffffff;
  color: var(--brand-teal-deep);
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.18);
}
.loc-opt .v-icon {
  color: inherit !important;
  font-size: 18px !important;
}

/* Generate button */
.brand-generate.v-btn {
  background: var(--brand-slate) !important;
  color: #fff !important;
  border-radius: 10px !important;
  letter-spacing: 0.08em;
  font-weight: 600;
  box-shadow: 0 8px 20px rgba(31, 45, 58, 0.32);
  transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
}
.brand-generate.v-btn:not(.v-btn--disabled):hover {
  background: var(--brand-slate-deep) !important;
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(31, 45, 58, 0.4);
}

/* Detected-region chip */
.brand-detect {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255,255,255,0.12);
  border: 1px solid rgba(255,255,255,0.22);
  border-radius: 10px;
  padding: 9px 12px;
  color: #fff;
  font-size: 0.8rem;
}
.brand-detect .mdi { color: #d6ecf1; }
.brand-detect.is-error {
  background: rgba(229,115,78,0.16);
  border-color: rgba(229,115,78,0.5);
}
.brand-hint {
  color: rgba(255,255,255,0.66);
  font-size: 0.72rem;
  line-height: 1.4;
}

/* Map framing */
.brand-map-wrap {
  position: relative;
  height: 100%;
  background: var(--brand-paper);
}
.brand-draw-hint {
  position: absolute;
  top: 14px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 5;
  background: rgba(31, 45, 58, 0.92);
  color: #fff;
  font-size: 0.78rem;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 999px;
  box-shadow: 0 6px 18px rgba(0,0,0,0.28);
  display: flex;
  align-items: center;
  gap: 8px;
}

/* Inputs a touch more premium */
.brand-panel .v-text-field--outlined fieldset,
.brand-panel .v-input--is-focused fieldset { border-color: rgba(255,255,255,0.4) !important; }
</style>
