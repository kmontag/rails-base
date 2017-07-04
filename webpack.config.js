require('dotenv').config()
const production = (process.env.NODE_ENV === 'production');

const path = require('path');
const StatsPlugin = require('stats-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');

const devServerPort = parseInt(process.env.WEBPACK_DEV_SERVER_PORT);

var config = {
  entry: {
    application: path.join(__dirname, 'app', 'assets', 'javascripts', 'application.js'),
    style: path.join(__dirname, 'app', 'assets', 'stylesheets', 'application.css'),
  },

  output: {
    path: path.join(__dirname, 'public', 'webpack'),
    publicPath: (production ? '' : ('//localhost:' + devServerPort)) + '/webpack/',
    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  module: {
    rules: [
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            'css-loader',
          ],
        }),
      },
    ],
  },

  plugins: [
    // Copied in from the webpack-rails example config
    new StatsPlugin('manifest.json', {
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true,
    }),

    new ExtractTextPlugin({
      disable: !production,
      filename: '[name]-[contenthash].css',
    }),
  ],
};

if (production) {
  config.plugins.push(
    new UglifyJSPlugin()
  );
} else {
  config.devtool = 'cheap-module-eval-source-map';
  config.devServer = {
    disableHostCheck: true,
    host: '0.0.0.0',
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
}

module.exports = config;