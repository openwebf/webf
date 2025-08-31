import { execSync, spawn } from 'child_process';
import path from 'path';
import fs from 'fs-extra';
import glob from 'glob';
import chalk from 'chalk';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';
import express from 'express';
import open from 'open';
import * as esbuild from 'esbuild';

export interface ComparisonResult {
  testName: string;
  testDescription: string;
  specFile: string;
  webfSnapshot: string;
  chromeSnapshot: string;
  diffImage?: string;
  pixelDifference: number;
  percentDifference: number;
  width: number;
  height: number;
}

export interface ComparerOptions {
  specFile: string;
  port: number;
  autoOpen: boolean;
  threshold: number;
}

export class SnapshotComparer {
  private options: ComparerOptions;
  private rootDir: string;
  private webfSnapshotDir: string;
  private chromeSnapshotDir: string;
  private tempDir: string;

  constructor(options: ComparerOptions) {
    this.options = options;
    this.rootDir = path.resolve(__dirname, '../..');
    this.webfSnapshotDir = path.join(this.rootDir, 'snapshots');
    this.chromeSnapshotDir = path.join(this.rootDir, 'chrome_runner/snapshots');
    this.tempDir = path.join(this.rootDir, 'snapshot-compare/temp');
    
    // Ensure temp directory exists
    fs.ensureDirSync(this.tempDir);
  }

  async runWebFTest(): Promise<void> {
    console.log(chalk.gray(`Running WebF test: ${this.options.specFile}`));
    
    const args = ['run', 'integration', '--', this.options.specFile];
    const cwd = this.rootDir;
    console.log(chalk.blue(`Executing: npm ${args.join(' ')}`));
    console.log(chalk.blue(`Working directory: ${cwd}`));
    
    return new Promise<void>((resolve, reject) => {
      console.log(chalk.gray('\n--- WebF Test Output ---'));
      
      const proc = spawn('npm', args, {
        cwd: cwd,
        shell: true
      });
      
      // Stream stdout
      proc.stdout.on('data', (data) => {
        process.stdout.write(chalk.gray(data.toString()));
      });
      
      // Stream stderr
      proc.stderr.on('data', (data) => {
        process.stdout.write(chalk.red(data.toString()));
      });
      
      proc.on('close', (code) => {
        console.log(chalk.gray('\n--- End WebF Test Output ---\n'));
        
        if (code !== 0) {
          // WebF test might "fail" if snapshots don't match, but that's expected
          console.log(chalk.yellow('WebF test completed (snapshots may have been updated)'));
        }
        resolve();
      });
      
      proc.on('error', (error) => {
        console.log(chalk.gray('\n--- End WebF Test Output ---\n'));
        console.error(chalk.red(`Failed to start WebF test: ${error.message}`));
        reject(error);
      });
    });
  }

  async runChromeTest(): Promise<void> {
    console.log(chalk.gray(`Running Chrome test: ${this.options.specFile}`));
    
    const args = ['test', '--', this.options.specFile];
    const cwd = path.join(this.rootDir, 'chrome_runner');
    console.log(chalk.blue(`Executing: npm ${args.join(' ')}`));
    console.log(chalk.blue(`Working directory: ${cwd}`));
    
    return new Promise<void>((resolve, reject) => {
      console.log(chalk.gray('\n--- Chrome Test Output ---'));
      
      const proc = spawn('npm', args, {
        cwd: cwd,
        shell: true
      });
      
      let outputBuffer = '';
      
      // Stream stdout
      proc.stdout.on('data', (data) => {
        const output = data.toString();
        outputBuffer += output;
        process.stdout.write(chalk.gray(output));
      });
      
      // Stream stderr
      proc.stderr.on('data', (data) => {
        process.stdout.write(chalk.red(data.toString()));
      });
      
      proc.on('close', (code) => {
        console.log(chalk.gray('\n--- End Chrome Test Output ---\n'));
        
        if (code !== 0) {
          // Check if all tests failed
          if (outputBuffer.includes('Failed: ') && outputBuffer.includes('Passed: 0')) {
            reject(new Error('All Chrome tests failed. Please check the test implementation.'));
          } else {
            reject(new Error(`Chrome runner test failed with exit code ${code}. Please check the test file and ensure it exists.`));
          }
        } else {
          resolve();
        }
      });
      
      proc.on('error', (error) => {
        console.log(chalk.gray('\n--- End Chrome Test Output ---\n'));
        console.error(chalk.red(`Failed to start Chrome test: ${error.message}`));
        reject(error);
      });
    });
  }

