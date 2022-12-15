#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const fs = require('fs');
const { IDLBlob } = require('../dist/ts_types/idl/IDLBlob');
const { JSONBlob } = require('../dist/json/JSONBlob');
const { JSONTemplate } = require('../dist/json/JSONTemplate');
const { analyzer } = require('../dist/ts_types/analyzer');
const { TemplateType } = require('../dist/ts_types/types');
const { generatorIDLSource } = require('../dist/ts_types/idl/generator');
const { generatorDAP } = require('../dist/ts_types/dap/generator');
const { generateDAPSource } = require('../dist/ts_types/dap/generateSource');
const { generateUnionTypes, generateUnionTypeFileName } = require('../dist/idl/generateUnionTypes')
const { generateJSONTemplate } = require('../dist/json/generator');
const { generateNamesInstaller } = require("../dist/json/generator");
const { union } = require("lodash");

program
  .version(packageJSON.version)
  .description('WebF code generator.')
  .requiredOption('-s, --source <path>', 'source directory.')
  .requiredOption('--type [IDL,DAP,DART]', 'the template type')
  .requiredOption('-d, --dist <path>', 'destionation directory.')

program.parse(process.argv);

let {source, dist, type} = program.opts();

if (!TemplateType.hasOwnProperty(type.toUpperCase())) {
  throw new Error(`The template of type: [${type}] is not one of IDL,DAP,DART`);
}

if (!path.isAbsolute(source)) {
  source = path.join(process.cwd(), source);
}
if (!path.isAbsolute(dist)) {
  dist = path.join(process.cwd(), dist);
}

function writeFileIfChanged(filePath, content) {
  if (fs.existsSync(filePath)) {
    const oldContent = fs.readFileSync(filePath, 'utf-8')
    if (oldContent === content) {
      return;
    }
  }

  fs.writeFileSync(filePath, content, 'utf-8');
}

function genCodeFromTypeDefine() {
  // Generate code from type defines.
  let typeFiles = glob.sync("**/*.d.ts", {
    cwd: source,
  });

  let blobs = typeFiles.map(file => {
    let prefix = type.toUpperCase() === 'IDL' ? 'qjsc_' : ''

    let filename = prefix + file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, TemplateType[type.toUpperCase()], dapInfoCollector, unionTypeCollector);
  }

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];

    let result = '';
    switch(type.toUpperCase()) {
      case 'IDL':
        result = generatorIDLSource(b, TemplateType[type.toUpperCase()]);
        break;
      case 'DAP':
        result = generatorDAP(b, TemplateType[type.toUpperCase()]);
        break;
    }

    if (!fs.existsSync(b.dist)) {
      fs.mkdirSync(b.dist, {recursive: true});
    }

    let genFilePath = path.join(b.dist, b.filename);

    writeFileIfChanged(genFilePath + '.h', result.header);
    writeFileIfChanged(genFilePath + '.cc', result.source);
  }

  let unionTypes = Array.from(unionTypeCollector.types);
  unionTypes.forEach(union => {
    union.sort((p, n) => {
      if (typeof p.value === 'string') return 1;
      return -(n.value - p.value);
    })
  });
  for(let i = 0; i < unionTypes.length; i ++) {
    let result = generateUnionTypes(unionTypes[i]);
    let filename = generateUnionTypeFileName(unionTypes[i]);
    wirteFileIfChanged(path.join(dist, filename) + '.h', result.header);
    wirteFileIfChanged(path.join(dist, filename) + '.cc', result.source);
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
    let filename = file.split(path.sep).slice(-1)[0].replace('.json', '');
    return new JSONBlob(path.join(source, file), dist, filename);
  });

  let templates = templateFiles.map(template => {
    let filename = template.split(path.sep).slice(-1)[0].replace('.tpl', '');
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
        let cwdDir = blob.source.split(path.sep).slice(0, -1).join(path.sep);
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
      writeFileIfChanged(genFilePath + '.h', result.header);
      result.source && writeFileIfChanged(genFilePath + '.cc', result.source);
    });
  }

  // Generate name installer code.
  let targetTemplateHeader = templates.find(t => t.filename === 'names_installer.h');
  let targetTemplateBody = templates.find(t => t.filename === 'names_installer.cc');
  let result = generateNamesInstaller(targetTemplateHeader, targetTemplateBody, names_needs_install);
  let genFilePath = path.join(dist, 'names_installer');
  writeFileIfChanged(genFilePath + '.h', result.header);
  result.source && writeFileIfChanged(genFilePath + '.cc', result.source);
}

function genDapConverterCodes() {
  const dapConverterHeaderTemplate = fs.readFileSync(path.join(__dirname, '../templates/dap_templates/dap_converter.h.tpl'), {encoding: 'utf-8'});

  const converterSource = generateDAPSource(dapInfoCollector);

  const genFilePath = path.join(dist, 'dap_converter');
  writeFileIfChanged(genFilePath + '.h', dapConverterHeaderTemplate);
  writeFileIfChanged(genFilePath + '.c', converterSource);
}

class DefinedPropertyCollector {
  properties = new Set();
  files = new Set();
  interfaces = new Set();
}

class DAPInfoCollector {
  requests = new Set();
  arguments = new Set();
  response = new Set();
  bodies = new Set();
  events = new Set();
  others = new Set();
}

class UnionTypeCollector {
  types = new Set()
}

let definedPropertyCollector = new DefinedPropertyCollector();
let dapInfoCollector = new DAPInfoCollector();
let unionTypeCollector = new UnionTypeCollector();
let names_needs_install = new Set();

genCodeFromTypeDefine();
if (type.toUpperCase() === 'IDL') genCodeFromJSONData();
if (type.toUpperCase() === 'DAP') genDapConverterCodes();
