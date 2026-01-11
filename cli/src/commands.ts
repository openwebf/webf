import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import os from 'os';
import { dartGen, reactGen, vueGen } from './generator';
import { generateModuleArtifacts } from './module';
import { getPackageTypesFileFromDir, isPackageTypesReady, readJsonFile } from './peerDeps';
import { globSync } from 'glob';
import _ from 'lodash';
import inquirer from 'inquirer';
import yaml from 'yaml';
import { agentsInitCommand } from './agents';

interface GenerateOptions {
  flutterPackageSrc?: string;
  framework?: string;
  packageName?: string;
  publishToNpm?: boolean;
  npmRegistry?: string;
  exclude?: string[];
  dartOnly?: boolean;
}

interface FlutterPackageMetadata {
  name: string;
  version: string;
  description: string;
}

/**
 * Sanitize a package name to comply with npm naming rules
 * NPM package name rules:
 * - Must be lowercase
 * - Must be one word, no spaces
 * - Can contain hyphens and underscores
 * - Must start with a letter or number (or @ for scoped packages)
 * - Cannot contain special characters except @ for scoped packages
 * - Must be less than 214 characters
 * - Cannot start with . or _
 * - Cannot contain leading or trailing spaces
 * - Cannot contain any non-URL-safe characters
 */
function sanitizePackageName(name: string): string {
  // Remove any leading/trailing whitespace
  let sanitized = name.trim();

  // Check if it's a scoped package
  const isScoped = sanitized.startsWith('@');
  let scope = '';
  let packageName = sanitized;

  if (isScoped) {
    const parts = sanitized.split('/');
    if (parts.length >= 2) {
      scope = parts[0];
      packageName = parts.slice(1).join('/');
    } else {
      // Invalid scoped package, treat as regular
      packageName = sanitized.substring(1);
    }
  }

  // Sanitize scope if present
  if (scope) {
    scope = scope.toLowerCase();
    // Remove invalid characters from scope (keep only @ and alphanumeric/hyphen)
    scope = scope.replace(/[^@a-z0-9-]/g, '');
    if (scope === '@') {
      scope = '@pkg'; // Default scope if only @ remains
    }
  }

  // Sanitize package name part
  packageName = packageName.toLowerCase();
  packageName = packageName.replace(/\s+/g, '-');
  packageName = packageName.replace(/[^a-z0-9\-_.]/g, '');
  packageName = packageName.replace(/^[._]+/, '');
  packageName = packageName.replace(/[._]+$/, '');
  packageName = packageName.replace(/[-_.]{2,}/g, '-');
  packageName = packageName.replace(/^-+/, '').replace(/-+$/, '');

  // Ensure package name is not empty
  if (!packageName) {
    packageName = 'package';
  }

  // Ensure it starts with a letter or number
  if (!/^[a-z0-9]/.test(packageName)) {
    packageName = 'pkg-' + packageName;
  }

  // Combine scope and package name
  let result = scope ? `${scope}/${packageName}` : packageName;

  // Truncate to 214 characters (npm limit)
  if (result.length > 214) {
    if (scope) {
      // Try to preserve scope
      const maxPackageLength = 214 - scope.length - 1; // -1 for the /
      packageName = packageName.substring(0, maxPackageLength);
      packageName = packageName.replace(/[._-]+$/, '');
      result = `${scope}/${packageName}`;
    } else {
      result = result.substring(0, 214);
      result = result.replace(/[._-]+$/, '');
    }
  }

  return result;
}

/**
 * Validate if a package name follows npm naming rules
 */
function isValidNpmPackageName(name: string): boolean {
  // Check basic rules
  if (!name || name.length === 0 || name.length > 214) return false;
  if (name.trim() !== name) return false;

  // Check if it's a scoped package
  if (name.startsWith('@')) {
    const parts = name.split('/');
    if (parts.length !== 2) return false; // Scoped packages must have exactly one /

    const scope = parts[0];
    const packageName = parts[1];

    // Validate scope
    if (!/^@[a-z0-9][a-z0-9-]*$/.test(scope)) return false;

    // Validate package name part
    return isValidNpmPackageName(packageName);
  }

  // For non-scoped packages
  if (name !== name.toLowerCase()) return false;
  if (name.startsWith('.') || name.startsWith('_')) return false;

  // Check for valid characters (letters, numbers, hyphens, underscores, dots)
  if (!/^[a-z0-9][a-z0-9\-_.]*$/.test(name)) return false;

  // Check for URL-safe characters
  try {
    if (encodeURIComponent(name) !== name) return false;
  } catch {
    return false;
  }

  return true;
}

const platform = process.platform;
const NPM = platform == 'win32' ? 'npm.cmd' : 'npm';

const gloabalDts = fs.readFileSync(
  path.resolve(__dirname, '../global.d.ts'),
  'utf-8'
);

const tsConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/tsconfig.json.tpl'),
  'utf-8'
);

const gitignore = fs.readFileSync(
  path.resolve(__dirname, '../templates/gitignore.tpl'),
  'utf-8'
);

const modulePackageJson = fs.readFileSync(
  path.resolve(__dirname, '../templates/module.package.json.tpl'),
  'utf-8'
);

const moduleTsConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/module.tsconfig.json.tpl'),
  'utf-8'
);

const moduleTsDownConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/module.tsdown.config.ts.tpl'),
  'utf-8'
);
const reactPackageJson = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.package.json.tpl'),
  'utf-8'
);

const reactTsConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.tsconfig.json.tpl'),
  'utf-8'
);

const reactTsDownConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.tsdown.config.ts.tpl'),
  'utf-8'
);

const reactIndexTpl = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.index.ts.tpl'),
  'utf-8'
);

const vuePackageJson = fs.readFileSync(
  path.resolve(__dirname, '../templates/vue.package.json.tpl'),
  'utf-8'
);

const vueTsConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/vue.tsconfig.json.tpl'),
  'utf-8'
);