  async compareSnapshots(): Promise<ComparisonResult[]> {
    // Remove 'specs/' prefix if present and extension
    let specPath = this.options.specFile;
    if (specPath.startsWith('specs/')) {
      specPath = specPath.substring(6);
    }
    specPath = specPath.replace(/\.(ts|js)$/, '');
    
    const specDir = path.dirname(specPath);
    const specName = path.basename(specPath);
    
    // Read Chrome runner test report to get test descriptions
    const testReportPath = path.join(this.rootDir, 'chrome_runner/test-report.json');
    let testDescriptions: Map<string, string> = new Map();
    
    if (fs.existsSync(testReportPath)) {
      try {
        const testReport = JSON.parse(fs.readFileSync(testReportPath, 'utf-8'));
        if (testReport.results) {
          for (const result of testReport.results) {
            if (result.snapshots) {
              for (const snapshot of result.snapshots) {
                const snapshotFilename = path.basename(snapshot);
                testDescriptions.set(snapshotFilename, result.name);
              }
            }
          }
        }
      } catch (error) {
        console.log(chalk.yellow('Could not read test descriptions from test report'));
      }
    }
    
    // Look for WebF snapshots - prioritize .current.png files
    const webfCurrentPattern = path.join(this.webfSnapshotDir, specDir, `${specName}*.current.png`);
    const webfRegularPattern = path.join(this.webfSnapshotDir, specDir, `${specName}*.png`);
    
    console.log(chalk.gray(`Looking for WebF current snapshots: ${webfCurrentPattern}`));
    const webfCurrentSnapshots = glob.sync(webfCurrentPattern);
    console.log(chalk.gray(`Found ${webfCurrentSnapshots.length} WebF current snapshot(s)`));
    
    // Also get regular snapshots for fallback
    const webfRegularSnapshots = glob.sync(webfRegularPattern)
      .filter(f => !f.endsWith('.current.png')); // Exclude .current.png from regular
    console.log(chalk.gray(`Found ${webfRegularSnapshots.length} WebF regular snapshot(s)`));

    const results: ComparisonResult[] = [];
    const processedBasenames = new Set<string>();

    // Process .current.png snapshots first (these are the ones to compare with Chrome)
    for (const webfSnapshot of webfCurrentSnapshots) {
      const filename = path.basename(webfSnapshot);
      // Get the base filename without .current.png suffix
      const baseFilename = filename.replace('.current.png', '.png');
      processedBasenames.add(baseFilename);
      
      const chromeSnapshot = path.join(this.chromeSnapshotDir, specDir, baseFilename);

      console.log(chalk.gray(`Checking Chrome snapshot: ${chromeSnapshot}`));
      if (!fs.existsSync(chromeSnapshot)) {
        console.log(chalk.yellow(`Chrome snapshot not found: ${baseFilename}`));
        // Still include in results to show that WebF has a snapshot but Chrome doesn't
        const testDescription = testDescriptions.get(baseFilename) || baseFilename;
        results.push({
          testName: baseFilename.replace(/\.([\da-f]+)\d+\.png$/, ''),
          testDescription,
          specFile: this.options.specFile,
          webfSnapshot: webfSnapshot,
          chromeSnapshot: '',
          pixelDifference: -1,
          percentDifference: 100,
          width: 0,
          height: 0
        });
        continue;
      }

      const testDescription = testDescriptions.get(baseFilename) || baseFilename;
      const result = await this.compareImages(webfSnapshot, chromeSnapshot, baseFilename, testDescription);
      results.push(result);
    }

    // Process regular snapshots that don't have .current.png versions
    for (const webfSnapshot of webfRegularSnapshots) {
      const filename = path.basename(webfSnapshot);
      if (processedBasenames.has(filename)) {
        continue; // Skip if we already processed a .current.png version
      }
      
      const chromeSnapshot = path.join(this.chromeSnapshotDir, specDir, filename);

      console.log(chalk.gray(`Checking Chrome snapshot: ${chromeSnapshot}`));
      if (!fs.existsSync(chromeSnapshot)) {
        console.log(chalk.yellow(`Chrome snapshot not found: ${filename}`));
        continue;
      }

      const testDescription = testDescriptions.get(filename) || filename;
      const result = await this.compareImages(webfSnapshot, chromeSnapshot, filename, testDescription);
      results.push(result);
    }

    return results;
  }

