#!/usr/bin/env node

/**
 * Standalone script to add WebF package files to git and create a commit
 * 
 * Usage:
 *   node scripts/git_add_webf_files.js [webf-directory] [--no-commit]
 * 
 * If no directory is specified, defaults to 'webf' relative to the project root.
 * Use --no-commit flag to only stage files without creating a commit.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * Execute a git command and handle errors
 * @param {string} command - Git command to execute
 * @param {object} options - Execution options
 * @returns {string|null} Command output or null on error
 */
function execGitCommand(command, options = {}) {
  try {
    return execSync(command, {
      encoding: 'utf-8',
      ...options
    }).trim();
  } catch (error) {
    console.error(`❌ Git command failed: ${command}`);
    console.error(`   Error: ${error.message}`);
    return null;
  }
}

/**
 * Add files to git and optionally create commit
 * @param {string} webfDir - Path to the WebF package directory
 * @param {boolean} createCommit - Whether to create a commit after adding files
 */
function addFilesToGit(webfDir, createCommit = true) {
  console.log('🔄 Adding WebF package files to git...');
  
  try {
    const execOptions = { cwd: webfDir };
    
    // Check if we're in a git repository
    const gitStatus = execGitCommand('git status --porcelain', execOptions);
    if (gitStatus === null) {
      console.error('❌ Not in a git repository or git command failed');
      process.exit(1);
    }
    
    // Files and directories to add
    const itemsToAdd = [
      'src',
      'windows/CMakeLists.txt',
      'macos/libwebf.dylib',
      'macos/libquickjs.dylib',
      'ios/webf.podspec'
    ];
    
    let addedCount = 0;
    let skippedCount = 0;
    
    console.log('📋 Staging files:');
    
    // Add each item
    for (const item of itemsToAdd) {
      const itemPath = path.join(webfDir, item);
      
      if (fs.existsSync(itemPath)) {
        const result = execGitCommand(`git add "${item}"`, execOptions);
        if (result !== null) {
          console.log(`   ✅ Added: ${item}`);
          addedCount++;
        } else {
          console.log(`   ❌ Failed to add: ${item}`);
          skippedCount++;
        }
      } else {
        console.log(`   ⚠️  Skipped (not found): ${item}`);
        skippedCount++;
      }
    }
    
    // Remove win_src if it exists (cleanup old structure)
    const winSrcPath = path.join(webfDir, 'win_src');
    if (fs.existsSync(winSrcPath)) {
      console.log('\n🧹 Cleaning up old structures:');
      
      try {
        // Remove from filesystem
        if (process.platform === 'win32') {
          execSync(`rd /s /q "${winSrcPath}"`);
        } else {
          execSync(`rm -rf "${winSrcPath}"`);
        }
        console.log('   ✅ Removed win_src directory');
        
        // Remove from git if tracked
        execGitCommand('git rm -r --cached win_src', execOptions);
        console.log('   ✅ Removed win_src from git tracking');
      } catch (error) {
        console.warn('   ⚠️  Could not remove win_src:', error.message);
      }
    }
    
    // Check what's been staged
    const stagedFiles = execGitCommand('git diff --cached --name-only', execOptions);
    
    if (!stagedFiles || stagedFiles.length === 0) {
      console.log('\n⚠️  No changes staged for commit');
      return;
    }
    
    console.log('\n📊 Staging Summary:');
    console.log(`   ✅ Successfully staged: ${addedCount} items`);
    if (skippedCount > 0) {
      console.log(`   ⚠️  Skipped: ${skippedCount} items`);
    }
    
    // Create commit if requested
    if (createCommit) {
      console.log('\n📝 Creating commit...');
      
      const commitMessage = 'Prepare WebF package for publishing';
      const result = execGitCommand(`git commit -m "${commitMessage}"`, execOptions);
      
      if (result !== null) {
        // Get the commit hash
        const commitHash = execGitCommand('git rev-parse --short HEAD', execOptions);
        console.log(`✅ Commit created successfully!`);
        console.log(`   Hash: ${commitHash}`);
        console.log(`   Message: ${commitMessage}`);
      } else {
        console.error('❌ Failed to create commit');
        console.error('   Files have been staged but not committed');
      }
    } else {
      console.log('\n✅ Files staged successfully (no commit created)');
      console.log('   Run `git commit` to create the commit manually');
    }
    
  } catch (error) {
    console.error('❌ Error adding files to git:', error.message);
    process.exit(1);
  }
}

// Main execution
function main() {
  // Parse command line arguments
  const args = process.argv.slice(2);
  
  // Check for --no-commit flag
  const noCommitIndex = args.indexOf('--no-commit');
  const createCommit = noCommitIndex === -1;
  
  // Remove flag from args if present
  if (noCommitIndex !== -1) {
    args.splice(noCommitIndex, 1);
  }
  
  // Default to 'webf' directory if no argument provided
  const webfDir = args[0] || path.join(__dirname, '../webf');
  
  // Convert to absolute path
  const absoluteWebfDir = path.resolve(webfDir);
  
  console.log(`Using WebF directory: ${absoluteWebfDir}`);
  console.log(`Create commit: ${createCommit ? 'Yes' : 'No'}`);
  
  // Check if the directory exists
  if (!fs.existsSync(absoluteWebfDir)) {
    console.error(`Error: WebF directory does not exist: ${absoluteWebfDir}`);
    process.exit(1);
  }
  
  // Add files to git
  addFilesToGit(absoluteWebfDir, createCommit);
}

// Run the script if called directly
if (require.main === module) {
  main();
}

// Export for use as a module
module.exports = { addFilesToGit };