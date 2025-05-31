/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

const { src, dest, series, parallel, task } = require('gulp');
const mkdirp = require('mkdirp');
const path = require('path');
const { readFileSync, writeFileSync, mkdirSync } = require('fs');
const { spawnSync, execSync, fork, spawn, exec } = require('child_process');
const { join, resolve } = require('path');
const { program } = require('commander');
const chalk = require('chalk');
const fs = require('fs');
const del = require('del');
const os = require('os');
const uploader = require('./utils/uploader');

program
  .option('--static-quickjs', 'Build quickjs as static library and bundled into webf library.', false)
  .option('--enable-log', 'Enable log printing')
  .parse(process.argv);

const SUPPORTED_JS_ENGINES = ['jsc', 'quickjs'];
const targetJSEngine = process.env.WEBF_JS_ENGINE || 'quickjs';

if (SUPPORTED_JS_ENGINES.indexOf(targetJSEngine) < 0) {
  throw new Error('Unsupported js engine:' + targetJSEngine);
}

const WEBF_ROOT = join(__dirname, '..');
const TARGET_PATH = join(WEBF_ROOT, 'targets');
const platform = os.platform();
const buildMode = process.env.WEBF_BUILD || 'Debug';
const paths = {
  targets: resolveWebF('targets'),
  scripts: resolveWebF('scripts'),
  example: resolveWebF('webf/example'),
  webf: resolveWebF('webf'),
  bridge: resolveWebF('bridge'),
  polyfill: resolveWebF('bridge/polyfill'),
  codeGen: resolveWebF('bridge/scripts/code_generator'),
  thirdParty: resolveWebF('third_party'),
  tests: resolveWebF('integration_tests'),
  sdk: resolveWebF('sdk'),
  templates: resolveWebF('scripts/templates'),
  performanceTests: resolveWebF('performance_tests')
};

const NPM = platform == 'win32' ? 'npm.cmd' : 'npm';
const pkgVersion = readFileSync(path.join(paths.webf, 'pubspec.yaml'), 'utf-8').match(/version: (.*)/)[1].trim();
const isProfile = process.env.ENABLE_PROFILE === 'true';

exports.paths = paths;
exports.pkgVersion = pkgVersion;

let winShell = null;
if (platform == 'win32') {
  winShell = path.join(process.env.ProgramW6432, '\\Git\\bin\\bash.exe');

  if (!fs.existsSync(winShell)) {
    return done(new Error(`Can not location bash.exe, Please install Git for Windows at ${process.env.ProgramW6432}. \n https://git-scm.com/download/win`));
  }
}

function resolveWebF(submodule) {
  return resolve(WEBF_ROOT, submodule);
}

task('clean', () => {
  execSync('git clean -xfd', {
    cwd: paths.example,
    env: process.env,
    stdio: 'inherit'
  });

  if (buildMode === 'All') {
    return del(join(TARGET_PATH, platform));
  } else {
    return del(join(TARGET_PATH, platform, buildMode.toLowerCase()));
  }
});

const libOutputPath = join(TARGET_PATH, platform, 'lib');

task('compile-build-tools', done => {
  let buildType = 'Debug';

  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-x86_64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/macos/lib/x86_64')
    }
  });

  let webfTargets = ['qjsc'];

  let cpus = os.cpus();
  execSync(`cmake --build ${paths.bridge}/cmake-build-macos-x86_64 --target ${webfTargets.join(' ')} -- -j ${cpus.length}`, {
    stdio: 'inherit'
  });

  done();
});

task('build-darwin-webf-lib', done => {
  let externCmakeArgs = [];
  let buildType = 'Debug';
  if (process.env.WEBF_BUILD === 'Release') {
    buildType = 'RelWithDebInfo';
  }

  if (isProfile) {
    externCmakeArgs.push('-DENABLE_PROFILE=TRUE');
  }

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  // Bundle quickjs into webf.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} -DENABLE_TEST=true ${externCmakeArgs.join(' ')} \
    -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-x86_64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/macos/lib/x86_64')
    }
  });

  let webfTargets = ['webf', 'qjsc'];
  if (targetJSEngine === 'quickjs') {
    webfTargets.push('webf_unit_test');
  }
  if (buildMode === 'Debug') {
    webfTargets.push('webf_test');
  }

  let cpus = os.cpus();
  execSync(`cmake --build ${paths.bridge}/cmake-build-macos-x86_64 --target ${webfTargets.join(' ')} -- -j ${cpus.length}`, {
    stdio: 'inherit'
  });

  const binaryPath = path.join(paths.bridge, `build/macos/lib/x86_64/libwebf.dylib`);

  if (buildMode == 'Release' || buildMode == 'RelWithDebInfo') {
    execSync(`dsymutil ${binaryPath}`, { stdio: 'inherit' });
    execSync(`strip -S -X -x ${binaryPath}`, { stdio: 'inherit' });
  }

  done();
});

task('run-bridge-unit-test', done => {
  if (platform === 'darwin') {
    execSync(`${path.join(paths.bridge, 'build/macos/lib/x86_64/webf_unit_test')}`, { stdio: 'inherit' });
  } else if (platform === 'linux') {
    execSync(`${path.join(paths.bridge, 'build/linux/lib/webf_unit_test')}`, { stdio: 'inherit' });
  } else if (platform == 'win32') {
    execSync(`${path.join(paths.bridge, 'build/windows/lib/webf_unit_test.exe')}`, { stdio: 'inherit' });
  }
  done();
});