  private async compareImages(webfPath: string, chromePath: string, filename: string, testDescription: string): Promise<ComparisonResult> {
    // Check if Chrome snapshot exists
    if (!chromePath || !fs.existsSync(chromePath)) {
      const webfImg = PNG.sync.read(fs.readFileSync(webfPath));
      console.log(chalk.red(`  No Chrome snapshot available for comparison`));
      return {
        testName: filename.replace(/\.([\da-f]+)\d+\.png$/, ''),
        testDescription,
        specFile: this.options.specFile,
        webfSnapshot: webfPath,
        chromeSnapshot: '',
        diffImage: undefined,
        pixelDifference: -1,
        percentDifference: 100,
        width: webfImg.width,
        height: webfImg.height
      };
    }

    const webfImg = PNG.sync.read(fs.readFileSync(webfPath));
    const chromeImg = PNG.sync.read(fs.readFileSync(chromePath));

    const width = Math.max(webfImg.width, chromeImg.width);
    const height = Math.max(webfImg.height, chromeImg.height);

    // Create diff image
    const diff = new PNG({ width, height });

    // If dimensions don't match, we need to handle it
    let numDiffPixels = 0;
    if (webfImg.width !== chromeImg.width || webfImg.height !== chromeImg.height) {
      console.log(chalk.yellow(`Dimension mismatch for ${filename}: WebF(${webfImg.width}x${webfImg.height}) vs Chrome(${chromeImg.width}x${chromeImg.height})`));
      numDiffPixels = width * height; // Consider all pixels different
    } else {
      numDiffPixels = pixelmatch(
        webfImg.data,
        chromeImg.data,
        diff.data,
        width,
        height,
        { threshold: this.options.threshold }
      );
    }

    // Save diff image
    const diffPath = path.join(this.tempDir, `diff_${filename}`);
    fs.writeFileSync(diffPath, PNG.sync.write(diff));

    const totalPixels = width * height;
    const percentDifference = (numDiffPixels / totalPixels) * 100;

    // Extract test name from filename
    const testName = filename.replace(/\.([\da-f]+)\d+\.png$/, '');
    
    // Extract spec file path
    const specFile = this.options.specFile;

    // Log comparison result
    const matchType = percentDifference === 0 ? 'Perfect Match' :
                     percentDifference < 1 ? 'Close Match' : 'Different';
    const color = percentDifference === 0 ? chalk.green :
                  percentDifference < 1 ? chalk.yellow : chalk.red;
    
    console.log(color(`  ${matchType}: ${percentDifference.toFixed(2)}% difference (${numDiffPixels} pixels)`));

    return {
      testName,
      testDescription,
      specFile,
      webfSnapshot: webfPath,
      chromeSnapshot: chromePath,
      diffImage: diffPath,
      pixelDifference: numDiffPixels,
      percentDifference,
      width,
      height
    };
  }

