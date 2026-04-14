#!/usr/bin/env node

/**
 * Standalone script to copy C/C++ source files from bridge/ to webf/src for non-macOS platforms
 * 
 * Usage:
 *   node scripts/copy_cpp_sources.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

/**
 * Copy a file from source to destination
 * @param {string} source - Source file path
 * @param {string} destination - Destination file path
 */
function copyFile(source, destination) {
  console.log(`Copying file: ${path.basename(source)} -> ${destination}`);
  
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
}

/**
 * Copy C/C++ source files from bridge/ to webf/src
 * @param {string} rootDir - Path to the project root directory
 * @param {string} webfDir - Path to the WebF package directory
 */
function copyCppSourceFiles(rootDir, webfDir) {
  console.log('🔄 Copying C/C++ source files...');
  
  try {
    const bridgeDir = path.join(rootDir, 'bridge');
    const srcDir = path.join(webfDir, 'src');
    
    console.log(`📁 Source: ${bridgeDir}`);
    console.log(`📁 Target: ${srcDir}`);
    
    // Check if source directory exists
    if (!fs.existsSync(bridgeDir)) {
      console.error(`❌ Bridge directory not found: ${bridgeDir}`);
      process.exit(1);
    }
    
    // Ensure the src directory exists
    if (!fs.existsSync(srcDir)) {
      fs.mkdirSync(srcDir, { recursive: true });
      console.log(`✅ Created directory: ${srcDir}`);
    } else {
      // Clean the src directory if it exists
      console.log('🧹 Cleaning existing src directory...');
      if (os.platform() === 'win32') {
        execSync(`rd /s /q "${srcDir}"`);
        fs.mkdirSync(srcDir, { recursive: true });
      } else {
        execSync(`rm -rf "${srcDir}"`);
        fs.mkdirSync(srcDir, { recursive: true });
      }
    }
    
    // Directories to copy (based on iOS structure)
    const directoriesToCopy = [
      'bindings',
      'core',
      'foundation',
      'include',
      'code_gen',
      'bridge_sources.json5',
      'scripts/get_app_ver.js',
      'scripts/read_bridge_sources.js',
      'scripts/read_quickjs_sources.js',
      'multiple_threading',
      'third_party/dart',
      'third_party/gumbo-parser',
      'third_party/modp_b64',
      'third_party/quickjs',
      'third_party/cityhash',
      'third_party/double_conversion'
    ];
    
    let successCount = 0;
    let warningCount = 0;
    
    // Copy all directories and files
    for (const item of directoriesToCopy) {
      const sourcePath = path.join(bridgeDir, item);
      const destPath = path.join(srcDir, item);
      
      if (fs.existsSync(sourcePath)) {
        const stats = fs.statSync(sourcePath);
        
        if (stats.isDirectory()) {
          // It's a directory - copy recursively
          // Create the destination directory if it doesn't exist
          if (!fs.existsSync(destPath)) {
            fs.mkdirSync(destPath, { recursive: true });
          }
          
          // Use rsync or recursive copy depending on the platform
          if (os.platform() === 'win32') {
            // For Windows, use xcopy or robocopy
            execSync(`xcopy "${sourcePath}" "${destPath}" /E /I /Y`, { stdio: 'ignore' });
          } else {
            // For Unix-like systems, use rsync or cp
            execSync(`rsync -a "${sourcePath}/" "${destPath}/"`, { stdio: 'ignore' });
          }
          console.log(`✅ Copied directory: ${item}`);
          successCount++;
        } else if (stats.isFile()) {
          // It's a file - copy it directly
          copyFile(sourcePath, destPath);
          console.log(`✅ Copied file: ${item}`);
          successCount++;
        }
      } else {
        console.warn(`⚠️  Warning: Source path ${sourcePath} does not exist.`);
        warningCount++;
      }
    }
    
    // Also copy specific files at the root level
    const rootFilesToCopy = [
      'CMakeLists.txt',
      'webf_bridge.cc',
      'webf_bridge.h'
    ];
    
    for (const file of rootFilesToCopy) {
      const sourceFile = path.join(bridgeDir, file);
      const destFile = path.join(srcDir, file);
      
      if (fs.existsSync(sourceFile)) {
        copyFile(sourceFile, destFile);
        console.log(`✅ Copied root file: ${file}`);
        successCount++;
      } else {
        console.warn(`⚠️  Warning: Source file ${sourceFile} does not exist.`);
        warningCount++;
      }
    }
    
    // Summary
    console.log('\n📊 Copy Summary:');
    console.log(`   ✅ Successfully copied: ${successCount} items`);
    if (warningCount > 0) {
      console.log(`   ⚠️  Warnings: ${warningCount} items not found`);
    }
    
    console.log('\n🎉 C/C++ source files copied successfully!');
    console.log(`   Files are now available in: ${srcDir}`);
    
  } catch (error) {
    console.error('❌ Error copying C/C++ source files:', error.message);
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
  const rootDir = path.join(__dirname, '..');
  
  console.log(`Using WebF directory: ${absoluteWebfDir}`);
  console.log(`Using root directory: ${rootDir}`);
  
  // Check if the directory exists
  if (!fs.existsSync(absoluteWebfDir)) {
    console.error(`Error: WebF directory does not exist: ${absoluteWebfDir}`);
    process.exit(1);
  }
  
  // Copy the C/C++ source files
  copyCppSourceFiles(rootDir, absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { copyCppSourceFiles };