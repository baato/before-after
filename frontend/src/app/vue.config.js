const Dotenv = require('dotenv-webpack');


module.exports = {
  transpileDependencies: [
    'vuetify'
  ],
  devServer: {
    disableHostCheck: true
  },
  configureWebpack: {
    plugins: [
      new Dotenv()
    ]
  }
}
