#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Path to the script files
const COPY_SCRIPT = path.resolve(__dirname, './build_android_jnilibs.js');
const PATCH_SCRIPT = path.resolve(__dirname, './patch_android_build_gradle.js');

// Execute a command and log the output
function runCommand(command, options = {}) {
  console.log(`Running: ${command}`);
  try {
    const output = execSync(command, {
      stdio: 'inherit',
      ...options
    });
    return output;
  } catch (error) {
    console.error(`Command failed: ${command}`);
    console.error(error.message);
    process.exit(1);
  }
}

// Main function
function main() {
  console.log('=== WebF Android Package Build Script ===');
  
  // Step 1: Run the copy script to copy JNI libraries
  console.log('\n=== Step 1: Copying JNI libraries ===');
  runCommand(`node ${COPY_SCRIPT}`);
  
  // Step 2: Run the patch script to update build.gradle
  console.log('\n=== Step 2: Patching build.gradle ===');
  runCommand(`node ${PATCH_SCRIPT}`);
  
  console.log('\n=== Build completed successfully! ===');
  console.log('The WebF Android package is now ready.');
}

main();