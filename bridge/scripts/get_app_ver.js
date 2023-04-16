const fs = require('fs');
const path = require('path');
const pubspecFile = path.resolve(__dirname, '../../webf/pubspec.yaml');

const config = fs.readFileSync(pubspecFile, {encoding: 'utf-8'});
const regex = /version: ([\w\.\+\-]+)/;
console.log(regex.exec(config)[1]);