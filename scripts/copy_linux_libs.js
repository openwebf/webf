#!/usr/bin/env node

/**
 * Script to copy Linux shared libraries from bridge/build/linux/lib to webf/linux directory
 * Note: QuickJS is statically linked into libwebf.so
 * 
 * Usage:
 *   node scripts/copy_linux_libs.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

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
 * @returns {boolean} True if successful
 */
function copyFile(source, destination) {
  try {
    // Ensure destination directory exists
    const destDir = path.dirname(destination);
    ensureDirectoryExists(destDir);
    
    // Remove existing file or symlink if present
    if (fs.existsSync(destination)) {
      const stats = fs.lstatSync(destination);
      if (stats.isSymbolicLink()) {
        console.log(`   Removing existing symlink: ${path.basename(destination)}`);
      }
      fs.unlinkSync(destination);
    }
    
    // Copy the file
    const buffer = fs.readFileSync(source);
    fs.writeFileSync(destination, buffer);
    
    // Get file size for display
    const stats = fs.statSync(destination);
    const sizeMB = (stats.size / (1024 * 1024)).toFixed(2);
    console.log(`✅ Copied: ${path.basename(source)} (${sizeMB} MB)`);
    
    return true;
  } catch (error) {
    console.error(`❌ Failed to copy ${source}: ${error.message}`);
    return false;
  }
}

/**
 * Check if running on Linux or in a Linux-compatible environment
 * @returns {boolean} True if Linux or WSL
 */
function isLinuxCompatible() {
  const platform = process.platform;
  if (platform === 'linux') {
    return true;
  }
  
  // Check for WSL
  if (platform === 'win32') {
    try {
      const output = execSync('wsl --status', { encoding: 'utf8' });
      if (output.includes('Default Distribution')) {
        console.log('🐧 WSL detected, proceeding...');
        return true;
      }
    } catch (error) {
      // WSL not available
    }
  }
  
  return false;
}

/**
 * Check if a file is an ELF binary (Linux executable/library)
 * @param {string} filePath - Path to the file
 * @returns {boolean} True if ELF binary
 */
function isElfBinary(filePath) {
  try {
    const fd = fs.openSync(filePath, 'r');
    const buffer = Buffer.alloc(4);
    fs.readSync(fd, buffer, 0, 4, 0);
    fs.closeSync(fd);
    
    // ELF magic number: 0x7F 'E' 'L' 'F'
    return buffer[0] === 0x7F && 
           buffer[1] === 0x45 && 
           buffer[2] === 0x4C && 
           buffer[3] === 0x46;
  } catch (error) {
    return false;
  }
}

/**
 * Copy Linux shared libraries to webf/linux folder
 * @param {string} webfDir - Path to the WebF package directory
 */
