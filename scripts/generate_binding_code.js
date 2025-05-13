/**
 * Only build libkraken.dylib for macOS
 */
const { series } = require('gulp');
const chalk = require('chalk');

require('./tasks');

// Run tasks
series(
  'update-typings-version',
  'generate-typings',
  'generate-bindings-code',
  'compile-polyfill',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
