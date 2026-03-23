const {spawn} = require('child_process');
const os = require('os');
const path = require('path');

function getDeviceName() {
  if (os.platform() === 'darwin') return 'macos';
  if (os.platform() === 'linux') return 'linux';
  if (os.platform() === 'win32') return 'windows';
  throw new Error(`Unsupported platform: ${os.platform()}`);
}

function main() {
  const deviceName = getDeviceName();
  const workingDirectory = path.join(__dirname, '..');
  const args = [
    'drive',
    '-d',
    deviceName,
    '--driver=test_driver/profile_hotspot_cases_test.dart',
    '--target=integration_test/profile_hotspot_cases_test.dart',
    ...process.argv.slice(2),
  ];

  const child = spawn('flutter', args, {
    cwd: workingDirectory,
    env: {
      ...process.env,
      NO_PROXY: process.env.NO_PROXY || '127.0.0.1,localhost',
      no_proxy: process.env.no_proxy || '127.0.0.1,localhost',
    },
    stdio: 'inherit',
  });

  child.on('close', (code) => {
    process.exit(code ?? 1);
  });

  child.on('error', (error) => {
    console.error('profile hotspot integration failed', error);
    process.exit(1);
  });
}

main();
