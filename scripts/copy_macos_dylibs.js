#!/usr/bin/env node

/**
 * Standalone script to copy macOS dynamic libraries to webf/macos folder
 * 
 * Usage:
 *   node scripts/copy_macos_dylibs.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const fs = require('fs');
const path = require('path');

/**
 * Copy a file from source to destination
 * @param {string} source - Source file path
 * @param {string} destination - Destination file path
 */
function copyFile(source, destination) {
  console.log(`Copying file: ${source} -> ${destination}`);
  
  // Ensure the destination directory exists
  const destDir = path.dirname(destination);
  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }
  
  // Delete the destination file if it exists
  if (fs.existsSync(destination)) {
    fs.unlinkSync(destination);
    console.log(`Deleted existing file: ${destination}`);
  }
  
  // Read and write the file
  const buffer = fs.readFileSync(source);
  fs.writeFileSync(destination, buffer);
}

/**
 * Copy macOS dynamic libraries to webf/macos folder
 * @param {string} webfDir - Path to the WebF package directory
 */
function copyMacOSDynamicLibraries(webfDir) {
  console.log('🔄 Copying macOS dynamic libraries...');
  
  try {
    const macosDir = path.join(webfDir, 'macos');
    const sourceDylibDir = path.join(__dirname, '../bridge/build/macos/lib/x86_64/');
    
    console.log(`📁 Source: ${sourceDylibDir}`);
    console.log(`📁 Target: ${macosDir}`);
    
    // Check if source directory exists
    if (!fs.existsSync(sourceDylibDir)) {
      console.error(`❌ Source directory not found: ${sourceDylibDir}`);
      console.error(`   Please run 'npm run build:bridge:macos' first to build the libraries.`);
      process.exit(1);
    }
    
    // Ensure target directory exists
    if (!fs.existsSync(macosDir)) {
      fs.mkdirSync(macosDir, { recursive: true });
      console.log(`✅ Created directory: ${macosDir}`);
    }
    
    // Copy the dynamic libraries
    const libraries = ['libwebf.dylib', 'libquickjs.dylib'];
    let successCount = 0;
    let failureCount = 0;
    
    for (const lib of libraries) {
      const sourceLib = path.join(sourceDylibDir, lib);
      const destLib = path.join(macosDir, lib);
      
      if (fs.existsSync(sourceLib)) {
        copyFile(sourceLib, destLib);
        console.log(`✅ Copied: ${lib}`);
        successCount++;
      } else {
        console.error(`❌ Could not find ${sourceLib}`);
        failureCount++;
      }
    }
    
    // Summary
    console.log('\n📊 Copy Summary:');
    console.log(`   ✅ Successfully copied: ${successCount} libraries`);
    if (failureCount > 0) {
      console.log(`   ❌ Failed to copy: ${failureCount} libraries`);
    }
    
    if (failureCount > 0) {
      console.error('\n❌ Some libraries failed to copy. Please check the errors above.');
      process.exit(1);
    } else {
      console.log('\n🎉 All macOS dynamic libraries copied successfully!');
      console.log(`   Files are now available in: ${macosDir}`);
    }
    
  } catch (error) {
    console.error('❌ Error copying macOS dynamic libraries:', error.message);
    process.exit(1);
  }
}

// Main execution
function main() {
  // Parse command line arguments
  const args = process.argv.slice(2);
  
  // Default to 'webf' directory if no argument provided
  const webfDir = args[0] || path.join(__dirname, '../webf');
  
  // Convert to absolute path
  const absoluteWebfDir = path.resolve(webfDir);
  
  console.log(`Using WebF directory: ${absoluteWebfDir}`);
  
  // Check if the directory exists
  if (!fs.existsSync(absoluteWebfDir)) {
    console.error(`Error: WebF directory does not exist: ${absoluteWebfDir}`);
    process.exit(1);
  }
  
  // Copy the macOS dynamic libraries
  copyMacOSDynamicLibraries(absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { copyMacOSDynamicLibraries };