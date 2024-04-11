// config/webpack/custom.js

const webpack = require('webpack');

module.exports = {
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      popper: ['popper.js', 'default'],
    }),
  ],
};
