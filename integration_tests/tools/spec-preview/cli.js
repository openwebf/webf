#!/usr/bin/env node

const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const { SpecPreviewServer } = require('./server');

// Parse command line arguments
const args = process.argv.slice(2);

// Default values
let port = 3400;
let openBrowser = true;

// Parse arguments
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  
  if (arg === '-h' || arg === '--help') {
    showHelp();
    process.exit(0);
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
${chalk.bold('WebF Spec Preview')}

Interactive tool for previewing and testing WebF integration test specs.

${chalk.cyan('Usage:')}
  webf-spec-preview [options]

${chalk.cyan('Options:')}
  -p, --port <port>    Server port (default: 3400)
  --no-open            Don't open browser automatically
  -h, --help           Show this help message

${chalk.cyan('Examples:')}
  webf-spec-preview
  webf-spec-preview --port 4000 --no-open

${chalk.cyan('Features:')}
  • Live code editing with syntax highlighting
  • Compile TypeScript specs to JavaScript
  • Run specs in browser with mocked WebF environment
  • Launch specs in actual WebF runtime
  • Real-time output console

${chalk.cyan('Keyboard Shortcuts:')}
  ${chalk.gray('Cmd/Ctrl + S')}         Compile code
  ${chalk.gray('Cmd/Ctrl + Enter')}     Run in browser
  ${chalk.gray('Cmd/Ctrl + Shift + B')} Run in browser
  ${chalk.gray('Cmd/Ctrl + Shift + W')} Run in WebF
  ${chalk.gray('Cmd/Ctrl + Shift + C')} Compile code
  `);
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
    const server = new SpecPreviewServer(port);
    server.start();

    // Open browser if requested
    if (openBrowser) {
      const open = require('open');
      setTimeout(() => {
        open(`http://localhost:${port}/preview`);
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