function readFlutterPackageMetadata(packagePath: string): FlutterPackageMetadata | null {
  try {
    const pubspecPath = path.join(packagePath, 'pubspec.yaml');
    if (!fs.existsSync(pubspecPath)) {
      console.warn(`Warning: pubspec.yaml not found at ${pubspecPath}. Using default metadata.`);
      return null;
    }

    const pubspecContent = fs.readFileSync(pubspecPath, 'utf-8');
    const pubspec = yaml.parse(pubspecContent);

    // Validate required fields
    if (!pubspec.name) {
      console.warn(`Warning: Flutter package name not found in ${pubspecPath}. Using default name.`);
    }

    return {
      name: pubspec.name || '',
      version: pubspec.version || '0.0.1',
      description: pubspec.description || ''
    };
  } catch (error) {
    console.warn(`Warning: Could not read Flutter package metadata from ${packagePath}:`, error);
    console.warn('Using default metadata. Ensure pubspec.yaml exists and is valid YAML.');
    return null;
  }
}

function copyReadmeToPackageRoot(params: {
  sourceRoot: string;
  targetRoot: string;
}): { copied: boolean; sourcePath?: string; targetPath: string } {
  const { sourceRoot, targetRoot } = params;
  const targetPath = path.join(targetRoot, 'README.md');

  if (fs.existsSync(targetPath)) {
    return { copied: false, targetPath };
  }

  const candidateNames = ['README.md', 'Readme.md', 'readme.md'];
  let sourcePath: string | null = null;
  for (const candidate of candidateNames) {
    const abs = path.join(sourceRoot, candidate);
    if (fs.existsSync(abs)) {
      sourcePath = abs;
      break;
    }
  }

  if (!sourcePath) {
    return { copied: false, targetPath };
  }

  try {
    const content = fs.readFileSync(sourcePath, 'utf-8');
    writeFileIfChanged(targetPath, content);
    return { copied: true, sourcePath, targetPath };
  } catch {
    return { copied: false, targetPath };
  }
}

// Copy markdown docs that match .d.ts basenames from source to the built dist folder,
// and generate an aggregated README.md in the dist directory.
async function copyMarkdownDocsToDist(params: {
  sourceRoot: string;
  distRoot: string;
  exclude?: string[];
}): Promise<{ copied: number; skipped: number }> {
  const { sourceRoot, distRoot, exclude } = params;

  // Ensure dist exists
  if (!fs.existsSync(distRoot)) {
    return { copied: 0, skipped: 0 };
  }

  // Default ignore patterns similar to generator
  const defaultIgnore = ['**/node_modules/**', '**/dist/**', '**/build/**', '**/example/**'];
  const ignore = exclude && exclude.length ? [...defaultIgnore, ...exclude] : defaultIgnore;

  // Find all .d.ts files and check for sibling .md files
  const dtsFiles = globSync('**/*.d.ts', { cwd: sourceRoot, ignore });
  let copied = 0;
  let skipped = 0;
  const readmeSections: { title: string; relPath: string; content: string }[] = [];

  for (const relDts of dtsFiles) {
    if (path.basename(relDts) === 'global.d.ts') {
      continue;
    }

    const relMd = relDts.replace(/\.d\.ts$/i, '.md');
    const absMd = path.join(sourceRoot, relMd);
    if (!fs.existsSync(absMd)) {
      skipped++;
      continue;
    }

    let content = '';
    try {
      content = fs.readFileSync(absMd, 'utf-8');
    } catch {
      // If we cannot read the file, still attempt to copy it and skip README aggregation for this entry.
    }

    // Copy into dist preserving relative path
    const destPath = path.join(distRoot, relMd);
    const destDir = path.dirname(destPath);
    if (!fs.existsSync(destDir)) {
      fs.mkdirSync(destDir, { recursive: true });
    }
    fs.copyFileSync(absMd, destPath);
    copied++;

    if (content) {
      const base = path.basename(relMd, '.md');
      const title = base
        .split(/[-_]+/)
        .filter(Boolean)
        .map(part => part.charAt(0).toUpperCase() + part.slice(1))
        .join(' ');
      readmeSections.push({
        title: title || base,
        relPath: relMd,
        content
      });
    }
  }

  // Generate an aggregated README.md inside distRoot so consumers can see component docs easily.
  if (readmeSections.length > 0) {
    const readmePath = path.join(distRoot, 'README.md');
    let existing = '';
    if (fs.existsSync(readmePath)) {
      try {
        existing = fs.readFileSync(readmePath, 'utf-8');
      } catch {
        existing = '';
      }
    }

    const headerLines: string[] = [
      '# WebF Component Documentation',
      '',
      '> This README is generated from markdown docs co-located with TypeScript definitions in the Flutter package.',
      ''
    ];

    const sectionBlocks = readmeSections.map(section => {
      const lines: string[] = [];
      lines.push(`## ${section.title}`);
      lines.push('');
      lines.push(`_Source: \`./${section.relPath}\`_`);
      lines.push('');
      lines.push(section.content.trim());
      lines.push('');
      return lines.join('\n');
    }).join('\n');

    let finalContent: string;
    if (existing && existing.trim().length > 0) {
      finalContent = `${existing.trim()}\n\n---\n\n${headerLines.join('\n')}${sectionBlocks}\n`;
    } else {
      finalContent = `${headerLines.join('\n')}${sectionBlocks}\n`;
    }

    try {
      fs.writeFileSync(readmePath, finalContent, 'utf-8');
    } catch {
      // If README generation fails, do not affect overall codegen.
    }
  }

  return { copied, skipped };
}

