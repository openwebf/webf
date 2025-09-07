#!/usr/bin/env node

/**
 * Standalone script to remove symbolic links from webf/src directory
 * 
 * Usage:
 *   node scripts/remove_src_symlinks.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Recursively find all symbolic links in a directory
 * @param {string} dir - Directory to search
 * @param {string[]} symlinks - Array to store found symlinks
 */
function findSymlinks(dir, symlinks = []) {
  try {
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      const filePath = path.join(dir, file);
      
      try {
        const stats = fs.lstatSync(filePath);
        
        if (stats.isSymbolicLink()) {
          symlinks.push(filePath);
        } else if (stats.isDirectory()) {
          // Recursively search subdirectories
          findSymlinks(filePath, symlinks);
        }
      } catch (err) {
        console.warn(`⚠️  Warning: Could not stat ${filePath}: ${err.message}`);
      }
    }
  } catch (err) {
    console.error(`❌ Error reading directory ${dir}: ${err.message}`);
  }
  
  return symlinks;
}

/**
 * Remove symbolic links from webf/src directory
 * @param {string} webfDir - Path to the WebF package directory
 */
function removeSrcSymlinks(webfDir) {
  console.log('🔄 Removing symbolic links from webf/src directory...');
  
  try {
    const srcDir = path.join(webfDir, 'src');
    
    console.log(`📁 Target directory: ${srcDir}`);
    
    // Check if src directory exists
    if (!fs.existsSync(srcDir)) {
      console.log(`ℹ️  src directory does not exist at ${srcDir}`);
      console.log('   Nothing to remove.');
      return;
    }
    
    // Find all symbolic links in src directory
    console.log('🔍 Searching for symbolic links...');
    const symlinks = findSymlinks(srcDir);
    
    if (symlinks.length === 0) {
      console.log('ℹ️  No symbolic links found in src directory.');
      return;
    }
    
    console.log(`📋 Found ${symlinks.length} symbolic link(s) to remove:`);
    
    let removedCount = 0;
    let failedCount = 0;
    
    // Remove each symbolic link
    for (const symlink of symlinks) {
      const relativePath = path.relative(srcDir, symlink);
      
      try {
        // Get the target of the symlink for logging
        let target = 'unknown';
        try {
          target = fs.readlinkSync(symlink);
        } catch (e) {
          // Ignore error getting target
        }
        
        // Remove the symbolic link
        fs.unlinkSync(symlink);
        console.log(`   ✅ Removed: ${relativePath} -> ${target}`);
        removedCount++;
      } catch (err) {
        console.error(`   ❌ Failed to remove: ${relativePath}`);
        console.error(`      Error: ${err.message}`);
        failedCount++;
      }
    }
    
    // Summary
    console.log('\n📊 Removal Summary:');
    console.log(`   ✅ Successfully removed: ${removedCount} symlink(s)`);
    if (failedCount > 0) {
      console.log(`   ❌ Failed to remove: ${failedCount} symlink(s)`);
    }
    
    if (failedCount > 0) {
      console.error('\n❌ Some symbolic links failed to be removed. Please check the errors above.');
      process.exit(1);
    } else if (removedCount > 0) {
      console.log('\n🎉 All symbolic links removed successfully!');
    }
    
  } catch (error) {
    console.error('❌ Error removing symbolic links:', error.message);
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
  
  // Remove symbolic links from src directory
  removeSrcSymlinks(absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { removeSrcSymlinks };