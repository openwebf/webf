/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const { spawn, spawnSync } = require('child_process');
const path = require('path');
const os = require('os');
const Jasmine = require('jasmine');
const jasmine = new Jasmine();

let tester;

function buildRunner() {
  console.log('Building integration tests macOS application from "lib/main.dart"...');
  spawnSync('flutter', ['build', 'macos', '--debug'], {
    stdio: 'inherit'
  });
}

// Dart null safety error didn't report in dist binaries. Should run integration test with flutter run directly.
function startIntegrationTest(skipBuild = false) {
  return new Promise((resolve, reject) => {
    const platform = os.platform();
    let testExecutable;
    if (platform === 'linux') {
      testExecutable = path.join(__dirname, '../build/linux/x64/debug/bundle/inspector_test');
    } else if (platform === 'darwin') {
      testExecutable = path.join(__dirname, '../build/macos/Build/Products/Debug/inspector_test.app/Contents/MacOS/inspector_test');
    } else {
      throw new Error('Unsupported platform:' + platform);
    }

    tester = spawn(testExecutable, [], {
      env: {
        ...process.env,
      },
      cwd: process.cwd(),
      stdio: 'pipe'
    });
    tester.stdout.on('data', (message) => {
      let logMessage = message.toString();
      const pattern = /WebF DevTool listening at (ws\:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{3,5})/;
      let result;
      if (result = pattern.exec(message)) {
        resolve(result[1]);
      }
    });
    tester.stdout.pipe(process.stdout);

    tester.on('close', (code) => {

    });
    tester.on('error', (error) => {
      console.error('integration failed', error);
      process.exit(1);
    });
    // tester.on('exit', (code, signal) => {
    //   if (signal) {
    //     console.log('Process exit with ' + signal);
    //     process.exit(1);
    //   }
    //   if (code != 0) {
    //     process.exit(1);
    //   }
    // });

    process.on('exit', () => {
      tester.kill();
    });
  });
}

jasmine.configureDefaultReporter({
  // The `timer` passed to the reporter will determine the mechanism for seeing how long the suite takes to run.
  timer: new jasmine.jasmine.Timer(),
  // The `print` function passed the reporter will be called to print its results.
  print: function(message) {
    process.stdout.write(message);
  },
  // `showColors` determines whether or not the reporter should use ANSI color codes.
  showColors: true
});


buildRunner();

globalThis.DEBUG_HOST_SERVER = 'ws://127.0.0.1:9222';
jasmine.execute([path.join(__dirname, '../.specs/bundle.build.js')]);

globalThis.reRestartApp = async () => {
  if (tester) {
    tester.kill();
  }
  await startIntegrationTest(true);
}