function validateTypeScriptEnvironment(projectPath: string): { isValid: boolean; errors: string[] } {
  const errors: string[] = [];

  // Check for TypeScript configuration
  const tsConfigPath = path.join(projectPath, 'tsconfig.json');
  if (!fs.existsSync(tsConfigPath)) {
    errors.push('Missing tsconfig.json - TypeScript configuration is required for type definitions');
  }

  // Check for .d.ts files - this is critical
  const libPath = path.join(projectPath, 'lib');
  let hasDtsFiles = false;

  if (fs.existsSync(libPath)) {
    // Check in lib directory
    hasDtsFiles = fs.readdirSync(libPath).some(file =>
      file.endsWith('.d.ts') ||
      (fs.statSync(path.join(libPath, file)).isDirectory() &&
       fs.readdirSync(path.join(libPath, file)).some(f => f.endsWith('.d.ts')))
    );
  }

  // Also check in root directory
  if (!hasDtsFiles) {
    hasDtsFiles = fs.readdirSync(projectPath).some(file =>
      file.endsWith('.d.ts') ||
      (fs.statSync(path.join(projectPath, file)).isDirectory() &&
       file !== 'node_modules' &&
       fs.existsSync(path.join(projectPath, file, 'index.d.ts')))
    );
  }

  if (!hasDtsFiles) {
    errors.push('No TypeScript definition files (.d.ts) found in the project - Please create .d.ts files for your components');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

function createCommand(target: string, options: { framework: string; packageName: string; metadata?: FlutterPackageMetadata }): void {
  const { framework, metadata } = options;
  // Ensure package name is always valid
  const packageName = isValidNpmPackageName(options.packageName)
    ? options.packageName
    : sanitizePackageName(options.packageName);

  if (!fs.existsSync(target)) {
    fs.mkdirSync(target, { recursive: true });
  }

  if (framework === 'react') {
    const packageJsonPath = path.join(target, 'package.json');
    const packageJsonContent = _.template(reactPackageJson)({
      packageName,
      version: metadata?.version || '0.0.1',
      description: metadata?.description || ''
    });
    writeFileIfChanged(packageJsonPath, packageJsonContent);

    const tsConfigPath = path.join(target, 'tsconfig.json');
    const tsConfigContent = _.template(reactTsConfig)({});
    writeFileIfChanged(tsConfigPath, tsConfigContent);

    const tsdownConfigPath = path.join(target, 'tsdown.config.ts');
    const tsdownConfigContent = _.template(reactTsDownConfig)({});
    writeFileIfChanged(tsdownConfigPath, tsdownConfigContent);

    const gitignorePath = path.join(target, '.gitignore');
    const gitignoreContent = _.template(gitignore)({});
    writeFileIfChanged(gitignorePath, gitignoreContent);

    const srcDir = path.join(target, 'src');
    if (!fs.existsSync(srcDir)) {
      fs.mkdirSync(srcDir, { recursive: true });
    }

    const indexFilePath = path.join(srcDir, 'index.ts');
    if (!fs.existsSync(indexFilePath)) {
      const indexContent = _.template(reactIndexTpl)({
        components: [],
      });
      writeFileIfChanged(indexFilePath, indexContent);
    } else {
      // Do not overwrite existing index.ts created by the user
      // Leave merge to the codegen step which appends exports safely
    }

    // Ensure devDependencies are installed even if the user's shell has NODE_ENV=production.
    spawnSync(NPM, ['install', '--production=false'], {
      cwd: target,
      stdio: 'inherit'
    });

  } else if (framework === 'vue') {
    const packageJsonPath = path.join(target, 'package.json');
    const packageJsonContent = _.template(vuePackageJson)({
      packageName,
      version: metadata?.version || '0.0.1',
      description: metadata?.description || ''
    });
    writeFileIfChanged(packageJsonPath, packageJsonContent);

    const tsConfigPath = path.join(target, 'tsconfig.json');
    const tsConfigContent = _.template(vueTsConfig)({});
    writeFileIfChanged(tsConfigPath, tsConfigContent);

    const gitignorePath = path.join(target, '.gitignore');
    const gitignoreContent = _.template(gitignore)({});
    writeFileIfChanged(gitignorePath, gitignoreContent);

    // Ensure devDependencies are installed even if the user's shell has NODE_ENV=production.
    spawnSync(NPM, ['install', '--production=false'], {
      cwd: target,
      stdio: 'inherit'
    });
  }

  console.log(`WebF ${framework} package created at: ${target}`);
}

function createModuleProject(target: string, options: { packageName: string; metadata?: FlutterPackageMetadata; skipGitignore?: boolean }): void {
  const { metadata, skipGitignore } = options;
  const packageName = isValidNpmPackageName(options.packageName)
    ? options.packageName
    : sanitizePackageName(options.packageName);

  if (!fs.existsSync(target)) {
    fs.mkdirSync(target, { recursive: true });
  }

  const packageJsonPath = path.join(target, 'package.json');
  const packageJsonContent = _.template(modulePackageJson)({
    packageName,
    version: metadata?.version || '0.0.1',
    description: metadata?.description || '',
  });
  writeFileIfChanged(packageJsonPath, packageJsonContent);

  const tsConfigPath = path.join(target, 'tsconfig.json');
  const tsConfigContent = _.template(moduleTsConfig)({});
  writeFileIfChanged(tsConfigPath, tsConfigContent);

  const tsdownConfigPath = path.join(target, 'tsdown.config.ts');
  const tsdownConfigContent = _.template(moduleTsDownConfig)({});
  writeFileIfChanged(tsdownConfigPath, tsdownConfigContent);

  if (!skipGitignore) {
    const gitignorePath = path.join(target, '.gitignore');
    const gitignoreContent = _.template(gitignore)({});
    writeFileIfChanged(gitignorePath, gitignoreContent);
  }

  const srcDir = path.join(target, 'src');
  if (!fs.existsSync(srcDir)) {
    fs.mkdirSync(srcDir, { recursive: true });
  }

  console.log(`WebF module package scaffold created at: ${target}`);
}

async function generateCommand(distPath: string, options: GenerateOptions): Promise<void> {
  // If distPath is not provided or is '.', create a temporary directory
  let resolvedDistPath: string;
  let isTempDir = false;
  const isDartOnly = options.dartOnly;

  if (!distPath || distPath === '.') {
    if (isDartOnly) {
      // In Dart-only mode we don't need a temporary Node project directory
      resolvedDistPath = path.resolve(distPath || '.');
    } else {
      // Create a temporary directory for the generated package
      const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'webf-typings-'));
      resolvedDistPath = tempDir;
      isTempDir = true;
      console.log(`\nUsing temporary directory: ${tempDir}`);
    }
  } else {
    resolvedDistPath = path.resolve(distPath);
  }

  // First, check if we're in a Flutter package directory when flutter-package-src is not provided
  if (!options.flutterPackageSrc) {
    // Check if current directory or parent directories contain pubspec.yaml
    let currentDir = process.cwd();
    let foundPubspec = false;
    let pubspecDir = '';

    // Search up to 3 levels up for pubspec.yaml
    for (let i = 0; i < 3; i++) {
      const pubspecPath = path.join(currentDir, 'pubspec.yaml');
      if (fs.existsSync(pubspecPath)) {
        foundPubspec = true;
        pubspecDir = currentDir;
        break;
      }
      const parentDir = path.dirname(currentDir);
      if (parentDir === currentDir) break; // Reached root
      currentDir = parentDir;
    }

    if (foundPubspec) {
      // Use the directory containing pubspec.yaml as the flutter package source
      options.flutterPackageSrc = pubspecDir;
      console.log(`\nDetected Flutter package at: ${pubspecDir}`);
    }
  }

  let framework = options.framework;
  let packageName = options.packageName;
  let isExistingProject = false;

  if (!isDartOnly) {
    // Check if the directory exists and has required files
    const packageJsonPath = path.join(resolvedDistPath, 'package.json');
    const globalDtsPath = path.join(resolvedDistPath, 'global.d.ts');
    const tsConfigPath = path.join(resolvedDistPath, 'tsconfig.json');

    const hasPackageJson = fs.existsSync(packageJsonPath);
    const hasGlobalDts = fs.existsSync(globalDtsPath);
    const hasTsConfig = fs.existsSync(tsConfigPath);

    // Determine if we need to create a new project
    const needsProjectCreation = !hasPackageJson || !hasGlobalDts || !hasTsConfig;

    // Track if this is an existing project (has all required files)
    isExistingProject = hasPackageJson && hasGlobalDts && hasTsConfig;

    // Validate and sanitize package name if provided
    if (packageName && !isValidNpmPackageName(packageName)) {
      console.warn(`Warning: Package name "${packageName}" is not valid for npm.`);
      const sanitized = sanitizePackageName(packageName);
      console.log(`Using sanitized name: "${sanitized}"`);
      packageName = sanitized;
    }

    if (needsProjectCreation) {
      // If project needs creation but options are missing, prompt for them
      if (!framework) {
        const frameworkAnswer = await inquirer.prompt([{
          type: 'list',
          name: 'framework',
          message: 'Which framework would you like to use?',
          choices: ['react', 'vue']
        }]);
        framework = frameworkAnswer.framework;
      }

      // Try to read Flutter package metadata if flutterPackageSrc is provided
      let metadata: FlutterPackageMetadata | null = null;
      if (options.flutterPackageSrc) {
        metadata = readFlutterPackageMetadata(options.flutterPackageSrc);
      }

      if (!packageName) {
        // Use Flutter package name as default if available, sanitized for npm
        const rawDefaultName = metadata?.name || path.basename(resolvedDistPath);
        const defaultPackageName = sanitizePackageName(rawDefaultName);

        const packageNameAnswer = await inquirer.prompt([{
          type: 'input',
          name: 'packageName',
          message: 'What is your package name?',
          default: defaultPackageName,
          validate: (input: string) => {
            if (!input || input.trim() === '') {
              return 'Package name is required';
            }

            // Check if it's valid as-is
            if (isValidNpmPackageName(input)) {
              return true;
            }

            // If not valid, show what it would be sanitized to
            const sanitized = sanitizePackageName(input);
            return `Invalid npm package name. Would be sanitized to: "${sanitized}". Please enter a valid name.`;
          }
        }]);
        packageName = packageNameAnswer.packageName;
      }

      console.log(`\nCreating new ${framework} project in ${resolvedDistPath}...`);
      createCommand(resolvedDistPath, {
        framework: framework!,
        packageName: packageName!,
        metadata: metadata || undefined
      });
    } else {
      // Validate existing project structure
      if (hasPackageJson) {
        try {
          const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));

          // Detect framework from existing package.json
          if (!framework) {
            if (packageJson.dependencies?.react || packageJson.devDependencies?.react) {
              framework = 'react';
            } else if (packageJson.dependencies?.vue || packageJson.devDependencies?.vue) {
              framework = 'vue';
            } else {
              // If can't detect, prompt for it
              const frameworkAnswer = await inquirer.prompt([{
                type: 'list',
                name: 'framework',
                message: 'Which framework are you using?',
                choices: ['react', 'vue']
              }]);
              framework = frameworkAnswer.framework;
            }
          }

          console.log(`\nDetected existing ${framework} project in ${resolvedDistPath}`);
        } catch (e) {
          console.error('Error reading package.json:', e);
          process.exit(1);
        }
      }
    }
  } else {
    // In Dart-only mode, framework/packageName are unused; ensure framework is not accidentally required later.
    framework = options.framework;
  }

  // Now proceed with code generation if flutter package source is provided
  if (!options.flutterPackageSrc) {
    console.log('\nProject is ready for code generation.');
    console.log('To generate code, run:');
    const displayPath = isTempDir ? '<output-dir>' : distPath;
    if (isDartOnly) {
      console.log(`  webf codegen ${displayPath} --flutter-package-src=<path> --dart-only`);
    } else {
      console.log(`  webf codegen ${displayPath} --flutter-package-src=<path> --framework=${framework}`);
    }
    if (isTempDir) {
      // Clean up temporary directory if we're not using it
      fs.rmSync(resolvedDistPath, { recursive: true, force: true });
    }
    return;
  }

  // Validate TypeScript environment in the Flutter package
  console.log(`\nValidating TypeScript environment in ${options.flutterPackageSrc}...`);
  const validation = validateTypeScriptEnvironment(options.flutterPackageSrc);

  if (!validation.isValid) {
    // Check specifically for missing tsconfig.json
    const tsConfigPath = path.join(options.flutterPackageSrc, 'tsconfig.json');
    if (!fs.existsSync(tsConfigPath)) {
      const createTsConfigAnswer = await inquirer.prompt([{
        type: 'confirm',
        name: 'createTsConfig',
        message: 'No tsconfig.json found. Would you like me to create one for you?',
        default: true
      }]);

      if (createTsConfigAnswer.createTsConfig) {
        // Create a default tsconfig.json
        const defaultTsConfig = {
          compilerOptions: {
            target: 'ES2020',
            module: 'commonjs',
            lib: ['ES2020'],
            declaration: true,
            strict: true,
            esModuleInterop: true,
            skipLibCheck: true,
            forceConsistentCasingInFileNames: true,
            resolveJsonModule: true,
            moduleResolution: 'node'
          },
          include: ['lib/**/*.d.ts', '**/*.d.ts'],
          exclude: ['node_modules', 'dist', 'build']
        };

        fs.writeFileSync(tsConfigPath, JSON.stringify(defaultTsConfig, null, 2), 'utf-8');
        console.log('✅ Created tsconfig.json');

        // Re-validate after creating tsconfig
        const newValidation = validateTypeScriptEnvironment(options.flutterPackageSrc);
        if (!newValidation.isValid) {
          console.error('\n⚠️  Additional setup required:');
          newValidation.errors.forEach(error => console.error(`   - ${error}`));
          console.error('\nPlease fix the above issues and run the command again.');
          process.exit(1);
        }
      } else {
        console.error('\n❌ TypeScript configuration is required for code generation.');
        console.error('Please create a tsconfig.json file manually and run the command again.');
        process.exit(1);
      }
    } else {
      // Show all validation errors
      console.error('\n❌ TypeScript environment validation failed:');
      validation.errors.forEach(error => console.error(`   - ${error}`));
      console.error('\nPlease fix the above issues before generating code.');
      process.exit(1);
    }
  }

  const baseCommand = 'webf codegen';
  const flutterPart = options.flutterPackageSrc ? ` --flutter-package-src=${options.flutterPackageSrc}` : '';
  const modePart = isDartOnly
    ? ' --dart-only'
    : (framework ? ` --framework=${framework}` : '');
  const command = `${baseCommand}${flutterPart}${modePart} <distPath>`;

  if (isDartOnly) {
    console.log(`\nGenerating Dart bindings from ${options.flutterPackageSrc}...`);

    await dartGen({
      source: options.flutterPackageSrc,
      target: options.flutterPackageSrc,
      command,
      exclude: options.exclude,
    });

    console.log('\nDart code generation completed successfully!');
    return;
  }

  // Auto-initialize typings in the output directory if needed
  ensureInitialized(resolvedDistPath);

  // Copy README.md from the source Flutter package into the npm package root (so `npm publish` includes it).
  if (options.flutterPackageSrc) {
    const { copied } = copyReadmeToPackageRoot({
      sourceRoot: options.flutterPackageSrc,
      targetRoot: resolvedDistPath,
    });
    if (copied) {
      console.log('📄 Copied README.md to package root');
    }
  }

  console.log(`\nGenerating ${framework} code from ${options.flutterPackageSrc}...`);

  await dartGen({
    source: options.flutterPackageSrc,
    target: options.flutterPackageSrc,
    command,
    exclude: options.exclude,
  });

  if (framework === 'react') {
    // Get the package name from package.json if it exists
    let reactPackageName: string | undefined;
    try {
      const packageJsonPath = path.join(resolvedDistPath, 'package.json');
      if (fs.existsSync(packageJsonPath)) {
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
        reactPackageName = packageJson.name;
      }
    } catch (e) {
      // Ignore errors
    }

    await reactGen({
      source: options.flutterPackageSrc,
      target: resolvedDistPath,
      command,
      exclude: options.exclude,
      // Prefer CLI-provided packageName (validated/sanitized above),
      // fallback to detected name from package.json
      packageName: packageName || reactPackageName,
    });
  } else if (framework === 'vue') {
    await vueGen({
      source: options.flutterPackageSrc,
      target: resolvedDistPath,
      command,
      exclude: options.exclude,
    });
  }

  console.log('\nCode generation completed successfully!');

  // Automatically build the generated package
  if (framework) {
    try {
      await buildPackage(resolvedDistPath);
      // After building React package, copy any matching .md docs next to built JS files
      if (framework === 'react' && options.flutterPackageSrc) {
        const distOut = path.join(resolvedDistPath, 'dist');
        const { copied } = await copyMarkdownDocsToDist({
          sourceRoot: options.flutterPackageSrc,
          distRoot: distOut,
          exclude: options.exclude,
        });
        if (copied > 0) {
          console.log(`📄 Copied ${copied} markdown docs to dist`);
        }
      }
    } catch (error) {
      console.error('\nWarning: Build failed:', error);
      // Don't exit here since generation was successful
    }
  }

  // Handle npm publishing if requested via command line option
  if (options.publishToNpm && framework) {
    try {
      await buildAndPublishPackage(resolvedDistPath, options.npmRegistry, isExistingProject);
    } catch (error) {
      console.error('\nError during npm publish:', error);
      process.exit(1);
    }
  } else if (framework && !options.publishToNpm) {
    // If not publishing via command line option, ask the user
    const publishAnswer = await inquirer.prompt([{
      type: 'confirm',
      name: 'publish',
      message: 'Would you like to publish this package to npm?',
      default: false
    }]);

    if (publishAnswer.publish) {
      // Ask for registry
      const registryAnswer = await inquirer.prompt([{
        type: 'input',
        name: 'registry',
        message: 'NPM registry URL (leave empty for default npm registry):',
        default: '',
        validate: (input: string) => {
          if (!input) return true; // Empty is valid (use default)
          try {
            new URL(input); // Validate URL format
            return true;
          } catch {
            return 'Please enter a valid URL';
          }
        }
      }]);

      try {
        await buildAndPublishPackage(
          resolvedDistPath,
          registryAnswer.registry || undefined,
          isExistingProject
        );
      } catch (error) {
        console.error('\nError during npm publish:', error);
        // Don't exit here since generation was successful
      }
    }
  }

  // If using a temporary directory, remind the user where the files are
  if (isTempDir) {
    console.log(`\n📁 Generated files are in: ${resolvedDistPath}`);
    console.log('💡 To use these files, copy them to your desired location or publish to npm.');
  }
}

