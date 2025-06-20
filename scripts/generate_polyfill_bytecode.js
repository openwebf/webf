/**
 * Only build libkraken.dylib for macOS
 */
const { series } = require('gulp');
const chalk = require('chalk');

require('./tasks');

// Run tasks
series(
  'generate-bindings-code',
  'compile-build-tools',
  'compile-polyfill',
  'generate-polyfill-typings',
  'generate-polyfill-bytecode',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
