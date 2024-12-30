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

