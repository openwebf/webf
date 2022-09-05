#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const fs = require('fs');
const { IDLBlob } = require('../dist/idl/IDLBlob');
const { JSONBlob } = require('../dist/json/JSONBlob');
const { JSONTemplate } = require('../dist/json/JSONTemplate');
const { analyzer } = require('../dist/idl/analyzer');
const { generateJSONTemplate } = require('../dist/json/generator');
const { generateNamesInstaller } = require("../dist/json/generator");

program
  .version(packageJSON.version)
  .description('WebF code generator.')
  .requiredOption('-s, --source <path>', 'source directory.')
  .requiredOption('-d, --dist <path>', 'destionation directory.')

program.parse(process.argv);

let {source, dist} = program.opts();

if (!path.isAbsolute(source)) {
  source = path.join(process.cwd(), source);
}
if (!path.isAbsolute(dist)) {
  dist = path.join(process.cwd(), dist);
}

function genCodeFromTypeDefine() {
  // Generate code from type defines.
  let typeFiles = glob.sync("**/*.d.ts", {
    cwd: source,
  });

  let blobs = typeFiles.map(file => {
    let filename = 'qjs_' + file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = analyzer(b);

    if (!fs.existsSync(b.dist)) {
      fs.mkdirSync(b.dist, {recursive: true});
    }

    let genFilePath = path.join(b.dist, b.filename);

    fs.writeFileSync(genFilePath + '.h', result.header);
    fs.writeFileSync(genFilePath + '.cc', result.source);
  }
}

// Generate code from json data.
function genCodeFromJSONData() {
  let jsonFiles = glob.sync('**/*.json5', {
    cwd: source
  });
  let templateFiles = glob.sync('**/*.tpl', {
    cwd: path.join(__dirname, '../static/json_templates')
  });

  let blobs = jsonFiles.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.json', '');
    return new JSONBlob(path.join(source, file), dist, filename);
  });

  let templates = templateFiles.map(template => {
    let filename = template.split('/').slice(-1)[0].replace('.tpl', '');
    return new JSONTemplate(path.join(path.join(__dirname, '../static/json_templates'), template), filename);
  });

  let names_needs_install = new Set();
  for (let i = 0; i < blobs.length; i ++) {
    let blob = blobs[i];
    blob.json.metadata.templates.forEach((targetTemplate) => {
      if (targetTemplate.template === 'make_names') {
        names_needs_install.add(targetTemplate.filename);
      }
      let depsBlob = {};
      if (targetTemplate.deps) {
        let cwdDir = blob.source.split('/').slice(0, -1).join('/');
        targetTemplate.deps.forEach(depPath => {
          let filename = depPath.split('/').slice(-1)[0].replace('.json5', '');
          depsBlob[filename] = new JSONBlob(path.join(cwdDir, depPath), filename).json;
        });
      }
      let targetTemplateHeaderData = templates.find(t => t.filename === targetTemplate.template + '.h');
      let targetTemplateBodyData = templates.find(t => t.filename === targetTemplate.template + '.cc');
      blob.filename = targetTemplate.filename;
      let result = generateJSONTemplate(blobs[i], targetTemplateHeaderData, targetTemplateBodyData, depsBlob);
      let dist = blob.dist;
      let genFilePath = path.join(dist, targetTemplate.filename);
      fs.writeFileSync(genFilePath + '.h', result.header);
      result.source && fs.writeFileSync(genFilePath + '.cc', result.source);
    });
  }

  // Generate name installer code.
  let targetTemplateHeader = templates.find(t => t.filename === 'names_installer.h');
  let targetTemplateBody = templates.find(t => t.filename === 'names_installer.cc');
  let result = generateNamesInstaller(targetTemplateHeader, targetTemplateBody, names_needs_install);
  let genFilePath = path.join(dist, 'names_installer');
  fs.writeFileSync(genFilePath + '.h', result.header);
  result.source && fs.writeFileSync(genFilePath + '.cc', result.source);
}

genCodeFromTypeDefine();
genCodeFromJSONData();
