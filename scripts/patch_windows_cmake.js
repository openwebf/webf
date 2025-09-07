#!/usr/bin/env node

/**
 * Standalone script to patch the Windows CMakeLists.txt to use src instead of win_src
 * 
 * Usage:
 *   node scripts/patch_windows_cmake.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const fs = require('fs');
const path = require('path');

/**
 * Patch the Windows CMakeLists.txt to use src instead of win_src
 * @param {string} webfDir - Path to the WebF package directory
 */
function patchWindowsCMake(webfDir) {
  console.log('🔄 Patching Windows CMakeLists.txt...');
  
  try {
    const windowsCMake = path.join(webfDir, 'windows/CMakeLists.txt');
    
    console.log(`📁 Target file: ${windowsCMake}`);
    
    if (!fs.existsSync(windowsCMake)) {
      console.error(`❌ Windows CMakeLists.txt not found at ${windowsCMake}`);
      process.exit(1);
    }
    
    // Read the CMakeLists.txt file
    let cmakeContent = fs.readFileSync(windowsCMake, { encoding: 'utf-8' });
    
    // Check if the file contains 'win_src'
    if (!cmakeContent.includes('win_src')) {
      console.log(`ℹ️  No 'win_src' found in CMakeLists.txt. File may already be patched.`);
      return;
    }
    
    // Replace 'win_src' with 'src'
    const originalContent = cmakeContent;
    cmakeContent = cmakeContent.replace(/win_src/g, 'src');
    
    // Count replacements
    const replacementCount = (originalContent.match(/win_src/g) || []).length;
    
    // Write the updated content back
    fs.writeFileSync(windowsCMake, cmakeContent);
    
    console.log(`✅ Windows CMakeLists.txt patched successfully!`);
    console.log(`   Replaced ${replacementCount} occurrence(s) of 'win_src' with 'src'`);
    console.log(`   File: ${windowsCMake}`);
    
  } catch (error) {
    console.error('❌ Error patching Windows CMakeLists.txt:', error.message);
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
  
  // Check if windows directory exists
  const windowsDir = path.join(absoluteWebfDir, 'windows');
  if (!fs.existsSync(windowsDir)) {
    console.error(`Error: Windows directory does not exist: ${windowsDir}`);
    process.exit(1);
  }
  
  // Patch the Windows CMakeLists.txt
  patchWindowsCMake(absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { patchWindowsCMake };