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

program
  .option('--static-quickjs', 'Bundle QuickJS into webf library (default for Android)', false)
  .option('--static-stl', 'Use static C++ standard library (Android default, kept for compatibility)', false)
  .option('--dynamic-stl', 'Use dynamic C++ standard library (Android only)', false)
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
  typings: resolveWebF('bridge/typings'),
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
  
  // Detect current architecture
  const currentArch = process.arch === 'x64' ? 'x86_64' : 'arm64';
  
  console.log(chalk.blue(`Building build tools for ${currentArch}...`));

  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_OSX_ARCHITECTURES=${currentArch} \
    -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-${currentArch} -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, `build/macos/lib/${currentArch}`)
    }
  });

  let webfTargets = ['qjsc'];

  let cpus = os.cpus();
  execSync(`cmake --build ${paths.bridge}/cmake-build-macos-${currentArch} --target ${webfTargets.join(' ')} -- -j ${cpus.length}`, {
    stdio: 'inherit'
  });

  done();
});

task('build-darwin-webf-lib', done => {
  let externCmakeArgs = [];
  let buildType = 'Debug';
  if (process.env.WEBF_BUILD === 'Release' || buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
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
  
  // Only enable tests for debug/development builds
  const enableTest = buildMode !== 'Release';
  
  // Define architectures to build based on environment variable or default
  let architectures = ['arm64', 'x86_64']; // Default: build both
  
  if (process.env.MACOS_ARCH) {
    // Allow specifying single architecture or comma-separated list
    const archList = process.env.MACOS_ARCH.split(',').map(a => a.trim());
    const validArchs = ['arm64', 'x86_64'];
    architectures = archList.filter(arch => {
      if (!validArchs.includes(arch)) {
        console.log(chalk.yellow(`Warning: Invalid architecture '${arch}' ignored. Valid options: arm64, x86_64`));
        return false;
      }
      return true;
    });
    
    if (architectures.length === 0) {
      console.log(chalk.red('Error: No valid architectures specified'));
      return done(new Error('No valid architectures specified'));
    }
    
    console.log(chalk.blue(`Building for architecture(s): ${architectures.join(', ')}`));
  }
  const cpuCount = Math.max(1, (os.cpus() || []).length || 1);
  const webfTargets = ['webf', 'qjsc', 'webf_unit_test'];
  
  // Build for each architecture
  architectures.forEach(arch => {
    console.log(chalk.blue(`Building macOS ${arch}...`));
    
    // Configure CMake for this architecture
    execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
      -DCMAKE_OSX_ARCHITECTURES=${arch} \
      ${enableTest ? '-DENABLE_TEST=true' : ''} \
      ${externCmakeArgs.join(' ')} \
      -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-${arch} -S ${paths.bridge}`, {
      cwd: paths.bridge,
      stdio: 'inherit',
      env: {
        ...process.env,
        WEBF_JS_ENGINE: targetJSEngine,
        LIBRARY_OUTPUT_DIR: path.join(paths.bridge, `build/macos/lib/${arch}`)
      }
    });
    
    // Build targets
    execSync(`cmake --build ${paths.bridge}/cmake-build-macos-${arch} --target ${webfTargets.join(' ')} -- -j ${cpuCount}`, {
      stdio: 'inherit'
    });
    
    // Extract debug symbols and strip for Release builds
    if (buildMode == 'Release' || buildMode == 'RelWithDebInfo') {
      const binaryPath = path.join(paths.bridge, `build/macos/lib/${arch}/libwebf.dylib`);
      if (fs.existsSync(binaryPath)) {
        execSync(`dsymutil ${binaryPath}`, { stdio: 'inherit' });
        execSync(`strip -S -X -x ${binaryPath}`, { stdio: 'inherit' });
        console.log(chalk.green(`✓ Stripped debug symbols for ${arch}`));
      }
      
      // Also handle QuickJS if it's separate
      const quickjsPath = path.join(paths.bridge, `build/macos/lib/${arch}/libquickjs.dylib`);
      if (fs.existsSync(quickjsPath)) {
        execSync(`dsymutil ${quickjsPath}`, { stdio: 'inherit' });
        execSync(`strip -S -X -x ${quickjsPath}`, { stdio: 'inherit' });
      }
    }
  });
  
  // Create universal binaries (fat binaries) combining both architectures
  console.log(chalk.blue('Creating universal binaries...'));
  const universalDir = path.join(paths.bridge, 'build/macos/lib/universal');
  mkdirp.sync(universalDir);
  
  // Create universal binary for libwebf.dylib
  const webfLibs = architectures.map(arch => 
    path.join(paths.bridge, `build/macos/lib/${arch}/libwebf.dylib`)
  );
  if (webfLibs.every(lib => fs.existsSync(lib))) {
    execSync(`lipo -create ${webfLibs.join(' ')} -output ${universalDir}/libwebf.dylib`, {
      stdio: 'inherit'
    });
    console.log(chalk.green('✓ Created universal libwebf.dylib'));
  }
  
  // Create universal binary for libquickjs.dylib if it exists
  const quickjsLibs = architectures.map(arch => 
    path.join(paths.bridge, `build/macos/lib/${arch}/libquickjs.dylib`)
  );
  if (quickjsLibs.every(lib => fs.existsSync(lib))) {
    execSync(`lipo -create ${quickjsLibs.join(' ')} -output ${universalDir}/libquickjs.dylib`, {
      stdio: 'inherit'
    });
    console.log(chalk.green('✓ Created universal libquickjs.dylib'));
  }
  
  // Create universal binary for webf_unit_test
  const testBins = architectures.map(arch => 
    path.join(paths.bridge, `build/macos/lib/${arch}/webf_unit_test`)
  );
  if (testBins.every(bin => fs.existsSync(bin))) {
    execSync(`lipo -create ${testBins.join(' ')} -output ${universalDir}/webf_unit_test`, {
      stdio: 'inherit'
    });
    console.log(chalk.green('✓ Created universal webf_unit_test'));
  }
  
  console.log(chalk.green('✓ macOS build completed successfully!'));

  const copyMacosDylibsScriptPath = path.join(paths.scripts, 'copy_macos_dylibs.js');
  execSync(`node ${copyMacosDylibsScriptPath}`, { stdio: 'inherit' });
  console.log(chalk.green('✓ Copied macOS dylibs to target directory'));
  done();
});

task('run-bridge-unit-test', done => {
  if (platform === 'darwin') {
    // Try universal binary first, then fall back to architecture-specific binary
    const universalTest = path.join(paths.bridge, 'build/macos/lib/universal/webf_unit_test');
    const arm64Test = path.join(paths.bridge, 'build/macos/lib/arm64/webf_unit_test');
    const x86_64Test = path.join(paths.bridge, 'build/macos/lib/x86_64/webf_unit_test');
    
    if (fs.existsSync(universalTest)) {
      execSync(universalTest, { stdio: 'inherit' });
    } else if (fs.existsSync(arm64Test)) {
      execSync(arm64Test, { stdio: 'inherit' });
    } else if (fs.existsSync(x86_64Test)) {
      execSync(x86_64Test, { stdio: 'inherit' });
    } else {
      throw new Error('No webf_unit_test binary found for macOS');
    }
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

  // Only compile JavaScript, skip type generation (handled in merge-webf-and-polyfill-typings)
  const args = ['rollup', '--config', 'rollup.config.js'];
  let result = spawnSync('npx', args, {
    cwd: paths.polyfill,
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      NODE_ENV: 'production'
    },
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  done();
});

task('generate-polyfill-typings', (done) => {
  console.log(chalk.blue('Generating polyfill TypeScript declarations...'));

  if (!fs.existsSync(path.join(paths.polyfill, 'node_modules'))) {
    spawnSync(NPM, ['install'], {
      cwd: paths.polyfill,
      stdio: 'inherit'
    });
  }

  // Generate TypeScript declarations using rollup
  const result = spawnSync(NPM, ['run', 'build:types'], {
    cwd: paths.polyfill,
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    console.error(chalk.red('Failed to generate polyfill typings'));
    return done(result.status);
  }

  // Fix the generated polyfill.d.ts file
  const polyfillTypesPath = path.join(paths.typings, 'polyfill.d.ts');
  let polyfillContent = fs.readFileSync(polyfillTypesPath, 'utf-8');

  // Fix all $1 renaming issues from rollup-plugin-dts
  polyfillContent = polyfillContent.replace(/URLSearchParams\$1/g, 'URLSearchParams');
  polyfillContent = polyfillContent.replace(/HeadersInit\$1/g, 'HeadersInit');
  polyfillContent = polyfillContent.replace(/BodyInit\$1/g, 'BodyInit');
  polyfillContent = polyfillContent.replace(/RequestInit\$1/g, 'RequestInit');
  polyfillContent = polyfillContent.replace(/ResponseInit\$1/g, 'ResponseInit');
  polyfillContent = polyfillContent.replace(/ResizeObserverEntry\$1/g, 'ResizeObserverEntry');

  // Fix EventTarget extension issue - change extends to implements for interfaces
  polyfillContent = polyfillContent.replace(
    /class\s+(\w+)\s+implements\s+(\w+Interface)\s+extends\s+EventTarget/g,
    'class $1 extends EventTarget implements $2'
  );

  // Fix DOMException private properties conflict
  polyfillContent = polyfillContent.replace(
    /declare class DOMException extends Error \{\s*private message;\s*private name;/g,
    'declare class DOMException extends Error {'
  );

  // Add RequestInfo type alias (used by fetch API)
  const requestInfoType = '\ntype RequestInfo = Request | string;\n';
  polyfillContent = polyfillContent.replace(
    /declare type HeadersInit = /,
    requestInfoType + 'declare type HeadersInit = '
  );

  fs.writeFileSync(polyfillTypesPath, polyfillContent);

  console.log(chalk.green('Polyfill typings generated and fixed successfully'));
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
        <string>12.0</string>`);
    fs.writeFileSync(pListPath, pListString);
  }
}

// Helper function to build iOS CMake arguments
function getIOSCMakeArgs(buildType, externCmakeArgs) {
  const baseArgs = [
    `-DCMAKE_BUILD_TYPE=${buildType}`,
    `-DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake`,
    `-DDEPLOYMENT_TARGET=12.0`,
    `-DIS_IOS=TRUE`,
    `-DENABLE_BITCODE=FALSE`,
    `-G "Unix Makefiles"`,
    `-S ${paths.bridge}`
  ];

  if (isProfile) {
    baseArgs.push('-DENABLE_PROFILE=TRUE');
  }

  return [...baseArgs, ...externCmakeArgs];
}

// Helper function to configure and build iOS target
function configureAndBuildIOSTarget(platform, arch, buildType, externCmakeArgs) {
  const buildDir = `${paths.bridge}/cmake-build-ios-${arch}`;
  const outputDir = path.join(paths.bridge, `build/ios/lib/${arch}`);

  try {
    // Configure
    const cmakeArgs = getIOSCMakeArgs(buildType, externCmakeArgs);
    cmakeArgs.push(`-DPLATFORM=${platform}`);
    cmakeArgs.push(`-B ${buildDir}`);

    execSync(`cmake ${cmakeArgs.join(' ')}`, {
      cwd: paths.bridge,
      stdio: 'inherit',
      env: {
        ...process.env,
        WEBF_JS_ENGINE: targetJSEngine,
        LIBRARY_OUTPUT_DIR: outputDir
      }
    });

    // Build
    const cpuCount = os.cpus().length;
    execSync(`cmake --build ${buildDir} --target webf -- -j ${cpuCount}`, {
      stdio: 'inherit'
    });

    return { buildDir, outputDir };
  } catch (error) {
    console.error(chalk.red(`Failed to build iOS target ${arch}: ${error.message}`));
    throw error;
  }
}

// Helper function to create XCFramework for a target
function createXCFramework(target, architectures, options = {}) {
  try {
    // Options for XCFramework creation
    const includeDsyms = options.includeDsyms !== undefined ? options.includeDsyms : (buildMode === 'Debug');
    const createSeparateDsyms = options.createSeparateDsyms !== undefined ? options.createSeparateDsyms : true;

    const frameworkPaths = architectures.map(arch =>
      path.join(paths.bridge, `build/ios/lib/${arch.name}/${target}.framework`)
    );

    // Verify all frameworks exist
    frameworkPaths.forEach((frameworkPath, idx) => {
      if (!fs.existsSync(frameworkPath)) {
        throw new Error(`Framework not found at ${frameworkPath} for architecture ${architectures[idx].name}`);
      }
    });

    // Separate device and simulator architectures
    const simArchs = architectures.filter(a => a.isSimulator);
    const deviceArchs = architectures.filter(a => !a.isSimulator);

    // Create universal binary for simulators (merge x86_64 and arm64)
    let simulatorFrameworkPath = null;
    if (simArchs.length > 0) {
      // Use the first simulator path as the output location for the universal binary
      simulatorFrameworkPath = path.join(paths.bridge, `build/ios/lib/${simArchs[0].name}/${target}.framework`);

      if (simArchs.length > 1) {
        // Merge multiple simulator architectures into a universal binary
        const simBinaries = simArchs.map(arch =>
          path.join(paths.bridge, `build/ios/lib/${arch.name}/${target}.framework/${target}`)
        );
        console.log(chalk.gray(`    Creating universal simulator binary...`));
        execSync(`lipo -create ${simBinaries.join(' ')} -output ${simulatorFrameworkPath}/${target}`, {
          stdio: 'inherit'
        });
      }
    }

    // Collect frameworks for XCFramework (universal simulator + device)
    const xcframeworkInputs = [];
    const dSymPaths = [];

    // Add simulator framework (now contains both x86_64 and arm64 if both were built)
    if (simulatorFrameworkPath) {
      patchiOSFrameworkPList(simulatorFrameworkPath);

      if (createSeparateDsyms) {
        const simDSymPath = `${simulatorFrameworkPath}/../${target}.dSYM`;
        execSync(`dsymutil -o ${simDSymPath} ${simulatorFrameworkPath}/${target}`, { stdio: 'inherit' });
        dSymPaths.push({ platform: 'simulator', path: simDSymPath });

        // Strip debug symbols from Release builds after extracting dSYM
        if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
          console.log(chalk.gray(`    Stripping debug symbols from simulator binary...`));
          execSync(`strip -S -x ${simulatorFrameworkPath}/${target}`, { stdio: 'inherit' });
        }

        xcframeworkInputs.push({
          frameworkPath: simulatorFrameworkPath,
          dSymPath: includeDsyms ? simDSymPath : null
        });
      } else {
        xcframeworkInputs.push({
          frameworkPath: simulatorFrameworkPath,
          dSymPath: null
        });
      }
    }

    // Add device framework(s)
    deviceArchs.forEach(arch => {
      const deviceFrameworkPath = path.join(paths.bridge, `build/ios/lib/${arch.name}/${target}.framework`);
      patchiOSFrameworkPList(deviceFrameworkPath);

      if (createSeparateDsyms) {
        const deviceDSymPath = `${deviceFrameworkPath}/../${target}.dSYM`;
        execSync(`dsymutil -o ${deviceDSymPath} ${deviceFrameworkPath}/${target}`, { stdio: 'inherit' });
        dSymPaths.push({ platform: arch.name, path: deviceDSymPath });

        // Strip debug symbols from Release builds after extracting dSYM
        if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
          console.log(chalk.gray(`    Stripping debug symbols from ${arch.name} binary...`));
          execSync(`strip -S -x ${deviceFrameworkPath}/${target}`, { stdio: 'inherit' });
        }

        xcframeworkInputs.push({
          frameworkPath: deviceFrameworkPath,
          dSymPath: includeDsyms ? deviceDSymPath : null
        });
      } else {
        xcframeworkInputs.push({
          frameworkPath: deviceFrameworkPath,
          dSymPath: null
        });
      }
    });

    // Create XCFramework with all inputs
    const targetDynamicSDKPath = `${paths.bridge}/build/ios/framework`;
    mkdirp.sync(targetDynamicSDKPath);

    const xcframeworkPath = `${targetDynamicSDKPath}/${target}.xcframework`;

    // Remove existing XCFramework if it exists
    if (fs.existsSync(xcframeworkPath)) {
      execSync(`rm -rf ${xcframeworkPath}`, { stdio: 'inherit' });
    }

    // Build XCFramework command
    const xcframeworkArgs = xcframeworkInputs.map(({ frameworkPath, dSymPath }) => {
      let args = `-framework ${frameworkPath}`;
      if (dSymPath) {
        args += ` -debug-symbols ${dSymPath}`;
      }
      return args;
    }).join(' ');

    console.log(chalk.gray(`    Creating XCFramework ${includeDsyms ? 'with' : 'without'} embedded dSYMs...`));
    execSync(`xcodebuild -create-xcframework ${xcframeworkArgs} -output ${xcframeworkPath}`, {
      stdio: 'inherit'
    });

    // If we created separate dSYMs but didn't include them, create a separate dSYMs bundle
    if (createSeparateDsyms && !includeDsyms && dSymPaths.length > 0) {
      const dSymBundlePath = `${targetDynamicSDKPath}/${target}.dSYMs`;
      mkdirp.sync(dSymBundlePath);

      console.log(chalk.gray(`    Copying dSYMs to separate bundle...`));
      dSymPaths.forEach(({ platform, path: dSymPath }) => {
        const targetPath = `${dSymBundlePath}/${platform}`;
        mkdirp.sync(targetPath);
        execSync(`cp -R ${dSymPath} ${targetPath}/`, { stdio: 'inherit' });
      });
      console.log(chalk.blue(`    ℹ dSYMs saved separately at: ${dSymBundlePath}`));
    }

    console.log(chalk.green(`  ✓ Created ${target}.xcframework`));
  } catch (error) {
    console.error(chalk.red(`Failed to create XCFramework for ${target}: ${error.message}`));
    throw error;
  }
}