function copyLinuxLibraries(webfDir) {
  console.log(`🔄 Copying Linux shared libraries...`);
  
  const projectRoot = path.join(__dirname, '../');
  const bridgeBuildDir = path.join(projectRoot, 'bridge/build/linux/lib');
  const linuxDir = path.join(webfDir, 'linux');
  
  console.log(`📁 Source: ${bridgeBuildDir}`);
  console.log(`📁 Target: ${linuxDir}`);
  
  // Check if source directory exists
  if (!fs.existsSync(bridgeBuildDir)) {
    console.error(`❌ Bridge build directory not found: ${bridgeBuildDir}`);
    console.error(`   Please run one of the following commands first:`);
    console.error(`   - npm run build:bridge:linux (debug build)`);
    console.error(`   - npm run build:bridge:linux:release (release build)`);
    process.exit(1);
  }
  
  // Ensure target directory exists
  ensureDirectoryExists(linuxDir);
  
  // Libraries to copy
  // Note: QuickJS is statically linked into libwebf.so, so no separate libquickjs.so
  const libraries = [
    'libwebf.so',       // Main WebF library (includes QuickJS)
    'libc++.so.1',      // C++ standard library
    'libc++abi.so.1',   // C++ ABI library
    'libunwind.so.1'    // Stack unwinding library
  ];
  
  // Check available libraries
  console.log(`\n📋 Available libraries in build directory:`);
  const availableLibs = fs.readdirSync(bridgeBuildDir)
    .filter(file => file.endsWith('.so') || file.endsWith('.so.1'));
  
  if (availableLibs.length > 0) {
    availableLibs.forEach(lib => {
      const libPath = path.join(bridgeBuildDir, lib);
      const stats = fs.statSync(libPath);
      const sizeMB = (stats.size / (1024 * 1024)).toFixed(2);
      const isDebugSymbol = lib.includes('.debug');
      
      if (isDebugSymbol) {
        console.log(`   📝 ${lib}: ${sizeMB} MB (debug symbols)`);
      } else {
        console.log(`   ✅ ${lib}: ${sizeMB} MB`);
      }
    });
  } else {
    console.log(`   ⚠️  No shared libraries found`);
  }
  
  // Copy the libraries
  console.log(`\n📦 Copying libraries...`);
  let successCount = 0;
  let failureCount = 0;
  let notFoundCount = 0;
  
  for (const libName of libraries) {
    const sourcePath = path.join(bridgeBuildDir, libName);
    const targetPath = path.join(linuxDir, libName);
    
    if (!fs.existsSync(sourcePath)) {
      console.warn(`⚠️  ${libName} not found in build directory`);
      notFoundCount++;
      continue;
    }
    
    if (copyFile(sourcePath, targetPath)) {
      // Verify it's a valid ELF binary
      if (isElfBinary(targetPath)) {
        console.log(`   └─ Valid ELF binary confirmed`);
      }
      successCount++;
    } else {
      failureCount++;
    }
  }
  
  // Check for debug symbols
  const debugSymbols = fs.readdirSync(bridgeBuildDir)
    .filter(file => file.endsWith('.debug'));
  
  if (debugSymbols.length > 0) {
    console.log(`\n📝 Debug symbols available (not copied):`);
    debugSymbols.forEach(debugFile => {
      const debugPath = path.join(bridgeBuildDir, debugFile);
      const stats = fs.statSync(debugPath);
      const sizeMB = (stats.size / (1024 * 1024)).toFixed(2);
      console.log(`   - ${debugFile}: ${sizeMB} MB`);
    });
    console.log(`   ℹ️  Debug symbols are kept separate for release builds`);
  }
  
  // Summary
  console.log('\n📊 Copy Summary:');
  console.log(`   ✅ Successfully copied: ${successCount} libraries`);
  if (notFoundCount > 0) {
    console.log(`   ⚠️  Not found: ${notFoundCount} libraries`);
  }
  if (failureCount > 0) {
    console.log(`   ❌ Failed to copy: ${failureCount} libraries`);
  }
  
  // Verify copied files
  if (successCount > 0) {
    console.log('\n📋 Verifying copied libraries:');
    libraries.forEach(libName => {
      const targetPath = path.join(linuxDir, libName);
      if (fs.existsSync(targetPath)) {
        const stats = fs.statSync(targetPath);
        const sizeMB = (stats.size / (1024 * 1024)).toFixed(2);
        console.log(`   - ${libName}: ${sizeMB} MB`);
        
        // Special note for libwebf.so
        if (libName === 'libwebf.so') {
          console.log(`     └─ Includes statically linked QuickJS`);
        }
      }
    });
  }
  
  if (failureCount > 0) {
    console.error('\n❌ Some libraries failed to copy. Please check the errors above.');
    process.exit(1);
  } else if (successCount === 0) {
    console.error('\n❌ No libraries were copied. Please check if the Linux bridge has been built.');
    process.exit(1);
  } else {
    console.log('\n🎉 Linux shared libraries copied successfully!');
    console.log(`   Files are now available in: ${linuxDir}`);
    
    // Platform-specific instructions
    if (!isLinuxCompatible()) {
      console.log(`\n⚠️  Note: These libraries are for Linux deployment only.`);
    }
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
  
  // Check platform with warning
  if (!isLinuxCompatible()) {
    console.warn('⚠️  Warning: This script is designed for Linux libraries.');
    console.warn('   You appear to be on', process.platform);
    console.warn('   Continuing anyway for cross-platform development...\n');
  }
  
  // Check if the directory exists
  if (!fs.existsSync(absoluteWebfDir)) {
    console.error(`Error: WebF directory does not exist: ${absoluteWebfDir}`);
    process.exit(1);
  }
  
  // Copy the Linux libraries
  copyLinuxLibraries(absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { copyLinuxLibraries };