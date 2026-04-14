#!/usr/bin/env node

/**
 * Standalone script to patch iOS podspec file with app version and revision
 * 
 * Usage:
 *   node scripts/patch_ios_podspec.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * Patch the iOS podspec file with app version and revision
 * @param {string} webfDir - Path to the WebF package directory
 */
function patchIOSPodspec(webfDir) {
  console.log('Patching iOS podspec file...');
  
  try {
    // Get git revision
    const gitHead = execSync('git rev-parse --short HEAD', { 
      encoding: 'utf-8',
      cwd: path.join(__dirname, '../')
    }).trim();
    
    // Get full version string with QuickJS info
    const fullAppVer = execSync('node bridge/scripts/get_app_ver.js', {
      encoding: 'utf-8',
      cwd: path.join(__dirname, '../')
    }).trim();
    
    // Extract just the app version and QuickJS version
    const appVerMatch = fullAppVer.match(/^([\w\.\+\-]+)\/QuickJS: (.+)$/);
    const appVer = appVerMatch ? appVerMatch[1] : fullAppVer;
    const quickjsVer = appVerMatch ? appVerMatch[2].trim() : '2025-04-26'; // Default if not found
    
    const podspecPath = path.join(webfDir, 'ios/webf.podspec');
    
    if (!fs.existsSync(podspecPath)) {
      console.error(`Error: iOS podspec not found at ${podspecPath}`);
      process.exit(1);
    }
    
    // Read the podspec file
    let podspecContent = fs.readFileSync(podspecPath, { encoding: 'utf-8' });
    
    // Replace APP_REV, APP_VERSION, and CONFIG_VERSION in podspec
    podspecContent = podspecContent.replace(/APP_REV=\\\\"[^\\]*\\\\"/, `APP_REV=\\\\"${gitHead}\\\\"`);
    podspecContent = podspecContent.replace(/APP_VERSION=\\\\"[^\\]*\\\\"/, `APP_VERSION=\\\\"${appVer}\\\\"`);
    podspecContent = podspecContent.replace(/CONFIG_VERSION=\\\\"[^\\]*\\\\"/, `CONFIG_VERSION=\\\\"${quickjsVer}\\\\"`);
    
    // Write the updated content back
    fs.writeFileSync(podspecPath, podspecContent);
    
    console.log(`✅ iOS podspec patched successfully:`);
    console.log(`   Revision: ${gitHead}`);
    console.log(`   Version: ${appVer}`);
    console.log(`   QuickJS: ${quickjsVer}`);
    console.log(`   File: ${podspecPath}`);
    
  } catch (error) {
    console.error('❌ Error patching iOS podspec:', error.message);
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
  
  // Patch the iOS podspec
  patchIOSPodspec(absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { patchIOSPodspec };