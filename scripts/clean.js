/**
 * Only build libkraken.dylib for macOS
 */
const { series } = require('gulp');
const chalk = require('chalk');

require('./tasks');

// Run tasks
series(
  'android-so-clean',
  'ios-framework-clean',
  'macos-dylib-clean',
  'android-so-clean',
  'clean',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
