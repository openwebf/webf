const fs = require('fs');
const fsp = require('fs/promises');
const {spawn} = require('child_process');
const os = require('os');
const path = require('path');
const {fileURLToPath} = require('url');

const PROFILE_CASE_FILTER_DEFINE = '--dart-define=WEBF_PROFILE_CASE_FILTER=';
const WORKING_DIRECTORY = path.join(__dirname, '..');
const PROFILE_CASES_TEST_PATH = path.join(
  WORKING_DIRECTORY,
  'integration_test',
  'profile_hotspot_cases_test.dart',
);
const PROFILE_OUTPUT_DIRECTORY = path.join(
  WORKING_DIRECTORY,
  'build',
  'profile_hotspots',
);
const ANDROID_LOCAL_PROPERTIES_PATH = path.join(
  WORKING_DIRECTORY,
  'android',
  'local.properties',
);

function parseLocalProperties() {
  if (!fs.existsSync(ANDROID_LOCAL_PROPERTIES_PATH)) {
    return {};
  }

  const source = fs.readFileSync(ANDROID_LOCAL_PROPERTIES_PATH, 'utf8');
  const properties = {};
  for (const line of source.split(/\r?\n/)) {
    if (!line || line.trimStart().startsWith('#')) continue;
    const separatorIndex = line.indexOf('=');
    if (separatorIndex === -1) continue;
    const key = line.slice(0, separatorIndex).trim();
    const value = line.slice(separatorIndex + 1).trim();
    properties[key] = value;
  }
  return properties;
}

function resolveFlutterRootFromPackageConfig() {
  const packageConfigPath = path.join(WORKING_DIRECTORY, '.dart_tool', 'package_config.json');
  if (!fs.existsSync(packageConfigPath)) {
    return null;
  }

  try {
    const packageConfig = JSON.parse(fs.readFileSync(packageConfigPath, 'utf8'));
    if (!packageConfig.flutterRoot) {
      return null;
    }
    return path.resolve(fileURLToPath(packageConfig.flutterRoot));
  } catch (_) {
    return null;
  }
}

function resolveFlutterBinary() {
  const localProperties = parseLocalProperties();
  const flutterRoot =
    localProperties['flutter.sdk'] ||
    process.env.FLUTTER_ROOT ||
    process.env.FLUTTER_SDK;
  if (!flutterRoot) {
    return 'flutter';
  }
  return path.join(flutterRoot, 'bin', 'flutter');
}

function normalizePath(filePath) {
  return path.normalize(path.resolve(filePath));
}

function runFlutterCommand(args) {
  const flutterBinary = resolveFlutterBinary();
  return new Promise((resolve, reject) => {
    const child = spawn(flutterBinary, args, {
      cwd: WORKING_DIRECTORY,
      env: {
        ...process.env,
        NO_PROXY: process.env.NO_PROXY || '127.0.0.1,localhost',
        no_proxy: process.env.no_proxy || '127.0.0.1,localhost',
      },
      stdio: 'inherit',
    });

    child.on('close', (code) => {
      if ((code ?? 1) === 0) {
        resolve();
        return;
      }
      reject(new Error(`${path.basename(flutterBinary)} ${args.join(' ')} exited with code ${code ?? 1}`));
    });

    child.on('error', reject);
  });
}

async function ensureFlutterPackageConfigIsCurrent() {
  const configuredFlutterBinary = resolveFlutterBinary();
  const configuredFlutterRoot = normalizePath(path.dirname(path.dirname(configuredFlutterBinary)));
  const packageConfigFlutterRoot = resolveFlutterRootFromPackageConfig();

  if (packageConfigFlutterRoot && normalizePath(packageConfigFlutterRoot) === configuredFlutterRoot) {
    return;
  }

  console.log(
    `Refreshing Flutter package config for ${configuredFlutterRoot}` +
      (packageConfigFlutterRoot
        ? ` (was ${normalizePath(packageConfigFlutterRoot)})`
        : ' (package_config.json missing Flutter root)'),
  );
  await runFlutterCommand(['pub', 'get']);
}

function getDefaultDeviceName() {
  if (os.platform() === 'darwin') return 'macos';
  if (os.platform() === 'linux') return 'linux';
  if (os.platform() === 'win32') return 'windows';
  throw new Error(`Unsupported platform: ${os.platform()}`);
}