task(`build-ios-webf-lib`, (done) => {
  const buildType = (buildMode == 'Release' || buildMode === 'RelWithDebInfo') ? 'RelWithDebInfo' : 'Debug';

  // Collect external CMake arguments
  const externCmakeArgs = [];
  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }
  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }
  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  // Define architectures to build
  const architectures = [
    { platform: 'SIMULATOR64', name: 'simulator_x86', isSimulator: true },
    { platform: 'SIMULATORARM64', name: 'simulator_arm64', isSimulator: true },
    { platform: 'OS64', name: 'arm64', isSimulator: false }
  ];

  // Build all architectures
  console.log(chalk.blue('Building iOS frameworks...'));
  architectures.forEach(arch => {
    console.log(chalk.gray(`  - Building ${arch.name}...`));
    configureAndBuildIOSTarget(arch.platform, arch.name, buildType, externCmakeArgs);
  });

  // Determine which frameworks to build
  const targetFrameworks = ['webf_bridge'];
  if (!program.staticQuickjs) {
    targetFrameworks.push('quickjs');
  }

  // Create XCFrameworks
  console.log(chalk.blue('Creating XCFrameworks...'));

  // Determine dSYM handling based on build mode
  const xcframeworkOptions = {
    // For Debug builds: include dSYMs in XCFramework for easier debugging
    // For Release builds: keep dSYMs separate for distribution
    includeDsyms: buildMode === 'Debug',
    createSeparateDsyms: true
  };

  // Allow environment variable override
  if (process.env.INCLUDE_DSYMS_IN_XCFRAMEWORK !== undefined) {
    xcframeworkOptions.includeDsyms = process.env.INCLUDE_DSYMS_IN_XCFRAMEWORK === 'true';
  }

  targetFrameworks.forEach(target => {
    console.log(chalk.gray(`  - Creating ${target}.xcframework...`));
    createXCFramework(target, architectures, xcframeworkOptions);
  });

  console.log(chalk.green('✓ iOS build completed successfully!'));
  done();
});

