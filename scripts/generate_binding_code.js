/**
 * Only build libkraken.dylib for macOS
 */
const { series } = require('gulp');
const chalk = require('chalk');

require('./tasks');

// Run tasks
series(
  'merge-bridge-typings',
  'update-typings-version',
  'generate-bindings-code'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
