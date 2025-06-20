#!/usr/bin/env node

/**
 * Test runner for WebF typings
 * This script compiles all TypeScript test files to verify the types are correct
 */

const { execSync } = require('child_process');
const { existsSync } = require('fs');
const { join } = require('path');
const chalk = require('chalk');

console.log(chalk.blue('🧪 Running WebF typings tests...\n'));

const testDir = __dirname;
const tscPath = join(testDir, '../node_modules/.bin/tsc');

// Check if TypeScript is installed
if (!existsSync(tscPath)) {
  console.log(chalk.yellow('TypeScript not found in typings package, trying global installation...'));
  try {
    execSync('tsc --version', { stdio: 'inherit' });
  } catch (error) {
    console.error(chalk.red('❌ TypeScript is not installed. Please run: npm install -D typescript'));
    process.exit(1);
  }
}

const tests = [
  {
    name: 'Global WebF API',
    file: 'global-webf-api.test.ts'
  },
  {
    name: 'DOM/BOM Typings',
    file: 'dom-bom-typings.test.ts'
  },
  {
    name: 'Module Imports',
    file: 'module-import.test.ts'
  }
];

let allPassed = true;

for (const test of tests) {
  console.log(chalk.yellow(`\nTesting ${test.name}...`));
  
  try {
    // Use the tsconfig.json for compilation
    const cmd = existsSync(tscPath) 
      ? `${tscPath} --project ${join(testDir, 'tsconfig.json')} --noEmit`
      : `tsc --project ${join(testDir, 'tsconfig.json')} --noEmit`;
    
    execSync(cmd, { 
      stdio: 'pipe',
      cwd: testDir 
    });
    
    console.log(chalk.green(`✅ ${test.name} - PASSED`));
  } catch (error) {
    console.log(chalk.red(`❌ ${test.name} - FAILED`));
    console.error(chalk.red(error.stdout?.toString() || error.message));
    allPassed = false;
  }
}

console.log('\n' + chalk.blue('─'.repeat(50)));

if (allPassed) {
  console.log(chalk.green('\n✅ All typings tests passed!'));
  console.log(chalk.gray('\nThe WebF typings are correctly configured and working.'));
} else {
  console.log(chalk.red('\n❌ Some tests failed!'));
  console.log(chalk.gray('\nPlease fix the type errors before publishing.'));
  process.exit(1);
}