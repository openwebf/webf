const path = require('path');
const glob = require('glob');
const context = path.join(__dirname);
const buildPath = path.join(context, '.specs');
const testPath = path.join(context, 'specs');

let testFiles = glob.sync('specs/**/*.{js,jsx,ts,tsx,html}', {
  cwd: context,
  ignore: ['node_modules/**'],
}).map((file) => './' + file).filter(name => name.indexOf('plugins') < 0)


module.exports = {
  context: context,
  mode: 'development',
  devtool: false,
  entry: testFiles,
  target: 'node',
  output: {
    path: buildPath,
    filename: 'bundle.build.js',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.ts', '.tsx']
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: require.resolve('stylesheet-loader'),
      },
      {
        test: /\.(jsx?|tsx?)$/i,
        exclude: /node_modules/,
        use: [{
          loader: 'babel-loader',
          options: {
            presets: [
              [
                '@babel/preset-env',
                {
                  targets: {
                    chrome: 76,
                  },
                  useBuiltIns: 'usage',
                  corejs: 3,
                }],
              [
                '@babel/preset-typescript',
                {
                  isTSX: true,
                  allExtensions: true
                }
              ],
              [
                '@babel/preset-react',
                {
                  throwIfNamespace: false,
                  runtime: 'automatic',
                  importSource: '@vanilla-jsx'
                }
              ]
            ]
          }
        }]
      }
    ],
  },
  devServer: {
    hot: false,
    inline: false,
  },
};