async function generateModuleCommand(distPath: string, options: GenerateOptions): Promise<void> {
  let resolvedDistPath: string;
  let isTempDir = false;
  if (!distPath || distPath === '.') {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'webf-module-'));
    resolvedDistPath = tempDir;
    isTempDir = true;
    console.log(`\nUsing temporary directory for module package: ${tempDir}`);
  } else {
    resolvedDistPath = path.resolve(distPath);
  }

  // Detect Flutter package root if not provided
  if (!options.flutterPackageSrc) {
    let currentDir = process.cwd();
    let foundPubspec = false;
    let pubspecDir = '';

    for (let i = 0; i < 3; i++) {
      const pubspecPath = path.join(currentDir, 'pubspec.yaml');
      if (fs.existsSync(pubspecPath)) {
        foundPubspec = true;
        pubspecDir = currentDir;
        break;
      }
      const parentDir = path.dirname(currentDir);
      if (parentDir === currentDir) break;
      currentDir = parentDir;
    }

    if (!foundPubspec) {
      console.error('Could not find pubspec.yaml. Please provide --flutter-package-src.');
      process.exit(1);
    }

    options.flutterPackageSrc = pubspecDir;
    console.log(`Detected Flutter package at: ${pubspecDir}`);
  }

  const flutterPackageSrc = path.resolve(options.flutterPackageSrc);

  // Validate TS environment in the Flutter package
  console.log(`\nValidating TypeScript environment in ${flutterPackageSrc}...`);
  let validation = validateTypeScriptEnvironment(flutterPackageSrc);
  if (!validation.isValid) {
    const tsConfigPath = path.join(flutterPackageSrc, 'tsconfig.json');
    if (!fs.existsSync(tsConfigPath)) {
      const defaultTsConfig = {
        compilerOptions: {
          target: 'ES2020',
          module: 'commonjs',
          lib: ['ES2020'],
          declaration: true,
          strict: true,
          esModuleInterop: true,
          skipLibCheck: true,
          forceConsistentCasingInFileNames: true,
          resolveJsonModule: true,
          moduleResolution: 'node',
        },
        include: ['lib/**/*.d.ts', '**/*.d.ts'],
        exclude: ['node_modules', 'dist', 'build'],
      };

      fs.writeFileSync(tsConfigPath, JSON.stringify(defaultTsConfig, null, 2), 'utf-8');
      console.log('✅ Created tsconfig.json for module package');

      validation = validateTypeScriptEnvironment(flutterPackageSrc);
    }

    if (!validation.isValid) {
      console.error('\n❌ TypeScript environment validation failed:');
      validation.errors.forEach(err => console.error(`   - ${err}`));
      console.error('\nPlease fix the above issues before running `webf module-codegen` again.');
      process.exit(1);
    }
  }

  // Read Flutter metadata for package.json
  const metadata = readFlutterPackageMetadata(flutterPackageSrc);

  // Determine package name
  let packageName = options.packageName;
  if (packageName && !isValidNpmPackageName(packageName)) {
    console.warn(`Warning: Package name "${packageName}" is not valid for npm.`);
    const sanitized = sanitizePackageName(packageName);
    console.log(`Using sanitized name: "${sanitized}"`);
    packageName = sanitized;
  }

  if (!packageName) {
    const rawDefaultName = metadata?.name
      ? `@openwebf/${metadata.name.replace(/^webf_/, 'webf-')}`
      : '@openwebf/webf-module';

    const defaultPackageName = isValidNpmPackageName(rawDefaultName)
      ? rawDefaultName
      : sanitizePackageName(rawDefaultName);

    const packageNameAnswer = await inquirer.prompt([{
      type: 'input',
      name: 'packageName',
      message: 'What is your npm package name for this module?',
      default: defaultPackageName,
      validate: (input: string) => {
        if (!input || input.trim() === '') {
          return 'Package name is required';
        }

        if (isValidNpmPackageName(input)) {
          return true;
        }

        const sanitized = sanitizePackageName(input);
        return `Invalid npm package name. Would be sanitized to: "${sanitized}". Please enter a valid name.`;
      }
    }]);
    packageName = packageNameAnswer.packageName;
  }

  // Prevent npm scaffolding (package.json, tsdown.config.ts, etc.) from being written into
  // the Flutter package itself. Force users to choose a separate output directory.
  if (resolvedDistPath === flutterPackageSrc) {
    console.error('\n❌ Output directory must not be the Flutter package root.');
    console.error('Please choose a separate directory for the generated npm package, for example:');
    console.error('  webf module-codegen ../packages/webf-share --flutter-package-src=../webf_modules/share');
    process.exit(1);
  }

  // Scaffold npm project for the module
  if (!packageName) {
    throw new Error('Package name could not be resolved for module package.');
  }
  createModuleProject(resolvedDistPath, {
    packageName,
    metadata: metadata || undefined,
  });

  // Locate module interface file (*.module.d.ts)
  const defaultIgnore = ['**/node_modules/**', '**/dist/**', '**/build/**', '**/example/**'];
  const ignore = options.exclude && options.exclude.length
    ? [...defaultIgnore, ...options.exclude]
    : defaultIgnore;

  const candidates = globSync('**/*.module.d.ts', {
    cwd: flutterPackageSrc,
    ignore,
  });

  if (candidates.length === 0) {
    console.error(
      `\n❌ No module interface files (*.module.d.ts) found under ${flutterPackageSrc}.`
    );
    console.error('Please add a TypeScript interface file describing your module API.');
    process.exit(1);
  }

  const moduleInterfaceRel = candidates[0];
  const moduleInterfacePath = path.join(flutterPackageSrc, moduleInterfaceRel);

  const command = `webf module-codegen --flutter-package-src=${flutterPackageSrc} <distPath>`;

  console.log(`\nGenerating module npm package and Dart bindings from ${moduleInterfaceRel}...`);

  generateModuleArtifacts({
    moduleInterfacePath,
    npmTargetDir: resolvedDistPath,
    flutterPackageDir: flutterPackageSrc,
    command,
  });

  // Copy README.md from the source Flutter package into the npm package root
  const { copied } = copyReadmeToPackageRoot({
    sourceRoot: flutterPackageSrc,
    targetRoot: resolvedDistPath,
  });
  if (copied) {
    console.log('📄 Copied README.md to package root');
  }

  console.log('\nModule code generation completed successfully!');

  try {
    await buildPackage(resolvedDistPath);
  } catch (error) {
    console.error('\nWarning: Build failed:', error);
  }

  if (options.publishToNpm) {
    try {
      await buildAndPublishPackage(resolvedDistPath, options.npmRegistry, false);
    } catch (error) {
      console.error('\nError during npm publish:', error);
      process.exit(1);
    }
  } else {
    const publishAnswer = await inquirer.prompt([{
      type: 'confirm',
      name: 'publish',
      message: 'Would you like to publish this module package to npm?',
      default: false
    }]);

    if (publishAnswer.publish) {
      const registryAnswer = await inquirer.prompt([{
        type: 'input',
        name: 'registry',
        message: 'NPM registry URL (leave empty for default npm registry):',
        default: '',
        validate: (input: string) => {
          if (!input) return true;
          try {
            new URL(input);
            return true;
          } catch {
            return 'Please enter a valid URL';
          }
        }
      }]);

      try {
        await buildAndPublishPackage(
          resolvedDistPath,
          registryAnswer.registry || undefined,
          false
        );
      } catch (error) {
        console.error('\nError during npm publish:', error);
        // Don't exit here since generation was successful
      }
    }
  }

  if (isTempDir) {
    console.log(`\n📁 Generated module npm package is in: ${resolvedDistPath}`);
    console.log('💡 To use it, copy this directory to your packages folder or publish it directly.');
  }
}

