#!/usr/bin/env node

const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const { SnapshotViewerServer } = require('./server');

// Parse command line arguments
const args = process.argv.slice(2);

// Default values
let snapshotDir = path.join(process.cwd(), 'snapshots');
let port = 3300;
let openBrowser = true;

// Parse arguments
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  
  if (arg === '-h' || arg === '--help') {
    showHelp();
    process.exit(0);
  }
  
  if (arg === '-d' || arg === '--dir') {
    snapshotDir = args[++i];
    if (!snapshotDir) {
      console.error(chalk.red('Error: --dir requires a directory path'));
      process.exit(1);
    }
    if (!path.isAbsolute(snapshotDir)) {
      snapshotDir = path.join(process.cwd(), snapshotDir);
    }
  }
  
  if (arg === '-p' || arg === '--port') {
    port = parseInt(args[++i], 10);
    if (isNaN(port)) {
      console.error(chalk.red('Error: --port requires a valid number'));
      process.exit(1);
    }
  }
  
  if (arg === '--no-open') {
    openBrowser = false;
  }
}

function showHelp() {
  console.log(`
${chalk.bold('WebF Snapshot Viewer')}

${chalk.cyan('Usage:')}
  webf-snapshot-viewer [options]

${chalk.cyan('Options:')}
  -d, --dir <path>     Snapshot directory (default: ./snapshots)
  -p, --port <port>    Server port (default: 3300)
  --no-open            Don't open browser automatically
  -h, --help           Show this help message

${chalk.cyan('Examples:')}
  webf-snapshot-viewer
  webf-snapshot-viewer --dir ./integration_tests/snapshots
  webf-snapshot-viewer --port 4000 --no-open

${chalk.cyan('Keyboard Shortcuts:')}
  ${chalk.gray('Cmd/Ctrl + ←')}     Previous snapshot
  ${chalk.gray('Cmd/Ctrl + →')}     Next snapshot
  ${chalk.gray('Cmd/Ctrl + Enter')} Accept current version
  ${chalk.gray('Escape')}           Keep original version
  ${chalk.gray('Alt + A')}          Accept all current
  ${chalk.gray('Alt + R')}          Keep all original
  `);
}

// Validate snapshot directory
if (!fs.existsSync(snapshotDir)) {
  console.error(chalk.red(`Error: Snapshot directory not found: ${snapshotDir}`));
  process.exit(1);
}

// Start server
async function start() {
  try {
    // Check if port is available
    const getPort = require('get-port-please');
    const availablePort = await getPort.getPort({ port });
    
    if (availablePort !== port) {
      console.log(chalk.yellow(`Port ${port} is in use, using port ${availablePort} instead`));
      port = availablePort;
    }

    // Create and start server
    const server = new SnapshotViewerServer(snapshotDir, port);
    server.start();

    // Open browser if requested
    if (openBrowser) {
      const open = require('open');
      setTimeout(() => {
        open(`http://localhost:${port}/viewer`);
      }, 1000);
    }

    // Handle graceful shutdown
    process.on('SIGINT', () => {
      console.log(chalk.yellow('\n\nShutting down server...'));
      process.exit(0);
    });

  } catch (error) {
    console.error(chalk.red('Failed to start server:'), error.message);
    process.exit(1);
  }
}

start();