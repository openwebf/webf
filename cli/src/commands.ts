import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import os from 'os';
import { dartGen, reactGen, vueGen } from './generator';
import _ from 'lodash';
import inquirer from 'inquirer';
import yaml from 'yaml';

interface GenerateOptions {
  flutterPackageSrc?: string;
  framework?: string;
  packageName?: string;
  publishToNpm?: boolean;
  npmRegistry?: string;
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

const reactPackageJson = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.package.json.tpl'),
  'utf-8'
);

const reactTsConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.tsconfig.json.tpl'),
  'utf-8'
);

const reactTsUpConfig = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.tsup.config.ts.tpl'),
  'utf-8'
);

const createComponentTpl = fs.readFileSync(
  path.resolve(__dirname, '../templates/react.createComponent.tpl'),
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
      return null;
    }
    
    const pubspecContent = fs.readFileSync(pubspecPath, 'utf-8');
    const pubspec = yaml.parse(pubspecContent);
    
    return {
      name: pubspec.name || '',
      version: pubspec.version || '0.0.1',
      description: pubspec.description || ''
    };
  } catch (error) {
    console.warn('Warning: Could not read Flutter package metadata:', error);
    return null;
  }
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

    const tsupConfigPath = path.join(target, 'tsup.config.ts');
    const tsupConfigContent = _.template(reactTsUpConfig)({});
    writeFileIfChanged(tsupConfigPath, tsupConfigContent);

    const gitignorePath = path.join(target, '.gitignore');
    const gitignoreContent = _.template(gitignore)({});
    writeFileIfChanged(gitignorePath, gitignoreContent);

    const srcDir = path.join(target, 'src');
    if (!fs.existsSync(srcDir)) {
      fs.mkdirSync(srcDir, { recursive: true });
    }

    const indexFilePath = path.join(srcDir, 'index.ts');
    const indexContent = _.template(reactIndexTpl)({
      components: [],
    });
    writeFileIfChanged(indexFilePath, indexContent);

    const utilsDir = path.join(srcDir, 'utils');
    if (!fs.existsSync(utilsDir)) {
      fs.mkdirSync(utilsDir, { recursive: true });
    }

    const createComponentPath = path.join(utilsDir, 'createComponent.ts');
    const createComponentContent = _.template(createComponentTpl)({});
    writeFileIfChanged(createComponentPath, createComponentContent);

    spawnSync(NPM, ['install', '--omit=peer'], {
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

    spawnSync(NPM, ['install', '@openwebf/webf-enterprise-typings'], {
      cwd: target,
      stdio: 'inherit'
    });

    spawnSync(NPM, ['install', '@types/vue', '-D'], {
      cwd: target,
      stdio: 'inherit'
    });
  }

  console.log(`WebF ${framework} package created at: ${target}`);
}

async function generateCommand(distPath: string, options: GenerateOptions): Promise<void> {
  // If distPath is not provided or is '.', create a temporary directory
  let resolvedDistPath: string;
  let isTempDir = false;
  
  if (!distPath || distPath === '.') {
    // Create a temporary directory for the generated package
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'webf-typings-'));
    resolvedDistPath = tempDir;
    isTempDir = true;
    console.log(`\nUsing temporary directory: ${tempDir}`);
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
  
  // Check if the directory exists and has required files
  const packageJsonPath = path.join(resolvedDistPath, 'package.json');
  const globalDtsPath = path.join(resolvedDistPath, 'global.d.ts');
  const tsConfigPath = path.join(resolvedDistPath, 'tsconfig.json');
  
  const hasPackageJson = fs.existsSync(packageJsonPath);
  const hasGlobalDts = fs.existsSync(globalDtsPath);
  const hasTsConfig = fs.existsSync(tsConfigPath);
  
  // Determine if we need to create a new project
  const needsProjectCreation = !hasPackageJson || !hasGlobalDts || !hasTsConfig;
  
  let framework = options.framework;
  let packageName = options.packageName;
  
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
  
  // Now proceed with code generation if flutter package source is provided
  if (!options.flutterPackageSrc) {
    console.log('\nProject is ready for code generation.');
    console.log('To generate code, run:');
    const displayPath = isTempDir ? '<output-dir>' : distPath;
    console.log(`  webf codegen ${displayPath} --flutter-package-src=<path> --framework=${framework}`);
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
  
  const command = `webf codegen --flutter-package-src=${options.flutterPackageSrc} --framework=${framework} <distPath>`;
  
  // Auto-initialize typings in the output directory if needed
  ensureInitialized(resolvedDistPath);
  
  console.log(`\nGenerating ${framework} code from ${options.flutterPackageSrc}...`);
  
  await dartGen({
    source: options.flutterPackageSrc,
    target: options.flutterPackageSrc,
    command,
  });
  
  if (framework === 'react') {
    await reactGen({
      source: options.flutterPackageSrc,
      target: resolvedDistPath,
      command,
    });
  } else if (framework === 'vue') {
    await vueGen({
      source: options.flutterPackageSrc,
      target: resolvedDistPath,
      command,
    });
  }
  
  console.log('\nCode generation completed successfully!');
  
  // Automatically build the generated package
  if (framework) {
    try {
      await buildPackage(resolvedDistPath);
    } catch (error) {
      console.error('\nWarning: Build failed:', error);
      // Don't exit here since generation was successful
    }
  }
  
  // Handle npm publishing if requested via command line option
  if (options.publishToNpm && framework) {
    try {
      await buildAndPublishPackage(resolvedDistPath, options.npmRegistry);
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
          registryAnswer.registry || undefined
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
    throw new Error(`No package.json found in ${packagePath}`);
  }
  
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
  const packageName = packageJson.name;
  const packageVersion = packageJson.version;
  
  // Check if package has a build script
  if (packageJson.scripts?.build) {
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

async function buildAndPublishPackage(packagePath: string, registry?: string): Promise<void> {
  const packageJsonPath = path.join(packagePath, 'package.json');
  
  if (!fs.existsSync(packageJsonPath)) {
    throw new Error(`No package.json found in ${packagePath}`);
  }
  
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
  const packageName = packageJson.name;
  const packageVersion = packageJson.version;
  
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

export { generateCommand };
