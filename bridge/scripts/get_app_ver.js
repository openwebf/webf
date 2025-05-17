const fs = require('fs');
const path = require('path');
const pubspecFile = path.resolve(__dirname, '../../webf/pubspec.yaml');
const quickjsVersionFile = path.resolve(__dirname, '../third_party/quickjs/VERSION')

const config = fs.readFileSync(pubspecFile, {encoding: 'utf-8'});
const regex = /version: ([\w\.\+\-]+)/;
const string = `${regex.exec(config)[1]}/QuickJS: ${fs.readFileSync(quickjsVersionFile, {encoding: 'utf-8'})}`;
console.log(string);