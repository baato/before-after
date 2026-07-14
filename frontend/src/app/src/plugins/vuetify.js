import Vue from 'vue';
import Vuetify from 'vuetify/lib/framework';

Vue.use(Vuetify);

export default new Vuetify({
    theme: {
        options: { customProperties: true },
        themes: {
            light: {
                primary: '#47889d',   // Baato teal
                secondary: '#2c3e50',  // slate
                accent: '#6fb3c7',
                info: '#47889d',
                success: '#3fae7c',
                warning: '#f0c15a',
                error: '#e5734e',
            },
        },
        dark: false
    },
});
