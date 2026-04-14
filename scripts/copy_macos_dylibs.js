#!/usr/bin/env node

/**
 * Script to copy macOS dylibs from bridge/build/macos/lib to webf/macos directory
 * Prioritizes universal binaries, falls back to architecture-specific binaries
 * 
 * Usage:
 *   node scripts/copy_macos_dylibs.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

function isMachOBinary(filePath) {
  try {
    const fd = fs.openSync(filePath, 'r');
    const buffer = Buffer.alloc(4);
    fs.readSync(fd, buffer, 0, 4, 0);
    fs.closeSync(fd);

    // Mach-O & FAT (universal) magic numbers.
    const magics = new Set([
      buffer.toString('hex'),
    ]);

    // Mach-O 32-bit / 64-bit (big-endian and little-endian)
    if (magics.has('feedface') || magics.has('cefaedfe')) return true;
    if (magics.has('feedfacf') || magics.has('cffaedfe')) return true;

    // FAT/universal (32-bit and 64-bit, big-endian and little-endian)
    if (magics.has('cafebabe') || magics.has('bebafeca')) return true;
    if (magics.has('cafebabf') || magics.has('bfbafeca')) return true;

    return false;
  } catch (error) {
    return false;
  }
}

function isFileCommandAvailable() {
  try {
    execSync('file --version', { stdio: 'ignore' });
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Get current system architecture
 * @returns {string} 'arm64' or 'x86_64'
 */
function getSystemArchitecture() {
  try {
    const arch = execSync('uname -m', { encoding: 'utf8' }).trim();
    return arch;
  } catch (error) {
    // Fallback for non-POSIX environments (or sandboxed shells).
    const arch = process.arch === 'arm64' ? 'arm64' : 'x86_64';
    console.warn(`⚠️  Could not determine system architecture via uname, defaulting to ${arch}`);
    return arch;
  }
}

/**
 * Check if a file is a universal binary
 * @param {string} filePath - Path to the file
 * @returns {boolean} True if universal binary
 */
function isUniversalBinary(filePath) {
  if (!isFileCommandAvailable()) {
    return false;
  }
  try {
    const output = execSync(`file "${filePath}"`, { encoding: 'utf8' });
    return output.includes('universal binary') || 
           (output.includes('x86_64') && output.includes('arm64'));
  } catch (error) {
    return false;
  }
}

/**
 * Copy a file from source to destination
 * @param {string} source - Source file path
 * @param {string} destination - Destination file path
 * @returns {boolean} True if successful
 */
function copyFile(source, destination) {
  try {
    // Ensure the destination directory exists
    const destDir = path.dirname(destination);
    if (!fs.existsSync(destDir)) {
      fs.mkdirSync(destDir, { recursive: true });
    }
    
    // Delete the destination file if it exists
    if (fs.existsSync(destination)) {
      fs.unlinkSync(destination);
    }
    
    // Read and write the file
    const buffer = fs.readFileSync(source);
    fs.writeFileSync(destination, buffer);
    console.log(`✅ Copied: ${path.basename(source)} -> ${destination}`);
    return true;
  } catch (error) {
    console.error(`❌ Failed to copy ${source}: ${error.message}`);
    return false;
  }
}

/**
 * Find and copy a dylib with fallback logic
 * @param {string} libName - Name of the library (e.g., 'libwebf.dylib')
 * @param {string} bridgeBuildDir - Bridge build directory
 * @param {string} targetDir - Target directory
 * @returns {boolean} True if copied successfully
 */
function copyDylib(libName, bridgeBuildDir, targetDir) {
  const universalPath = path.join(bridgeBuildDir, 'universal', libName);
  const arm64Path = path.join(bridgeBuildDir, 'arm64', libName);
  const x86_64Path = path.join(bridgeBuildDir, 'x86_64', libName);
  const targetPath = path.join(targetDir, libName);
  
  // Try universal binary first
  if (fs.existsSync(universalPath)) {
    console.log(`📦 Found universal binary for ${libName}`);
    if (isUniversalBinary(universalPath)) {
      console.log(`   ✅ Confirmed as universal binary (arm64 + x86_64)`);
    }
    if (!isMachOBinary(universalPath)) {
      console.error(`❌ ${libName} does not appear to be a Mach-O binary: ${universalPath}`);
      return false;
    }
    return copyFile(universalPath, targetPath);
  }
  
  // Fallback to architecture-specific binary
  const systemArch = getSystemArchitecture();
  console.log(`📦 Universal binary not found for ${libName}, checking ${systemArch} architecture...`);
  
  const archPath = systemArch === 'arm64' ? arm64Path : x86_64Path;
  if (fs.existsSync(archPath)) {
    console.log(`   ✅ Found ${systemArch} binary for ${libName}`);
    if (!isMachOBinary(archPath)) {
      console.error(`❌ ${libName} does not appear to be a Mach-O binary: ${archPath}`);
      return false;
    }
    return copyFile(archPath, targetPath);
  }
  
  // Try the other architecture as last resort
  const otherArch = systemArch === 'arm64' ? 'x86_64' : 'arm64';
  const otherArchPath = systemArch === 'arm64' ? x86_64Path : arm64Path;
  
  if (fs.existsSync(otherArchPath)) {
    console.warn(`⚠️  Only ${otherArch} binary found for ${libName} (current system: ${systemArch})`);
    console.warn(`   This may cause compatibility issues!`);
    if (!isMachOBinary(otherArchPath)) {
      console.error(`❌ ${libName} does not appear to be a Mach-O binary: ${otherArchPath}`);
      return false;
    }
    return copyFile(otherArchPath, targetPath);
  }
  
  console.error(`❌ No binary found for ${libName} in any architecture`);
  return false;
}

