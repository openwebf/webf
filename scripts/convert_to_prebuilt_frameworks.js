#!/usr/bin/env node

/**
 * Script to convert WebF iOS from source compilation to using pre-built frameworks
 * This script:
 * 1. Copies pre-built frameworks from bridge/build/ios/framework to webf/ios/Frameworks
 * 2. Removes C++ source symlinks from webf/ios/Classes
 * 3. Updates webf.podspec to use vendored frameworks instead of compiling sources
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT_DIR = path.join(__dirname, '..');
const BRIDGE_FRAMEWORKS_DIR = path.join(ROOT_DIR, 'bridge/build/ios/framework');
const WEBF_IOS_DIR = path.join(ROOT_DIR, 'webf/ios');
const WEBF_FRAMEWORKS_DIR = path.join(WEBF_IOS_DIR, 'Frameworks');
const WEBF_CLASSES_DIR = path.join(WEBF_IOS_DIR, 'Classes');
const WEBF_PODSPEC_PATH = path.join(WEBF_IOS_DIR, 'webf.podspec');

// Directories to remove from Classes (C++ sources)
const DIRS_TO_REMOVE = ['bindings', 'code_gen', 'core', 'foundation', 'multiple_threading', 'third_party'];

// Files to keep in Classes (Objective-C plugin files)
const FILES_TO_KEEP = ['WebFPlugin.h', 'WebFPlugin.m'];

function ensureDirectory(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`Created directory: ${dir}`);
  }
}

function copyFrameworks() {
  console.log('Copying pre-built frameworks...');
  
  // Create Frameworks directory
  ensureDirectory(WEBF_FRAMEWORKS_DIR);
  
  // Copy webf_bridge.xcframework
  const webfBridgeSource = path.join(BRIDGE_FRAMEWORKS_DIR, 'webf_bridge.xcframework');
  const webfBridgeDest = path.join(WEBF_FRAMEWORKS_DIR, 'webf_bridge.xcframework');
  
  if (fs.existsSync(webfBridgeSource)) {
    execSync(`cp -R "${webfBridgeSource}" "${webfBridgeDest}"`);
    console.log('Copied webf_bridge.xcframework');
  } else {
    throw new Error(`webf_bridge.xcframework not found at ${webfBridgeSource}`);
  }
  
  // Copy quickjs.xcframework
  const quickjsSource = path.join(BRIDGE_FRAMEWORKS_DIR, 'quickjs.xcframework');
  const quickjsDest = path.join(WEBF_FRAMEWORKS_DIR, 'quickjs.xcframework');
  
  if (fs.existsSync(quickjsSource)) {
    execSync(`cp -R "${quickjsSource}" "${quickjsDest}"`);
    console.log('Copied quickjs.xcframework');
  } else {
    throw new Error(`quickjs.xcframework not found at ${quickjsSource}`);
  }
}

function removeSourceFiles() {
  console.log('Removing C++ source files from Classes directory...');
  
  // Remove C++ source directories
  DIRS_TO_REMOVE.forEach(dir => {
    const dirPath = path.join(WEBF_CLASSES_DIR, dir);
    if (fs.existsSync(dirPath)) {
      execSync(`rm -rf "${dirPath}"`);
      console.log(`Removed directory: ${dir}`);
    }
  });
  
  // Remove webf_bridge.cc if it exists
  const webfBridgeFile = path.join(WEBF_CLASSES_DIR, 'webf_bridge.cc');
  if (fs.existsSync(webfBridgeFile)) {
    fs.unlinkSync(webfBridgeFile);
    console.log('Removed webf_bridge.cc');
  }
}

function updatePodspec() {
  console.log('Updating webf.podspec...');
  
  let podspecContent = fs.readFileSync(WEBF_PODSPEC_PATH, 'utf8');
  
  // Replace source_files to only include ObjC plugin files
  podspecContent = podspecContent.replace(
    /s\.source_files = 'Classes\/\*\*\/\*'/,
    "s.source_files = 'Classes/WebFPlugin.h', 'Classes/WebFPlugin.m'"
  );
  
  // Add vendored_frameworks and resource after s.platform line
  const platformLineMatch = podspecContent.match(/s\.platform = :ios, '[\d.]+'\n/);
  if (platformLineMatch) {
    const insertPosition = platformLineMatch.index + platformLineMatch[0].length;
    const frameworksConfig = `  s.vendored_frameworks = ['Frameworks/*.xcframework']\n  s.resource = 'Frameworks/*.xcframework'\n`;
    podspecContent = podspecContent.slice(0, insertPosition) + frameworksConfig + podspecContent.slice(insertPosition);
  }
  
  // Remove C++ specific configurations that are no longer needed
  const cppConfigsToRemove = [
    /s\.libraries = 'c\+\+'\n/,
    /'CLANG_CXX_LANGUAGE_STANDARD' => 'c\+\+17',\n\s*/,
    /'CLANG_CXX_LIBRARY' => 'libc\+\+',\n\s*/,
    /'GCC_ENABLE_CPP_EXCEPTIONS' => 'NO',\n\s*/,
    /'GCC_ENABLE_CPP_RTTI' => 'YES',\n\s*/,
    /'OTHER_CPLUSPLUSFLAGS' => '[^']+',.*\n\s*/,
    /'LLVM_LTO' => 'YES',.*\n\s*/,
    /'GCC_OPTIMIZATION_LEVEL' => 's',.*\n\s*/,
  ];
  
  cppConfigsToRemove.forEach(regex => {
    podspecContent = podspecContent.replace(regex, '');
  });
  
  // Remove HEADER_SEARCH_PATHS as they're no longer needed
  podspecContent = podspecContent.replace(
    /'HEADER_SEARCH_PATHS' => '.*?' \+[\s\S]*?\n(?=\s*\})/,
    ''
  );
  
  // Clean up any multiple newlines
  podspecContent = podspecContent.replace(/\n{3,}/g, '\n\n');
  
  fs.writeFileSync(WEBF_PODSPEC_PATH, podspecContent);
  console.log('Updated webf.podspec');
}

function main() {
  try {
    console.log('Starting conversion to pre-built frameworks...\n');
    
    // Check if pre-built frameworks exist
    if (!fs.existsSync(BRIDGE_FRAMEWORKS_DIR)) {
      console.error(`Error: Pre-built frameworks not found at ${BRIDGE_FRAMEWORKS_DIR}`);
      console.error('Please build the frameworks first using: npm run build:bridge:ios:release');
      process.exit(1);
    }
    
    // Step 1: Copy frameworks
    copyFrameworks();
    
    // Step 2: Remove source files
    removeSourceFiles();
    
    // Step 3: Update podspec
    updatePodspec();
    
    console.log('\n✅ Successfully converted to pre-built frameworks!');
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