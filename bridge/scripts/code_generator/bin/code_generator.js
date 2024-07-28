#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const fs = require('fs');
const { execSync } = require('child_process');
const { IDLBlob } = require('../dist/idl/IDLBlob');
const { JSONBlob } = require('../dist/json/JSONBlob');
const { JSONTemplate } = require('../dist/json/JSONTemplate');
const { analyzer } = require('../dist/idl/analyzer');
const { generatorSource } = require('../dist/idl/generator')
const { generateUnionTypes, generateUnionTypeFileName } = require('../dist/idl/generateUnionTypes')
const { generateJSONTemplate } = require('../dist/json/generator');
const { generateNamesInstaller } = require("../dist/json/generator");
const { union } = require("lodash");
const {makeCSSPropertyNames} = require("../dist/json/make_css_property_names");
const {makePropertyBitset} = require("../dist/json/make_property_bitset");
const {makeStylePropertyShorthand} = require("../dist/json/make_property_shorthand");
const {makeCSSPropertySubClasses} = require("../dist/json/make_css_property_subclasses");

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
    let filename = 'qjs_' + file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

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
    writeFileIfChanged(path.join(dist, filename) + '.h', result.header);
    writeFileIfChanged(path.join(dist, filename) + '.cc', result.source);
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
      writeFileIfChanged(genFilePath + '.h', result.header);

      if (targetTemplate.gperf) {
        execSync(`cat << EOF | gperf ${targetTemplate.gperf} > ${genFilePath + '.cc'} 
${result.source}
EOF`, {stdio: 'inherit'})
      } else {
        result.source && writeFileIfChanged(genFilePath + '.cc', result.source);
      }
    });
  }

  // Generate name installer code.
  let targetTemplateHeader = templates.find(t => t.filename === 'names_installer.h');
  let targetTemplateBody = templates.find(t => t.filename === 'names_installer.cc');
  let result = generateNamesInstaller(targetTemplateHeader, targetTemplateBody, names_needs_install);
  let genFilePath = path.join(dist, 'names_installer');
  writeFileIfChanged(genFilePath + '.h', result.header);
  result.source && writeFileIfChanged(genFilePath + '.cc', result.source);

  // Generate css_property_names code
  let cssPropertyNamesResult = makeCSSPropertyNames();
  let cssPropertyGenFilePath = path.join(dist, 'css_property_names');
  writeFileIfChanged(cssPropertyGenFilePath + '.h', cssPropertyNamesResult.header);
  execSync(`cat << EOF | gperf --key-positions='*' -P -n -m 50 -D -Q CSSPropStringPool > ${cssPropertyGenFilePath + '.cc'} 
${cssPropertyNamesResult.source}
EOF`, {stdio: 'inherit'});

  // Generate property_bitset code
  let propertyBitsetResult = makePropertyBitset();
  let propertyBitSetGenFilePath = path.join(dist, 'property_bitset');
  writeFileIfChanged(propertyBitSetGenFilePath + '.cc', propertyBitsetResult.source);

  // Generate css_property_subclass code
  let cssShortHandResult = makeCSSPropertySubClasses(true);
  let cssShortHandGenFilePath = path.join(dist, 'shorthands');
  writeFileIfChanged(cssShortHandGenFilePath + '.h', cssShortHandResult.header);
  writeFileIfChanged(cssShortHandGenFilePath + '.cc', cssShortHandResult.source);

  let cssLongHandResult = makeCSSPropertySubClasses(false);
  let cssLongHandResultGenFilePath = path.join(dist, 'longhands');
  writeFileIfChanged(cssLongHandResultGenFilePath + '.h', cssLongHandResult.header);
  writeFileIfChanged(cssLongHandResultGenFilePath + '.cc', cssLongHandResult.source);

  // Generate style_property_shorthand code
  let stylePropertyShorthandResult = makeStylePropertyShorthand();
  let stylePropertyShorthandGenFilePath = path.join(dist, 'style_property_shorthand');
  writeFileIfChanged(stylePropertyShorthandGenFilePath + '.h', stylePropertyShorthandResult.header);
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

genCodeFromTypeDefine();
genCodeFromJSONData();
