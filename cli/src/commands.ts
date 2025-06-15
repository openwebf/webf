import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { dartGen, reactGen, vueGen } from './generator';
import _ from 'lodash';

interface CreateOptions {
  framework: string;
  packageName: string;
}

interface GenerateOptions {
  flutterPackageSrc: string;
  framework: string;
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

function initCommand(target: string): void {
  const typingsPath = path.resolve(target);
  const globalDtsPath = path.join(typingsPath, 'global.d.ts');
  const tsConfigPath = path.join(typingsPath, 'tsconfig.json');

  fs.mkdirSync(typingsPath, { recursive: true });
  fs.writeFileSync(globalDtsPath, gloabalDts, 'utf-8');
  fs.writeFileSync(tsConfigPath, tsConfig, 'utf-8');

  console.log(`WebF typings initialized: ${typingsPath}`);
}

function createCommand(target: string, options: CreateOptions): void {
  const { framework, packageName } = options;

  if (!fs.existsSync(target)) {
    fs.mkdirSync(target, { recursive: true });
  }

  if (framework === 'react') {
    const packageJsonPath = path.join(target, 'package.json');
    const packageJsonContent = _.template(reactPackageJson)({
      packageName,
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
  const command = `webf codegen generate --flutter-package-src=${options.flutterPackageSrc} --framework=<framework> <distPath>`;

  await dartGen({
    source: options.flutterPackageSrc,
    target: options.flutterPackageSrc,
    command,
  });

  if (options.framework === 'react') {
    const packageJsonPath = path.join(distPath, 'package.json');

    if (!fs.existsSync(packageJsonPath)) {
      console.error(`Error: package.json not found in ${distPath}, please run 'webf create' first.`);
      return;
    }

    await reactGen({
      source: options.flutterPackageSrc,
      target: distPath,
      command,
    });
  }
  else if (options.framework === 'vue') {
    await vueGen({
      source: options.flutterPackageSrc,
      target: distPath,
      command,
    });
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

export { initCommand, createCommand, generateCommand };