  async startWebServer(results: ComparisonResult[]): Promise<void> {
    const app = express();

    // Serve static files
    app.use('/snapshots', express.static(this.rootDir));
    app.use('/temp', express.static(this.tempDir));
    app.use('/specs', express.static(path.join(this.rootDir, 'specs')));
    app.use('/fonts', express.static(path.join(this.rootDir, 'fonts')));
    app.use('/assets', express.static(path.join(this.rootDir, 'assets')));

    // API endpoint for results
    app.get('/api/results', (req, res) => {
      res.json(results.map(r => ({
        ...r,
        webfSnapshot: `/snapshots/${path.relative(this.rootDir, r.webfSnapshot)}`,
        chromeSnapshot: `/snapshots/${path.relative(this.rootDir, r.chromeSnapshot)}`,
        diffImage: r.diffImage ? `/temp/${path.basename(r.diffImage)}` : undefined,
        testDescription: r.testDescription,
        specFile: r.specFile
      })));
    });

    // API endpoint to get spec file content
    app.get('/api/spec-content', async (req, res) => {
      const specFile = req.query.file as string;
      if (!specFile) {
        return res.status(400).json({ error: 'No file specified' });
      }
      
      try {
        const filePath = path.join(this.rootDir, specFile);
        const content = await fs.readFile(filePath, 'utf-8');
        res.json({ content, path: specFile });
      } catch (error) {
        res.status(404).json({ error: 'File not found' });
      }
    });

    // API endpoint to compile TypeScript to JavaScript
    app.post('/api/compile-typescript', express.json({ limit: '10mb' }), async (req, res) => {
      const { code } = req.body;
      if (!code) {
        return res.status(400).json({ error: 'No code provided' });
      }
      
      try {
        const result = await esbuild.transform(code, {
          loader: 'ts',
          target: 'es2020',
          format: 'iife'
        });
        res.json({ compiledCode: result.code });
      } catch (error: any) {
        res.status(400).json({ error: error.message });
      }
    });

    // Store the current test page content (single constant URL)
    let currentTestPageContent: string | null = null;

    // API endpoint to update the test page content
    app.post('/api/update-test-page', express.json({ limit: '10mb' }), async (req, res) => {
      const { code, fontFamily, focusedTestIndex } = req.body;
      if (!code) {
        return res.status(400).json({ error: 'No code provided' });
      }
      
      try {
        const result = await esbuild.transform(code, {
          loader: 'ts',
          target: 'es2020',
          format: 'iife'
        });
        
        // Create full HTML page
        const html = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=360, height=640">
    <style>
        /* Global box-sizing reset */
        *, *::before, *::after {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            padding: 0;
            background: white;
            font-family: ${fontFamily || "'Alibaba-PuHuiTi', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"};
            font-size: 16px;
        }
        
        /* Default user agent styles */
        p { margin: 1em 0; }
        h1 { font-size: 2em; margin: 0.67em 0; font-weight: bold; }
        h2 { font-size: 1.5em; margin: 0.83em 0; font-weight: bold; }
        h3 { font-size: 1.17em; margin: 1em 0; font-weight: bold; }
        
        /* Load fonts - AlibabaSans */
        @font-face {
            font-family: 'AlibabaSans';
            src: url('/fonts/AlibabaSans-Regular.otf') format('opentype');
            font-weight: 400;
        }
        @font-face {
            font-family: 'AlibabaSans';
            src: url('/fonts/AlibabaSans-Bold.otf') format('opentype');
            font-weight: 700;
        }
        
        /* Load fonts - Alibaba-PuHuiTi */
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Regular.ttf') format('truetype');
            font-weight: 400;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Light.ttf') format('truetype');
            font-weight: 300;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Medium.ttf') format('truetype');
            font-weight: 500;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Bold.ttf') format('truetype');
            font-weight: 700;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Heavy.ttf') format('truetype');
            font-weight: 900;
        }
    </style>
</head>
<body>
    <script>
        var testCases = [];
        var focusedTestIndex = ${focusedTestIndex !== undefined ? focusedTestIndex : 'null'};
        
        // Mock Jasmine functions - collect tests first
        window.describe = function(name, fn) { 
            // Just execute the describe block to collect tests
            fn(); 
        };
        
        window.it = window.fit = function(name, fn) {
            testCases.push({ name: name, fn: fn });
        };
        
        window.xit = function() {}; // Skip
        window.beforeEach = window.afterEach = function() {};
        window.expect = function(actual) {
            return {
                toBe: function() {},
                toEqual: function() {},
                toBeGreaterThan: function() {},
                toBeLessThan: function() {}
            };
        };
        
        // Mock snapshot function
        window.snapshot = async function() { 
            console.log('Snapshot captured');
            return Promise.resolve();
        };
        
        // Mock other common functions
        window.sleep = function(s) { return new Promise(function(r) { setTimeout(r, s * 1000); }); };
        window.requestAnimationFrame = window.requestAnimationFrame || function(cb) { return setTimeout(cb, 16); };
        
        // Add BODY global
        Object.defineProperty(window, 'BODY', {
            get: function() { return document.body; }
        });
        
        // Store original functions to avoid circular references
        var originalCreateElement = document.createElement.bind(document);
        var originalCreateTextNode = document.createTextNode.bind(document);
        
        // Add createElement helper
        window.createElement = function(tag, attrs, children) {
            var el = originalCreateElement(tag);
            if (attrs) {
                Object.keys(attrs).forEach(function(key) {
                    if (key === 'style' && typeof attrs[key] === 'object') {
                        Object.assign(el.style, attrs[key]);
                    } else {
                        el.setAttribute(key, attrs[key]);
                    }
                });
            }
            if (children) {
                children.forEach(function(child) {
                    if (typeof child === 'string') {
                        el.appendChild(originalCreateTextNode(child));
                    } else {
                        el.appendChild(child);
                    }
                });
            }
            return el;
        };
        
        // Add createText helper
        window.createText = function(content) {
            return originalCreateTextNode(content);
        };
        
        // Function to run a specific test
        function runTest(test) {
            // Clear all content from body first
            document.body.innerHTML = '';
            
            // Reset body styles
            var fontFamilyValue = "${(fontFamily || "'Alibaba-PuHuiTi', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif").replace(/"/g, '\\"')}";
            document.body.style.cssText = 'margin: 0; padding: 0; background: white; font-family: ' + fontFamilyValue + '; font-size: 16px;';
            
            try {
                if (test.fn.length > 0) {
                    const done = function() { console.log('Test completed'); };
                    test.fn(done);
                } else {
                    test.fn();
                }
            } catch (e) {
                document.body.innerHTML = '<div style="color: red; padding: 20px;">Error: ' + e.message + '</div>';
                console.error('Test error:', e);
            }
        }
        
        // Collect all tests first
        try {
            ${result.code}
            
            // Now run only the focused test if specified
            if (focusedTestIndex !== null && focusedTestIndex >= 0 && focusedTestIndex < testCases.length) {
                console.log('Running focused test:', testCases[focusedTestIndex].name);
                runTest(testCases[focusedTestIndex]);
            } else if (testCases.length > 0) {
                // If no focused test specified, run the first one
                console.log('Running first test:', testCases[0].name);
                runTest(testCases[0]);
            } else {
                document.body.innerHTML = '<div style="color: #666; padding: 20px;">No tests found in this file.</div>';
            }
        } catch (e) {
            document.body.innerHTML = '<div style="color: red; padding: 20px;">Error: ' + e.message + '</div>';
            console.error(e);
        }
    </script>
</body>
</html>`;
        
        // Update the current test page content
        currentTestPageContent = html;
        
        res.json({ 
          success: true,
          url: `http://localhost:${this.options.port}/test-page/current`
        });
      } catch (error: any) {
        res.status(400).json({ error: error.message });
      }
    });

    // Serve the current test page at a constant URL
    app.get('/test-page/current', (req, res) => {
      if (!currentTestPageContent) {
        return res.status(404).send('No test page available. Generate one from the snapshot comparison tool.');
      }
      
      res.setHeader('Content-Type', 'text/html');
      res.send(currentTestPageContent);
    });

    // Serve the React app
    const distPath = path.join(this.rootDir, 'snapshot-compare/dist');
    app.use(express.static(distPath));
    
    // Fallback to index.html for client-side routing
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });

    return new Promise((resolve) => {
      app.listen(this.options.port, () => {
        resolve();
        if (this.options.autoOpen) {
          open(`http://localhost:${this.options.port}`);
        }
      });
    });
  }
}
