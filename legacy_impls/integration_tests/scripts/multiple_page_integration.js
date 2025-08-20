/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const { spawn, spawnSync } = require('child_process');
const path = require('path');
const os = require('os');

// Dart null safety error didn't report in dist binaries. Should run integration test with flutter run directly.
function startIntegrationTest() {
  const shouldSkipBuild = /skip\-build/.test(process.argv);
  if (!shouldSkipBuild) {
    spawnSync('flutter', ['build', 'macos', '--debug', '--target=lib/multiple_page.dart'], {
      stdio: 'inherit'
    });
  }

  const platform = os.platform();
  let testExecutable;
  if (platform === 'linux') {
    testExecutable = path.join(__dirname, '../build/linux/x64/debug/bundle/app');
  } else if (platform === 'darwin') {
    testExecutable = path.join(__dirname, '../build/macos/Build/Products/Debug/tests.app/Contents/MacOS/tests');
  } else {
    throw new Error('Unsupported platform:' + platform);
  }

  const tester = spawn(testExecutable, [], {
    env: {
      ...process.env,
      WEBF_ENABLE_TEST: 'true',
      'enable-software-rendering': true,
      'skia-deterministic-rendering': true,
      WEBF_TEST_DIR: path.join(__dirname, '../')
    },
    cwd: process.cwd(),
    stdio: 'inherit'
  });

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

startIntegrationTest();
