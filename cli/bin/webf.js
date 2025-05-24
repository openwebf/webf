#!/usr/bin/env node

const { Command } = require('commander');
const version = require('../package.json').version;
const { initCommand, createCommand, generateCommand } = require('../dist/commands');

const program = new Command();

program
  .name('webf')
  .description('CLI tool for webf development')
  .version(version, '-v, --version', 'output the current version');

const codegen = program.command('codegen').description('Webf codegen utilities');

codegen
  .command('init')
  .argument('<path>', 'Path to Flutter project')
  .description('Configure webf element typings for a Flutter project')
  .action(initCommand);

codegen
  .command('create')
  .requiredOption('--framework <framework>', 'Target framework (e.g., react)')
  .requiredOption('--package-name <package_name>', 'Package name for the webf typings')
  .argument('<path>', 'Destination path')
  .description('Scaffold typings for a webf project')
  .action(createCommand);

codegen
  .command('generate')
  .requiredOption('--flutter-package-src <src>', 'Flutter package source path')
  .requiredOption('--framework <framework>', 'Target framework')
  .argument('[distPath]', 'Path to output generated files', '.')
  .description('Generate dart abstract classes and React components')
  .action(generateCommand);

program.parse();
