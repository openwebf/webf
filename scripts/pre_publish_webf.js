const exec = require("child_process").execSync;
const fs = require("fs");
const PATH = require("path");
const os = require('os');

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

function cleanUpBridge() {
  let bridgeDir = PATH.join(__dirname, "../bridge");
  exec('rm -rf cmake-*', {
    cwd: bridgeDir
  });
  exec('rm -rf build', {
    cwd: bridgeDir
  });
  exec('rm -rf polyfill/node_modules', {
    cwd: bridgeDir
  });
  exec('rm -rf polyfill/package-lock.json', {
    cwd: bridgeDir
  });
  exec('rm -rf polyfill/.gitignore', {
    cwd: bridgeDir
  });
  exec('rm -rf rusty_webf_sys/target', {
    cwd: bridgeDir
  });
  exec('rm -rf scripts/code_generator', {
    cwd: bridgeDir
  });
  exec('rm -rf ../webf/win_src', {
    cwd: bridgeDir
  });
  exec('rm -rf .gitignore', {
    cwd: bridgeDir
  })
}

function patchWindowsCMake(baseDir) {
  const windowCMake = PATH.join(baseDir, 'windows/CMakeLists.txt');
  let txt = fs.readFileSync(windowCMake, {encoding: 'utf-8'});
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

cleanUpBridge();

const sourceSymbolFiles = [
  "src",
];

for (let file of sourceSymbolFiles) {
  symbolicToRealFile(PATH.join(krakenDir, file));
}

patchWindowsCMake(krakenDir);
