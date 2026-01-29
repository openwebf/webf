/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const {spawn, spawnSync} = require('child_process');
const path = require('path');
const os = require('os');
const {startWsServer} = require('./ws_server');

// Show usage help
function showHelp() {
  console.log(`
WebF Integration Test Runner

Usage:
  npm run integration                                    Run all integration tests
  npm run integration -- <spec-file>                    Run specific test file
  npm run integration -- <spec-file1> <spec-file2>      Run multiple test files
  npm run integration -- <spec-file> --filter "<test-name>"  Run specific test within a file

Examples:
  npm run integration -- specs/css/css_text_baseline_test.ts
  npm run integration -- specs/css/css_locale_support_test.ts
  npm run integration -- specs/css/css_color_relative_properties_test.ts specs/css/css_text_effects_test.ts
  npm run integration -- specs/css/css-inline-formatting/bidi-basic-rtl.ts --filter "should handle nested direction changes"

Options:
  --help, -h                                            Show this help message
  --skip-build                                          Skip the Flutter build step
  --filter "<test-name>"                                Filter to run only tests matching the name
  --enable-blink                                        Enable Blink compatibility mode and include blink-only specs (default: disabled)

Note:
  Tests in specs/blink-only/ directory only run when --enable-blink is specified.
  These tests cover features that require Blink mode, such as document.styleSheets.
`);
}

// Parse command line arguments for specific spec files
function parseArgs() {
  const args = process.argv.slice(2);
  const specFiles = [];
  const otherArgs = [];
  let filter = null;
  let enableBlink = false;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === '--help' || arg === '-h') {
      showHelp();
      process.exit(0);
    }

    // Handle --filter option
    if (arg === '--filter' && i + 1 < args.length) {
      filter = args[i + 1];
      i++; // Skip the next argument as it's the filter value
      continue;
    }

    // Handle --enable-blink option
    if (arg === '--enable-blink') {
      enableBlink = true;
      continue;
    }

    // Handle spec files (can start with specs/ or ./specs/)
    if ((arg.startsWith('specs/') || arg.startsWith('./specs/')) &&
        (arg.endsWith('.ts') || arg.endsWith('.js') || arg.endsWith('.tsx') || arg.endsWith('.jsx'))) {
      // Normalize path to start with specs/
      const normalizedPath = arg.startsWith('./') ? arg.slice(2) : arg;
      specFiles.push(normalizedPath);
    } else if (arg !== '--' && !arg.startsWith('-')) {
      // Skip npm's -- separator and other flags
      otherArgs.push(arg);
    }
  }

  return { specFiles, otherArgs, filter, enableBlink };
}

// Build specs with optional filtering
function buildSpecs(specFiles, enableBlink) {
  console.log('Building integration test specs...');

  const env = { ...process.env };

  // If specific spec files are provided, set WEBF_TEST_FILTER
  if (specFiles.length > 0) {
    console.log('Running specific spec files:', specFiles.join(', '));
    // Create a filter that matches the full relative path
    env.WEBF_TEST_FILTER = specFiles.map(f => f.replace(/\\/g, '/')).join('|');
  }

  // Pass enableBlink to webpack so blink-only specs are included
  if (enableBlink) {
    env.WEBF_ENABLE_BLINK = 'true';
  }

  const result = spawnSync('npm', ['run', 'specs'], {
    stdio: 'inherit',
    env: env,
    shell: true,
  });

  if (result.status !== 0) {
    console.error('Failed to build specs');
    process.exit(1);
  }
}

function getRunningPlatform() {
  if (os.platform() == 'darwin') return 'macos';
  if (os.platform() == 'linux') return 'linux';
  if (os.platform() == 'win32') return 'windows';
}

// Dart null safety error didn't report in dist binaries. Should run integration test with flutter run directly.
function startIntegrationTest(websocketPort, filter, enableBlink) {
  const shouldSkipBuild = /skip\-build/.test(process.argv);
  if (!shouldSkipBuild) {
    console.log('Building integration tests macOS application from "lib/main.dart"...');
    spawnSync('flutter', ['build', getRunningPlatform(), '--debug'], {
      stdio: 'inherit',
      shell: true
    });
  }

  const platform = os.platform();
  let testExecutable;
  if (platform === 'linux') {
    testExecutable = path.join(__dirname, '../build/linux/x64/debug/bundle/app');
  } else if (platform === 'darwin') {
    testExecutable = path.join(__dirname, '../build/macos/Build/Products/Debug/tests.app/Contents/MacOS/tests');
  } else if (platform == 'win32') {
    testExecutable = path.join(__dirname, '../build/windows/x64/runner/Debug/app.exe');
  } else {
    throw new Error('Unsupported platform:' + platform);
  }

  const env = {
    ...process.env,
    WEBF_ENABLE_TEST: 'true',
    WEBF_WEBSOCKET_SERVER_PORT: websocketPort,
    'enable-software-rendering': true,
    'skia-deterministic-rendering': true,
    WEBF_TEST_DIR: path.join(__dirname, '../')
  };

  // Pass filter through environment variable
  if (filter) {
    env.WEBF_TEST_NAME_FILTER = filter;
    console.log(`Running tests with filter: "${filter}"`);
  }

  // Pass enableBlink through environment variable
  if (enableBlink) {
    env.WEBF_ENABLE_BLINK = 'true';
    console.log('Running tests with Blink compatibility mode enabled');
  }

  const tester = spawn(testExecutable, [], {
    env: env,
    cwd: process.cwd(),
    stdio: 'pipe'
  });

  // Pipe child process output directly to parent to avoid truncation
  // or formatting issues with long lines.
  if (tester.stdout) {
    tester.stdout.pipe(process.stdout);
  }
  if (tester.stderr) {
    tester.stderr.pipe(process.stderr);
  }

  tester.on('close', (code) => {
    process.exit(code);
  });
  tester.on('error', (error) => {
    console.error('integration failed', error);
    process.exit(1);
  });
  tester.on('exit', (code, signal) => {
    if (signal) {
      console.log('Process exit with ' + signal);
      process.exit(1);
    }
    if (code != 0) {
      process.exit(1);
    }
  });
}

function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function main() {
  const { specFiles, otherArgs, filter, enableBlink } = parseArgs();

  // Build specs with optional filtering
  buildSpecs(specFiles, enableBlink);

  const port = await getRandomNumber(11000, 14000);

  startIntegrationTest(port, filter, enableBlink);
  startWsServer(port);
}

main();
