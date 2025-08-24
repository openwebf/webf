const express = require('express');
const path = require('path');
const fs = require('fs');
const glob = require('glob');
const chalk = require('chalk');
const { spawn } = require('child_process');
const webpack = require('webpack');
const webpackConfig = require('../../webpack.config.js');

// Load the shared runtime
const runtimeCode = fs.readFileSync(path.join(__dirname, 'runtime.js'), 'utf8');

class SpecPreviewServer {
  constructor(port) {
    this.port = port;
    this.app = express();
    this.debugServerCode = '';
    this.setupMiddleware();
    this.setupRoutes();
  }

  setupMiddleware() {
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use('/preview', express.static(path.join(__dirname, 'client')));
    this.app.use('/runtime', express.static(path.join(__dirname, '../../runtime')));
    this.app.use('/assets', express.static(path.join(__dirname, '../../assets')));
    this.app.use('/build', express.static(path.join(__dirname, '../../build')));
  }

  async compileSpec(specPath) {
    return new Promise((resolve, reject) => {
      // Create a custom webpack config for single spec
      const customConfig = {
        ...webpackConfig,
        entry: {
          spec: specPath
        },
        output: {
          path: path.join(__dirname, 'temp'),
          filename: 'compiled-spec.js'
        },
        mode: 'development'
      };

      webpack(customConfig, (err, stats) => {
        if (err || stats.hasErrors()) {
          const errorMsg = err ? err.toString() : stats.toString('errors-only');
          reject(new Error(errorMsg));
          return;
        }

        // Read the compiled file
        const compiledPath = path.join(__dirname, 'temp', 'compiled-spec.js');
        fs.readFile(compiledPath, 'utf8', (readErr, data) => {
          if (readErr) {
            reject(readErr);
            return;
          }
          resolve(data);
        });
      });
    });
  }


