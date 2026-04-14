#!/usr/bin/env node

/**
 * Standalone script to patch both App Revision and App Version in CMakeLists.txt
 * 
 * This script patches:
 * - App Revision: Git commit hash (replaces ${GIT_HEAD})
 * - App Version: Semantic version + QuickJS version (replaces ${APP_VER})
 * 
 * Usage:
 *   node scripts/patch_cmake_versions.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * Get the current git revision (short hash)
 * @returns {string} The short git hash
 */
function getGitRevision() {
  try {
    return execSync('git rev-parse --short HEAD', {
      encoding: 'utf-8',
      cwd: path.join(__dirname, '../')
    }).trim();
  } catch (error) {
    console.error('❌ Failed to get git revision:', error.message);
    process.exit(1);
  }
}

/**
 * Get the app version from bridge/scripts/get_app_ver.js
 * @returns {string} The app version string
 */
function getAppVersion() {
  try {
    return execSync('node bridge/scripts/get_app_ver.js', {
      encoding: 'utf-8',
      cwd: path.join(__dirname, '../')
    }).trim();
  } catch (error) {
    console.error('❌ Failed to get app version:', error.message);
    process.exit(1);
  }
}

/**
 * Remove execute_process blocks for git rev-parse and get_app_ver from CMakeLists.txt
 * @param {string} content - The CMakeLists.txt content
 * @returns {string} The cleaned content
 */
function removeExecuteProcessBlocks(content) {
  const lines = content.split('\n');
  const cleanedLines = [];
  let skipUntilNextBlock = false;
  let bracketCount = 0;
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Check if this is the start of a git rev-parse or get_app_ver execute_process block
    if (line.includes('execute_process') && 
        (lines[i + 1] && (lines[i + 1].includes('git rev-parse') || 
                         lines[i + 1].includes('node get_app_ver.js')))) {
      skipUntilNextBlock = true;
      bracketCount = 1;
      continue;
    }
    
    // If we're skipping, count brackets to know when the block ends
    if (skipUntilNextBlock) {
      bracketCount += (line.match(/\(/g) || []).length;
      bracketCount -= (line.match(/\)/g) || []).length;
      
      if (bracketCount <= 0) {
        skipUntilNextBlock = false;
      }
      continue;
    }
    
    cleanedLines.push(line);
  }
  
  return cleanedLines.join('\n');
}

/**
 * Patch both App Revision and App Version in CMakeLists.txt
 * @param {string} webfDir - Path to the WebF package directory
 */
function patchCMakeVersions(webfDir) {
  console.log('🔄 Patching App Revision and App Version in CMakeLists.txt...');
  
  try {
    const gitHead = getGitRevision();
    const appVer = getAppVersion();
    const cmakePath = path.join(webfDir, 'src/CMakeLists.txt');
    
    console.log(`📁 Target file: ${cmakePath}`);
    console.log(`🔖 Git revision: ${gitHead}`);
    console.log(`📦 App version: ${appVer}`);
    
    if (!fs.existsSync(cmakePath)) {
      console.error(`❌ CMakeLists.txt not found at ${cmakePath}`);
      process.exit(1);
    }
    
    // Read the CMakeLists.txt file
    let cmakeContent = fs.readFileSync(cmakePath, { encoding: 'utf-8' });
    
    // Remove execute_process blocks for both git rev-parse and get_app_ver
    let updatedContent = removeExecuteProcessBlocks(cmakeContent);
    
    // Replace placeholders with actual values
    let replacements = 0;
    
    // Replace ${GIT_HEAD} with the actual git revision
    if (updatedContent.includes('${GIT_HEAD}')) {
      updatedContent = updatedContent.replace(/\$\{GIT_HEAD\}/g, gitHead);
      replacements++;
      console.log(`✅ Replaced \${GIT_HEAD} with: ${gitHead}`);
    } else {
      console.log(`ℹ️  No \${GIT_HEAD} placeholder found (may already be patched)`);
    }
    
    // Replace ${APP_VER} with the actual app version
    if (updatedContent.includes('${APP_VER}')) {
      updatedContent = updatedContent.replace(/\$\{APP_VER\}/g, appVer);
      replacements++;
      console.log(`✅ Replaced \${APP_VER} with: ${appVer}`);
    } else {
      console.log(`ℹ️  No \${APP_VER} placeholder found (may already be patched)`);
    }
    
    // Write the updated content back only if changes were made
    if (updatedContent !== cmakeContent) {
      fs.writeFileSync(cmakePath, updatedContent);
      
      console.log(`\n✅ CMakeLists.txt patched successfully!`);
      console.log(`   Git Revision: ${gitHead}`);
      console.log(`   App Version: ${appVer}`);
      console.log(`   File: ${cmakePath}`);
      
      if (replacements === 0) {
        console.log(`   Note: Removed execute_process blocks but no placeholders were replaced`);
      }
    } else {
      console.log(`\nℹ️  No changes needed in CMakeLists.txt`);
      console.log(`   File may already be patched or has a different structure`);
    }
    
  } catch (error) {
    console.error('❌ Error patching CMake versions:', error.message);
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
  
  // Check if src directory exists
  const srcDir = path.join(absoluteWebfDir, 'src');
  if (!fs.existsSync(srcDir)) {
    console.error(`Error: src directory does not exist: ${srcDir}`);
    console.error(`Please ensure the WebF package structure is correct.`);
    process.exit(1);
  }
  
  // Patch both App Revision and App Version
  patchCMakeVersions(absoluteWebfDir);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { patchCMakeVersions };