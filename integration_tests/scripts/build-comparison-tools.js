#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const chalk = require('chalk');

function checkAndInstall(projectDir, projectName) {
  const nodeModulesPath = path.join(projectDir, 'node_modules');
  
  if (!fs.existsSync(nodeModulesPath)) {
    console.log(chalk.yellow(`Installing dependencies for ${projectName}...`));
    execSync('npm install', { cwd: projectDir, stdio: 'inherit' });
  } else {
    console.log(chalk.green(`✓ ${projectName} dependencies already installed`));
  }
}

function buildProject(projectDir, projectName) {
  console.log(chalk.blue(`Building ${projectName}...`));
  execSync('npm run build', { cwd: projectDir, stdio: 'inherit' });
  console.log(chalk.green(`✓ ${projectName} built successfully`));
}

// Main execution
try {
  const rootDir = path.join(__dirname, '..');
  const snapshotCompareDir = path.join(rootDir, 'snapshot-compare');
  const chromeRunnerDir = path.join(rootDir, 'chrome_runner');

  // Check and install dependencies
  checkAndInstall(snapshotCompareDir, 'Snapshot Compare');
  checkAndInstall(chromeRunnerDir, 'Chrome Runner');

  // Build projects
  buildProject(snapshotCompareDir, 'Snapshot Compare');
  buildProject(chromeRunnerDir, 'Chrome Runner');

  console.log(chalk.green('\n✨ All tools built successfully!'));
} catch (error) {
  console.error(chalk.red('Error building comparison tools:'), error.message);
  process.exit(1);
}