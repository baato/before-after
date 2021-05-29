import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'
import VueTour from 'vue-tour'

Vue.config.productionTip = false

// use vue-tour
require('vue-tour/dist/vue-tour.css')
Vue.use(VueTour)


new Vue({
  vuetify,
  render: h => h(App)
}).$mount('#app')
