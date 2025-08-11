#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Script to fix WebF library symlinks for integration tests

const INTEGRATION_TESTS_DIR = path.resolve(__dirname, '..');
const WEBF_ROOT = path.resolve(INTEGRATION_TESTS_DIR, '..');
const WEBF_PLUGIN_DIR = path.join(
  INTEGRATION_TESTS_DIR,
  'macos',
  'Flutter',
  'ephemeral',
  '.symlinks',
  'plugins',
  'webf',
  'macos'
);

console.log('Fixing WebF library symlinks...');
console.log(`Integration tests dir: ${INTEGRATION_TESTS_DIR}`);
console.log(`WebF root: ${WEBF_ROOT}`);
console.log(`WebF plugin dir: ${WEBF_PLUGIN_DIR}`);

// Check if the plugin directory exists
if (!fs.existsSync(WEBF_PLUGIN_DIR)) {
  console.error(`Error: WebF plugin directory not found at ${WEBF_PLUGIN_DIR}`);
  console.error("Please run 'flutter pub get' first");
  process.exit(1);
}

// Change to the plugin directory
process.chdir(WEBF_PLUGIN_DIR);

// Function to safely remove file or symlink
function removeIfExists(filename) {
  try {
    const stats = fs.lstatSync(filename);
    if (stats.isSymbolicLink() || stats.isFile()) {
      console.log(`Removing existing ${filename}...`);
      fs.unlinkSync(filename);
    }
  } catch (err) {
    // File doesn't exist, which is fine
  }
}

// Remove existing symlinks if they exist
removeIfExists('libwebf.dylib');
removeIfExists('libquickjs.dylib');

// Check if the libraries exist in the bridge build directory
const BRIDGE_LIB_DIR = path.join(WEBF_ROOT, 'bridge', 'build', 'macos', 'lib', 'x86_64');
const libwebfPath = path.join(BRIDGE_LIB_DIR, 'libwebf.dylib');
const libquickjsPath = path.join(BRIDGE_LIB_DIR, 'libquickjs.dylib');

if (!fs.existsSync(libwebfPath)) {
  console.error(`Error: libwebf.dylib not found at ${BRIDGE_LIB_DIR}`);
  console.error('Please build the bridge first with: npm run build:bridge:macos');
  process.exit(1);
}

if (!fs.existsSync(libquickjsPath)) {
  console.error(`Error: libquickjs.dylib not found at ${BRIDGE_LIB_DIR}`);
  console.error('Please build the bridge first with: npm run build:bridge:macos');
  process.exit(1);
}

// Create correct symlinks
console.log(`Creating symlink: libwebf.dylib -> ${libwebfPath}`);
fs.symlinkSync(libwebfPath, 'libwebf.dylib');

console.log(`Creating symlink: libquickjs.dylib -> ${libquickjsPath}`);
fs.symlinkSync(libquickjsPath, 'libquickjs.dylib');

// Verify symlinks
console.log('Verifying symlinks...');

function verifySymlink(filename) {
  try {
    const stats = fs.lstatSync(filename);
    if (stats.isSymbolicLink() && fs.existsSync(filename)) {
      console.log(`✓ ${filename} symlink is valid`);
      return true;
    }
  } catch (err) {
    // Error checking symlink
  }
  console.error(`✗ ${filename} symlink is broken`);
  return false;
}

const webfValid = verifySymlink('libwebf.dylib');
const quickjsValid = verifySymlink('libquickjs.dylib');

if (!webfValid || !quickjsValid) {
  process.exit(1);
}

console.log('Symlinks fixed successfully!');
console.log('');
console.log('You can now run: flutter build macos --debug');