task('compile-polyfill', (done) => {
  if (!fs.existsSync(path.join(paths.polyfill, 'node_modules'))) {
    spawnSync(NPM, ['install'], {
      cwd: paths.polyfill,
      stdio: 'inherit'
    });
  }

  let result = spawnSync(NPM, ['run', (buildMode === 'Release' || buildMode === 'RelWithDebInfo') ? 'build:release' : 'build'], {
    cwd: paths.polyfill,
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine
    },
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  done();
});


function matchError(errmsg) {
  return errmsg.match(/(Failed assertion|\sexception\s|Dart\nError)/i);
}

task('integration-test', (done) => {
  const childProcess = spawn('npm', ['run', 'test'], {
    stdio: 'pipe',
    cwd: paths.tests
  });

  let stdout = '';

  childProcess.stderr.pipe(process.stderr);
  childProcess.stdout.pipe(process.stdout);

  childProcess.stderr.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.stdout.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.on('error', (error) => {
    done(error);
  });

  childProcess.on('close', (code) => {
    let dartErrorMatch = matchError(stdout);
    if (dartErrorMatch) {
      let error = new Error('UnExpected Flutter Assert Failed.');
      done(error);
      return;
    }

    if (code === 0) {
      done();
    } else {
      // TODO: collect error message from stdout.
      const err = new Error('Some error occurred, please check log.');
      done(err);
    }
  });
});

task('plugin-test', (done) => {
  const childProcess = spawn('npm', ['run', 'plugin_test'], {
    stdio: 'pipe',
    cwd: paths.tests
  });

  let stdout = '';

  childProcess.stderr.pipe(process.stderr);
  childProcess.stdout.pipe(process.stdout);

  childProcess.stderr.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.stdout.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.on('error', (error) => {
    done(error);
  });

  childProcess.on('close', (code) => {
    let dartErrorMatch = matchError(stdout);
    if (dartErrorMatch) {
      let error = new Error('UnExpected Flutter Assert Failed.');
      done(error);
      return;
    }

    if (code === 0) {
      done();
    } else {
      // TODO: collect error message from stdout.
      const err = new Error('Some error occurred, please check log.');
      done(err);
    }
  });
});

task('unit-test', (done) => {
  const childProcess = spawn('flutter', ['test', '--coverage'], {
    stdio: 'pipe',
    cwd: paths.webf
  });

  let stdout = '';

  childProcess.stderr.pipe(process.stderr);
  childProcess.stdout.pipe(process.stdout);

  childProcess.stderr.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.stdout.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.on('error', (error) => {
    done(error);
  });

  childProcess.on('close', (code) => {
    let dartErrorMatch = matchError(stdout);
    if (dartErrorMatch) {
      let error = new Error('UnExpected Flutter Assert Failed.');
      done(error);
      return;
    }

    if (code === 0) {
      done();
    } else {
      done(new Error('Some error occurred, please check log.'));
    }
  });
});

task('unit-test-coverage-reporter', (done) => {
  const childProcess = spawn('npm', ['run', 'test:unit:report'], {
    stdio: 'inherit',
    cwd: WEBF_ROOT,
  });
  childProcess.on('exit', () => {
    done();
  });
});

task('sdk-clean', (done) => {
  execSync(`rm -rf ${paths.sdk}/build`, { stdio: 'inherit' });
  done();
});

function insertStringSlice(code, position, slice) {
  let leftHalf = code.substring(0, position);
  let rightHalf = code.substring(position);

  return leftHalf + slice + rightHalf;
}

function patchiOSFrameworkPList(frameworkPath) {
  const pListPath = path.join(frameworkPath, 'Info.plist');
  let pListString = fs.readFileSync(pListPath, { encoding: 'utf-8' });
  let versionIndex = pListString.indexOf('CFBundleVersion');
  if (versionIndex != -1) {
    let versionStringLast = pListString.indexOf('</string>', versionIndex) + '</string>'.length;

    pListString = insertStringSlice(pListString, versionStringLast, `
        <key>MinimumOSVersion</key>
        <string>11.0</string>`);
    fs.writeFileSync(pListPath, pListString);
  }
}

task(`build-ios-webf-lib`, (done) => {
  const buildType = (buildMode == 'Release' || buildMode === 'RelWithDebInfo') ? 'RelWithDebInfo' : 'Debug';
  let externCmakeArgs = [];

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into webf.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  // generate build scripts for simulator
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=SIMULATOR64 \
    -DDEPLOYMENT_TARGET=11.0 \
    -DIS_IOS=TRUE \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-simulator-x86 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/simulator_x86')
    }
  });
  // genereate build scripts for simulator arm64
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=SIMULATORARM64 \
    -DDEPLOYMENT_TARGET=11.0 \
    -DIS_IOS=TRUE \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-simulator-arm64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/simulator_arm64')
    }
  });

  let cpus = os.cpus();

  // build for simulator x86
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-simulator-x86 --target webf -- -j ${cpus.length}`, {
    stdio: 'inherit'
  });

  // build for simulator arm64
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-simulator-arm64 --target webf -- -j ${cpus.length}`, {
    stdio: 'inherit'
  });

  // Generate builds scripts for ARM64
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=OS64 \
    -DDEPLOYMENT_TARGET=11.0 \
    -DIS_IOS=TRUE \
    ${externCmakeArgs.join(' ')} \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm64')
    }
  });

  // Build for ARM64
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm64 --target webf -- -j ${cpus.length}`, {
    stdio: 'inherit'
  });

  const targetSourceFrameworks = ['webf_bridge'];

  // If quickjs is not static, there will be another framework called quickjs.framework.
  if (!program.staticQuickjs) {
    targetSourceFrameworks.push('quickjs');
  }

  targetSourceFrameworks.forEach(target => {
    const arm64DynamicSDKPath = path.join(paths.bridge, `build/ios/lib/arm64/${target}.framework`);
    const simulatorX64DynamicSDKPath = path.join(paths.bridge, `build/ios/lib/simulator_x86/${target}.framework`);
    const simulatorArm64DynamicSDKPath = path.join(paths.bridge, `build/ios/lib/simulator_arm64/${target}.framework`);

    // Create flat simulator frameworks with multiple archs.
    execSync(`lipo -create ${simulatorX64DynamicSDKPath}/${target} ${simulatorArm64DynamicSDKPath}/${target} -output ${simulatorX64DynamicSDKPath}/${target}`, {
      stdio: 'inherit'
    });

    // CMake generated iOS frameworks does not contains <MinimumOSVersion> key in Info.plist.
    patchiOSFrameworkPList(simulatorX64DynamicSDKPath);;
    patchiOSFrameworkPList(arm64DynamicSDKPath);

    const targetDynamicSDKPath = `${paths.bridge}/build/ios/framework`;
    const frameworkPath = `${targetDynamicSDKPath}/${target}.xcframework`;
    mkdirp.sync(targetDynamicSDKPath);

    // dSYM file are located at /path/to/webf/build/ios/lib/${arch}/target.dSYM.
    // Create dSYM for simulator.
    execSync(`dsymutil ${simulatorX64DynamicSDKPath}/${target} --out ${simulatorX64DynamicSDKPath}/../${target}.dSYM`, { stdio: 'inherit' });
    // Create dSYM for arm64,armv7.
    execSync(`dsymutil ${arm64DynamicSDKPath}/${target} --out ${arm64DynamicSDKPath}/../${target}.dSYM`, { stdio: 'inherit' });

    // Generated xcframework at located at /path/to/webf/build/ios/framework/${target}.xcframework.
    // Generate xcframework with dSYM.
    if (buildMode === 'RelWithDebInfo') {
      execSync(`xcodebuild -create-xcframework \
        -framework ${simulatorX64DynamicSDKPath} -debug-symbols ${simulatorX64DynamicSDKPath}/../${target}.dSYM \
        -framework ${arm64DynamicSDKPath} -debug-symbols ${arm64DynamicSDKPath}/../${target}.dSYM -output ${frameworkPath}`, {
        stdio: 'inherit'
      });
    } else {
      execSync(`xcodebuild -create-xcframework \
        -framework ${simulatorX64DynamicSDKPath} \
        -framework ${arm64DynamicSDKPath} -output ${frameworkPath}`, {
        stdio: 'inherit'
      });
    }
  });
  done();
});

task('build-linux-webf-lib', (done) => {
  const buildType = buildMode == 'Release' ? 'Release' : 'RelWithDebInfo';
  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';

  let externCmakeArgs = [];

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  const soBinaryDirectory = path.join(paths.bridge, `build/linux/lib/`);
  const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-linux');
  // generate project
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
  ${externCmakeArgs.join(' ')} \
  ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
  ${'-DENABLE_TEST=true \\'}
  -G "${cmakeGeneratorTemplate}" \
  -B ${paths.bridge}/cmake-build-linux -S ${paths.bridge}`,
    {
      cwd: paths.bridge,
      stdio: 'inherit',
      env: {
        ...process.env,
        WEBF_JS_ENGINE: targetJSEngine,
        LIBRARY_OUTPUT_DIR: soBinaryDirectory
      }
    });

  // build
  execSync(`cmake --build ${bridgeCmakeDir} --target webf ${buildMode != 'Release' ? 'webf_test' : ''} webf_unit_test -- -j 12`, {
    stdio: 'inherit'
  });

  const libs = [
    'libwebf.so'
  ];

  if (buildMode != 'Release') {
    libs.push('libwebf_test.so');
  }

  libs.forEach(lib => {
    const libkrakenPath = path.join(paths.bridge, `build/linux/lib/${lib}`);
    // Patch libkraken.so's runtime path.
    execSync(`chrpath --replace \\$ORIGIN ${libkrakenPath}`, { stdio: 'inherit' });
  });

  done();
});