task('build-linux-webf-lib', (done) => {
  const buildType = (buildMode == 'Release' || buildMode == 'RelWithDebInfo') ? 'RelWithDebInfo' : 'Debug';
  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';

  let externCmakeArgs = [];

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Force static QuickJS for Linux to bundle everything into libwebf.so
  externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  
  // Only enable tests for debug/development builds
  const enableTest = buildMode !== 'Release';

  const soBinaryDirectory = path.join(paths.bridge, `build/linux/lib/`);
  const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-linux');
  // generate project
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  ${externCmakeArgs.join(' ')} \
  ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
  ${enableTest ? '-DENABLE_TEST=true \\' : '\\'}
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

  // build - always build webf_unit_test for testing
  const buildTargets = 'webf webf_unit_test';
  execSync(`cmake --build ${bridgeCmakeDir} --target ${buildTargets} -- -j 12`, {
    stdio: 'inherit'
  });

  // Copy C++ standard library dependencies to the output directory
  const fs = require('fs');
  const libcppPath = '/lib/x86_64-linux-gnu/libc++.so.1';
  const libcppabiPath = '/lib/x86_64-linux-gnu/libc++abi.so.1';
  const libunwindPath = '/lib/x86_64-linux-gnu/libunwind.so.1';
  
  if (fs.existsSync(libcppPath)) {
    execSync(`cp -L ${libcppPath} ${soBinaryDirectory}/libc++.so.1`, { stdio: 'inherit' });
    console.log(chalk.green('✓ Copied libc++.so.1'));
  }
  
  if (fs.existsSync(libcppabiPath)) {
    execSync(`cp -L ${libcppabiPath} ${soBinaryDirectory}/libc++abi.so.1`, { stdio: 'inherit' });
    console.log(chalk.green('✓ Copied libc++abi.so.1'));
  }
  
  if (fs.existsSync(libunwindPath)) {
    execSync(`cp -L ${libunwindPath} ${soBinaryDirectory}/libunwind.so.1`, { stdio: 'inherit' });
    console.log(chalk.green('✓ Copied libunwind.so.1'));
  }
  
  // Use patchelf to set RPATH so libwebf.so looks for dependencies in its own directory
  const libwebfPath = path.join(soBinaryDirectory, 'libwebf.so');
  if (fs.existsSync(libwebfPath)) {
    try {
      // Set RPATH to $ORIGIN (the directory containing the library)
      execSync(`patchelf --set-rpath '$ORIGIN' ${libwebfPath}`, { stdio: 'inherit' });
      console.log(chalk.green('✓ Set RPATH for libwebf.so to use local dependencies'));
    } catch (e) {
      console.log(chalk.yellow('⚠ patchelf not found. Install it to enable local library loading: sudo apt-get install patchelf'));
    }
  }

  // Extract debug symbols for release builds
  if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
    console.log(chalk.blue('Extracting debug symbols for release build...'));
    
    // List of libraries to process
    const librariesToProcess = ['libwebf.so'];
    
    // Check if QuickJS is built as a separate library
    const libquickjsPath = path.join(soBinaryDirectory, 'libquickjs.so');
    if (fs.existsSync(libquickjsPath)) {
      librariesToProcess.push('libquickjs.so');
    }
    
    librariesToProcess.forEach(libName => {
      const libPath = path.join(soBinaryDirectory, libName);
      const debugPath = path.join(soBinaryDirectory, `${libName}.debug`);
      
      if (fs.existsSync(libPath)) {
        try {
          // Extract debug symbols
          execSync(`objcopy --only-keep-debug "${libPath}" "${debugPath}"`, { stdio: 'inherit' });
          console.log(chalk.green(`  ✓ Extracted debug symbols to ${libName}.debug`));
          
          // Strip debug symbols from the binary
          execSync(`strip --strip-debug --strip-unneeded "${libPath}"`, { stdio: 'inherit' });
          console.log(chalk.green(`  ✓ Stripped debug symbols from ${libName}`));
          
          // Add debug link to the stripped binary
          execSync(`objcopy --add-gnu-debuglink="${debugPath}" "${libPath}"`, { stdio: 'inherit' });
          console.log(chalk.green(`  ✓ Added debug link to ${libName}`));
        } catch (error) {
          console.log(chalk.yellow(`  ⚠ Failed to extract/strip debug symbols from ${libName}: ${error.message}`));
        }
      }
    });
    
    console.log(chalk.green('✓ Debug symbol extraction completed'));
  }

  done();
});

