#!/usr/bin/env node

/**
 * Script to revert WebF iOS from pre-built frameworks back to source compilation
 * This script:
 * 1. Removes Frameworks directory
 * 2. Restores webf.podspec to original state
 * 3. Restores C++ source symlinks (requires git checkout)
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT_DIR = path.join(__dirname, '..');
const WEBF_IOS_DIR = path.join(ROOT_DIR, 'webf/ios');
const WEBF_FRAMEWORKS_DIR = path.join(WEBF_IOS_DIR, 'Frameworks');
const WEBF_PODSPEC_PATH = path.join(WEBF_IOS_DIR, 'webf.podspec');

function removeFrameworks() {
  console.log('Removing Frameworks directory...');
  
  if (fs.existsSync(WEBF_FRAMEWORKS_DIR)) {
    execSync(`rm -rf "${WEBF_FRAMEWORKS_DIR}"`);
    console.log('Removed Frameworks directory');
  }
}

function restorePodspecAndSources() {
  console.log('Restoring webf.podspec and source files from git...');
  
  try {
    // Check if there are uncommitted changes to webf.podspec
    const gitStatus = execSync('git status --porcelain webf/ios/webf.podspec', { cwd: ROOT_DIR }).toString();
    
    if (gitStatus.trim()) {
      // Restore webf.podspec from git
      execSync('git checkout webf/ios/webf.podspec', { cwd: ROOT_DIR });
      console.log('Restored webf.podspec from git');
    }
    
    // Restore Classes directory from git
    execSync('git checkout webf/ios/Classes', { cwd: ROOT_DIR });
    console.log('Restored Classes directory from git');
    
  } catch (error) {
    console.error('Warning: Could not restore from git. You may need to manually restore the files.');
    console.error('Error:', error.message);
  }
}

function main() {
  try {
    console.log('Starting reversion to source compilation...\n');
    
    // Step 1: Remove frameworks
    removeFrameworks();
    
    // Step 2: Restore podspec and sources
    restorePodspecAndSources();
    
    console.log('\n✅ Successfully reverted to source compilation!');
    console.log('\nNext steps:');
    console.log('1. cd webf/example/ios');
    console.log('2. pod install');
    console.log('3. Build and run the iOS app');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

// Run the script
main();