task('generate-polyfill-bytecode', (done) => {
  if (platform == 'darwin') {
    const qjscExecDir = path.join(paths.bridge, 'build/macos/lib/x86_64/');
    const polyfillTarget = path.join(paths.bridge, 'core/bridge_polyfill.c');
    const polyfillSource = path.join(paths.polyfill, 'dist/main.js');
    let polyfillCompileResult = spawnSync('./qjsc', ['-c', '-N', 'bridge_polyfill', '-o', polyfillTarget, polyfillSource], {
      cwd: qjscExecDir,
      shell: true,
      stdio: 'inherit'
    });
    if (polyfillCompileResult.status !== 0) {
      return done(compileResult.status);
    }

    const testPpolyfillTarget = path.join(paths.bridge, 'test/test_framework_polyfill.c');
    const testPolyfillSource = path.join(paths.polyfill, 'dist/test.js');
    let testPolyfillCompileResult = spawnSync('./qjsc', ['-c', '-N', 'test_framework_polyfill', '-o', testPpolyfillTarget, testPolyfillSource], {
      cwd: qjscExecDir,
      shell: true,
      stdio: 'inherit'
    });
    if (testPolyfillCompileResult.status !== 0) {
      return done(compileResult.status);
    }
  }
});

task('generate-bindings-code', (done) => {
  if (!fs.existsSync(path.join(paths.codeGen, 'node_modules'))) {
    spawnSync(NPM, ['install'], {
      cwd: paths.codeGen,
      stdio: 'inherit'
    });
  }

  let buildResult = spawnSync(NPM, ['run', 'build'], {
    cwd: paths.codeGen,
    env: {
      ...process.env,
    },
    shell: true,
    stdio: 'inherit'
  });

  if (buildResult.status !== 0) {
    return done(buildResult.status);
  }

  let compileResult = spawnSync('node', ['bin/code_generator', '-s', '../../core', '-d', '../../code_gen'], {
    cwd: paths.codeGen,
    env: {
      ...process.env,
    },
    shell: true,
    stdio: 'inherit'
  });

  if (compileResult.status !== 0) {
    return done(compileResult.status);
  }

  done();
});

