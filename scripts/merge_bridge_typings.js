/**
 * Merge bridge/core TypeScript definitions into webf.d.ts
 */
const { series } = require('gulp');
const chalk = require('chalk');

require('./tasks');

// Run task
series(
  'merge-bridge-typings'
)((err) => {
  if (err) {
    console.log(err);
    process.exit(1);
  } else {
    console.log(chalk.green('Success.'));
  }
});