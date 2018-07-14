const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const package_json = require('./package.json');

module.exports = {
  entry: './src/index.js',
  devtool: 'inline-source-map',
  devServer: {
    contentBase: './www'
  },
  plugins: [
    new CleanWebpackPlugin(['www']),
    new HtmlWebpackPlugin({
      title: package_json.displayName,
      template: 'src/index.html',
      filename: 'index.html',
      favicon: './icon.png'
    })
  ],
  output: {
    filename: 'main_bundle.js',
    path: path.resolve(__dirname, 'www')
  }
};
