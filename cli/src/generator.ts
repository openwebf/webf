import path from 'path';
import fs from 'fs';
import process from 'process';
import _ from 'lodash';
import glob from 'glob';
import { IDLBlob } from './IDLBlob';
import { ClassObject } from './declaration';
import { analyzer, ParameterType } from './analyzer';
import { generateDartClass } from './dart';
import { generateReactComponent, generateReactIndex } from './react';
import { generateVueTypings } from './vue';

function wirteFileIfChanged(filePath: string, content: string) {
  if (fs.existsSync(filePath)) {
    const oldContent = fs.readFileSync(filePath, 'utf-8')
    if (oldContent === content) {
      return;
    }
  }

  fs.writeFileSync(filePath, content, 'utf-8');
}

class DefinedPropertyCollector {
  properties = new Set<string>();
  files = new Set<string>();
  interfaces = new Set<string>();
}

class UnionTypeCollector {
  types = new Set<ParameterType[]>()
}

interface GenerateOptions {
  source: string;
  target: string;
  command: string;
}

export function dartGen({ source, target, command }: GenerateOptions) {
  if (!path.isAbsolute(source)) {
    source = path.join(process.cwd(), source);
  }
  if (!path.isAbsolute(target)) {
    target = path.join(process.cwd(), target);
  }

  let definedPropertyCollector = new DefinedPropertyCollector();
  let unionTypeCollector = new UnionTypeCollector();

  // Generate code from type defines.
  let typeFiles = glob.sync("**/*.d.ts", {
    cwd: source,
  }).filter(file => {
    return !file.includes('global.d.ts');
  });

  let blobs = typeFiles.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../'), '').replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), target, filename, implement);
  });

  ClassObject.globalClassMap = Object.create(null);

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, unionTypeCollector);
  }

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = generateDartClass(b, command);

    b.dist = path.join(target);

    if (!fs.existsSync(b.dist)) {
      fs.mkdirSync(b.dist, {recursive: true});
    }

    let genFilePath = path.join(b.dist, _.snakeCase(b.filename));

    wirteFileIfChanged(genFilePath + '_bindings_generated.dart', result);
  }

  console.log('Dart code generation completed. See ' + target + ' for generated files.');

};

export function reactGen({ source, target }: GenerateOptions) {
  target = _.kebabCase(target);
  if (!path.isAbsolute(source)) {
    source = path.join(process.cwd(), source);
  }
  if (!path.isAbsolute(target)) {
    target = path.join(process.cwd(), target);
  }

  let definedPropertyCollector = new DefinedPropertyCollector();
  let unionTypeCollector = new UnionTypeCollector();

  // Generate code from type defines.
  let typeFiles = glob.sync("**/*.d.ts", {
    cwd: source,
  }).filter(file => {
    return !file.includes('global.d.ts');
  });

  let blobs = typeFiles.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../'), '').replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), target, filename, implement);
  });

  ClassObject.globalClassMap = Object.create(null);

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, unionTypeCollector);
  }

  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    let result = generateReactComponent(b);
    let genFilePath = path.join(b.dist, 'src', b.filename);

    wirteFileIfChanged(genFilePath + '.tsx', result);
  }

  const indexContent = generateReactIndex(blobs);
  const indexFilePath = path.join(target, 'src', 'index.ts');
  wirteFileIfChanged(indexFilePath, indexContent);
  console.log('React code generation completed. See ' + target + ' for generated files.');
  console.log('You can now import these components in your React project.');
};

export function vueGen({ source, target }: GenerateOptions) {
  target = _.kebabCase(target);
  if (!path.isAbsolute(source)) {
    source = path.join(process.cwd(), source);
  }
  if (!path.isAbsolute(target)) {
    target = path.join(process.cwd(), target);
  }

  let definedPropertyCollector = new DefinedPropertyCollector();
  let unionTypeCollector = new UnionTypeCollector();

  // Generate code from type defines.
  let typeFiles = glob.sync("**/*.d.ts", {
    cwd: source,
  }).filter(file => {
    return !file.includes('global.d.ts');
  });

  let blobs = typeFiles.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../'), '').replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), target, filename, implement);
  });

  ClassObject.globalClassMap = Object.create(null);

  // Analyze all files first.
  for (let i = 0; i < blobs.length; i ++) {
    let b = blobs[i];
    analyzer(b, definedPropertyCollector, unionTypeCollector);
  }

  const typingsContent = generateVueTypings(blobs);
  const typingsFilePath = path.join(target, 'index.d.ts');
  wirteFileIfChanged(typingsFilePath, typingsContent);
  console.log('Vue typings generation completed. See ' + target + ' for generated files.');
  console.log('You can now import these types in your Vue project.');
}