function resolveDevice(argv) {
  const deviceArg = argv.find((arg) => arg.startsWith('--device='));
  if (deviceArg) {
    return {
      deviceName: deviceArg.slice('--device='.length),
      remainingArgs: argv.filter((arg) => arg !== deviceArg),
    };
  }

  if (process.env.WEBF_PROFILE_DEVICE) {
    return {
      deviceName: process.env.WEBF_PROFILE_DEVICE,
      remainingArgs: argv,
    };
  }

  return {
    deviceName: getDefaultDeviceName(),
    remainingArgs: argv,
  };
}

function shouldForceNoDds(deviceName) {
  return !['macos', 'linux', 'windows'].includes(deviceName);
}

function isMobileDevice(deviceName) {
  return shouldForceNoDds(deviceName);
}

function extractRequestedCaseIds(argv) {
  const filterArg = argv.find((arg) => arg.startsWith(PROFILE_CASE_FILTER_DEFINE));
  if (!filterArg) {
    return {
      requestedCaseIds: null,
      remainingArgs: argv,
    };
  }

  return {
    requestedCaseIds: filterArg
      .slice(PROFILE_CASE_FILTER_DEFINE.length)
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean),
    remainingArgs: argv.filter((arg) => arg !== filterArg),
  };
}

function loadProfileCaseIds() {
  const source = fs.readFileSync(PROFILE_CASES_TEST_PATH, 'utf8');
  return [...source.matchAll(/testWidgets\('([^']+)'/g)].map((match) => match[1]);
}

function buildFlutterDriveArgs(deviceName, extraArgs) {
  const hasDdsFlag = extraArgs.includes('--no-dds') || extraArgs.includes('--dds');
  return [
    'drive',
    '-d',
    deviceName,
    '--driver=test_driver/profile_hotspot_cases_test.dart',
    '--target=integration_test/profile_hotspot_cases_test.dart',
    ...(shouldForceNoDds(deviceName) && !hasDdsFlag ? ['--no-dds'] : []),
    ...extraArgs,
  ];
}

function runFlutterDrive(args) {
  return runFlutterCommand(args);
}

async function readJson(filePath) {
  return JSON.parse(await fsp.readFile(filePath, 'utf8'));
}

async function writeJson(filePath, data) {
  await fsp.writeFile(filePath, `${JSON.stringify(data, null, 2)}\n`);
}

async function resetProfileOutputDirectory() {
  await fsp.rm(PROFILE_OUTPUT_DIRECTORY, {recursive: true, force: true});
  await fsp.mkdir(PROFILE_OUTPUT_DIRECTORY, {recursive: true});
}

async function mergeCaseArtifacts(aggregateData) {
  const caseManifest = await readJson(path.join(PROFILE_OUTPUT_DIRECTORY, 'manifest.json'));
  Object.assign(aggregateData, caseManifest);
}

async function writeAggregateArtifacts(aggregateData) {
  await writeJson(path.join(PROFILE_OUTPUT_DIRECTORY, 'all_cases.json'), aggregateData);
  await writeJson(path.join(PROFILE_OUTPUT_DIRECTORY, 'manifest.json'), aggregateData);
}

async function runMobileCasesIndividually({
  deviceName,
  baseArgs,
  caseIds,
}) {
  const aggregateData = {};
  await resetProfileOutputDirectory();

  for (const caseId of caseIds) {
    console.log(`\n=== Running Android profile case: ${caseId} ===`);
    await runFlutterDrive(
      buildFlutterDriveArgs(deviceName, [
        ...baseArgs,
        `${PROFILE_CASE_FILTER_DEFINE}${caseId}`,
      ]),
    );
    await mergeCaseArtifacts(aggregateData);
  }

  await writeAggregateArtifacts(aggregateData);
}

async function main() {
  const {deviceName, remainingArgs: deviceArgs} = resolveDevice(process.argv.slice(2));
  const {requestedCaseIds, remainingArgs} = extractRequestedCaseIds(deviceArgs);
  const requestedOrAllCaseIds = requestedCaseIds ?? loadProfileCaseIds();

  await ensureFlutterPackageConfigIsCurrent();

  if (isMobileDevice(deviceName)) {
    await runMobileCasesIndividually({
      deviceName,
      baseArgs: remainingArgs,
      caseIds: requestedOrAllCaseIds,
    });
    return;
  }

  const args = buildFlutterDriveArgs(deviceName, [
    ...remainingArgs,
    ...(requestedCaseIds
      ? [`${PROFILE_CASE_FILTER_DEFINE}${requestedCaseIds.join(',')}`]
      : []),
  ]);
  await runFlutterDrive(args);
}

main().catch((error) => {
  console.error('profile hotspot integration failed', error);
  process.exit(1);
});
