const exec = require("child_process").execSync;
const fs = require("fs");
const PATH = require("path");
const os = require('os');

const updatedRootGitIgnore = `.vscode
.history
*.log
*.apk
*.ap_
*.aab
*.dex
*.class
.gradle/
local.properties

# IntelliJ
.idea/workspace.xml
.idea/tasks.xml
.idea/gradle.xml
.idea/assetWizardSettings.xml
.idea/dictionaries
.idea/libraries
.idea/caches
.idea

# External native build folder generated in Android Studio 2.2 and later
.externalNativeBuild

# OS-specific files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# cquery
compile_commands.json

# Gradle files
.gradle/
build/

# Android Studio
/*/build/
/*/local.properties
/*/*/build
/*/*/production
*.ipr
*~
*.swp

# NDK
obj/
yarn.lock
node_modules

# cmake
cmake-build-debug
cmake-build-release
cmake-build-macos

# Node.js
package-lock.json

Podfile.lock
.cxx

temp
coverage
pubspec.lock
.fvm
`;

const updatedBridgeIgnore = `
xcschememanagement.plist

cmake-build-*
build
`;

const updatedPolyFillIgnore = `
package-lock.json
`;

function symbolicToRealFile(path) {
  let realPath = PATH.join(path, "../", fs.readlinkSync(path));
  moveFile(path, realPath);
}

function moveFile(path, realPath, replaceDll = false) {
  if (fs.lstatSync(realPath).isDirectory()) {
    exec(`rm ${path}`);
    exec(`cp -r ${realPath} ${path}`);
  } else {
    let buffer = fs.readFileSync(realPath);
    fs.rmSync(path);
    if (replaceDll) {
      fs.writeFileSync(path.replace('.txt', '.dll'), buffer);
    } else {
      fs.writeFileSync(path, buffer);
    }
  }
}

function patchAppRev(baseDir) {
  const gitHead = exec('git rev-parse --short HEAD');
  const cmake = PATH.join(baseDir, 'src/CMakeLists.txt');
  let txt = fs.readFileSync(cmake, { encoding: 'utf-8' });

  // Split the content into lines
  const lines = txt.split('\n');

  const start = lines.findIndex(line => line.indexOf('git rev-parse') >= 0);

  // Remove lines 690 to 696 (indexes are 689 to 695 because arrays are zero-based)
  let updatedContent = [
    ...lines.slice(0, start - 1),
    ...lines.slice(start + 5)
  ].join('\n');

  updatedContent = updatedContent.replace('${GIT_HEAD}', gitHead.toString().trim());

  fs.writeFileSync(cmake, updatedContent);
}

function patchAppVersion(baseDir) {
  const appVer = exec('node bridge/scripts/get_app_ver.js', {
    cwd: PATH.join(__dirname, '../')
  });

  const cmake = PATH.join(baseDir, 'src/CMakeLists.txt');
  let txt = fs.readFileSync(cmake, { encoding: 'utf-8' });

  // Split the content into lines
  const lines = txt.split('\n');

  const start = lines.findIndex(line => line.indexOf('node get_app_ver.js') >= 0);

  // Remove lines 690 to 696 (indexes are 689 to 695 because arrays are zero-based)
  let updatedContent = [
    ...lines.slice(0, start - 1),
    ...lines.slice(start + 5)
  ].join('\n');

  updatedContent = updatedContent.replace('${APP_VER}', appVer.toString().trim());
  fs.writeFileSync(cmake, updatedContent);
}

function patchGitIgnore() {
  let rootGitIgnore = PATH.join(__dirname, "../.gitignore");
  let bridgeGitIgnore = PATH.join(__dirname, "../bridge/.gitignore");
  let polyfillGitIgnore = PATH.join(__dirname, "../bridge/polyfill/.gitignore");
  fs.writeFileSync(rootGitIgnore, updatedRootGitIgnore);
  fs.writeFileSync(bridgeGitIgnore, updatedBridgeIgnore);
  fs.writeFileSync(polyfillGitIgnore, updatedPolyFillIgnore);
}

function addGenFilesToGit() {
  let webfDir = PATH.join(__dirname, "../webf");
  exec('git add src', {
    cwd: webfDir
  });
  exec('rm -rf webf/win_src', {
    cwd: PATH.join(__dirname, '../')
  });
  exec(`git add windows/CMakeLists.txt`, {
    cwd: webfDir
  });
  exec(`git add .gitignore`, {
    cwd: PATH.join(__dirname, '../')
  });
  exec(`git add bridge/.gitignore`, {
    cwd: PATH.join(__dirname, '../')
  });
  exec(`git add bridge/polyfill/.gitignore`, {
    cwd: PATH.join(__dirname, '../')
  });
  exec('git config user.email bot@openwebf.com');
  exec('git config user.name openwebf-bot');
  exec('git commit -m "init"');
}

function patchWindowsCMake(baseDir) {
  const windowCMake = PATH.join(baseDir, 'windows/CMakeLists.txt');
  let txt = fs.readFileSync(windowCMake, { encoding: 'utf-8' });
  txt = txt.replace('win_src', 'src');
  fs.writeFileSync(windowCMake, txt);
}

const krakenDir = PATH.join(__dirname, "../webf");

const symbolFiles = [
  "ios/Frameworks/webf_bridge.xcframework",
  "ios/Frameworks/quickjs.xcframework",
  "macos/libwebf.dylib",
  "macos/libquickjs.dylib",
];

for (let file of symbolFiles) {
  symbolicToRealFile(PATH.join(krakenDir, file));
}

patchGitIgnore();

const sourceSymbolFiles = [
  "src",
];

for (let file of sourceSymbolFiles) {
  symbolicToRealFile(PATH.join(krakenDir, file));
}

patchWindowsCMake(krakenDir);

patchAppRev(krakenDir);
patchAppVersion(krakenDir);

addGenFilesToGit();