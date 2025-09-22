import path from 'path';
import fs from 'fs';
import process from 'process';
import _ from 'lodash';
import { glob } from 'glob';
import yaml from 'yaml';
import { IDLBlob } from './IDLBlob';
import { ClassObject } from './declaration';
import { analyzer, ParameterType, clearCaches } from './analyzer';
import { generateDartClass } from './dart';
import { generateReactComponent, generateReactIndex } from './react';
import { generateVueTypings } from './vue';
import { logger, debug, info, success, warn, error, group, progress, time, timeEnd } from './logger';
import ts from 'typescript';

// Cache for file content to avoid redundant reads
const fileContentCache = new Map<string, string>();

// Cache for generated content to detect changes
const generatedContentCache = new Map<string, string>();

function writeFileIfChanged(filePath: string, content: string): boolean {
  // Check if content has changed by comparing with cache
  const cachedContent = generatedContentCache.get(filePath);
  if (cachedContent === content) {
    return false; // No change
  }
  
  // Check if file exists and has same content
  if (fs.existsSync(filePath)) {
    const existingContent = fileContentCache.get(filePath) || fs.readFileSync(filePath, 'utf-8');
    fileContentCache.set(filePath, existingContent);
    
    if (existingContent === content) {
      generatedContentCache.set(filePath, content);
      return false; // No change
    }
  }
  
  // Create directory if it doesn't exist
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  // Write file and update caches
  fs.writeFileSync(filePath, content, 'utf-8');
  fileContentCache.set(filePath, content);
  generatedContentCache.set(filePath, content);
  
  return true; // File was changed
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
  exclude?: string[];
  packageName?: string;
}

// Batch processing for file operations
async function processFilesInBatch<T>(
  items: T[],
  batchSize: number,
  processor: (item: T) => Promise<void> | void
): Promise<void> {
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    await Promise.all(batch.map(item => processor(item)));
  }
}

function validatePaths(source: string, target: string): { source: string; target: string } {
  if (!source) {
    throw new Error('Source path is required');
  }
  
  if (!target) {
    throw new Error('Target path is required');
  }
  
  // Normalize paths
  const normalizedSource = path.isAbsolute(source) ? source : path.join(process.cwd(), source);
  const normalizedTarget = path.isAbsolute(target) ? target : path.join(process.cwd(), target);
  
  // Validate source exists
  if (!fs.existsSync(normalizedSource)) {
    throw new Error(`Source path does not exist: ${normalizedSource}`);
  }
  
  return { source: normalizedSource, target: normalizedTarget };
}

function getTypeFiles(source: string, excludePatterns?: string[]): string[] {
  try {
    const defaultIgnore = ['**/node_modules/**', '**/dist/**', '**/build/**', '**/example/**'];
    const ignore = excludePatterns ? [...defaultIgnore, ...excludePatterns] : defaultIgnore;
    
    const files = glob.globSync("**/*.d.ts", {
      cwd: source,
      ignore: ignore
    });
    
    return files.filter(file => !file.includes('global.d.ts'));
  } catch (err) {
    error(`Error scanning for type files in ${source}`, err);
    throw new Error(`Failed to scan type files: ${err instanceof Error ? err.message : String(err)}`);
  }
}

function createBlobs(typeFiles: string[], source: string, target: string): IDLBlob[] {
  return typeFiles.map(file => {
    const filename = path.basename(file, '.d.ts');
    const implement = file.replace(path.join(__dirname, '../../'), '').replace('.d.ts', '');
    // Store the relative directory path for maintaining structure
    const relativeDir = path.dirname(file);
    const blob = new IDLBlob(path.join(source, file), target, filename, implement, relativeDir);
    
    // Pre-cache file content
    if (!fileContentCache.has(blob.source)) {
      try {
        const content = fs.readFileSync(blob.source, 'utf-8');
        fileContentCache.set(blob.source, content);
        blob.raw = content;
      } catch (err) {
        error(`Error reading file ${blob.source}`, err);
        throw err;
      }
    } else {
      blob.raw = fileContentCache.get(blob.source)!;
    }
    
    return blob;
  });
}

