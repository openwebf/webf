#!/usr/bin/env node

/**
 * Batch Snapshot Comparison Script
 * 
 * Compare all snapshots in a directory or from a specific test group
 * 
 * Usage:
 *   ./compare-all-snapshots.js css-text-mixin
 *   ./compare-all-snapshots.js css/css-overflow
 *   ./compare-all-snapshots.js --all
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const glob = require('glob');

// Simple glob implementation if not available
function findFiles(pattern) {
  const globLib = require('glob');
  return globLib.sync(pattern);
}

// Parse arguments
const args = process.argv.slice(2);

if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
  console.log(`
📸 Batch Snapshot Comparison Tool

Compare multiple WebF and Chrome runner snapshots.

Usage:
  ./compare-all-snapshots.js <directory|group> [options]
  ./compare-all-snapshots.js --all [options]

Examples:
  ./compare-all-snapshots.js css-text-mixin
  ./compare-all-snapshots.js css/css-overflow
  ./compare-all-snapshots.js --all --port 4000

Options:
  --all              Compare all tests with snapshots
  --port <number>    Port for web interface (default: 3000)
  --summary          Show summary only, don't start web server
  --help, -h         Show this help message
  `);
  process.exit(0);
}

// Configuration
const compareScript = path.join(__dirname, 'compare-snapshots.js');
const specsDir = path.join(__dirname, 'specs');
const snapshotsDir = path.join(__dirname, 'snapshots');
const port = args.includes('--port') ? args[args.indexOf('--port') + 1] : '3000';
const summaryOnly = args.includes('--summary');
const compareAll = args.includes('--all');

// Determine which tests to run
let testPattern;
if (compareAll) {
  testPattern = path.join(snapshotsDir, '**/*.png');
} else {
  const target = args.find(arg => !arg.startsWith('--'));
  if (!target) {
    console.error('❌ Error: No directory or group specified');
    process.exit(1);
  }
  testPattern = path.join(snapshotsDir, target, '**/*.png');
}

console.log('🔍 Finding tests with snapshots...\n');

// Find all snapshot files
let snapshotFiles;
try {
  snapshotFiles = findFiles(testPattern);
} catch (error) {
  // Fallback to manual directory traversal
  snapshotFiles = [];
  function walkDir(dir) {
    if (!fs.existsSync(dir)) return;
    const files = fs.readdirSync(dir);
    files.forEach(file => {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        walkDir(fullPath);
      } else if (file.endsWith('.png')) {
        snapshotFiles.push(fullPath);
      }
    });
  }
  walkDir(compareAll ? snapshotsDir : path.join(snapshotsDir, args[0]));
}

if (snapshotFiles.length === 0) {
  console.log('❌ No snapshot files found');
  process.exit(0);
}

// Extract unique test files from snapshots
const testFiles = new Set();
snapshotFiles.forEach(snapshot => {
  // Extract test file path from snapshot filename
  const relativePath = path.relative(snapshotsDir, snapshot);
  const testPath = relativePath.replace(/\.[a-f0-9]{8}\d+\.png$/, '');
  testFiles.add('specs/' + testPath);
});

console.log(`Found ${testFiles.size} test file(s) with snapshots:\n`);
Array.from(testFiles).forEach(file => {
  console.log(`  - ${file}`);
});

if (summaryOnly) {
  console.log('\n✅ Summary complete (--summary flag used)');
  process.exit(0);
}

// Run comparisons
console.log('\n🚀 Starting batch comparison...\n');

const results = [];
let currentIndex = 0;
const testArray = Array.from(testFiles);

function runNextComparison() {
  if (currentIndex >= testArray.length) {
    showSummary();
    return;
  }

  const testFile = testArray[currentIndex];
  console.log(`\n[${currentIndex + 1}/${testArray.length}] Comparing: ${testFile}`);
  
  try {
    // Run comparison for this test file
    execSync(`node ${compareScript} ${testFile} --port ${port} --no-open`, {
      stdio: 'inherit'
    });
    results.push({ file: testFile, status: 'success' });
  } catch (error) {
    results.push({ file: testFile, status: 'failed', error: error.message });
  }

  currentIndex++;
  
  // Add a small delay between tests
  setTimeout(runNextComparison, 1000);
}

function showSummary() {
  console.log('\n' + '='.repeat(60));
  console.log('📊 Batch Comparison Summary');
  console.log('='.repeat(60) + '\n');

  const successful = results.filter(r => r.status === 'success').length;
  const failed = results.filter(r => r.status === 'failed').length;

  console.log(`✅ Successful: ${successful}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`📁 Total: ${results.length}\n`);

  if (failed > 0) {
    console.log('Failed comparisons:');
    results.filter(r => r.status === 'failed').forEach(r => {
      console.log(`  - ${r.file}`);
    });
  }

  console.log('\n✨ Batch comparison complete!');
  
  if (successful > 0) {
    console.log(`\n🌐 View results at: http://localhost:${port}`);
    console.log('   (Web server is running for the last successful comparison)');
  }
}

// Start the batch process
runNextComparison();