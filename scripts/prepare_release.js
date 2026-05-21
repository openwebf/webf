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
const { execSync } = require('child_process');

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
/**
 * Materialise the bridge source under webf/src as a real directory.
 *
 * In dev, `webf/src` is a symbolic link pointing at `../bridge`. The iOS
 * pod's source-mode shims under `webf/ios/Classes/` `#include` files via
 * `../../../src/...`, which resolves through the symlink at dev time.
 *
 * When publishing to pub.dev the symlink either gets stripped or dangles
 * (its target `../bridge/` lives outside the package root, which pub will
 * not ship). Consumer Xcode builds then fail with "file not found"
 * errors deep inside quickjs.c.
 *
 * To make the published pod self-contained we copy the bridge subtree
 * the iOS pod actually needs into `webf/src/` as a real directory,
 * pruning build outputs, CMake artefacts, alternative-engine code, and
 * test machinery that the Xcode build won't touch.
 *
 * @param {string} projectRoot
 * @returns {void}
 */
function materializeBridgeSourceUnderWebfSrc(projectRoot) {
  const webfSrcLink = path.join(projectRoot, 'webf', 'src');
  const bridgeDir = path.join(projectRoot, 'bridge');

  if (!fs.existsSync(bridgeDir)) {
    console.error(`❌ Bridge directory not found at ${bridgeDir}; cannot materialise webf/src`);
    process.exit(1);
  }

  // Remove the symlink (or existing directory) so we start clean.
  if (fs.existsSync(webfSrcLink) || fs.lstatSync(webfSrcLink, { throwIfNoEntry: false })) {
    const stats = fs.lstatSync(webfSrcLink);
    if (stats.isSymbolicLink()) {
      fs.unlinkSync(webfSrcLink);
      console.log(`   Removed dev symlink: ${webfSrcLink} → ../bridge`);
    } else if (stats.isDirectory()) {
      execSync(`rm -rf "${webfSrcLink}"`);
      console.log(`   Removed pre-existing directory: ${webfSrcLink}`);
    }
  }

  fs.mkdirSync(webfSrcLink, { recursive: true });

  // Subtrees the iOS pod compiles via `#include` shims in
  // `webf/ios/Classes/`. Everything else under `bridge/` is build
  // tooling, alternative JS engines, or test machinery that adds
  // megabytes to the pub package for zero consumer benefit.
  const INCLUDE_SUBDIRS = [
    'core',
    'bindings',
    'foundation',
    'code_gen',
    'include',
    'multiple_threading',
  ];

  // Third-party dependencies actually linked by the iOS pod.
  // Excluded: benchmark/, googletest/ (test-only).
  const INCLUDE_THIRD_PARTY = [
    'quickjs',
    'dart',
    'gumbo-parser',
    'modp_b64',
  ];

  // Individual top-level files the shims include directly.
  const INCLUDE_TOP_FILES = [
    'webf_bridge.cc',
  ];

  // rsync excludes: skip build outputs, hidden git/VCS dirs, and any
  // .o/.a/.dylib leftovers from local development.
  const RSYNC_EXCLUDES = [
    '.git*',
    'cmake-build-*',
    'build',
    '*.o',
    '*.a',
    '*.dylib',
    '*.so',
    '*.dll',
    'node_modules',
    '.DS_Store',
  ];

  function rsyncCopy(srcAbsPath, destAbsPath) {
    const excludeArgs = RSYNC_EXCLUDES.map((p) => `--exclude='${p}'`).join(' ');
    fs.mkdirSync(path.dirname(destAbsPath), { recursive: true });
    execSync(`rsync -a ${excludeArgs} "${srcAbsPath}/" "${destAbsPath}/"`, {
      stdio: 'inherit',
    });
  }

  // Subtrees whose absence is fatal — the published pod cannot compile
  // without them. `code_gen/` is the usual culprit since it is generated
  // by `npm run bindgen` (run separately per build job in CI) and isn't
  // checked into git, so it's easy to forget to regenerate before the
  // publish step.
  const REQUIRED_SUBDIRS = new Set(['core', 'bindings', 'foundation', 'code_gen', 'include']);

  for (const sub of INCLUDE_SUBDIRS) {
    const src = path.join(bridgeDir, sub);
    const dest = path.join(webfSrcLink, sub);
    if (!fs.existsSync(src)) {
      if (REQUIRED_SUBDIRS.has(sub)) {
        console.error(`❌ Missing required bridge subtree: bridge/${sub}`);
        console.error(`   The published pod will fail to compile without it.`);
        if (sub === 'code_gen') {
          console.error(`   This directory is generated by \`npm run bindgen\` — run that first.`);
        }
        process.exit(1);
      }
      console.log(`   ⚠️  Skipping missing subtree: bridge/${sub}`);
      continue;
    }
    // Reject empty required subtrees too (bindgen ran but produced nothing).
    if (REQUIRED_SUBDIRS.has(sub) && fs.readdirSync(src).length === 0) {
      console.error(`❌ Required bridge subtree is empty: bridge/${sub}`);
      process.exit(1);
    }
    rsyncCopy(src, dest);
    console.log(`   Copied bridge/${sub} → webf/src/${sub}`);
  }

  // third_party — selective copy
  fs.mkdirSync(path.join(webfSrcLink, 'third_party'), { recursive: true });
  for (const tp of INCLUDE_THIRD_PARTY) {
    const src = path.join(bridgeDir, 'third_party', tp);
    const dest = path.join(webfSrcLink, 'third_party', tp);
    if (!fs.existsSync(src)) {
      console.log(`   ⚠️  Skipping missing third_party/${tp}`);
      continue;
    }
    rsyncCopy(src, dest);
    console.log(`   Copied bridge/third_party/${tp} → webf/src/third_party/${tp}`);
  }

  // Top-level files
  for (const f of INCLUDE_TOP_FILES) {
    const src = path.join(bridgeDir, f);
    const dest = path.join(webfSrcLink, f);
    if (!fs.existsSync(src)) continue;
    fs.copyFileSync(src, dest);
    console.log(`   Copied bridge/${f} → webf/src/${f}`);
  }
}

function prepareRelease() {
  console.log('🚀 Preparing WebF package for release...\n');

  const projectRoot = path.join(__dirname, '..');
  const webfSrcLink = path.join(projectRoot, 'webf', 'src');

  console.log('📦 Cleaning up development artifacts...');

  // Materialise webf/src as a real directory so the iOS pod can ship
  // as source. Previously this step removed the dev symlink unconditionally
  // because all platforms shipped prebuilt binaries; now that iOS ships
  // from source the published package must include the bridge sources
  // the pod's Classes shims #include.
  console.log('\n1️⃣  Materialising webf/src for source-mode iOS pod...');
  materializeBridgeSourceUnderWebfSrc(projectRoot);
  
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