export async function dartGen({ source, target, command, exclude }: GenerateOptions) {
  group('Dart Code Generation');
  time('dartGen');
  
  const { source: normalizedSource, target: normalizedTarget } = validatePaths(source, target);
  
  const definedPropertyCollector = new DefinedPropertyCollector();
  const unionTypeCollector = new UnionTypeCollector();
  
  // Clear analyzer caches for fresh run
  if (typeof clearCaches === 'function') {
    clearCaches();
  }
  
  // Get type files
  const typeFiles = getTypeFiles(normalizedSource, exclude);
  info(`Found ${typeFiles.length} type definition files`);
  
  if (typeFiles.length === 0) {
    warn('No type definition files found');
    timeEnd('dartGen');
    return;
  }
  
  // Create blobs
  const blobs = createBlobs(typeFiles, normalizedSource, normalizedTarget);
  
  // Reset global class map
  ClassObject.globalClassMap = Object.create(null);
  
  // Analyze all files first
  info('Analyzing type definitions...');
  let analyzed = 0;
  for (const blob of blobs) {
    try {
      analyzer(blob, definedPropertyCollector, unionTypeCollector);
      analyzed++;
      progress(analyzed, blobs.length, `Analyzing ${blob.filename}`);
    } catch (err) {
      error(`Error analyzing ${blob.filename}`, err);
      // Continue with other files
    }
  }
  
  // Generate Dart code and copy .d.ts files
  info('\nGenerating Dart classes...');
  let filesChanged = 0;
  
  await processFilesInBatch(blobs, 5, async (blob) => {
    try {
      const result = generateDartClass(blob, command);
      blob.dist = normalizedTarget;
      
      // Maintain the same directory structure as the .d.ts file
      const outputDir = path.join(blob.dist, blob.relativeDir);
      // Ensure the directory exists
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }
      
      // Generate Dart file
      const genFilePath = path.join(outputDir, _.snakeCase(blob.filename));
      const fullPath = genFilePath + '_bindings_generated.dart';
      
      if (writeFileIfChanged(fullPath, result)) {
        filesChanged++;
        debug(`Generated: ${path.basename(fullPath)}`);
      }
      
      // Copy the original .d.ts file to the output directory
      const dtsOutputPath = path.join(outputDir, blob.filename + '.d.ts');
      if (writeFileIfChanged(dtsOutputPath, blob.raw)) {
        filesChanged++;
        debug(`Copied: ${path.basename(dtsOutputPath)}`);
      }
    } catch (err) {
      error(`Error generating Dart code for ${blob.filename}`, err);
    }
  });
  
  // Generate index.d.ts file with references to all .d.ts files
  const indexDtsContent = generateTypeScriptIndex(blobs, normalizedTarget);
  const indexDtsPath = path.join(normalizedTarget, 'index.d.ts');
  if (writeFileIfChanged(indexDtsPath, indexDtsContent)) {
    filesChanged++;
    debug('Generated: index.d.ts');
  }
  
  timeEnd('dartGen');
  success(`Dart code generation completed. ${filesChanged} files changed.`);
  info(`Output directory: ${normalizedTarget}`);
}

