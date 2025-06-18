import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
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

function createCommand(target: string, options: { framework: string; packageName: string; metadata?: FlutterPackageMetadata }): void {
  const { framework, packageName, metadata } = options;

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
  const resolvedDistPath = path.resolve(distPath);
  
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
    
    if (!packageName) {
      const packageNameAnswer = await inquirer.prompt([{
        type: 'input',
        name: 'packageName',
        message: 'What is your package name?',
        default: path.basename(resolvedDistPath),
        validate: (input: string) => {
          if (!input || input.trim() === '') {
            return 'Package name is required';
          }
          // Basic npm package name validation
          if (!/^[a-z0-9]([a-z0-9-._])*$/.test(input)) {
            return 'Package name must be lowercase and may contain hyphens, dots, and underscores';
          }
          return true;
        }
      }]);
      packageName = packageNameAnswer.packageName;
    }
    
    // Try to read Flutter package metadata if flutterPackageSrc is provided
    let metadata: FlutterPackageMetadata | null = null;
    if (options.flutterPackageSrc) {
      metadata = readFlutterPackageMetadata(options.flutterPackageSrc);
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
    console.log(`  webf codegen generate ${distPath} --flutter-package-src=<path> --framework=${framework}`);
    return;
  }
  
  const command = `webf codegen generate --flutter-package-src=${options.flutterPackageSrc} --framework=${framework} <distPath>`;
  
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
  
  // Handle npm publishing if requested
  if (options.publishToNpm && framework) {
    try {
      await buildAndPublishPackage(resolvedDistPath, options.npmRegistry);
    } catch (error) {
      console.error('\nError during npm publish:', error);
      process.exit(1);
    }
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

async function buildAndPublishPackage(packagePath: string, registry?: string): Promise<void> {
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
  } else {
    console.log(`\nNo build script found, proceeding to publish ${packageName}@${packageVersion}...`);
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

export { generateCommand };
