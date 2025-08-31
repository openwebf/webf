#!/usr/bin/env node

/**
 * Snapshot Comparison Script
 * 
 * Usage:
 *   ./compare-snapshots.js <spec-file>
 *   ./compare-snapshots.js specs/css/css-text-mixin/color_relative_properties_test.ts
 *   ./compare-snapshots.js css/css-text-mixin/color_relative_properties_test.ts
 * 
 * Options:
 *   --port <number>     Port for web interface (default: 3500)
 *   --threshold <num>   Pixel difference threshold 0-1 (default: 0.1)
 *   --no-open          Don't auto-open browser
 *   --help             Show help
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Parse command line arguments
const args = process.argv.slice(2);
if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
  console.log(`
📸 WebF Snapshot Comparison Tool

Compare visual snapshots between WebF integration tests and Chrome runner.

Usage:
  ./compare-snapshots.js <spec-file> [options]

Examples:
  ./compare-snapshots.js specs/css/css-text-mixin/color_relative_properties_test.ts
  ./compare-snapshots.js css/css-overflow/overflow-inline.ts --port 4000
  ./compare-snapshots.js specs/dom/elements/canvas.ts --threshold 0.2

Options:
  --port <number>     Port for web interface (default: 3500)
  --threshold <num>   Pixel difference threshold 0-1 (default: 0.1)
  --no-open          Don't automatically open browser
  --help, -h         Show this help message

The tool will:
1. Run WebF integration test for the specified file
2. Run Chrome runner test for the same file
3. Compare all generated snapshots
4. Start a web server with visual comparison interface
  `);
  process.exit(0);
}

// Extract spec file (first non-option argument)
let specFile = null;
const options = [];

for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg.startsWith('--')) {
    options.push(arg);
    // Include the next argument if it's a value for this option
    if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
      options.push(args[i + 1]);
      i++;
    }
  } else if (!specFile) {
    specFile = arg;
  }
}

if (!specFile) {
  console.error('❌ Error: No spec file provided');
  process.exit(1);
}

// Normalize spec file path
if (!specFile.startsWith('specs/')) {
  specFile = 'specs/' + specFile;
}

// Check if comparison tool is built
const compareToolPath = path.join(__dirname, 'snapshot-compare');
const cliPath = path.join(compareToolPath, 'lib', 'cli.js');

if (!fs.existsSync(cliPath)) {
  console.log('🔨 Building snapshot comparison tool...');
  const buildProcess = spawn('npm', ['run', 'build'], {
    cwd: compareToolPath,
    stdio: 'inherit'
  });
  
  buildProcess.on('close', (code) => {
    if (code !== 0) {
      console.error('❌ Failed to build comparison tool');
      process.exit(1);
    }
    runComparison();
  });
} else {
  runComparison();
}

function runComparison() {
  console.log(`\n🔍 Comparing snapshots for: ${specFile}\n`);
  
  // Run the comparison tool via Node to avoid exec permission issues
  const compareProcess = spawn(process.execPath, [cliPath, specFile, ...options], {
    stdio: 'inherit'
  });

  compareProcess.on('close', (code) => {
    if (code !== 0) {
      console.error('\n❌ Comparison failed');
      process.exit(1);
    }
  });

  // Handle Ctrl+C gracefully
  process.on('SIGINT', () => {
    compareProcess.kill('SIGINT');
    process.exit(0);
  });
}
