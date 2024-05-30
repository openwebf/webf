/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const { spawn, spawnSync } = require('child_process');
const path = require('path');
const os = require('os');
const { startWsServer } = require('./ws_server');

function getRunningPlatform() {
  if (os.platform() == 'darwin') return 'macos';
  if (os.platform() == 'linux') return 'linux';
  if (os.platform() == 'win32') return 'windows';
}

// Dart null safety error didn't report in dist binaries. Should run integration test with flutter run directly.
function startIntegrationTest() {
  const shouldSkipBuild = /skip\-build/.test(process.argv);
  if (!shouldSkipBuild) {
    console.log('Building integration tests macOS application from "lib/main.dart"...');
    spawnSync('flutter', ['build', getRunningPlatform(), '--debug'], {
      stdio: 'inherit'
    });
  }

  const platform = os.platform();
  let testExecutable;
  if (platform === 'linux') {
    testExecutable = path.join(__dirname, '../build/linux/x64/debug/bundle/app');
  } else if (platform === 'darwin') {
    testExecutable = path.join(__dirname, '../build/macos/Build/Products/Debug/tests.app/Contents/MacOS/tests');
  } else if (platform == 'win32') {
    testExecutable = path.join(__dirname, '../build/windows/runner/Debug/app.exe');
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
    stdio: 'pipe'
  });

  tester.stdout.on('data', (data) => {
    console.log(`${data && data.toString().trim()}`);
  });

  tester.stderr.on('data', (data) => {
    console.error(`${data && data.toString().trim()}`);
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
startWsServer(8399);
