const path = require('path');
const glob = require('glob');
const execSync = require('child_process').execSync;
const bableTransformSnapshotPlugin = require('./scripts/babel_transform_snapshot');

const context = path.join(__dirname);
const runtimePath = path.join(context, 'runtime');
const globalRuntimePath = path.join(context, 'runtime/global');
const resetRuntimePath = path.join(context, 'runtime/reset');
const buildPath = path.join(context, '.specs');
const testPath = path.join(context, 'specs');
const snapshotPath = path.join(context, 'snapshots');
const specGroup = require('./spec_group.json');

let coreSpecFiles = [];

//if (process.env.SPEC_SCOPE) {
//  let targetSpec = specGroup.find((item) => item.name === process.env.SPEC_SCOPE.trim());
//  if (targetSpec) {
//    let targetSpecCollection = targetSpec.specs;
//    targetSpecCollection.forEach(spec => {
//      let files = glob.sync(spec, {
//        cwd: context,
//        ignore: ['node_modules/**'],
//      }).map((file) => './' + file);
//      coreSpecFiles = coreSpecFiles.concat(files);
//    });
//  } else {
//    throw new Error('Unknown target spec scope: ' + process.env.SPEC_SCOPE);
//  }
//} else {
//  coreSpecFiles = glob.sync('specs/**/*.{js,jsx,ts,tsx,html,svg}', {
//    cwd: context,
//    ignore: ['node_modules/**'],
//  }).map((file) => './' + file);
//  if (process.env.WEBF_TEST_FILTER) {
//    coreSpecFiles = coreSpecFiles.filter(name => name.includes(process.env.WEBF_TEST_FILTER))
//  }
//}


const dartVersion = execSync('dart --version', {encoding: 'utf-8'});
const regExp = /Dart SDK version: (\d\.\d{1,3}\.\d{1,3}) /;
let versionNum = regExp.exec(dartVersion)[1];
const ignoreSpecsForOldFlutter = [
    './specs/dom/elements/pre.ts'
];
if (versionNum && parseFloat(versionNum) < 2.19) {
  coreSpecFiles = coreSpecFiles.filter(file => {
    return ignoreSpecsForOldFlutter.indexOf(file) === -1;
  })
}

// Add global vars
coreSpecFiles.unshift(globalRuntimePath);
coreSpecFiles.unshift(resetRuntimePath);

module.exports = {
  context: context,
  mode: 'development',
  devtool: false,
  entry: {
    core: coreSpecFiles,
  },
  output: {
    path: buildPath,
    filename: '[name].build.js',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.ts', '.tsx'],
    alias: {
      '@vanilla-jsx': runtimePath,
    }
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: require.resolve('stylesheet-loader'),
      },
      {
        test: /\.(html?)$/i,
        exclude: /node_modules/,
        use: [
          {
            loader: path.resolve('./scripts/html_loader'),
            options: {
              workspacePath: context,
              testPath,
              snapshotPath,
            }
          }
        ]
      },
      {
        test: /\.svg$/i,
        exclude: /node_modules/,
        use: [
          {
            loader: path.resolve('./scripts/svg_loader'),
            options: {
              workspacePath: context,
              testPath,
              snapshotPath,
            }
          }
        ]
      },
      {
        test: /\.(jsx?|tsx?)$/i,
        exclude: /node_modules/,
        use: [{
          loader: 'babel-loader',
          options: {
            plugins: [
              [
                bableTransformSnapshotPlugin,
                {
                  workspacePath: context,
                  testPath,
                  snapshotPath,
                }
              ]
            ],
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
        }, {
          loader: path.resolve('./scripts/quickjs_syntax_fix_loader'),
        }]
      }
    ],
  },
  devServer: {
    hot: false,
    inline: false,
  },
};
