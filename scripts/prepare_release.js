#!/usr/bin/env node

/**
 * Script to prepare the WebF package for release
 * Removes development symbolic links and prepares the package structure
 * 
 * Usage:
 *   npm run prepare-release
 */

const fs = require('fs');
const path = require('path');

/**
 * Remove symbolic link if it exists
 * @param {string} linkPath - Path to the symbolic link
 * @returns {boolean} True if removed, false if didn't exist
 */
function removeSymlink(linkPath) {
  try {
    if (fs.existsSync(linkPath)) {
      const stats = fs.lstatSync(linkPath);
      if (stats.isSymbolicLink()) {
        fs.unlinkSync(linkPath);
        console.log(`✅ Removed symbolic link: ${linkPath}`);
        return true;
      } else {
        console.log(`⚠️  Path exists but is not a symbolic link: ${linkPath}`);
        return false;
      }
    } else {
      console.log(`ℹ️  Symbolic link does not exist: ${linkPath}`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error removing symbolic link ${linkPath}: ${error.message}`);
    throw error;
  }
}

/**
 * Main function to prepare the release
 */
function prepareRelease() {
  console.log('🚀 Preparing WebF package for release...\n');
  
  const projectRoot = path.join(__dirname, '..');
  const webfSrcLink = path.join(projectRoot, 'webf', 'src');
  
  console.log('📦 Cleaning up development artifacts...');
  
  // Remove the webf/src symbolic link
  console.log('\n1️⃣  Removing webf/src symbolic link...');
  removeSymlink(webfSrcLink);
  
  // Check if there are any other symbolic links that should be cleaned
  const webfDir = path.join(projectRoot, 'webf');
  if (fs.existsSync(webfDir)) {
    console.log('\n2️⃣  Checking for other symbolic links in webf directory...');
    
    const entries = fs.readdirSync(webfDir);
    let symlinksFound = 0;
    
    entries.forEach(entry => {
      const entryPath = path.join(webfDir, entry);
      try {
        const stats = fs.lstatSync(entryPath);
        if (stats.isSymbolicLink()) {
          if (entry !== 'src') {  // We already handled src
            console.log(`   Found symbolic link: ${entry}`);
            symlinksFound++;
          }
        }
      } catch (error) {
        // Ignore errors for individual entries
      }
    });
    
    if (symlinksFound === 0) {
      console.log('   No additional symbolic links found.');
    } else {
      console.log(`   ⚠️  Found ${symlinksFound} additional symbolic link(s). Review if they should be removed.`);
    }
  }
  
  // Verify the package structure
  console.log('\n3️⃣  Verifying package structure...');
  
  const requiredDirs = [
    'webf/lib',
    'webf/android',
    'webf/ios',
    'webf/macos',
    'webf/linux',
    'webf/windows'
  ];
  
  let missingDirs = [];
  requiredDirs.forEach(dir => {
    const dirPath = path.join(projectRoot, dir);
    if (fs.existsSync(dirPath)) {
      console.log(`   ✅ ${dir}`);
    } else {
      console.log(`   ❌ ${dir} (missing)`);
      missingDirs.push(dir);
    }
  });
  
  // Check if pubspec.yaml exists
  const pubspecPath = path.join(projectRoot, 'webf', 'pubspec.yaml');
  if (fs.existsSync(pubspecPath)) {
    console.log('   ✅ webf/pubspec.yaml');
  } else {
    console.log('   ❌ webf/pubspec.yaml (missing)');
    missingDirs.push('webf/pubspec.yaml');
  }
  
  // Summary
  console.log('\n' + '='.repeat(50));
  if (missingDirs.length === 0) {
    console.log('✅ Release preparation completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Run platform-specific use-prebuilt scripts');
    console.log('2. Update version in pubspec.yaml if needed');
    console.log('3. Run `dart pub publish` to publish the package');
  } else {
    console.log('⚠️  Release preparation completed with warnings.');
    console.log(`\nMissing ${missingDirs.length} required directories/files:`);
    missingDirs.forEach(dir => console.log(`   - ${dir}`));
    console.log('\nPlease ensure all required files are present before publishing.');
  }
  console.log('='.repeat(50));
}

// Main execution
function main() {
  try {
    prepareRelease();
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Release preparation failed:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { prepareRelease, removeSymlink };