task('build-window-webf-lib', (done) => {
  const buildType = buildMode == 'Release' ? 'RelWithDebInfo' : 'Debug';

  let externCmakeArgs = [];

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  const soBinaryDirectory = path.join(paths.bridge, `build/windows/lib/`).replaceAll(path.sep, path.posix.sep);
  const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-windows');
  // generate project
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} ${externCmakeArgs.join(' ')} -B ${bridgeCmakeDir} -S ${paths.bridge}`,
    {
      cwd: paths.bridge,
      stdio: 'inherit',
      env: {
        ...process.env,
        WEBF_JS_ENGINE: targetJSEngine,
        LIBRARY_OUTPUT_DIR: soBinaryDirectory,
        MSYSTEM_PREFIX: 'C:/msys64/mingw64'
      }
    });

  const webfTargets = ['webf'];

  // build
  execSync(`cmake --build ${bridgeCmakeDir} --target ${webfTargets.join(' ')} --verbose --config ${buildType}`, {
    stdio: 'inherit'
  });

  execSync(`cmake --install ./`, {
    stdio: 'inherit',
    cwd: path.join(paths.bridge, 'cmake-build-windows')
  });

  done();
});

task('build-android-webf-lib', (done) => {
  let ndkDir = '';

  // If ANDROID_NDK_HOME env defined, use it.
  if (process.env.ANDROID_NDK_HOME) {
    ndkDir = process.env.ANDROID_NDK_HOME;
  } else {
    let androidHome;
    if (process.env.ANDROID_HOME) {
      androidHome = process.env.ANDROID_HOME;
    } else if (platform == 'win32') {
      androidHome = path.join(process.env.LOCALAPPDATA, 'Android\\Sdk');
    } else if (platform == 'darwin') {
      androidHome = path.join(process.env.HOME, 'Library/Android/sdk')
    } else if (platform == 'linux') {
      androidHome = path.join(process.env.HOME, 'Android/Sdk');
    }
    const ndkVersion = '22.1.7171670';
    ndkDir = path.join(androidHome, 'ndk', ndkVersion);

    if (!fs.existsSync(ndkDir)) {
      throw new Error(`Android NDK version (${ndkVersion}) not installed.`);
    }
  }

  const archs = ['arm64-v8a', 'armeabi-v7a', 'x86'];
  const toolChainMap = {
    'arm64-v8a': 'aarch64-linux-android',
    'armeabi-v7a': 'arm-linux-androideabi',
    'x86': 'i686-linux-android'
  };
  const buildType = (buildMode === 'Release' || buildMode == 'RelWithDebInfo') ? 'RelWithDebInfo' : 'Debug';
  let externCmakeArgs = [];

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  // Bundle quickjs into webf.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  const soFileNames = [
    'libwebf',
    'libc++_shared'
  ];

  // If quickjs is not static, there will be another so called libquickjs.so.
  if (!program.staticQuickjs) {
    soFileNames.push('libquickjs');
  }

  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';
  archs.forEach(arch => {
    const soBinaryDirectory = path.join(paths.bridge, `build/android/lib/${arch}`);
    const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-android-' + arch);
    // generate project
    execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${path.join(ndkDir, '/build/cmake/android.toolchain.cmake')} \
    -DANDROID_NDK=${ndkDir} \
    -DIS_ANDROID=TRUE \
    -DANDROID_ABI="${arch}" \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DANDROID_PLATFORM="android-18" \
    -DANDROID_STL=c++_shared \
    -G "${cmakeGeneratorTemplate}" \
    -B ${paths.bridge}/cmake-build-android-${arch} -S ${paths.bridge}`,
      {
        cwd: paths.bridge,
        stdio: 'inherit',
        env: {
          ...process.env,
          WEBF_JS_ENGINE: targetJSEngine,
          LIBRARY_OUTPUT_DIR: soBinaryDirectory
        }
      });

    // build
    execSync(`cmake --build ${bridgeCmakeDir} --target webf -- -j 12`, {
      stdio: 'inherit'
    });

    // Copy libc++_shared.so to dist from NDK.
    const libcppSharedPath = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/sysroot/usr/lib/${toolChainMap[arch]}/libc++_shared.so`);
    execSync(`cp ${libcppSharedPath} ${soBinaryDirectory}`);

    // Strip release binary in release mode.
    if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
      const strip = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/bin/llvm-strip`);
      const objcopy = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/bin/llvm-objcopy`);

      for (let soFileName of soFileNames) {
        const soBinaryFile = path.join(soBinaryDirectory, soFileName + '.so');
        execSync(`${objcopy} --only-keep-debug "${soBinaryFile}" "${soBinaryDirectory}/${soFileName}.debug"`);
        execSync(`${strip} --strip-debug --strip-unneeded "${soBinaryFile}"`)
      }
    }
  });

  done();
});

task('android-so-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/android`, { stdio: 'inherit' });
  done();
});

task('ios-framework-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/ios`, { stdio: 'inherit' });
  done();
});

task('macos-dylib-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/macos`, { stdio: 'inherit' });
  done();
});

task('android-so-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/android`, { stdio: 'inherit', shell: winShell });
  done();
});

