#!/usr/bin/env node

import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';
import chalk from 'chalk';
import path from 'path';
import fs from 'fs-extra';
import { glob } from 'glob';
import { minimatch } from 'minimatch';
import JSON5 from 'json5';
import { ChromeTestRunner } from './test-runner';
import { TestConfig, TestScope } from './types';

async function loadConfig(): Promise<{ testScopes: Record<string, TestScope> }> {
  const configPath = path.join(__dirname, '..', 'config.json5');
  const configContent = await fs.readFile(configPath, 'utf-8');
  return JSON5.parse(configContent);
}

async function getTestFiles(scope: string): Promise<string[]> {
  const config = await loadConfig();
  const testScope = config.testScopes[scope];
  
  if (!testScope) {
    throw new Error(`Unknown test scope: ${scope}. Available scopes: ${Object.keys(config.testScopes).join(', ')}`);
  }

  const integrationTestsPath = path.join(__dirname, '..', '..');
  const files: string[] = [];

  // Handle include patterns
  if (testScope.include) {
    for (const pattern of testScope.include) {
      const matches = glob.sync(pattern, {
        cwd: integrationTestsPath,
        absolute: true
      });
      files.push(...matches);
    }
  }

  // Handle spec groups
  if (testScope.groups && testScope.groups.length > 0) {
    const specGroupPath = path.join(integrationTestsPath, 'spec_group.json5');
    const specGroupContent = await fs.readFile(specGroupPath, 'utf-8');
    const specGroups = JSON5.parse(specGroupContent);
    
    const targetGroups = specGroups.filter((group: any) => 
      testScope.groups!.includes(group.name)
    );
    
    for (const group of targetGroups) {
      for (const specPattern of group.specs) {
        const matches = glob.sync(specPattern, {
          cwd: integrationTestsPath,
          absolute: true
        });
        files.push(...matches);
      }
    }
  }

  // Remove duplicates
  const uniqueFiles = [...new Set(files)];

  // Apply exclusions
  if (testScope.exclude && testScope.exclude.length > 0) {
    return uniqueFiles.filter(file => {
      const relativePath = path.relative(integrationTestsPath, file);
      return !testScope.exclude!.some(pattern => 
        minimatch(relativePath, pattern)
      );
    });
  }

  return uniqueFiles;
}

async function main() {
  const argv = await yargs(hideBin(process.argv))
    .usage('Usage: $0 [options] [test-files...]')
    .positional('test-files', {
      describe: 'Specific test files to run',
      type: 'string',
      array: true
    })
    .option('scope', {
      alias: 's',
      type: 'string',
      description: 'Test scope to run',
      default: 'css-text'
    })
    .option('headless', {
      alias: 'h',
      type: 'boolean',
      description: 'Run in headless mode',
      default: true
    })
    .option('devtools', {
      alias: 'd',
      type: 'boolean',
      description: 'Open Chrome DevTools',
      default: false
    })
    .option('parallel', {
      alias: 'p',
      type: 'boolean',
      description: 'Run tests in parallel',
      default: false
    })
    .option('verbose', {
      alias: 'v',
      type: 'boolean',
      description: 'Verbose output',
      default: false
    })
    .option('filter', {
      alias: 'f',
      type: 'string',
      description: 'Filter test files by pattern'
    })
    .option('list-scopes', {
      type: 'boolean',
      description: 'List available test scopes',
      default: false
    })
    .option('snapshots', {
      type: 'boolean',
      description: 'Enable snapshot capture',
      default: true
    })
    .option('update-snapshots', {
      type: 'boolean',
      description: 'Update baseline snapshots',
      default: false
    })
    .help()
    .argv;

  try {
    // List scopes if requested
    if (argv['list-scopes']) {
      const config = await loadConfig();
      console.log(chalk.bold('\nAvailable test scopes:\n'));
      
      for (const [name, scope] of Object.entries(config.testScopes)) {
        console.log(chalk.blue(`  ${name}`) + chalk.gray(` - ${scope.description}`));
      }
      
      process.exit(0);
    }

    console.log(chalk.bold.blue('\n🧪 WebF Chrome Test Runner\n'));
    console.log(chalk.gray(`Mode: ${argv.headless ? 'Headless' : 'Headed'}`));

    // Get test files
    let testFiles: string[];
    
    // Check if specific test files were provided as positional arguments
    const positionalArgs = argv._ || [];
    if (positionalArgs.length > 0) {
      // Use provided test files
      const integrationTestsPath = path.join(__dirname, '..', '..');
      testFiles = positionalArgs.map(file => {
        const filePath = file.toString();
        // If the path is relative, resolve it relative to integration_tests directory
        if (!path.isAbsolute(filePath)) {
          return path.resolve(integrationTestsPath, filePath);
        }
        return filePath;
      });
      console.log(chalk.gray(`Running specific test files: ${testFiles.length}`));
    } else {
      // Use scope-based test discovery
      console.log(chalk.gray(`Scope: ${argv.scope}`));
      testFiles = await getTestFiles(argv.scope);
      
      // Apply filter if provided
      if (argv.filter) {
        testFiles = testFiles.filter(file => file.includes(argv.filter as string));
      }
    }

    if (testFiles.length === 0) {
      console.log(chalk.yellow('No test files found for the specified scope.'));
      process.exit(0);
    }

    console.log(chalk.gray(`Found ${testFiles.length} test file(s)\n`));

    // Create test runner
    const testConfig: TestConfig = {
      scope: argv.scope,
      headless: argv.headless,
      devtools: argv.devtools,
      parallel: argv.parallel,
      verbose: argv.verbose,
      snapshots: {
        enabled: argv.snapshots,
        updateSnapshots: argv['update-snapshots']
      }
    };

    const runner = new ChromeTestRunner(testConfig);

    // Initialize browser
    try {
      await runner.initialize();
    } catch (error: any) {
      console.error(chalk.red('\n❌ Failed to initialize browser:'));
      console.error(error);
      if (error.stack) {
        console.error(error.stack);
      }
      process.exit(1);
    }

    // Run tests
    const startTime = Date.now();
    await runner.runTests(testFiles);
    const duration = Date.now() - startTime;

    // Print summary
    runner.printSummary();
    console.log(chalk.gray(`\nCompleted in ${(duration / 1000).toFixed(2)}s`));

    // Save report
    const results = runner.getResults();
    const reportPath = path.join(process.cwd(), 'test-report.json');
    await fs.writeJson(reportPath, {
      scope: argv.scope,
      timestamp: Date.now(),
      duration,
      results,
      summary: {
        total: results.length,
        passed: results.filter(r => r.status === 'passed').length,
        failed: results.filter(r => r.status === 'failed').length,
        skipped: results.filter(r => r.status === 'pending' || r.status === 'disabled').length
      }
    }, { spaces: 2 });

    console.log(chalk.gray(`\nReport saved to: ${reportPath}`));
    
    // Display snapshot location if any were captured
    const totalSnapshots = results.reduce((sum, r) => sum + (r.snapshots?.length || 0), 0);
    if (totalSnapshots > 0) {
      console.log(chalk.gray(`Snapshots saved to: __expected__/${argv.scope}/`));
      console.log(chalk.gray(`Total snapshots captured: ${totalSnapshots}`));
    }

    // Cleanup
    await runner.cleanup();

    // Exit with appropriate code
    const failed = results.filter(r => r.status === 'failed').length;
    process.exit(failed > 0 ? 1 : 0);

  } catch (error: any) {
    console.error(chalk.red('\n❌ Error:'), error.message);
    if (argv.verbose) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

// Run CLI
main().catch(console.error);