  setupRoutes() {
    // Redirect root to preview
    this.app.get('/', (req, res) => {
      res.redirect('/preview');
    });

    // Debug server endpoint for WebF to fetch code
    // Both endpoints serve the same code for compatibility
    const serveDebugCode = (req, res) => {
      res.setHeader('Content-Type', 'application/javascript');
      res.setHeader('Cache-Control', 'no-cache');
      res.send(this.debugServerCode);
    };
    
    this.app.get('/kraken_debug_server.js', serveDebugCode);
    this.app.get('/webf_debug_server.js', serveDebugCode);

    // API: Compile spec
    this.app.post('/api/compile', async (req, res) => {
      const { code } = req.body;

      try {
        let compiledCode;
        
        if (code) {
          // Compile from provided code
          const tempFile = path.join(__dirname, 'temp', 'custom-spec.ts');
          fs.mkdirSync(path.dirname(tempFile), { recursive: true });
          fs.writeFileSync(tempFile, code);
          compiledCode = await this.compileSpec(tempFile);
        } else {
          return res.status(400).json({ error: 'No code provided' });
        }

        // Add shared runtime and ensure immediate execution
        const fullCode = `
// WebF Test Runtime - Supports multiple environments:
// 1. Browser (mock test runner)
// 2. WebF Example (no Jasmine, uses mock runner)
// 3. WebF Integration Playground (has Jasmine, auto-executes)

${runtimeCode}

// User test code starts here
${compiledCode}

// Environment detection and test execution
(function() {
  const hasJasmine = typeof jasmine !== 'undefined';
  const hasWebF = typeof webf !== 'undefined';
  const hasSimulatePointer = typeof simulatePointer !== 'undefined';
  
  if (hasJasmine && hasSimulatePointer) {
    // WebF Integration Playground - tests execute via Jasmine
    console.log('Tests loaded in Integration Playground - Jasmine will execute');
  } else if (hasWebF && !hasJasmine) {
    // WebF Example environment - tests execute via mock runner
    console.log('Tests loaded in WebF Example - using mock test runner');
  } else {
    // Browser environment - tests execute via mock runner
    console.log('Tests loaded in browser - using mock test runner');
  }
})();
`;

        // Store for debug server
        this.debugServerCode = fullCode;

        res.json({ 
          success: true,
          code: fullCode 
        });
      } catch (error) {
        console.error(chalk.red('Compilation error:'), error);
        res.status(500).json({ 
          error: 'Compilation failed',
          details: error.message 
        });
      }
    });

    // API: Run in browser
    this.app.post('/api/run/browser', (req, res) => {
      const { code } = req.body;

      if (!code) {
        return res.status(400).json({ error: 'No code provided' });
      }

      // Create a data URL for the browser with the same runtime
      const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>WebF Spec Preview</title>
  <style>
    body {
      margin: 0;
      padding: 20px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: white;
    }
    .test-result {
      padding: 12px 15px;
      margin: 10px 0;
      border-radius: 6px;
      border-left: 4px solid;
      position: relative;
      transition: transform 0.2s;
    }
    .test-result:hover {
      transform: translateX(5px);
    }
    .test-result.pass {
      background: #d4edda;
      color: #155724;
      border-left-color: #28a745;
    }
    .test-result.fail {
      background: #f8d7da;
      color: #721c24;
      border-left-color: #dc3545;
    }
    .test-result.skip {
      background: #e2e3e5;
      color: #383d41;
      border-left-color: #6c757d;
    }
    .test-result strong {
      display: block;
      margin-bottom: 5px;
    }
    .test-result small {
      opacity: 0.8;
      font-family: 'Consolas', 'Monaco', monospace;
      display: block;
      margin-top: 5px;
    }
    #results:empty::before {
      content: 'Running tests...';
      color: #6c757d;
      font-style: italic;
    }
  </style>
</head>
<body>
  <div id="results"></div>
  <script>
    // Test result handler for browser UI
    const testResults = [];
    
    window.addTestResult = function(name, status, error) {
      const resultsDiv = document.getElementById('results');
      const resultDiv = document.createElement('div');
      resultDiv.className = 'test-result ' + status;
      
      let icon = '✓';
      if (status === 'fail') icon = '✗';
      if (status === 'skip') icon = '⊘';
      
      resultDiv.innerHTML = \`
        <strong>\${icon} \${name}</strong>
        \${error ? '<small>' + error + '</small>' : ''}
      \`;
      resultsDiv.appendChild(resultDiv);
      testResults.push({ name, status, error });
    };
    
    // Execute the test code (runtime + user code)
    try {
      ${code}
      
      // Show completion message after a short delay
      setTimeout(() => {
        if (testResults.length === 0) {
          const resultsDiv = document.getElementById('results');
          resultsDiv.innerHTML = '<div style="color: #6c757d; text-align: center; padding: 20px;">No tests found in the spec</div>';
        }
      }, 100);
    } catch (err) {
      console.error('Failed to execute test:', err);
      window.addTestResult('Test Execution', 'fail', err.toString());
    }
  </script>
</body>
</html>
      `;

      const dataUrl = `data:text/html;base64,${Buffer.from(html).toString('base64')}`;
      res.json({ 
        success: true,
        url: dataUrl 
      });
    });

    // API: Get WebF debug URL
    this.app.get('/api/webf/url', (req, res) => {
      const debugUrl = `http://localhost:${this.port}/kraken_debug_server.js`;
      res.json({ 
        success: true,
        url: debugUrl,
        instructions: 'Use this URL in WebF or your development environment to run the compiled spec'
      });
    });

  }

  start() {
    // Ensure temp directory exists
    const tempDir = path.join(__dirname, 'temp');
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }

    this.app.listen(this.port, () => {
      console.log(chalk.green(`\n🧪 WebF Spec Preview Server`));
      console.log(chalk.cyan(`   Server running at: http://localhost:${this.port}/preview`));
      console.log(chalk.cyan(`   WebF Debug URL: http://localhost:${this.port}/kraken_debug_server.js`));
      console.log(chalk.gray(`   Press Ctrl+C to stop\n`));
    });
  }
}

module.exports = { SpecPreviewServer };