task('build-benchmark-app', async (done) => {
  execSync('npm install', { cwd: path.join(paths.performanceTests, '/benchmark') });
  const result = spawnSync('npm', ['run', 'build'], {
    cwd: path.join(paths.performanceTests, '/benchmark')
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  done();
})

task('run-benchmark', async (done) => {
  const serverPort = '8892';

  const childProcess = spawn('http-server', ['./', `-p ${serverPort}`], {
    stdio: 'pipe',
    cwd: path.join(paths.performanceTests, '/benchmark/build')
  })

  let serverIpAddress;
  let interfaces = os.networkInterfaces();
  for (let devName in interfaces) {
    interfaces[devName].forEach((item) => {
      if (item.family === 'IPv4' && !item.internal && item.address !== '127.0.0.1') {
        serverIpAddress = item.address;
      }
    })
  }

  if (!serverIpAddress) {
    const err = new Error('The IP address was not found.');
    done(err);
  }

  let androidDevices = getDevicesInfo();

  let performanceInfos = execSync(
    `flutter run -d ${androidDevices[0].id} --profile --dart-define="SERVER=${serverIpAddress}:${serverPort}" | grep Performance`,
    {
      cwd: paths.performanceTests
    }
  ).toString().split(/\n/);

  const KrakenPerformancePath = 'kraken-performance';
  for (let item in performanceInfos) {
    let info = performanceInfos[item];
    const match = /\[(\s?\d,?)+\]/.exec(info);
    if (match) {
      const viewType = item == 0 ? 'kraken' : 'web';
      try {
        let performanceDatas = JSON.parse(match[0]);
        // Remove the top and the bottom five from the final numbers to eliminate fluctuations, and calculate the average.
        performanceDatas = performanceDatas.sort().slice(5, performanceDatas.length - 5);

        // Save performance list to file and upload to OSS.
        const listFile = path.join(__dirname, `${viewType}-load-time-list.js`);
        fs.writeFileSync(listFile, `performanceCallback('${viewType}LoadtimeList', [${performanceDatas.toString()}]);`);

        let WebviewPerformanceOSSPath = `${KrakenPerformancePath}/${viewType}-loadtimeList.js`;
        await uploader(WebviewPerformanceOSSPath, listFile).then(() => {
          console.log(`Performance Upload Success: https://kraken.oss-cn-hangzhou.aliyuncs.com/${WebviewPerformanceOSSPath}`);
        }).catch(err => done(err));
        // Save performance data of Webview with kraken version.
        let WebviewPerformanceWithVersionOSSPath = `${KrakenPerformancePath}/${viewType}-${pkgVersion}-loadtimeList.js`;
        await uploader(WebviewPerformanceWithVersionOSSPath, listFile).then(() => {
          console.log(`Performance Upload Success: https://kraken.oss-cn-hangzhou.aliyuncs.com/${WebviewPerformanceWithVersionOSSPath}`);
        }).catch(err => done(err));
      } catch {
        const err = new Error('The performance info parse exception.');
        done(err);
      }
    }
  }

  execSync('adb uninstall com.example.performance_tests');

  done();
});

function getDevicesInfo() {
  let output = JSON.parse(execSync('flutter devices --machine', { stdio: 'pipe', encoding: 'utf-8' }));
  let androidDevices = output.filter(device => {
    return device.sdk.indexOf('Android') >= 0;
  });
  if (androidDevices.length == 0) {
    throw new Error('Can not find android benchmark devices.');
  }
  return androidDevices;
}

// Update typings version
task('update-typings-version', (done) => {
  try {
    // Read version from webf/pubspec.yaml
    const webfPubspecPath = join(WEBF_ROOT, 'webf/pubspec.yaml');
    const webfPubspec = readFileSync(webfPubspecPath, 'utf-8');
    const webfVersion = webfPubspec.match(/version: (.*)/)[1].trim();

    // Update version in bridge/typings/package.json
    const typingsPackageJsonPath = join(WEBF_ROOT, 'bridge/typings/package.json');
    const typingsPackageContent = readFileSync(typingsPackageJsonPath, 'utf-8');

    try {
      const typingsPackageJson = JSON.parse(typingsPackageContent);
      typingsPackageJson.version = webfVersion;
      writeFileSync(typingsPackageJsonPath, JSON.stringify(typingsPackageJson, null, 2));
      console.log(chalk.green(`Update typings version to ${webfVersion}`));
    } catch (e) {
      console.error(chalk.red('Parse package.json failed:'), e);
    }

    done();
  } catch (err) {
    done(err);
  }
});

// Helper function to recursively unwrap DartImpl<T> and DependentsOnLayout<T> types
function unwrapWrapperTypes(typeNode, ts) {
  if (!typeNode) return typeNode;
  
  // If it's a type reference like DartImpl<T> or DependentsOnLayout<T>
  if (ts.isTypeReferenceNode(typeNode) && ts.isIdentifier(typeNode.typeName)) {
    const typeName = typeNode.typeName.text;
    if (typeName === 'DartImpl' || typeName === 'DependentsOnLayout') {
      // Get the inner type T and recursively unwrap it
      const innerType = typeNode.typeArguments?.[0];
      if (innerType) {
        return unwrapWrapperTypes(innerType, ts);
      }
    }
  }
  
  // If it's a union type, unwrap each member
  if (ts.isUnionTypeNode(typeNode)) {
    const unwrappedTypes = typeNode.types.map(t => unwrapWrapperTypes(t, ts));
    return ts.factory.createUnionTypeNode(unwrappedTypes);
  }
  
  // If it's an intersection type, unwrap each member
  if (ts.isIntersectionTypeNode(typeNode)) {
    const unwrappedTypes = typeNode.types.map(t => unwrapWrapperTypes(t, ts));
    return ts.factory.createIntersectionTypeNode(unwrappedTypes);
  }
  
  // For other types, return as-is
  return typeNode;
}

// Function to extract static members from interfaces
function extractStaticMembers(content) {
  const staticMembersByInterface = {};
  const ts = require('typescript');
  
  // Parse the TypeScript content into an AST
  const sourceFile = ts.createSourceFile(
    'temp.d.ts',
    content,
    ts.ScriptTarget.Latest,
    true,
    ts.ScriptKind.TS
  );
  
  // Visit each interface and extract StaticMember/StaticMethod types
  function visit(node) {
    if (ts.isInterfaceDeclaration(node)) {
      const interfaceName = node.name.text;
      const staticMembers = [];
      
      for (const member of node.members) {
        if ((ts.isPropertySignature(member) || ts.isMethodSignature(member)) && member.type) {
          const typeNode = member.type;
          
          // Check if this is a StaticMember<T> or StaticMethod<T>
          if (ts.isTypeReferenceNode(typeNode) && 
              ts.isIdentifier(typeNode.typeName) && 
              (typeNode.typeName.text === 'StaticMember' || typeNode.typeName.text === 'StaticMethod')) {
            
            const memberName = member.name;
            if (ts.isIdentifier(memberName)) {
              const innerType = typeNode.typeArguments?.[0];
              if (innerType) {
                const unwrappedType = unwrapWrapperTypes(innerType, ts);
                const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
                const typeText = printer.printNode(ts.EmitHint.Unspecified, unwrappedType, sourceFile);
                
                if (ts.isPropertySignature(member)) {
                  const readonly = member.modifiers?.some(mod => mod.kind === ts.SyntaxKind.ReadonlyKeyword) ? 'const ' : 'let ';
                  staticMembers.push(`${readonly}${memberName.text}: ${typeText}`);
                } else if (ts.isMethodSignature(member)) {
                  const params = member.parameters.map(param => {
                    const paramName = ts.isIdentifier(param.name) ? param.name.text : 'param';
                    const paramType = param.type ? printer.printNode(ts.EmitHint.Unspecified, param.type, sourceFile) : 'any';
                    const optional = param.questionToken ? '?' : '';
                    return `${paramName}${optional}: ${paramType}`;
                  }).join(', ');
                  staticMembers.push(`function ${memberName.text}(${params}): ${typeText}`);
                }
              }
            }
          }
        }
      }
      
      if (staticMembers.length > 0) {
        staticMembersByInterface[interfaceName] = staticMembers;
      }
    }
    
    ts.forEachChild(node, visit);
  }
  
  visit(sourceFile);
  return staticMembersByInterface;
}

// Function to generate async variants for SupportAsync members using TypeScript AST
function generateAsyncVariants(content) {
  const ts = require('typescript');
  
  // Parse the TypeScript content into an AST
  const sourceFile = ts.createSourceFile(
    'temp.d.ts',
    content,
    ts.ScriptTarget.Latest,
    true,
    ts.ScriptKind.TS
  );
  
  const printer = ts.createPrinter({
    newLine: ts.NewLineKind.LineFeed,
    removeComments: false,
  });
  
  // Transform function to add async variants
  const transformer = (context) => {
    return (rootNode) => {
      function visit(node) {
        // Process interface declarations
        if (ts.isInterfaceDeclaration(node)) {
          const newMembers = [];
          let hasChanges = false;
          
          // Process each member and add async variants for SupportAsync members
          for (const member of node.members) {
            // Check if this member has a name starting with __ (double underscore) and skip it
            const memberName = member.name;
            if (memberName && ts.isIdentifier(memberName) && memberName.text.startsWith('__')) {
              // Skip members with __ prefix
              hasChanges = true;
              continue;
            }
            
            // Check if this member has SupportAsync type or StaticMember type
            if (ts.isPropertySignature(member) || ts.isMethodSignature(member)) {
              const typeNode = member.type;
              
              // Check if the type is StaticMember<T> or StaticMethod<T>
              if (typeNode && ts.isTypeReferenceNode(typeNode) && 
                  ts.isIdentifier(typeNode.typeName) && 
                  (typeNode.typeName.text === 'StaticMember' || typeNode.typeName.text === 'StaticMethod')) {
                
                const memberName = member.name;
                if (ts.isIdentifier(memberName)) {
                  // Get the inner type from StaticMember<T>
                  const innerType = typeNode.typeArguments?.[0];
                  if (innerType) {
                    // Unwrap DartImpl<T> and DependentsOnLayout<T> from the inner type
                    const fullyUnwrappedType = unwrapWrapperTypes(innerType, ts);
                    
                    // Skip adding static members to interfaces - we'll handle them separately
                    // Just mark as changed and skip this member
                    hasChanges = true;
                  }
                }
              }
              // Check if the type is SupportAsync<T> or SupportAsyncManual<T>
              else if (typeNode && ts.isTypeReferenceNode(typeNode) && 
                  ts.isIdentifier(typeNode.typeName) && 
                  (typeNode.typeName.text === 'SupportAsync' || typeNode.typeName.text === 'SupportAsyncManual')) {
                
                const memberName = member.name;
                if (ts.isIdentifier(memberName)) {
                  // Get the inner type from SupportAsync<T>
                  const innerType = typeNode.typeArguments?.[0];
                  if (innerType) {
                    // Unwrap DartImpl<T> and DependentsOnLayout<T> from the inner type
                    const fullyUnwrappedType = unwrapWrapperTypes(innerType, ts);
                    
                    // Create the original member with unwrapped type T (instead of SupportAsync<T>)
                    if (ts.isPropertySignature(member)) {
                      // For properties: memberName: T;
                      const unwrappedMember = ts.factory.createPropertySignature(
                        member.modifiers, // Copy readonly, etc.
                        memberName,
                        member.questionToken,
                        fullyUnwrappedType // Use the fully unwrapped type instead of SupportAsync<T>
                      );
                      newMembers.push(unwrappedMember);
                    } else if (ts.isMethodSignature(member)) {
                      // For methods: methodName(...args): T;
                      const unwrappedMember = ts.factory.createMethodSignature(
                        member.modifiers,
                        memberName,
                        member.questionToken,
                        member.typeParameters,
                        member.parameters,
                        fullyUnwrappedType // Use the fully unwrapped type instead of SupportAsync<T>
                      );
                      newMembers.push(unwrappedMember);
                    }
                    
                    // Create async variant member name
                    const asyncMemberName = ts.factory.createIdentifier(memberName.text + '_async');
                    
                    // Create Promise<T> type with unwrapped inner type
                    const promiseType = ts.factory.createTypeReferenceNode(
                      ts.factory.createIdentifier('Promise'),
                      [fullyUnwrappedType]
                    );
                    
                    // Create the async member (property or method)
                    if (ts.isPropertySignature(member)) {
                      // For properties: memberName_async: Promise<T>;
                      const asyncMember = ts.factory.createPropertySignature(
                        member.modifiers, // Copy readonly, etc.
                        asyncMemberName,
                        member.questionToken,
                        promiseType
                      );
                      newMembers.push(asyncMember);
                    } else if (ts.isMethodSignature(member)) {
                      // For methods: methodName_async(...args): Promise<T>;
                      const asyncMember = ts.factory.createMethodSignature(
                        member.modifiers,
                        asyncMemberName,
                        member.questionToken,
                        member.typeParameters,
                        member.parameters,
                        promiseType
                      );
                      newMembers.push(asyncMember);
                    }
                    
                    hasChanges = true;
                  }
                }
              }
              // Check if the type is JSArrayProtoMethod
              else if (typeNode && ts.isTypeReferenceNode(typeNode) && 
                  ts.isIdentifier(typeNode.typeName) && 
                  typeNode.typeName.text === 'JSArrayProtoMethod') {
                
                const memberName = member.name;
                if ((ts.isIdentifier(memberName) || ts.isComputedPropertyName(memberName)) && ts.isPropertySignature(member)) {
                  // Create Array prototype methods based on property name
                  let methodName;
                  if (ts.isIdentifier(memberName)) {
                    methodName = memberName.text;
                  } else if (ts.isComputedPropertyName(memberName)) {
                    // Handle [Symbol.iterator] case
                    const expression = memberName.expression;
                    if (ts.isPropertyAccessExpression(expression) && 
                        ts.isIdentifier(expression.expression) && 
                        expression.expression.text === 'Symbol' &&
                        ts.isIdentifier(expression.name) && 
                        expression.name.text === 'iterator') {
                      methodName = 'Symbol.iterator';
                    } else {
                      methodName = 'unknown';
                    }
                  } else {
                    methodName = 'unknown';
                  }
                  let arrayMethodSignature = null;
                  
                  // Define common Array prototype methods with their signatures
                  switch (methodName) {
                    case 'forEach':
                      arrayMethodSignature = '(callbackfn: (value: any, index: number, array: any[]) => void, thisArg?: any) => void';
                      break;
                    case 'keys':
                      arrayMethodSignature = '() => IterableIterator<number>';
                      break;
                    case 'entries':
                      arrayMethodSignature = '() => IterableIterator<[number, any]>';
                      break;
                    case 'values':
                      arrayMethodSignature = '() => IterableIterator<any>';
                      break;
                    case 'Symbol.iterator':
                      arrayMethodSignature = '() => IterableIterator<any>';
                      break;
                    default:
                      // For unknown methods, use a generic function signature
                      arrayMethodSignature = '(...args: any[]) => any';
                  }
                  
                  if (arrayMethodSignature) {
                    // Parse the signature string into TypeScript AST nodes
                    const tempPropertyName = methodName === 'Symbol.iterator' ? '[Symbol.iterator]' : methodName;
                    const tempSource = `interface Temp { ${tempPropertyName}: ${arrayMethodSignature}; }`;
                    const tempSourceFile = ts.createSourceFile(
                      'temp.ts',
                      tempSource,
                      ts.ScriptTarget.Latest,
                      true,
                      ts.ScriptKind.TS
                    );
                    
                    // Extract the type from the temporary interface
                    const tempInterface = tempSourceFile.statements[0];
                    if (ts.isInterfaceDeclaration(tempInterface) && tempInterface.members.length > 0) {
                      const tempMember = tempInterface.members[0];
                      if (ts.isPropertySignature(tempMember) && tempMember.type) {
                        const arrayMethodMember = ts.factory.createPropertySignature(
                          member.modifiers, // Copy readonly, etc.
                          memberName, // Use original member name (preserves computed property syntax)
                          member.questionToken,
                          tempMember.type
                        );
                        newMembers.push(arrayMethodMember);
                        hasChanges = true;
                      }
                    }
                  }
                }
              } else {
                // Add non-SupportAsync members as-is
                newMembers.push(member);
              }
            } else {
              // Add non-property/method members as-is
              newMembers.push(member);
            }
          }
          
          // If we modified any members (replaced SupportAsync with async variants), update the interface
          if (hasChanges) {
            return ts.factory.updateInterfaceDeclaration(
              node,
              node.modifiers,
              node.name,
              node.typeParameters,
              node.heritageClauses,
              newMembers
            );
          }
        }
        
        return ts.visitEachChild(node, visit, context);
      }
      
      return ts.visitNode(rootNode, visit);
    };
  };
  
  // Apply the transformation
  const result = ts.transform(sourceFile, [transformer]);
  
  // Convert back to string
  const transformedSourceFile = result.transformed[0];
  const output = printer.printFile(transformedSourceFile);
  
  // Clean up
  result.dispose();
  
  return output;
}

// Generate merged webf.d.ts from bridge/core .d.ts files
task('merge-bridge-typings', (done) => {
  try {
    console.log(chalk.blue('Merging bridge/core TypeScript definitions...'));
    
    const glob = require('glob');
    const bridgeCorePath = join(WEBF_ROOT, 'bridge/core');
    const typingsPath = join(WEBF_ROOT, 'bridge/typings');
    const webfDtsPath = join(typingsPath, 'webf.d.ts');
    const indexDtsPath = join(typingsPath, 'index.d.ts');
    
    // Find all .d.ts files in bridge/core
    const dtsFiles = glob.sync('**/*.d.ts', { 
      cwd: bridgeCorePath,
      absolute: true 
    });
    
    console.log(chalk.yellow(`Found ${dtsFiles.length} .d.ts files in bridge/core`));
    
    let mergedContent = `/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// Auto-generated merged WebF type definitions
// DO NOT EDIT MANUALLY - Generated from bridge/core/**/*.d.ts files

// WebF type aliases
type DartImpl<T> = T;
type StaticMember<T> = T;
type StaticMethod<T> = T;
type SupportAsync<T> = T;
type SupportAsyncManual<T> = T;
type DependentsOnLayout<T> = T;

// WebF-specific types
type EventListener = ((event: Event) => void) | null;
type LegacyNullToEmptyString = string;
type BlobPart = string | ArrayBuffer | ArrayBufferView | Blob;

`;

    const typeDefinitions = [];
    const namespaceMembers = [];
    
    // Process each .d.ts file
    dtsFiles.forEach(filePath => {
      console.log(chalk.gray(`Processing: ${path.relative(bridgeCorePath, filePath)}`));
      
      const content = readFileSync(filePath, 'utf-8');
      
      // Remove imports and exports
      let processedContent = content
        .replace(/^\/\*[\s\S]*?\*\/\s*/gm, '') // Remove copyright blocks (/* ... */)
        .replace(/^\/\/.*Copyright.*$/gm, '') // Remove single-line copyright comments
        .replace(/^import\s+.*?;?\s*$/gm, '') // Remove import statements
        .replace(/^export\s*{\s*};\s*$/gm, '') // Remove empty export statements
        .replace(/^export\s+/gm, '') // Remove export keywords
        .replace(/@\w+\([^)]*\)\s*/g, '') // Remove decorations like @Directory()
        .replace(/\/\/\s*@ts-ignore\s*$/gm, '') // Remove @ts-ignore comments
        .replace(/ImplementedAs<([^,>]+),\s*[^>]+>/g, '$1') // Replace ImplementedAs<T, S> with T
        .replace(/^\s*[\r\n]/gm, '') // Remove empty lines
        .trim();
      
      if (processedContent) {
        // Extract interface/class/type names for namespace exposure
        const interfaceMatches = processedContent.match(/(?:interface|class|type|enum)\s+(\w+)/g);
        if (interfaceMatches) {
          interfaceMatches.forEach(match => {
            const name = match.replace(/(?:interface|class|type|enum)\s+/, '');
            if (name && !namespaceMembers.includes(name)) {
              namespaceMembers.push(name);
            }
          });
        }
        
        typeDefinitions.push(processedContent);
      }
    });
    
    // Process all interfaces to add async variants for SupportAsync members
    let processedContent = typeDefinitions.join('\n\n');
    
    // Remove problematic commented lines that contain StaticMethod to avoid AST confusion
    processedContent = processedContent.replace(/\/\/ .*StaticMethod.*\n/g, '');
    
    // Replace WebF-specific types with standard TypeScript types
    processedContent = processedContent.replace(/\bint64\b/g, 'number');
    processedContent = processedContent.replace(/\bdouble\b/g, 'number');
    processedContent = processedContent.replace(/\bJSEventListener\b/g, 'EventListener');
    
    // Replace other WebF-specific types that might not be defined
    processedContent = processedContent.replace(/\bLegacyNullToEmptyString\b/g, 'LegacyNullToEmptyString');
    processedContent = processedContent.replace(/\bBlobPart\b/g, 'BlobPart');
    
    // Unwrap standalone DartImpl<T> and DependentsOnLayout<T> wrapper types
    processedContent = processedContent.replace(/\bDartImpl<([^>]+)>/g, '$1');
    processedContent = processedContent.replace(/\bDependentsOnLayout<([^>]+)>/g, '$1');
    
    processedContent = generateAsyncVariants(processedContent);
    
    // Extract and create namespace declarations for static members
    const staticMembersByInterface = extractStaticMembers(typeDefinitions.join('\n\n'));
    let staticNamespaces = '\n// Namespace declarations for static members\n';
    
    for (const [interfaceName, members] of Object.entries(staticMembersByInterface)) {
      if (members.length > 0) {
        staticNamespaces += `declare namespace ${interfaceName} {\n`;
        members.forEach(member => {
          staticNamespaces += `    ${member};\n`;
        });
        staticNamespaces += '}\n\n';
      }
    }
    
    processedContent = processedContent + staticNamespaces;
    
    // Combine all processed content
    mergedContent += processedContent;
    
    // Add webf namespace with all types
    if (namespaceMembers.length > 0) {
      mergedContent += `\n\n// WebF namespace containing all bridge types
declare namespace webf {
`;
      namespaceMembers.forEach(member => {
        mergedContent += `  export type ${member} = globalThis.${member};\n`;
      });
      mergedContent += '}\n';
    }
    
    // Write merged webf.d.ts
    writeFileSync(webfDtsPath, mergedContent);
    console.log(chalk.green(`Generated webf.d.ts with ${namespaceMembers.length} type definitions`));
    
    // Update index.d.ts to include webf.d.ts
    let indexContent = readFileSync(indexDtsPath, 'utf-8');
    
    // Add import for webf.d.ts if not already present
    if (!indexContent.includes("import './webf'")) {
      // Find a good place to insert the import (after other imports)
      const lastImportMatch = indexContent.match(/import\s+type\s+.*?from\s+.*?;/g);
      if (lastImportMatch) {
        const lastImport = lastImportMatch[lastImportMatch.length - 1];
        const insertPos = indexContent.indexOf(lastImport) + lastImport.length;
        indexContent = indexContent.slice(0, insertPos) + 
          "\nimport './webf';" + 
          indexContent.slice(insertPos);
      } else {
        // If no imports found, add at the beginning
        indexContent = "import './webf';\n" + indexContent;
      }
    }
    
    // Add webf namespace to global window interface if not present
    if (!indexContent.includes('webf: typeof webf')) {
      const windowInterfaceMatch = indexContent.match(/interface\s+Window\s*{([^}]*)}/s);
      if (windowInterfaceMatch) {
        const windowContent = windowInterfaceMatch[1];
        if (!windowContent.includes('webf:')) {
          const newWindowContent = windowContent.trimEnd() + '\n\n        // WebF bridge types\n        webf: typeof webf;\n    ';
          indexContent = indexContent.replace(windowInterfaceMatch[0], 
            `interface Window {${newWindowContent}}`);
        }
      }
    }
    
    // Add global webf constant if not present
    if (!indexContent.includes('const webf:')) {
      const globalConstantsSection = indexContent.indexOf('// WebF\n    const webf: Webf;');
      if (globalConstantsSection !== -1) {
        // Replace existing webf declaration
        indexContent = indexContent.replace(
          '// WebF\n    const webf: Webf;',
          '// WebF\n    const webf: Webf & typeof webf;'
        );
      } else {
        // Add before the closing of global declaration
        const globalClosing = indexContent.lastIndexOf('}\n\nexport { };');
        if (globalClosing !== -1) {
          indexContent = indexContent.slice(0, globalClosing) + 
            '\n    // WebF bridge types\n    const webf: typeof webf;\n' +
            indexContent.slice(globalClosing);
        }
      }
    }
    
    writeFileSync(indexDtsPath, indexContent);
    console.log(chalk.green('Updated index.d.ts to include WebF bridge types'));
    
    done();
  } catch (err) {
    console.error(chalk.red('Error merging bridge typings:'), err);
    done(err);
  }
});

// Generate type definitions file
task('generate-typings', (done) => {
  try {
    console.log(chalk.blue('Generating type definitions file...'));
    const polyfillPath = join(WEBF_ROOT, 'bridge/polyfill');

    // Ensure node_modules is installed
    if (!fs.existsSync(path.join(polyfillPath, 'node_modules'))) {
      console.log(chalk.yellow('Installing polyfill dependencies...'));
      spawnSync(NPM, ['install'], {
        cwd: polyfillPath,
        stdio: 'inherit',
        shell: true
      });
    }


    const result = spawnSync(NPM, ['run', platform == 'win32' ? 'build:dts:windows' : 'build:dts'], {
      cwd: polyfillPath,
      stdio: 'inherit',
      shell: true
    });

    if (result.error || result.status !== 0) {
      console.error(chalk.red('Failed to generate type definitions file'));
      if (result.error) console.error(result.error);
      done(new Error('Failed to generate type definitions file'));
    } else {
      console.log(chalk.green('Type definitions file generated successfully'));
      done();
    }
  } catch (err) {
    console.error(chalk.red('An error occurred during execution:'), err);
    done(err);
  }
});
