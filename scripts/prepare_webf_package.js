#!/usr/bin/env node

/**
 * WebF Package Preparation Pipeline
 * 
 * This script orchestrates the execution of standalone scripts to prepare
 * the WebF package for publishing. It runs the following steps in order:
 * 1. Copy macOS dynamic libraries
 * 2. Copy C/C++ source files
 * 3. Patch Windows CMakeLists.txt
 * 4. Remove symbolic links from src directory
 * 5. Patch CMake versions (App Revision and App Version)
 * 6. Patch iOS podspec
 * 7. Add files to git
 * 
 * Usage:
 *   node scripts/prepare_webf_package.js [webf-directory]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 */

const { execSync } = require('child_process');
const path = require('path');

/**
 * Execute a standalone script
 * @param {string} scriptName - Name of the script to execute
 * @param {string} webfDir - WebF directory path
 * @returns {boolean} Success status
 */
function executeScript(scriptName, webfDir) {
  try {
    const scriptPath = path.join(__dirname, scriptName);
    console.log(`\n🚀 Executing: ${scriptName}`);
    execSync(`node "${scriptPath}" "${webfDir}"`, {
      stdio: 'inherit',
      cwd: __dirname
    });
    return true;
  } catch (error) {
    console.error(`❌ Failed to execute ${scriptName}:`, error.message);
    return false;
  }
}

/**
 * Main function to run all tasks
 */
function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('    WebF Package Preparation Pipeline');
  console.log('═══════════════════════════════════════════════════════════');
  
  const rootDir = path.join(__dirname, '..');
  const webfDir = path.join(rootDir, 'webf');
  
  // Parse command line arguments
  const args = process.argv.slice(2);
  const customWebfDir = args[0];
  const targetWebfDir = customWebfDir ? path.resolve(customWebfDir) : webfDir;
  
  console.log(`\n📁 Target WebF directory: ${targetWebfDir}`);
  
  // List of scripts to execute in order
  const scripts = [
    { name: 'copy_macos_dylibs.js', description: 'Copy macOS dynamic libraries' },
    { name: 'copy_cpp_sources.js', description: 'Copy C/C++ source files' },
    { name: 'patch_cmake_versions.js', description: 'Patch CMake versions (App Revision and App Version)' },
    { name: 'patch_ios_podspec.js', description: 'Patch iOS podspec' },
    { name: 'git_add_webf_files.js', description: 'Add files to git' }
  ];
  
  console.log('\n📋 Pipeline steps:');
  scripts.forEach((script, index) => {
    console.log(`   ${index + 1}. ${script.description}`);
  });
  
  console.log('\n═══════════════════════════════════════════════════════════');
  
  let failedScripts = [];
  
  // Execute each script
  for (const script of scripts) {
    const success = executeScript(script.name, targetWebfDir);
    if (!success) {
      failedScripts.push(script.name);
      // Continue with other scripts even if one fails
    }
  }
  
  console.log('\n═══════════════════════════════════════════════════════════');
  
  if (failedScripts.length === 0) {
    console.log('✅ WebF package preparation completed successfully!');
    console.log(`   All ${scripts.length} steps executed without errors.`);
  } else {
    console.error('⚠️  WebF package preparation completed with errors:');
    console.error(`   Failed scripts: ${failedScripts.join(', ')}`);
    console.error('   Please review the errors above and fix any issues.');
    process.exit(1);
  }
}

// Run the main function
main();
