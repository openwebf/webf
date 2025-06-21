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
    console.error(chalk.red('Error occurred during code generation:'));
    if (err instanceof Error) {
      console.error(chalk.red(err.message));
      if (err.stack) {
        console.error(chalk.gray(err.stack));
      }
    } else {
      console.error(chalk.red(err));
    }
    process.exit(1);
  } else {
    console.log(chalk.green('Success.'));
  }
});