export async function reactGen({ source, target, exclude, packageName }: GenerateOptions) {
  group('React Code Generation');
  time('reactGen');
  
  const { source: normalizedSource, target: normalizedTarget } = validatePaths(source, target);
  
  const definedPropertyCollector = new DefinedPropertyCollector();
  const unionTypeCollector = new UnionTypeCollector();
  
  // Clear analyzer caches for fresh run
  if (typeof clearCaches === 'function') {
    clearCaches();
  }
  
  // Get type files
  const typeFiles = getTypeFiles(normalizedSource, exclude);
  info(`Found ${typeFiles.length} type definition files`);
  
  if (typeFiles.length === 0) {
    warn('No type definition files found');
    timeEnd('reactGen');
    return;
  }
  
  // Create blobs
  const blobs = createBlobs(typeFiles, normalizedSource, normalizedTarget);
  
  // Reset global class map
  ClassObject.globalClassMap = Object.create(null);
  
  // Analyze all files first
  info('Analyzing type definitions...');
  let analyzed = 0;
  for (const blob of blobs) {
    try {
      analyzer(blob, definedPropertyCollector, unionTypeCollector);
      analyzed++;
      progress(analyzed, blobs.length, `Analyzing ${blob.filename}`);
    } catch (err) {
      error(`Error analyzing ${blob.filename}`, err);
      // Continue with other files
    }
  }
  
  // Ensure src directory exists
  const srcDir = path.join(normalizedTarget, 'src');
  if (!fs.existsSync(srcDir)) {
    fs.mkdirSync(srcDir, { recursive: true });
  }
  
  // Generate React components
  info('\nGenerating React components...');
  let filesChanged = 0;
  
  await processFilesInBatch(blobs, 5, async (blob) => {
    try {
      const result = generateReactComponent(blob, packageName, blob.relativeDir);
      
      // Skip if no content was generated
      if (!result || result.trim().length === 0) {
        debug(`Skipped ${blob.filename} - no components found`);
        return;
      }
      
      // Maintain the same directory structure as the .d.ts file
      // Always put files under src/ directory
      const outputDir = path.join(normalizedTarget, 'src', blob.relativeDir);
      // Ensure the directory exists
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }
      
      const genFilePath = path.join(outputDir, blob.filename);
      const fullPath = genFilePath + '.tsx';
      
      if (writeFileIfChanged(fullPath, result)) {
        filesChanged++;
        debug(`Generated: ${path.basename(fullPath)}`);
      }
    } catch (err) {
      error(`Error generating React component for ${blob.filename}`, err);
    }
  });
  
  // Generate/merge index file
  const indexFilePath = path.join(normalizedTarget, 'src', 'index.ts');
  // Always build the full index content string for downstream tooling/logging
  const newExports = generateReactIndex(blobs);

  // Build desired export map: moduleSpecifier -> Set of names
  const desiredExports = new Map<string, Set<string>>();
  const components = blobs.flatMap(blob => {
    const classObjects = blob.objects.filter(obj => obj instanceof ClassObject) as ClassObject[];
    const properties = classObjects.filter(object => object.name.endsWith('Properties'));
    const events = classObjects.filter(object => object.name.endsWith('Events'));
    const componentMap = new Map<string, boolean>();
    properties.forEach(prop => componentMap.set(prop.name.replace(/Properties$/, ''), true));
    events.forEach(evt => componentMap.set(evt.name.replace(/Events$/, ''), true));
    return Array.from(componentMap.keys()).map(className => ({
      className,
      fileName: blob.filename,
      relativeDir: blob.relativeDir,
    }));
  });

  // Deduplicate by className
  const unique = new Map<string, { className: string; fileName: string; relativeDir: string }>();
  for (const c of components) {
    if (!unique.has(c.className)) unique.set(c.className, c);
  }
  for (const { className, fileName, relativeDir } of unique.values()) {
    const spec = `./${relativeDir ? `${relativeDir}/` : ''}${fileName}`;
    if (!desiredExports.has(spec)) desiredExports.set(spec, new Set());
    const set = desiredExports.get(spec)!;
    set.add(className);
    set.add(`${className}Element`);
  }

  if (!fs.existsSync(indexFilePath)) {
    // No index.ts -> generate fresh file from template
    if (writeFileIfChanged(indexFilePath, newExports)) {
      filesChanged++;
      debug(`Generated: index.ts`);
    }
  } else {
    // Merge into existing index.ts without removing user code
    try {
      const existing = fs.readFileSync(indexFilePath, 'utf-8');
      const sourceFile = ts.createSourceFile(indexFilePath, existing, ts.ScriptTarget.ES2020, true, ts.ScriptKind.TS);

      // Track which names already exported per module
      for (const stmt of sourceFile.statements) {
        if (ts.isExportDeclaration(stmt) && stmt.exportClause && ts.isNamedExports(stmt.exportClause)) {
          const moduleSpecifier = stmt.moduleSpecifier && ts.isStringLiteral(stmt.moduleSpecifier)
            ? stmt.moduleSpecifier.text
            : undefined;
          if (!moduleSpecifier) continue;
          const desired = desiredExports.get(moduleSpecifier);
          if (!desired) continue;
          for (const el of stmt.exportClause.elements) {
            const name = el.name.getText(sourceFile);
            if (desired.has(name)) desired.delete(name);
          }
        }
      }

      // Prepare new export lines for any remaining names
      const lines: string[] = [];
      for (const [spec, names] of desiredExports) {
        const missing = Array.from(names);
        if (missing.length === 0) continue;
        const specEscaped = spec.replace(/\\/g, '/');
        lines.push(`export { ${missing.join(', ')} } from "${specEscaped}";`);
      }

      if (lines.length > 0) {
        const appended = (existing.endsWith('\n') ? '' : '\n') + lines.join('\n') + '\n';
        if (writeFileIfChanged(indexFilePath, existing + appended)) {
          filesChanged++;
          debug(`Merged exports into existing index.ts`);
        }
      } else {
        debug(`index.ts is up to date; no merge needed.`);
      }
    } catch (err) {
      warn(`Failed to merge into existing index.ts. Skipping modifications: ${indexFilePath}`);
    }
  }
  
  timeEnd('reactGen');
  success(`React code generation completed. ${filesChanged} files changed.`);
  info(`Output directory: ${normalizedTarget}`);
  info('You can now import these components in your React project.');
}

