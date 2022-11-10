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
const { generatorSource } = require('../dist/idl/generator')
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

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector);
  }

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = generatorSource(b);

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
    cwd: path.join(__dirname, '../templates/json_templates')
  });

  let blobs = jsonFiles.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.json', '');
    return new JSONBlob(path.join(source, file), dist, filename);
  });

  let templates = templateFiles.map(template => {
    let filename = template.split('/').slice(-1)[0].replace('.tpl', '');
    return new JSONTemplate(path.join(path.join(__dirname, '../templates/json_templates'), template), filename);
  });

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

      // Inject allDefinedProperties set into the definedProperties source.
      if (targetTemplate.filename === 'defined_properties') {
        blob.json.data = Array.from(definedPropertyCollector.properties);
      }

      if (targetTemplate.filename === 'defined_properties_initializer') {
        blob.json.data = {
          filenames: Array.from(definedPropertyCollector.files),
          interfaces: Array.from(definedPropertyCollector.interfaces)
        };
      }

      let targetTemplateHeaderData = templates.find(t => t.filename === targetTemplate.template + '.h');
      let targetTemplateBodyData = templates.find(t => t.filename === targetTemplate.template + '.cc');
      blob.filename = targetTemplate.filename;
      let result = generateJSONTemplate(blobs[i], targetTemplateHeaderData, targetTemplateBodyData, depsBlob, targetTemplate.options);
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

class DefinedPropertyCollector {
  properties = new Set();
  files = new Set();
  interfaces = new Set();
}

let definedPropertyCollector = new DefinedPropertyCollector();
let names_needs_install = new Set();

genCodeFromTypeDefine();
genCodeFromJSONData();
