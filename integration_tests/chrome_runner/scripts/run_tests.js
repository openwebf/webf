#!/usr/bin/env node

const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const JSON5 = require('json5');

// Load configuration
const configPath = path.join(__dirname, '..', 'config.json5');
const chromeConfig = JSON5.parse(fs.readFileSync(configPath));

// Parse command line arguments
const args = process.argv.slice(2);
let testScope = chromeConfig.defaultScope;
let shouldWatch = false;
let shouldFilter = false;
let filterPattern = '';
let shouldListScopes = false;
let shouldBuild = true;

function showHelp() {
  console.log(`
WebF Chrome Test Runner

Usage:
  npm run test                                    Run tests with default scope
  npm run test -- --scope=<scope>                Run tests for specific scope  
  npm run test -- --filter=<pattern>             Filter tests by pattern
  npm run test -- --watch                        Run tests in watch mode
  npm run test -- --list-scopes                  List available test scopes
  npm run test -- --no-build                     Skip webpack build step

Available Test Scopes:
${Object.entries(chromeConfig.testScopes).map(([name, config]) => 
  `  ${name.padEnd(15)} - ${config.description}`
).join('\\n')}

Examples:
  npm run test -- --scope=css-text               Run CSS text tests
  npm run test -- --scope=dom-core               Run DOM core tests
  npm run test -- --scope=all                    Run all tests
  npm run test -- --filter=baseline              Run tests matching "baseline"
  npm run test -- --scope=css-text --watch       Run CSS text tests in watch mode

Environment Variables:
  TEST_SCOPE=<scope>                             Set test scope
  WEBF_TEST_FILTER=<pattern>                     Filter test files by pattern
  NODE_ENV=production                            Build in production mode
`);
}

function listScopes() {
  console.log('Available Test Scopes:');
  console.log('');
  Object.entries(chromeConfig.testScopes).forEach(([name, config]) => {
    console.log(`${name}:`);
    console.log(`  Description: ${config.description}`);
    if (config.groups && config.groups !== '*') {
      const groups = Array.isArray(config.groups) ? config.groups : [config.groups];
      console.log(`  Groups: ${groups.join(', ')}`);
    }
    if (config.include && config.include.length > 0) {
      console.log(`  Include patterns: ${config.include.slice(0, 3).join(', ')}${config.include.length > 3 ? '...' : ''}`);
    }
    if (config.exclude && config.exclude.length > 0) {
      console.log(`  Exclude patterns: ${config.exclude.join(', ')}`);
    }
    console.log('');
  });
}

// Parse arguments
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  
  if (arg === '--help' || arg === '-h') {
    showHelp();
    process.exit(0);
  } else if (arg === '--list-scopes') {
    shouldListScopes = true;
  } else if (arg === '--watch') {
    shouldWatch = true;
  } else if (arg === '--no-build') {
    shouldBuild = false;
  } else if (arg.startsWith('--scope=')) {
    testScope = arg.substring('--scope='.length);
  } else if (arg.startsWith('--filter=')) {
    shouldFilter = true;
    filterPattern = arg.substring('--filter='.length);
  } else if (arg === '--filter') {
    shouldFilter = true;
    filterPattern = args[i + 1] || '';
    i++; // Skip next argument
  }
}

if (shouldListScopes) {
  listScopes();
  process.exit(0);
}

// Validate test scope
if (!chromeConfig.testScopes[testScope]) {
  console.error(`Error: Unknown test scope "${testScope}"`);
  console.error(`Available scopes: ${Object.keys(chromeConfig.testScopes).join(', ')}`);
  console.error('Use --list-scopes to see detailed information about each scope.');
  process.exit(1);
}

// Set environment variables
process.env.TEST_SCOPE = testScope;
if (shouldFilter && filterPattern) {
  process.env.WEBF_TEST_FILTER = filterPattern;
}

console.log(`🧪 WebF Chrome Test Runner`);
console.log(`📋 Test Scope: ${testScope} (${chromeConfig.testScopes[testScope].description})`);
if (shouldFilter && filterPattern) {
  console.log(`🔍 Filter: ${filterPattern}`);
}
if (shouldWatch) {
  console.log(`👀 Watch Mode: Enabled`);
}
console.log('');

function buildTests() {
  return new Promise((resolve, reject) => {
    console.log('📦 Building test bundle...');
    
    const buildProcess = spawn('npm', ['run', 'build'], {
      stdio: 'inherit',
      env: { ...process.env }
    });
    
    buildProcess.on('close', (code) => {
      if (code === 0) {
        console.log('✅ Build completed successfully');
        resolve();
      } else {
        console.error(`❌ Build failed with exit code ${code}`);
        reject(new Error(`Build failed with exit code ${code}`));
      }
    });
    
    buildProcess.on('error', (error) => {
      console.error('❌ Build process error:', error);
      reject(error);
    });
  });
}

function serveTests() {
  return new Promise((resolve, reject) => {
    console.log('🚀 Starting test server...');
    
    const serverProcess = spawn('npm', ['run', 'serve'], {
      stdio: 'inherit',
      env: { ...process.env }
    });
    
    // Give server time to start
    setTimeout(() => {
      console.log('🌐 Test server running at http://localhost:8080');
      console.log('🧪 Open the URL in Chrome to run tests');
      resolve(serverProcess);
    }, 2000);
    
    serverProcess.on('error', (error) => {
      console.error('❌ Server process error:', error);
      reject(error);
    });
  });
}

async function runTests() {
  try {
    if (shouldBuild) {
      await buildTests();
    }
    
    if (shouldWatch) {
      console.log('👀 Starting development server with watch mode...');
      const devServerProcess = spawn('npx', ['webpack', 'serve', '--config', 'webpack.config.js'], {
        stdio: 'inherit',
        env: { ...process.env }
      });
      
      // Handle process termination
      process.on('SIGINT', () => {
        console.log('\\n🛑 Stopping development server...');
        devServerProcess.kill();
        process.exit(0);
      });
      
    } else {
      const serverProcess = await serveTests();
      
      // Handle process termination
      process.on('SIGINT', () => {
        console.log('\\n🛑 Stopping test server...');
        serverProcess.kill();
        process.exit(0);
      });
    }
    
  } catch (error) {
    console.error('❌ Failed to run tests:', error.message);
    process.exit(1);
  }
}

// Check if required dependencies are installed
try {
  require.resolve('webpack');
  require.resolve('express');
} catch (error) {
  console.error('❌ Missing dependencies. Please run: npm install');
  process.exit(1);
}

runTests();