task('generate-polyfill-bytecode', (done) => {
  if (platform == 'darwin') {
    // Detect current architecture and use appropriate qjsc
    const currentArch = process.arch === 'x64' ? 'x86_64' : 'arm64';
    const qjscExecDir = path.join(paths.bridge, `build/macos/lib/${currentArch}/`);
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
      stdio: 'inherit',
      shell: true
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
    console.error(chalk.red('Failed to build code generator'));
    if (buildResult.error) {
      console.error(chalk.red(buildResult.error.message));
    }
    return done(new Error(`Code generator build failed with status ${buildResult.status}`));
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
    console.error(chalk.red('Failed to generate binding code'));
    if (compileResult.error) {
      console.error(chalk.red(compileResult.error.message));
    }
    return done(new Error(`Code generation failed with status ${compileResult.status}`));
  }

  // No longer needed - fixed in code generator
  // console.log(chalk.yellow('Fixing generated element name files...'));
  // try {
  //   require('./fix_generated_element_names.js');
  // } catch (e) {
  //   console.error(chalk.red('Failed to fix generated files:'), e.message);
  // }

  done();
});

task('build-window-webf-lib', (done) => {
  const buildType = (buildMode == 'Release' || buildMode == 'RelWithDebInfo') ? 'RelWithDebInfo' : 'Debug';

  let externCmakeArgs = [];

  if (process.env.USE_SYSTEM_MALLOC === 'true') {
    externCmakeArgs.push('-DUSE_SYSTEM_MALLOC=true');
  }

  if (program.enableLog) {
    externCmakeArgs.push('-DENABLE_LOG=true');
  }
  
  // Only enable tests for debug/development builds
  const enableTest = buildMode !== 'Release';

  const soBinaryDirectory = path.join(paths.bridge, `build/windows/lib/`).replaceAll(path.sep, path.posix.sep);
  const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-windows');
  // generate project
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} ${enableTest ? '-DENABLE_TEST=true' : ''} ${externCmakeArgs.join(' ')} -B ${bridgeCmakeDir} -S ${paths.bridge}`,
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

  // Always build webf_unit_test for testing
  const webfTargets = ['webf', 'webf_unit_test'];

  // build
  execSync(`cmake --build ${bridgeCmakeDir} --target ${webfTargets.join(' ')} --verbose --config ${buildType}`, {
    stdio: 'inherit'
  });

  execSync(`cmake --install ./`, {
    stdio: 'inherit',
    cwd: path.join(paths.bridge, 'cmake-build-windows')
  });

  // Extract debug symbols and strip from Windows binary in release mode
  if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
    const targetDlls = [
      'libwebf',
      'libquickjs'
    ];

    for (var dll of targetDlls) {
      const binaryPath = path.join(paths.bridge, `build/windows/lib/${dll}.dll`);
      if (fs.existsSync(binaryPath)) {
        try {
          // Extract debug symbols before stripping
          const debugPath = path.join(paths.bridge, `build/windows/lib/${dll}.debug`);
          execSync(`objcopy --only-keep-debug "${binaryPath}" "${debugPath}"`, { stdio: 'inherit' });
          console.log(chalk.green(`Extracted debug symbols to ${debugPath}`));

          // Strip debug symbols from the binary
          execSync(`strip -S -X -x "${binaryPath}"`, { stdio: 'inherit' });
          console.log(chalk.green(`Stripped debug symbols from ${binaryPath}`));
        } catch (error) {
          console.log(chalk.yellow(`Warning: Failed to extract/strip debug symbols from ${binaryPath}: ${error.message}`));
        }
      } else {
        console.log(chalk.yellow(`Warning: Binary not found at ${binaryPath}, skipping debug symbol extraction and strip operation`));
      }
    }
  }

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
    const ndkVersion = '27.3.13750724';
    ndkDir = path.join(androidHome, 'ndk', ndkVersion);

    if (!fs.existsSync(ndkDir)) {
      throw new Error(`Android NDK version (${ndkVersion}) not installed.`);
    }
  }

  const archs = ['arm64-v8a', 'armeabi-v7a', 'x86', 'x86_64'];
  const toolChainMap = {
    'arm64-v8a': 'aarch64-linux-android',
    'armeabi-v7a': 'arm-linux-androideabi',
    'x86': 'i686-linux-android',
    'x86_64': 'x86_64-linux-android'
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

  // Bundle quickjs into webf by default for Android (simpler deployment)
  // Use WEBF_SEPARATE_QUICKJS=true environment variable to build as separate library if needed
  const useStaticQuickjs = program.staticQuickjs || process.env.WEBF_SEPARATE_QUICKJS !== 'true';
  if (useStaticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  // Configure Android STL - default to static for simpler deployment
  let androidStl = 'c++_static'; // Default to static (fewer dependencies)
  if (program.dynamicStl) {
    androidStl = 'c++_shared';
  } else if (process.env.ANDROID_STL) {
    androidStl = process.env.ANDROID_STL;
  } else if (program.staticStl) {
    // --static-stl flag is now redundant but kept for backward compatibility
    androidStl = 'c++_static';
  }
  const useDynamicStl = androidStl === 'c++_shared';

  const soFileNames = [
    'libwebf'
  ];

  // Only include libc++_shared.so if using dynamic STL
  if (useDynamicStl) {
    soFileNames.push('libc++_shared');
  }

  // If quickjs is not static, there will be another so called libquickjs.so.
  if (!useStaticQuickjs) {
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
    -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON \
    -DIS_ANDROID=TRUE \
    -DANDROID_ABI="${arch}" \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DANDROID_PLATFORM="android-18" \
    -DANDROID_STL=${androidStl} \
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

    // Copy libc++_shared.so to dist from NDK only when using dynamic STL.
    if (useDynamicStl) {
      const libcppSharedPath = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/sysroot/usr/lib/${toolChainMap[arch]}/libc++_shared.so`);
      execSync(`cp ${libcppSharedPath} ${soBinaryDirectory}`);
      console.log(chalk.green(`Copied libc++_shared.so for ${arch} (dynamic STL)`));
    } else {
      console.log(chalk.yellow(`Skipped libc++_shared.so for ${arch} (static STL: ${androidStl})`));
    }

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
    console.error(chalk.red('Error updating typings version:'));
    if (err instanceof Error) {
      console.error(chalk.red(err.message));
    } else {
      console.error(chalk.red(err));
    }
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
 * Use of this source code is governed by a GPL-3.0 license that can be
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
type EventListener<T extends Event> = ((event: T) => void) | null;
type EventListenerObject = { handleEvent(event: Event): void };
type LegacyNullToEmptyString = string;
type BlobPart = string | ArrayBuffer | ArrayBufferView | Blob;

