#!/usr/bin/env node

const { Command } = require('commander');
const version = require('../package.json').version;
const { generateCommand } = require('../dist/commands');

const program = new Command();

program
  .name('webf')
  .description('CLI tool for webf development')
  .version(version, '-v, --version', 'output the current version');

program
  .command('codegen')
  .option('--flutter-package-src <src>', 'Flutter package source path (for code generation)')
  .option('--framework <framework>', 'Target framework (react or vue)')
  .option('--package-name <name>', 'Package name for the webf typings')
  .option('--publish-to-npm', 'Automatically publish the generated package to npm')
  .option('--npm-registry <url>', 'Custom npm registry URL (defaults to https://registry.npmjs.org/)')
  .argument('[distPath]', 'Path to output generated files', '.')
  .description('Generate dart abstract classes and React/Vue components (auto-creates project if needed)')
  .action(generateCommand);

program.parse();
