const path = require('path');
const { minimatch } = require('minimatch');
const glob = require('glob');
const fs = require('fs');
const JSON5 = require('json5');
const execSync = require('child_process').execSync;
const bableTransformSnapshotPlugin = require('./scripts/babel_transform_snapshot');

const context = path.join(__dirname);
const runtimePath = path.join(context, 'runtime');
const globalRuntimePath = path.join(context, 'runtime/global');
const resetRuntimePath = path.join(context, 'runtime/reset');
const reactRuntimePath = path.join(context, 'runtime/react');
const buildPath = path.join(context, '.specs');
const testPath = path.join(context, 'specs');
const snapshotPath = path.join(context, 'snapshots');
const specGroup = JSON5.parse(fs.readFileSync(path.join(__dirname, './spec_group.json5')));
const specsPath = path.join(context, 'specs');
const specModuleExtensions = /\.(?:[jt]sx?)$/i;

const isSpecModule = (filepath) => {
  if (!filepath || !specModuleExtensions.test(filepath)) return false;
  const relative = path.relative(specsPath, filepath);
  return relative === '' || (!relative.startsWith('..') && !path.isAbsolute(relative));
};

const tailwindSpecLoaders = (() => {
  try {
    const styleLoader = require.resolve('style-loader');
    const cssLoader = require.resolve('css-loader');
    const postcssLoader = require.resolve('postcss-loader');
    const tailwindcss = require('tailwindcss');
    let autoprefixer;
    try {
      autoprefixer = require('autoprefixer');
    } catch (err) {
      console.warn('[webpack] Autoprefixer not found, continuing without it for Tailwind CSS.');
    }

    const tailwindConfigCandidates = [
      path.join(context, 'tailwind.config.js'),
      path.join(context, 'tailwind.config.cjs'),
    ];
    const tailwindConfigPath = tailwindConfigCandidates.find(candidate => fs.existsSync(candidate));
    const tailwindPlugin = tailwindConfigPath ? tailwindcss({ config: tailwindConfigPath }) : tailwindcss;
    const postcssPlugins = [tailwindPlugin];
    if (autoprefixer) {
      postcssPlugins.push(autoprefixer);
    }

    return [
      styleLoader,
      {
        loader: cssLoader,
        options: {
          importLoaders: 1,
        },
      },
      {
        loader: postcssLoader,
        options: {
          postcssOptions: {
            plugins: postcssPlugins,
          },
        },
      },
    ];
  } catch (error) {
    console.warn('[webpack] Tailwind CSS support is disabled:', error.message);
    return null;
  }
})();

let coreSpecFiles = [];
let getSnapshotOption = () => ({ snapshotRoot: null, delayForSnapshot: false });

if (process.env.SPEC_SCOPE) {
  let specList = process.env.SPEC_SCOPE.split(',').map(spec => spec.trim());
  let targetSpecGroup = specGroup.filter((item) => specList.indexOf(item.name) != -1);
  if (targetSpecGroup.length > 0) {

    targetSpecGroup.forEach((group) => {
      group.specs.forEach(spec => {
        let files = glob.sync(spec, {
          cwd: context,
          ignore: ['node_modules/**'],
        }).map((file) => './' + file);
        coreSpecFiles = coreSpecFiles.concat(files);
      });
    })

    getSnapshotOption = (file) => {
      for (const group of targetSpecGroup) {
        if (group.specs.some(pattern => minimatch(file, pattern))) {
          return { snapshotRoot: group.snapshotRoot || null, delayForSnapshot: group.delayForSnapshot };
        }
      }
      return { snapshotRoot: null, delayForSnapshot: false };
    }
  } else {
    throw new Error('Unknown target spec scope: ' + process.env.SPEC_SCOPE);
  }
} else {
  specGroup.forEach((group) => {
    group.specs.forEach(spec => {
      let files = glob.sync(spec, {
        cwd: context,
        ignore: ['node_modules/**'],
      }).map((file) => './' + file);
      coreSpecFiles = coreSpecFiles.concat(files);
    });
  })
  if (process.env.WEBF_TEST_FILTER) {
    const filters = process.env.WEBF_TEST_FILTER.split('|');
    
    const originalFiles = [...coreSpecFiles];
    coreSpecFiles = coreSpecFiles.filter(name => {
      return filters.some(filter => name.includes(filter));
    });
    
    console.log(`Filtered spec files (${coreSpecFiles.length - 2} test files from ${originalFiles.length - 2} total):`); // -2 for runtime files
    coreSpecFiles.forEach(file => {
      if (!file.includes('runtime')) {
        console.log(`  - ${file}`);
      }
    });
  }
  getSnapshotOption = (file) => {
    for (const group of specGroup) {
      if (group.specs.some(pattern => minimatch(file, pattern))) {
        return { snapshotRoot: group.snapshotRoot || null, delayForSnapshot: group.delayForSnapshot };
      }
    }
    return { snapshotRoot: null, delayForSnapshot: false };
  }
}

const dartVersion = execSync('dart --version', { encoding: 'utf-8' });
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

// Add runtime helpers
coreSpecFiles.unshift(reactRuntimePath);
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
        oneOf: [
          tailwindSpecLoaders && {
            issuer: (file) => isSpecModule(file),
            use: tailwindSpecLoaders,
          },
          {
            use: require.resolve('stylesheet-loader'),
          },
        ].filter(Boolean),
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
              buildPath,
              getSnapshotOption: (filepath) => {
                const relativePath = path.relative(context, filepath);
                return getSnapshotOption(relativePath);
              }
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
