import { Command } from 'commander';
import path from 'path';
import { SnapshotComparer } from './comparer';
import chalk from 'chalk';
import ora from 'ora';

const program = new Command();

program
  .name('snapshot-compare')
  .description('Compare WebF and Chrome runner snapshots')
  .version('1.0.0')
  .argument('<spec-file>', 'Test spec file path (e.g., specs/css/css-text-mixin/color_relative_properties_test.ts)')
  .option('-p, --port <number>', 'Port for the comparison web interface', '3000')
  .option('--no-open', 'Do not automatically open the browser')
  .option('--threshold <number>', 'Pixel difference threshold (0-1)', '0.1')
  .action(async (specFile: string, options) => {
    console.log(chalk.blue('\n🔍 WebF Snapshot Comparison Tool\n'));

    const spinner = ora('Initializing...').start();

    try {
      const comparer = new SnapshotComparer({
        specFile,
        port: parseInt(options.port),
        autoOpen: options.open,
        threshold: parseFloat(options.threshold)
      });

      spinner.text = 'Running WebF integration test...';
      await comparer.runWebFTest();

      spinner.text = 'Running Chrome runner test...';
      await comparer.runChromeTest();

      spinner.text = 'Comparing snapshots...';
      const results = await comparer.compareSnapshots();

      spinner.succeed('Snapshot comparison complete');

      console.log(chalk.green(`\n✅ Found ${results.length} snapshot(s) to compare`));

      if (results.length === 0) {
        console.log(chalk.yellow('\n⚠️  No snapshots found to compare'));
        console.log(chalk.gray('This could mean:'));
        console.log(chalk.gray('  - The test file has no snapshot tests'));
        console.log(chalk.gray('  - The tests failed to run properly'));
        console.log(chalk.gray('  - The snapshot files were not generated\n'));
        process.exit(0);
      }

      // Only start the server if we have results to show
      spinner.text = 'Starting web interface...';
      spinner.start();
      
      await comparer.startWebServer(results);
      spinner.succeed(`Web interface started at http://localhost:${options.port}`);
      
      console.log(chalk.gray('\nPress Ctrl+C to stop the server\n'));
    } catch (error: any) {
      spinner.fail('Error occurred');
      console.error(chalk.red(error.message));
      process.exit(1);
    }
  });

program.parse();