#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const fs = require('fs');
const { IDLBlob } = require('../dist/idl/IDLBlob');
const { JSONBlob } = require('../dist/json/JSONBlob');
const { JSONTemplate } = require('../dist/json/JSONTemplate');
const { analyzer, buildClassRelationship } = require('../dist/idl/analyzer');
const { generatorSource } = require('../dist/idl/generator')
const { generateUnionTypes, generateUnionTypeFileName } = require('../dist/idl/generateUnionTypes')
const { generateJSONTemplate } = require('../dist/json/generator');
const { generateNamesInstaller } = require("../dist/json/generator");
const { generatePluginAPI } = require("../dist/idl/pluginAPIGenerator/cppGen");
const { generateRustSource } = require("../dist/idl/pluginAPIGenerator/rsGen");
const { union } = require("lodash");
const { ClassObject } = require('../dist/idl/declaration');

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

function wirteFileIfChanged(filePath, content) {
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
    let filename = 'qjs_' + file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

  ClassObject.globalClassMap = Object.create(null);

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, unionTypeCollector);
  }

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = generatorSource(b);

    if (!fs.existsSync(b.dist)) {
      fs.mkdirSync(b.dist, {recursive: true});
    }

    let genFilePath = path.join(b.dist, b.filename);

    wirteFileIfChanged(genFilePath + '.h', result.header);
    wirteFileIfChanged(genFilePath + '.cc', result.source);
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
        blob.json.data = blob.json.data.concat(Array.from(definedPropertyCollector.properties));
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
      wirteFileIfChanged(genFilePath + '.h', result.header);
      result.source && wirteFileIfChanged(genFilePath + '.cc', result.source);
    });
  }

  // Generate name installer code.
  let targetTemplateHeader = templates.find(t => t.filename === 'names_installer.h');
  let targetTemplateBody = templates.find(t => t.filename === 'names_installer.cc');
  let result = generateNamesInstaller(targetTemplateHeader, targetTemplateBody, names_needs_install);
  let genFilePath = path.join(dist, 'names_installer');
  wirteFileIfChanged(genFilePath + '.h', result.header);
  result.source && wirteFileIfChanged(genFilePath + '.cc', result.source);
}

class DefinedPropertyCollector {
  properties = new Set();
  files = new Set();
  interfaces = new Set();
}

class UnionTypeCollector {
  types = new Set()
}

let definedPropertyCollector = new DefinedPropertyCollector();
let unionTypeCollector = new UnionTypeCollector();
let names_needs_install = new Set();

const pluginApiList = [
  'dom/events/add_event_listener_options.d.ts',
  'dom/events/event_listener_options.d.ts',
  'dom/scroll_options.d.ts',
  'dom/scroll_to_options.d.ts',
  'dom/events/event_init.d.ts',
  'events/animation_event_init.d.ts',
  'events/close_event_init.d.ts',
  'events/focus_event_init.d.ts',
  'events/gesture_event_init.d.ts',
  'events/hashchange_event_init.d.ts',
  'events/input_event_init.d.ts',
  'events/intersection_change_event_init.d.ts',
  'events/keyboard_event_init.d.ts',
  'events/mouse_event_init.d.ts',
  'events/pointer_event_init.d.ts',
  'events/transition_event_init.d.ts',
  'input/touch_init.d.ts',
  'events/ui_event_init.d.ts',
  'dom/events/event.d.ts',
  'dom/events/custom_event.d.ts',
  'events/animation_event.d.ts',
  'events/close_event.d.ts',
  'events/focus_event.d.ts',
  'events/gesture_event.d.ts',
  'events/hashchange_event.d.ts',
  'events/input_event.d.ts',
  'events/intersection_change_event.d.ts',
  'events/mouse_event.d.ts',
  'events/pointer_event.d.ts',
  'events/transition_event.d.ts',
  'events/ui_event.d.ts',
];

genCodeFromTypeDefine();
genCodeFromJSONData();
genPluginAPICodeFromTypeDefine();
genRustCodeFromTypeDefine();

function genPluginAPICodeFromTypeDefine() {
  // Generate code from type defines.
  // let typeFiles = glob.sync("**/*.d.ts", {
  //   cwd: source,
  // });

  let blobs = pluginApiList.map(file => {
    let filename = 'plugin_api_' + file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

  ClassObject.globalClassMap = Object.create(null);

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, unionTypeCollector);
  }

  buildClassRelationship();

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = generatePluginAPI(b);

    if (!fs.existsSync(b.dist)) {
      fs.mkdirSync(b.dist, {recursive: true});
    }

    let headerFilePath = path.join(b.dist, '../include/plugin_api', b.filename.replace('plugin_api_', ''));
    let genFilePath = path.join(b.dist, b.filename);

    wirteFileIfChanged(headerFilePath + '.h', result.header);

    if (result.source) {
      wirteFileIfChanged(genFilePath + '.cc', result.source);
    }
  }

}

function genRustCodeFromTypeDefine() {
  // Generate code from type defines.
  let blobs = pluginApiList.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

  ClassObject.globalClassMap = Object.create(null);

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, unionTypeCollector);
  }

  buildClassRelationship();

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = generateRustSource(b);

    if (!fs.existsSync(b.dist)) {
      fs.mkdirSync(b.dist, {recursive: true});
    }

    let genFilePath = path.join(b.dist, '../rusty_webf_sys/src', b.filename);

    wirteFileIfChanged(genFilePath + '.rs', result);
  }

}
