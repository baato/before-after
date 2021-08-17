import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'
import VueTour from 'vue-tour'
import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'
import VueGtag from 'vue-gtag'

// import VueFbCustomerChat from 'vue-fb-customer-chat'
require('vue-tour/dist/vue-tour.css')


Vue.config.productionTip = false

// use vue-tour
Vue.use(VueTour)

// Configuration VueAnalytics
Vue.use(VueGtag, {
  config: { id: 'G-PN50G7DNWT' }
});

// // use FB messenger 
// Vue.use(VueFbCustomerChat, {
//   page_id: 106055731698744, //  change 'null' to your Facebook Page ID,
//   theme_color: '#47889D', // theme color in HEX
//   locale: 'en_US', // default 'en_US'
// })


new Vue({
  vuetify,
  render: h => h(App)
}).$mount('#app')