/**
 * Copy macOS dynamic libraries to webf/macos folder
 * @param {string} webfDir - Path to the WebF package directory
 */
function copyMacOSDynamicLibraries(webfDir) {
  console.log('🔄 Copying macOS dynamic libraries...');
  
  try {
    const macosDir = path.join(webfDir, 'macos');
    const bridgeBuildDir = path.join(__dirname, '../bridge/build/macos/lib');
    
    console.log(`📁 Source: ${bridgeBuildDir}`);
    console.log(`📁 Target: ${macosDir}`);
    console.log(`🖥️  System architecture: ${getSystemArchitecture()}`);
    
    // Check if source directory exists
    if (!fs.existsSync(bridgeBuildDir)) {
      console.error(`❌ Bridge build directory not found: ${bridgeBuildDir}`);
      console.error(`   Please run one of the following commands first:`);
      console.error(`   - npm run build:bridge:macos (universal binary)`);
      console.error(`   - npm run build:bridge:macos:arm64 (ARM64 only)`);
      console.error(`   - npm run build:bridge:macos:x86_64 (Intel only)`);
      process.exit(1);
    }
    
    // Check available architectures
    console.log(`\n📋 Available architectures in build directory:`);
    const archs = ['universal', 'arm64', 'x86_64'];
    archs.forEach(arch => {
      const archPath = path.join(bridgeBuildDir, arch);
      if (fs.existsSync(archPath)) {
        const files = fs.readdirSync(archPath).filter(f => f.endsWith('.dylib'));
        if (files.length > 0) {
          console.log(`   ✅ ${arch}: ${files.join(', ')}`);
        }
      }
    });
    
    // Ensure target directory exists
    if (!fs.existsSync(macosDir)) {
      fs.mkdirSync(macosDir, { recursive: true });
      console.log(`✅ Created directory: ${macosDir}`);
    }
    
    // Copy the dynamic libraries
    const libraries = ['libwebf.dylib', 'libquickjs.dylib'];
    console.log(`\n📦 Copying libraries...`);
    let successCount = 0;
    let failureCount = 0;
    
    for (const lib of libraries) {
      if (copyDylib(lib, bridgeBuildDir, macosDir)) {
        successCount++;
      } else {
        failureCount++;
      }
    }
    
    // Summary
    console.log('\n📊 Copy Summary:');
    console.log(`   ✅ Successfully copied: ${successCount} libraries`);
    if (failureCount > 0) {
      console.log(`   ❌ Failed to copy: ${failureCount} libraries`);
    }
    
    // Verify copied files
    if (successCount > 0) {
      console.log('\n📋 Verifying copied files:');
      libraries.forEach(libName => {
        const targetPath = path.join(macosDir, libName);
        if (fs.existsSync(targetPath)) {
          const stats = fs.statSync(targetPath);
          const sizeMB = (stats.size / (1024 * 1024)).toFixed(2);
          console.log(`   - ${libName}: ${sizeMB} MB`);
          
          // Check if it's universal
          if (isUniversalBinary(targetPath)) {
            console.log(`     └─ Universal binary (arm64 + x86_64)`);
          } else {
            try {
              const fileInfo = execSync(`file "${targetPath}"`, { encoding: 'utf8' }).trim();
              if (fileInfo.includes('arm64')) {
                console.log(`     └─ ARM64 binary`);
              } else if (fileInfo.includes('x86_64')) {
                console.log(`     └─ Intel x86_64 binary`);
              }
            } catch (error) {
              // Ignore file command errors
            }
          }
        }
      });
    }
    
    if (failureCount > 0) {
      console.error('\n❌ Some libraries failed to copy. Please check the errors above.');
      process.exit(1);
    } else {
      console.log('\n🎉 All macOS dynamic libraries copied successfully!');
      console.log(`   Files are now available in: ${macosDir}`);
      console.log(`   Run 'cd ${webfDir}/macos && pod install' to update the Pod installation.`);
    }
    
  } catch (error) {
    console.error('❌ Error copying macOS dynamic libraries:', error.message);
    process.exit(1);
  }
}

// Main execution
function main() {
  // This script only copies Mach-O artifacts, so it can run in Linux containers/CI as long as the
  // macOS build outputs are present (e.g., when the repo is mounted from a macOS host).
  if (process.platform !== 'darwin') {
    console.warn(`⚠️  Not running on macOS (platform: ${process.platform}). Continuing with copy only.`);
    console.warn(`   Note: CocoaPods steps (pod install) must be run on macOS.`);
  }
  
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