function writeFileIfChanged(filePath: string, content: string) {
  if (fs.existsSync(filePath)) {
    const oldContent = fs.readFileSync(filePath, 'utf-8')
    if (oldContent === content) {
      return;
    }
  }

  fs.writeFileSync(filePath, content, 'utf-8');
}

function ensureInitialized(targetPath: string): void {
  const globalDtsPath = path.join(targetPath, 'global.d.ts');
  const tsConfigPath = path.join(targetPath, 'tsconfig.json');

  // Check if initialization files already exist
  const needsInit = !fs.existsSync(globalDtsPath) || !fs.existsSync(tsConfigPath);

  if (needsInit) {
    console.log('Initializing WebF typings...');
    fs.mkdirSync(targetPath, { recursive: true });

    if (!fs.existsSync(globalDtsPath)) {
      fs.writeFileSync(globalDtsPath, gloabalDts, 'utf-8');
      console.log('Created global.d.ts');
    }

    if (!fs.existsSync(tsConfigPath)) {
      fs.writeFileSync(tsConfigPath, tsConfig, 'utf-8');
      console.log('Created tsconfig.json');
    }
  }
}

async function buildPackage(packagePath: string): Promise<void> {
  const packageJsonPath = path.join(packagePath, 'package.json');

  if (!fs.existsSync(packageJsonPath)) {
    // Skip the error in test environment to avoid console warnings
    if (process.env.NODE_ENV === 'test' || process.env.JEST_WORKER_ID !== undefined) {
      return;
    }
    throw new Error(`No package.json found in ${packagePath}`);
  }

  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
  const packageName = packageJson.name;
  const packageVersion = packageJson.version;

  function getInstalledPackageJsonPath(pkgName: string): string {
    const parts = pkgName.split('/');
    return path.join(packagePath, 'node_modules', ...parts, 'package.json');
  }

  function getInstalledPackageDir(pkgName: string): string {
    const parts = pkgName.split('/');
    return path.join(packagePath, 'node_modules', ...parts);
  }

  function findUp(startDir: string, relativePathToFind: string): string | null {
    let dir = path.resolve(startDir);
    while (true) {
      const candidate = path.join(dir, relativePathToFind);
      if (fs.existsSync(candidate)) return candidate;
      const parent = path.dirname(dir);
      if (parent === dir) return null;
      dir = parent;
    }
  }

  function ensurePeerDependencyAvailableForBuild(peerName: string): void {
    const installedPkgJson = getInstalledPackageJsonPath(peerName);
    if (fs.existsSync(installedPkgJson)) return;

    const peerRange = packageJson.peerDependencies?.[peerName];
    const localMap: Record<string, string> = {
      '@openwebf/react-core-ui': path.join('packages', 'react-core-ui'),
      '@openwebf/vue-core-ui': path.join('packages', 'vue-core-ui'),
    };

    let installSpec: string | null = null;

    const localRel = localMap[peerName];
    if (localRel) {
      const localPath = findUp(process.cwd(), localRel);
      if (localPath) {
        if (!isPackageTypesReady(localPath)) {
          const localPkgJsonPath = path.join(localPath, 'package.json');
          if (fs.existsSync(localPkgJsonPath)) {
            const localPkgJson = readJsonFile(localPkgJsonPath);
            if (localPkgJson.scripts?.build) {
              if (process.env.WEBF_CODEGEN_BUILD_LOCAL_PEERS !== '1') {
                console.warn(
                  `\n⚠️  Local ${peerName} found at ${localPath} but type declarations are missing; falling back to registry install.`
                );
              } else {
                console.log(
                  `\n🔧 Local ${peerName} found at ${localPath} but build artifacts are missing; building it for DTS...`
                );
                const buildLocalResult = spawnSync(NPM, ['run', 'build'], {
                  cwd: localPath,
                  stdio: 'inherit'
                });
                if (buildLocalResult.status === 0) {
                  if (isPackageTypesReady(localPath)) {
                    installSpec = localPath;
                  } else {
                    console.warn(
                      `\n⚠️  Built local ${peerName} but type declarations are still missing; falling back to registry install.`
                    );
                  }
                } else {
                  console.warn(`\n⚠️  Failed to build local ${peerName}; falling back to registry install.`);
                }
              }
            }
          }
        } else {
          installSpec = localPath;
        }
      }
    }

    if (!installSpec) {
      installSpec = peerRange ? `${peerName}@${peerRange}` : peerName;
    }

    console.log(`\n📦 Installing peer dependency for build: ${peerName}...`);
    const installResult = spawnSync(NPM, ['install', '--no-save', installSpec], {
      cwd: packagePath,
      stdio: 'inherit'
    });
    if (installResult.status !== 0) {
      throw new Error(`Failed to install peer dependency for build: ${peerName}`);
    }

    const installedTypesFile = getPackageTypesFileFromDir(getInstalledPackageDir(peerName));
    if (installedTypesFile && !fs.existsSync(installedTypesFile)) {
      throw new Error(
        `Peer dependency ${peerName} was installed but type declarations were not found at ${installedTypesFile}`
      );
    }
  }

  // Check if node_modules exists
  const nodeModulesPath = path.join(packagePath, 'node_modules');
  if (!fs.existsSync(nodeModulesPath)) {
    console.log(`\n📦 Installing dependencies for ${packageName}...`);

    // Check if yarn.lock exists to determine package manager
    const yarnLockPath = path.join(packagePath, 'yarn.lock');
    const useYarn = fs.existsSync(yarnLockPath);

    const installCommand = useYarn ? 'yarn' : NPM;
    const installArgs = useYarn ? [] : ['install'];

    const installResult = spawnSync(installCommand, installArgs, {
      cwd: packagePath,
      stdio: 'inherit'
    });

    if (installResult.status !== 0) {
      throw new Error('Failed to install dependencies');
    }
    console.log('✅ Dependencies installed successfully!');
  }

  // Check if package has a build script
  if (packageJson.scripts?.build) {
    // DTS build needs peer deps present locally to resolve types (even though they are not bundled).
    if (packageJson.peerDependencies?.['@openwebf/react-core-ui']) {
      ensurePeerDependencyAvailableForBuild('@openwebf/react-core-ui');
    }
    if (packageJson.peerDependencies?.['@openwebf/vue-core-ui']) {
      ensurePeerDependencyAvailableForBuild('@openwebf/vue-core-ui');
    }

    console.log(`\nBuilding ${packageName}@${packageVersion}...`);
    const buildResult = spawnSync(NPM, ['run', 'build'], {
      cwd: packagePath,
      stdio: 'inherit'
    });

    if (buildResult.status !== 0) {
      throw new Error('Build failed');
    }
    console.log('✅ Build completed successfully!');
  } else {
    console.log(`\nNo build script found for ${packageName}@${packageVersion}`);
  }
}

