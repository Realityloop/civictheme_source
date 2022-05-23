const path = require('path');
const glob = require('glob');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const magicImporter = require('node-sass-magic-importer');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: (function (pattern) {
    // Scan for all JS.
    const entries = glob.sync(pattern);
    // Add explicitly imported (S)CSS entries from css.js.
    entries.push(path.resolve(__dirname, 'css.js'));
    entries.push(path.resolve(__dirname, 'assets.js'));
    return entries;
  }('../components/**/!(*.stories|*.component|*.min|*.test|*.utils).js')),
  output: {
    filename: 'civictheme.js',
    path: path.resolve(__dirname, '../dist'),
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '../dist/civictheme.css',
    }),
    new CleanWebpackPlugin(),
  ],
  module: {
    rules: [
      // JS Loader.
      {
        test: /^(?!.*\.(stories|component)\.js$).*\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      },
      // CSS Loader.
      {
        test: /\.s[ac]ss$/i,
        exclude: /node_modules/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              sourceMap: true,
              url: false,
            },
          },
          {
            loader: 'sass-loader',
            options: {
              // Inject path to assets so that it does not have to be provided
              // in variables.base.scss
              additionalData: "$civictheme-assets-directory: './assets/';",
              sourceMap: true,
              sassOptions: {
                importer: magicImporter(),
              },
            },
          },
        ],
      },
      // Load all assets files to be available for distributions and Storybook.
      {
        test: /\.(jpe?g|png|svg|ico|woff|woff2|ttf|eot|webm|avi|mp4)$/,
        use: {
          loader: 'file-loader',
          options: {
            name: '[name].[ext]',
            // Preserve relative path.
            outputPath: (url, resourcePath, context) => path.relative(context, resourcePath),
          },
        },
      },
      // Twig loader.
      {
        test: /\.twig$/,
        use: [{
          loader: 'twigjs-loader',
        }],
      },
      // Wrap JS with DOMContentLoaded.
      {
        test: /components\/[^/]+\/(?!.*\.(stories|component|utils)\.js$).*\.js$/,
        exclude: /(node_modules|webpack|themejs\.js|css\.js)/,
        use: [{
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env',
            ],
            plugins: [
              './node_modules/babel-plugin-syntax-dynamic-import',
              './webpack/babel-plugin-script-wrapper.js',
            ],
          },
        }],
      },
    ],
  },
  resolve: {
    alias: {
      '@base': path.resolve(__dirname, '../components/00-base'),
      '@atoms': path.resolve(__dirname, '../components/01-atoms'),
      '@molecules': path.resolve(__dirname, '../components/02-molecules'),
      '@organisms': path.resolve(__dirname, '../components/03-organisms'),
      '@templates': path.resolve(__dirname, '../components/04-templates'),
      '@pages': path.resolve(__dirname, '../components/05-pages'),
    },
  },
  stats: {
    errorDetails: true,
  },
};