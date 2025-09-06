#!/usr/bin/env node

/**
 * Script to copy Windows DLLs from bridge/build/windows/lib/bin to webf/windows directory
 * 
 * Usage:
 *   node scripts/copy_windows_dlls.js
 */

const fs = require('fs');
const path = require('path');

/**
 * Ensure directory exists, create if it doesn't
 * @param {string} dirPath - Directory path to create
 */
function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    console.log(`✅ Created directory: ${dirPath}`);
  }
}

/**
 * Copy file from source to destination
 * @param {string} source - Source file path
 * @param {string} destination - Destination file path
 */
function copyFile(source, destination) {
  try {
    // Ensure destination directory exists
    const destDir = path.dirname(destination);
    ensureDirectoryExists(destDir);
    
    // Copy the file
    fs.copyFileSync(source, destination);
    console.log(`✅ Copied: ${path.basename(source)} -> ${destination}`);
    return true;
  } catch (error) {
    console.error(`❌ Failed to copy ${source} to ${destination}: ${error.message}`);
    return false;
  }
}

/**
 * Get all DLL files from a directory
 * @param {string} dirPath - Directory path to search
 * @returns {string[]} Array of DLL file paths
 */
function getDllFiles(dirPath) {
  if (!fs.existsSync(dirPath)) {
    return [];
  }
  
  try {
    return fs.readdirSync(dirPath)
      .filter(file => file.toLowerCase().endsWith('.dll'))
      .map(file => path.join(dirPath, file));
  } catch (error) {
    console.error(`❌ Failed to read directory ${dirPath}: ${error.message}`);
    return [];
  }
}

/**
 * Copy Windows DLLs from bridge build directory to webf/windows
 */
function copyWindowsDlls() {
  console.log(`🔄 Copying Windows DLLs...`);
  
  const projectRoot = path.join(__dirname, '../');
  const bridgeBuildDir = path.join(projectRoot, 'bridge/build/windows/lib/bin');
  const webfWindowsDir = path.join(projectRoot, 'webf/windows');
  
  console.log(`📁 Source: ${bridgeBuildDir}`);
  console.log(`📁 Target: ${webfWindowsDir}`);
  
  // Check if source directory exists
  if (!fs.existsSync(bridgeBuildDir)) {
    console.error(`❌ Bridge build directory not found: ${bridgeBuildDir}`);
    console.error(`   Please run 'npm run build:bridge:windows' first to build the DLLs.`);
    process.exit(1);
  }
  
  // Get all DLL files from bridge build directory
  const dllFiles = getDllFiles(bridgeBuildDir);
  
  if (dllFiles.length === 0) {
    console.warn(`⚠️  No DLL files found in ${bridgeBuildDir}`);
    console.warn(`   Please ensure the Windows bridge has been built successfully.`);
    process.exit(1);
  }
  
  console.log(`📋 Found ${dllFiles.length} DLL files to copy:`);
  dllFiles.forEach(file => console.log(`   - ${path.basename(file)}`));
  
  // Ensure target directory exists
  ensureDirectoryExists(webfWindowsDir);
  
  // Copy each DLL file
  let successCount = 0;
  let failureCount = 0;
  
  dllFiles.forEach(dllFile => {
    const fileName = path.basename(dllFile);
    const targetPath = path.join(webfWindowsDir, fileName);
    
    if (copyFile(dllFile, targetPath)) {
      successCount++;
    } else {
      failureCount++;
    }
  });
  
  // Summary
  console.log('\n📊 Copy Summary:');
  console.log(`   ✅ Successfully copied: ${successCount} files`);
  if (failureCount > 0) {
    console.log(`   ❌ Failed to copy: ${failureCount} files`);
  }
  
  if (failureCount > 0) {
    console.error('\n❌ Some files failed to copy. Please check the errors above.');
    process.exit(1);
  } else {
    console.log('\n🎉 All Windows DLLs copied successfully!');
    console.log(`   Files are now available in: ${webfWindowsDir}`);
  }
}

// Main execution
function main() {
  copyWindowsDlls();
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { copyWindowsDlls };