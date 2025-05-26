#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Paths
const SOURCE_DIR = path.resolve(__dirname, '../bridge/build/android/lib');
const TARGET_DIR = path.resolve(__dirname, '../webf/android/jniLibs');
const BUILD_GRADLE = path.resolve(__dirname, '../webf/android/build.gradle');

// Ensure target directory exists
if (!fs.existsSync(TARGET_DIR)) {
  fs.mkdirSync(TARGET_DIR, { recursive: true });
}

// Copy the libraries from bridge/build/android to webf/android/jniLibs
function copyLibraries() {
  console.log('Copying libraries from bridge/build/android to webf/android/jniLibs...');
  
  // Check if source directory exists
  if (!fs.existsSync(SOURCE_DIR)) {
    console.error(`Source directory ${SOURCE_DIR} does not exist.`);
    console.log('Please run "npm run build:bridge:android" first.');
    process.exit(1);
  }
  
  // Get all architecture directories (arm64-v8a, armeabi-v7a, x86)
  const architectures = fs.readdirSync(SOURCE_DIR);
  
  // Copy each architecture directory
  architectures.forEach(arch => {
    const sourceArchDir = path.join(SOURCE_DIR, arch);
    const targetArchDir = path.join(TARGET_DIR, arch);
    
    // Create target architecture directory if it doesn't exist
    if (!fs.existsSync(targetArchDir)) {
      fs.mkdirSync(targetArchDir, { recursive: true });
    }
    
    // Copy all .so files
    const files = fs.readdirSync(sourceArchDir);
    files.forEach(file => {
      if (file.endsWith('.so')) {
        const sourceFile = path.join(sourceArchDir, file);
        const targetFile = path.join(targetArchDir, file);
        
        fs.copyFileSync(sourceFile, targetFile);
        console.log(`Copied ${arch}/${file}`);
      }
    });
  });
  
  console.log('Library copying completed.');
}

// Main function
function main() {
  try {
    copyLibraries();
    console.log('Android JNI libraries setup completed successfully!');
    console.log('\nNote: Make sure your build.gradle has the following configuration:');
    console.log('1. Comment out the externalNativeBuild section with cmake abiFilters');
    console.log('2. Ensure sourceSets section includes: jniLibs.srcDirs = [\'jniLibs\']');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();