export async function vueGen({ source, target, exclude }: GenerateOptions) {
  group('Vue Typings Generation');
  time('vueGen');
  
  const { source: normalizedSource, target: normalizedTarget } = validatePaths(source, target);
  
  const definedPropertyCollector = new DefinedPropertyCollector();
  const unionTypeCollector = new UnionTypeCollector();
  
  // Clear analyzer caches for fresh run
  if (typeof clearCaches === 'function') {
    clearCaches();
  }
  
  // Get type files
  const typeFiles = getTypeFiles(normalizedSource, exclude);
  info(`Found ${typeFiles.length} type definition files`);
  
  if (typeFiles.length === 0) {
    warn('No type definition files found');
    timeEnd('vueGen');
    return;
  }
  
  // Create blobs
  const blobs = createBlobs(typeFiles, normalizedSource, normalizedTarget);
  
  // Reset global class map
  ClassObject.globalClassMap = Object.create(null);
  
  // Analyze all files first
  info('Analyzing type definitions...');
  let analyzed = 0;
  for (const blob of blobs) {
    try {
      analyzer(blob, definedPropertyCollector, unionTypeCollector);
      analyzed++;
      progress(analyzed, blobs.length, `Analyzing ${blob.filename}`);
    } catch (err) {
      error(`Error analyzing ${blob.filename}`, err);
      // Continue with other files
    }
  }
  
  // Generate Vue typings
  info('\nGenerating Vue typings...');
  const typingsContent = generateVueTypings(blobs);
  const typingsFilePath = path.join(normalizedTarget, 'index.d.ts');
  
  let filesChanged = 0;
  if (writeFileIfChanged(typingsFilePath, typingsContent)) {
    filesChanged++;
    debug(`Generated: index.d.ts`);
  }
  
  timeEnd('vueGen');
  success(`Vue typings generation completed. ${filesChanged} files changed.`);
  info(`Output directory: ${normalizedTarget}`);
  info('You can now import these types in your Vue project.');
}

function generateTypeScriptIndex(blobs: IDLBlob[], targetPath: string): string {
  const references: string[] = ['/// <reference path="./global.d.ts" />'];
  const exports: string[] = [];
  
  // Group blobs by directory to maintain structure
  const filesByDir = new Map<string, IDLBlob[]>();
  
  blobs.forEach(blob => {
    const dir = blob.relativeDir || '.';
    if (!filesByDir.has(dir)) {
      filesByDir.set(dir, []);
    }
    filesByDir.get(dir)!.push(blob);
  });
  
  // Sort directories and files for consistent output
  const sortedDirs = Array.from(filesByDir.keys()).sort();
  
  sortedDirs.forEach(dir => {
    const dirBlobs = filesByDir.get(dir)!.sort((a, b) => a.filename.localeCompare(b.filename));
    
    dirBlobs.forEach(blob => {
      const relativePath = dir === '.' ? blob.filename : path.join(dir, blob.filename);
      references.push(`/// <reference path="./${relativePath}.d.ts" />`);
      exports.push(`export * from './${relativePath}';`);
    });
  });
  
  // Get package name from pubspec.yaml if available
  let packageName = 'WebF Package';
  let packageDescription = 'TypeScript Definitions';
  
  try {
    const pubspecPath = path.join(targetPath, 'pubspec.yaml');
    if (fs.existsSync(pubspecPath)) {
      const pubspecContent = fs.readFileSync(pubspecPath, 'utf-8');
      const pubspec = yaml.parse(pubspecContent);
      if (pubspec.name) {
        packageName = pubspec.name.replace(/_/g, ' ').replace(/\b\w/g, (l: string) => l.toUpperCase());
      }
      if (pubspec.description) {
        packageDescription = pubspec.description;
      }
    }
  } catch (err) {
    // Ignore errors, use defaults
  }
  
  return `${references.join('\n')}

/**
 * ${packageName} - TypeScript Definitions
 * 
 * ${packageDescription}
 */

${exports.join('\n')}
`;
}

// Clear all caches (useful for watch mode or between runs)
export function clearAllCaches() {
  fileContentCache.clear();
  generatedContentCache.clear();
  if (typeof clearCaches === 'function') {
    clearCaches(); // Clear analyzer caches
  }
}
