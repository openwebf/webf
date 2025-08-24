const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { minimatch } = require('minimatch');
const glob = require('glob');
const fs = require('fs');
const JSON5 = require('json5');

const context = path.join(__dirname);
const integrationTestsPath = path.join(__dirname, '..');
const runtimePath = path.join(integrationTestsPath, 'runtime');
const globalRuntimePath = path.join(runtimePath, 'global.ts');
const resetRuntimePath = path.join(runtimePath, 'reset.ts');
const buildPath = path.join(context, 'dist');
const testPath = path.join(integrationTestsPath, 'specs');

// Load configurations
const specGroup = JSON5.parse(fs.readFileSync(path.join(integrationTestsPath, 'spec_group.json5')));
const chromeConfig = JSON5.parse(fs.readFileSync(path.join(__dirname, 'config.json5')));

let coreSpecFiles = [];

// Parse command line arguments or environment variables for scope
const testScope = process.env.TEST_SCOPE || process.env.SPEC_SCOPE || chromeConfig.defaultScope;

function getSpecFilesFromScope(scopeName) {
  const scope = chromeConfig.testScopes[scopeName];
  if (!scope) {
    throw new Error(`Unknown test scope: ${scopeName}. Available scopes: ${Object.keys(chromeConfig.testScopes).join(', ')}`);
  }
  
  let files = [];
  
  // If scope uses spec groups
  if (scope.groups && scope.groups !== '*') {
    const groupNames = Array.isArray(scope.groups) ? scope.groups : [scope.groups];
    const targetSpecGroups = specGroup.filter((item) => groupNames.includes(item.name));
    
    targetSpecGroups.forEach((group) => {
      group.specs.forEach(spec => {
        let groupFiles = glob.sync(spec, {
          cwd: integrationTestsPath,
          ignore: ['node_modules/**'],
        }).map((file) => path.join(integrationTestsPath, file));
        files = files.concat(groupFiles);
      });
    });
  }
  
  // Add files from include patterns
  if (scope.include) {
    scope.include.forEach(pattern => {
      let includeFiles = glob.sync(pattern, {
        cwd: integrationTestsPath,
        ignore: ['node_modules/**'],
      }).map((file) => path.join(integrationTestsPath, file));
      files = files.concat(includeFiles);
    });
  }
  
  // Remove duplicates
  files = [...new Set(files)];
 
  console.log(files);
  
  // Apply exclude patterns
  if (scope.exclude && scope.exclude.length > 0) {
    files = files.filter(file => {
      const relativePath = path.relative(integrationTestsPath, file);
      return !scope.exclude.some(excludePattern => 
        minimatch(relativePath, excludePattern)
      );
    });
  }
  
  return files;
}

// Get spec files based on scope
if (testScope === 'all') {
  // Include all spec groups
  specGroup.forEach((group) => {
    group.specs.forEach(spec => {
      let files = glob.sync(spec, {
        cwd: integrationTestsPath,
        ignore: ['node_modules/**'],
      }).map((file) => path.join(integrationTestsPath, file));
      coreSpecFiles = coreSpecFiles.concat(files);
    });
  });
} else {
  coreSpecFiles = getSpecFilesFromScope(testScope);
}

// Apply additional filtering if specified
if (process.env.WEBF_TEST_FILTER) {
  const filters = process.env.WEBF_TEST_FILTER.split('|');
  
  const originalFiles = [...coreSpecFiles];
  coreSpecFiles = coreSpecFiles.filter(name => {
    return filters.some(filter => name.includes(filter));
  });
  
  console.log(`Chrome Runner: Filtered spec files (${coreSpecFiles.length} test files from ${originalFiles.length} total):`);
  coreSpecFiles.forEach(file => {
    console.log(`  - ${path.relative(integrationTestsPath, file)}`);
  });
} else {
  console.log(`Chrome Runner: Loading test scope "${testScope}" (${coreSpecFiles.length} test files):`);
  if (coreSpecFiles.length <= 20) {
    // Show all files if reasonable number
    coreSpecFiles.forEach(file => {
      console.log(`  - ${path.relative(integrationTestsPath, file)}`);
    });
  } else {
    // Show summary for large numbers
    console.log(`  - ${coreSpecFiles.length} files in scope "${testScope}"`);
  }
}

// Add global runtime files
coreSpecFiles.unshift(globalRuntimePath);
coreSpecFiles.unshift(resetRuntimePath);

// Add Chrome-specific runtime
coreSpecFiles.unshift(path.join(__dirname, 'src', 'chrome-runtime.ts'));

console.log(coreSpecFiles);

module.exports = {
  context: context,
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
  devtool: 'source-map',
  entry: {
    tests: coreSpecFiles,
  },
  output: {
    path: buildPath,
    filename: '[name].bundle.js',
    clean: true,
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.ts', '.tsx'],
    alias: {
      '@runtime': runtimePath,
    }
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
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
                    chrome: 90,
                  },
                  useBuiltIns: 'usage',
                  corejs: 3,
                }
              ],
              [
                '@babel/preset-typescript',
                {
                  isTSX: true,
                  allExtensions: true
                }
              ]
            ]
          }
        }]
      }
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'),
      filename: 'index.html',
      inject: 'body',
      templateParameters: {
        testScope: testScope,
        testCount: coreSpecFiles.length - 3, // Subtract runtime files
        chromeConfig: JSON.stringify(chromeConfig, null, 2)
      }
    }),
  ],
  devServer: {
    static: buildPath,
    port: 8080,
    open: true,
    hot: false,
    liveReload: true,
  },
  stats: {
    colors: true,
    modules: false,
    entrypoints: false,
  },
};