// Additional DOM types
type NodeListOf<T> = NodeList;
type HTMLCollectionOf<T> = HTMLCollection;
type DOMRect = BoundingClientRect;
interface AbortSignal {
  readonly aborted: boolean;
  onabort: ((this: AbortSignal, ev: Event) => any) | null;
}
interface Attr extends Node {
  readonly name: string;
  readonly value: string;
}

`;

    const typeDefinitions = [];
    const namespaceMembers = [];
    const mixinInterfaces = new Map();
    const mixinNames = new Set();

    // Process each .d.ts file
    dtsFiles.forEach(filePath => {
      console.log(chalk.gray(`Processing: ${path.relative(bridgeCorePath, filePath)}`));

      const content = readFileSync(filePath, 'utf-8');

      // First, check if this file contains @Mixin() interfaces before removing decorators
      const mixinMatches = content.matchAll(/@Mixin\(\)\s*(?:export\s+)?interface\s+(\w+)\s*{([^}]*)}/g);
      for (const match of mixinMatches) {
        const [, mixinName, mixinBody] = match;
        mixinInterfaces.set(mixinName, mixinBody);
        mixinNames.add(mixinName);
      }

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

    // Process interfaces to expand JSArrayProtoMethod and add async variants BEFORE converting to classes
    processedContent = generateAsyncVariants(processedContent);

    // Now convert interfaces to classes, but skip mixin interfaces
    processedContent = processedContent.replace(/interface\s+(\w+)(\s+extends\s+[^{]+)?(\s*{[^}]*})/g, (match, interfaceName, extendsClause, body) => {
      // Skip conversion if this is a mixin interface
      if (mixinNames.has(interfaceName)) {
        return match; // Keep as interface
      }

      // Extract the interface name and extends clause
      const extendsPart = extendsClause ? extendsClause.trim() : '';

      // Convert constructor signatures in the body
      let modifiedBody = body;

      // Extract constructor signature if present
      const constructorMatch = body.match(/\bnew\s*\(([^)]*)\)\s*:\s*\w+\s*;/);
      if (constructorMatch) {
        // Remove the interface constructor signature
        modifiedBody = modifiedBody.replace(/\bnew\s*\([^)]*\)\s*:\s*\w+\s*;/g, '');

        // Add it back as a proper constructor after the opening brace
        const params = constructorMatch[1];
        modifiedBody = modifiedBody.replace(/\s*{\s*/, `{\n    constructor(${params});\n    `);
      }

      // Check if this interface extends any mixin interfaces
      if (extendsPart) {
        const parents = extendsPart.replace(/extends\s+/, '').split(',').map(p => p.trim());
        const mixinParents = parents.filter(p => mixinNames.has(p));
        const nonMixinParents = parents.filter(p => !mixinNames.has(p));

        // Merge mixin interface properties into the body
        if (mixinParents.length > 0) {
          let mergedMixinProperties = '';
          mixinParents.forEach(mixinName => {
            const mixinBody = mixinInterfaces.get(mixinName);
            if (mixinBody) {
              // Remove the opening and closing braces and trim
              const cleanMixinBody = mixinBody.replace(/^\s*{\s*/, '').replace(/\s*}\s*$/, '').trim();
              if (cleanMixinBody) {
                mergedMixinProperties += '\n    ' + cleanMixinBody;
              }
            }
          });

          // Insert mixin properties into the class body
          if (mergedMixinProperties) {
            modifiedBody = modifiedBody.replace(/\s*{\s*/, `{${mergedMixinProperties}\n    `);
          }
        }

        // Build the extends clause with only non-mixin parents
        if (nonMixinParents.length > 0) {
          const firstParent = nonMixinParents[0];
          const otherParents = nonMixinParents.slice(1);

          if (otherParents.length > 0) {
            return `declare class ${interfaceName} extends ${firstParent} /* implements ${otherParents.join(', ')} */ ${modifiedBody}`;
          } else {
            return `declare class ${interfaceName} extends ${firstParent} ${modifiedBody}`;
          }
        } else {
          // No non-mixin parents, just a plain class
          return `declare class ${interfaceName} ${modifiedBody}`;
        }
      } else {
        // No inheritance - ensure space before body
        return `declare class ${interfaceName} ${modifiedBody}`;
      }
    });

    // Extract interface/class/type names for namespace exposure
    const namespaceTypes = [];
    const typeMatches = processedContent.match(/(?:declare\s+class|class|type|enum)\s+(\w+)/g);
    if (typeMatches) {
      typeMatches.forEach(match => {
        const name = match.replace(/(?:declare\s+class|class|type|enum)\s+/, '');
        // Filter out invalid type names (methods, keywords, etc.)
        const invalidNames = ['of', 'readonly', 'getBoundingClientRect'];
        if (name && !namespaceTypes.includes(name) && !invalidNames.includes(name)) {
          namespaceTypes.push(name);
        }
      });
    }
    // Merge with existing namespaceMembers
    namespaceTypes.forEach(name => {
      if (!namespaceMembers.includes(name)) {
        namespaceMembers.push(name);
      }
    });

    // Extract and create namespace declarations for static members
    const staticMembersByInterface = extractStaticMembers(processedContent);
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

    // Remove duplicate type declarations
    const typeDeclarations = {};
    processedContent = processedContent.replace(/^type\s+(\w+)\s*=\s*([^;]+);$/gm, (match, typeName, typeValue) => {
      if (typeDeclarations[typeName]) {
        // Skip duplicate
        return '';
      }
      typeDeclarations[typeName] = typeValue;
      return match;
    });

    // Combine all processed content
    mergedContent += processedContent;

    // Add webf namespace with all types
    if (namespaceMembers.length > 0) {
      mergedContent += `\n\n// WebF namespace containing all bridge types
declare namespace WEBF {
`;
      namespaceMembers.forEach(member => {
        mergedContent += `  export type ${member} = globalThis.${member};\n`;
      });
      mergedContent += '}\n';
    }


    // Write merged webf.d.ts
    writeFileSync(webfDtsPath, mergedContent);
    console.log(chalk.green(`Generated webf.d.ts with ${namespaceMembers.length} type definitions`));

    // Check if index.d.ts exists, if not create a minimal one
    if (!fs.existsSync(indexDtsPath)) {
      console.log(chalk.yellow('index.d.ts not found, creating a minimal index.d.ts'));

      // Create a minimal index.d.ts that imports webf.d.ts
      const minimalIndexContent = `/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a GPL-3.0 license that can be
 * found in the LICENSE file.
 */

// Import WebF core types
import './webf';

// Export empty to make this a module
export {};
`;

      writeFileSync(indexDtsPath, minimalIndexContent);
      console.log(chalk.green('Created minimal index.d.ts'));
    } else {
      // Update existing index.d.ts to include webf.d.ts
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
    }

    done();
  } catch (err) {
    console.error(chalk.red('Error merging bridge typings:'));
    if (err instanceof Error) {
      console.error(chalk.red(err.message));
      if (err.stack) {
        console.error(chalk.gray('Stack trace:'));
        console.error(chalk.gray(err.stack));
      }
    } else {
      console.error(chalk.red(err));
    }
    done(err);
  }
});
