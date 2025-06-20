#!/usr/bin/env node

/**
 * Test that polyfill types can be generated successfully
 */

const { execSync } = require('child_process');
const { existsSync, unlinkSync } = require('fs');
const { join } = require('path');
const chalk = require('chalk');

console.log(chalk.blue('Testing polyfill type generation...\n'));

const typingsDir = join(__dirname, '..');
const polyfillDtsPath = join(typingsDir, 'polyfill.d.ts');

// Remove existing polyfill.d.ts if it exists
if (existsSync(polyfillDtsPath)) {
  console.log(chalk.yellow('Removing existing polyfill.d.ts...'));
  unlinkSync(polyfillDtsPath);
}

// Generate polyfill types
console.log(chalk.yellow('Generating polyfill types...'));
try {
  execSync('npm run generate', { 
    cwd: typingsDir,
    stdio: 'inherit'
  });
  
  // Check if file was created
  if (existsSync(polyfillDtsPath)) {
    console.log(chalk.green('\n✅ Successfully generated polyfill.d.ts'));
    
    // Check file size
    const stats = require('fs').statSync(polyfillDtsPath);
    console.log(chalk.gray(`   File size: ${stats.size} bytes`));
    
    // Clean up
    console.log(chalk.yellow('\nCleaning up generated file...'));
    unlinkSync(polyfillDtsPath);
    console.log(chalk.gray('   Removed polyfill.d.ts'));
    
    console.log(chalk.green('\n✅ Type generation test passed!'));
  } else {
    throw new Error('polyfill.d.ts was not created');
  }
} catch (error) {
  console.error(chalk.red('\n❌ Type generation failed!'));
  console.error(error.message);
  process.exit(1);
}