async function buildAndPublishPackage(packagePath: string, registry?: string, isExistingProject: boolean = false): Promise<void> {
  const packageJsonPath = path.join(packagePath, 'package.json');

  if (!fs.existsSync(packageJsonPath)) {
    throw new Error(`No package.json found in ${packagePath}`);
  }

  let packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
  const packageName = packageJson.name;
  let packageVersion = packageJson.version;

  // First, ensure dependencies are installed and build the package
  await buildPackage(packagePath);

  // If this is an existing project, increment the patch version before publishing
  if (isExistingProject) {
    console.log(`\nIncrementing version for existing project...`);
    const versionResult = spawnSync(NPM, ['version', 'patch', '--no-git-tag-version'], {
      cwd: packagePath,
      encoding: 'utf-8',
      stdio: 'pipe'
    });

    if (versionResult.status !== 0) {
      console.error('Failed to increment version:', versionResult.stderr);
      throw new Error('Failed to increment version');
    }

    // Re-read package.json to get the new version
    packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
    packageVersion = packageJson.version;
    console.log(`Version updated to ${packageVersion}`);
  }

  // Set registry if provided
  if (registry) {
    console.log(`\nUsing npm registry: ${registry}`);
    const setRegistryResult = spawnSync(NPM, ['config', 'set', 'registry', registry], {
      cwd: packagePath,
      stdio: 'inherit'
    });

    if (setRegistryResult.status !== 0) {
      throw new Error('Failed to set npm registry');
    }
  }

  // Check if user is logged in to npm
  const whoamiResult = spawnSync(NPM, ['whoami'], {
    cwd: packagePath,
    encoding: 'utf-8'
  });

  if (whoamiResult.status !== 0) {
    console.error('\nError: You must be logged in to npm to publish packages.');
    console.error('Please run "npm login" first.');
    throw new Error('Not logged in to npm');
  }

  console.log(`\nPublishing ${packageName}@${packageVersion} to npm...`);

  // Publish the package
  const publishResult = spawnSync(NPM, ['publish'], {
    cwd: packagePath,
    stdio: 'inherit'
  });

  if (publishResult.status !== 0) {
    throw new Error('Publish failed');
  }

  console.log(`\n✅ Successfully published ${packageName}@${packageVersion}`);

  // Reset registry to default if it was changed
  if (registry) {
    spawnSync(NPM, ['config', 'delete', 'registry'], {
      cwd: packagePath
    });
  }
}

export { generateCommand, generateModuleCommand, agentsInitCommand };
