import puppeteer, { Browser, Page } from 'puppeteer';
import path from 'path';
import fs from 'fs-extra';
import chalk from 'chalk';
import ora from 'ora';
import pLimit from 'p-limit';
import * as esbuild from 'esbuild';
import express from 'express';
import { Server } from 'http';
import { TestConfig, TestResult, TestScope } from './types';

export class ChromeTestRunner {
  private config: TestConfig;
  private browser: Browser | null = null;
  private results: TestResult[] = [];
  private snapshotDir: string;
  private expectedDir: string;
  private rootDir: string;
  private fileServer: Server | null = null;
  private fileServerPort: number = 8080;

  constructor(config: TestConfig) {
    this.config = config;
    this.rootDir = process.cwd();
    // Store snapshots in chrome_runner/snapshots directory
    this.snapshotDir = path.join(this.rootDir, 'snapshots');
    this.expectedDir = this.snapshotDir;
  }

  async initialize() {
    // Ensure snapshot directory exists
    await fs.ensureDir(this.snapshotDir);

    // Start static file server for fonts and assets
    await this.startFileServer();

    // Launch browser with minimal config
    this.browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    console.log(chalk.green('✓ Chrome browser launched'));
  }

  private async startFileServer(): Promise<void> {
    const app = express();
    
    // Add CORS headers
    app.use((req, res, next) => {
      res.header('Access-Control-Allow-Origin', '*');
      res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
      res.header('Access-Control-Allow-Headers', 'Content-Type');
      next();
    });
    
    // Serve static files from integration_tests directory
    const integrationTestsDir = path.join(this.rootDir, '..');
    app.use('/fonts', express.static(path.join(integrationTestsDir, 'fonts')));
    app.use('/assets', express.static(path.join(integrationTestsDir, 'assets')));
    
    return new Promise((resolve) => {
      this.fileServer = app.listen(this.fileServerPort, () => {
        console.log(chalk.gray(`✓ Static file server started on port ${this.fileServerPort}`));
        resolve();
      });
    });
  }

  async runTests(testFiles: string[]): Promise<TestResult[]> {
    const spinner = ora('Running tests...').start();
    const limit = pLimit(this.config.parallel ? 5 : 1);

    try {
      const testPromises = testFiles.map((testFile) => 
        limit(() => this.runTestFile(testFile))
      );

      const results = await Promise.all(testPromises);
      this.results = results.flat();

      spinner.succeed(`Completed ${this.results.length} tests`);
      return this.results;
    } catch (error) {
      spinner.fail('Test execution failed');
      throw error;
    }
  }

  private async runTestFile(testFile: string): Promise<TestResult[]> {
    const page = await this.browser!.newPage();
    
    // Set viewport to match WebF integration tests
    await page.setViewport({
      width: 360,
      height: 640,
      deviceScaleFactor: 1
    });
    
    const results: TestResult[] = [];
    let snapshotCounter = 0;
    const testSnapshots: Map<string, string[]> = new Map();
    const specSnapshotCounters: Map<string, number> = new Map();
    
    try {
      // Navigate to blank page first
      await page.goto('about:blank');
      // Set up console logging
      page.on('console', msg => {
        const type = msg.type();
        const text = msg.text();
        
        if (type === 'error') {
          console.error(chalk.red(`[Browser Error] ${text}`));
        } else if (this.config.verbose) {
          console.log(chalk.gray(`[Browser] ${text}`));
        }
      });

      // Set up page error handling
      page.on('pageerror', error => {
        console.error(chalk.red(`[Page Error] ${error.message}`));
      });

      // Inject test runtime
      await this.injectTestRuntime(page, testFile);

      // Load and transpile the test file
      let testContent: string;
      const testName = path.basename(testFile, path.extname(testFile));
      
      // Check if file is TypeScript
      if (testFile.endsWith('.ts') || testFile.endsWith('.tsx')) {
        // Transpile TypeScript to JavaScript
        const result = await esbuild.build({
          entryPoints: [testFile],
          bundle: true,
          write: false,
          format: 'iife',
          platform: 'browser',
          target: 'es2020',
          loader: { '.ts': 'ts', '.tsx': 'tsx' },
          sourcemap: false,
          external: ['jasmine'],
          define: {
            'process.env.NODE_ENV': '"test"'
          },
          // Handle imports from WebF runtime
          plugins: [{
            name: 'webf-externals',
            setup(build) {
              // Mark WebF runtime imports as external
              build.onResolve({ filter: /^@runtime/ }, args => ({
                path: args.path,
                external: true
              }));
            }
          }]
        });
        
        testContent = result.outputFiles[0].text;
        
        if (this.config.verbose) {
          console.log(chalk.gray('  ✓ TypeScript transpiled'));
        }
      } else {
        // JavaScript file - read directly
        testContent = await fs.readFile(testFile, 'utf-8');
      }

      console.log(chalk.blue(`Running: ${testName}`));

      // Create isolated test environment
      await page.evaluate(() => {
        // Clear any existing content
        document.body.innerHTML = '';
        document.head.innerHTML = '';
        
        document.body.style.backgroundColor = 'white';
        document.body.style.margin = '0';
        document.body.style.padding = '0';
        document.body.style.width = '360px';
        document.body.style.height = '640px';
        document.body.style.overflow = 'hidden';
        
        // Add font-face definitions for Alibaba fonts and global styles
        const fontStyles = document.createElement('style');
        fontStyles.setAttribute('data-chrome-runner', 'true');
        fontStyles.textContent = `
          /* Global box-sizing reset */
          *, *::before, *::after {
            box-sizing: border-box;
          }
          
          /* Ensure html and body match viewport */
          html {
            width: 360px;
            height: 640px;
            margin: 0;
            padding: 0;
            overflow: hidden;
          }
          
          body {
            width: 360px;
            height: 640px;
            margin: 0;
            padding: 0;
            overflow: hidden;
          }
          
          /* Default user agent styles for block elements */
          p {
            display: block;
            margin-block-start: 1em;
            margin-block-end: 1em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
          }
          
          h1 {
            display: block;
            font-size: 2em;
            margin-block-start: 0.67em;
            margin-block-end: 0.67em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
            font-weight: bold;
          }
          
          h2 {
            display: block;
            font-size: 1.5em;
            margin-block-start: 0.83em;
            margin-block-end: 0.83em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
            font-weight: bold;
          }
          
          h3 {
            display: block;
            font-size: 1.17em;
            margin-block-start: 1em;
            margin-block-end: 1em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
            font-weight: bold;
          }
          
          h4 {
            display: block;
            margin-block-start: 1.33em;
            margin-block-end: 1.33em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
            font-weight: bold;
          }
          
          h5 {
            display: block;
            font-size: 0.83em;
            margin-block-start: 1.67em;
            margin-block-end: 1.67em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
            font-weight: bold;
          }
          
          h6 {
            display: block;
            font-size: 0.67em;
            margin-block-start: 2.33em;
            margin-block-end: 2.33em;
            margin-inline-start: 0px;
            margin-inline-end: 0px;
            font-weight: bold;
          }
          
          @font-face {
            font-family: 'AlibabaSans';
            src: url('http://localhost:8080/fonts/AlibabaSans-Regular.otf') format('opentype');
            font-weight: 400;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'AlibabaSans';
            src: url('http://localhost:8080/fonts/AlibabaSans-Bold.otf') format('opentype');
            font-weight: 700;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'AlibabaSans';
            src: url('http://localhost:8080/fonts/AlibabaSans-Light.otf') format('opentype');
            font-weight: 300;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'AlibabaSans';
            src: url('http://localhost:8080/fonts/AlibabaSans-Medium.otf') format('opentype');
            font-weight: 500;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'AlibabaSans';
            src: url('http://localhost:8080/fonts/AlibabaSans-Heavy.otf') format('opentype');
            font-weight: 900;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('http://localhost:8080/fonts/Alibaba-PuHuiTi-Regular.ttf') format('truetype');
            font-weight: 400;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('http://localhost:8080/fonts/Alibaba-PuHuiTi-Light.ttf') format('truetype');
            font-weight: 300;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('http://localhost:8080/fonts/Alibaba-PuHuiTi-Medium.ttf') format('truetype');
            font-weight: 500;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('http://localhost:8080/fonts/Alibaba-PuHuiTi-Bold.ttf') format('truetype');
            font-weight: 700;
            font-style: normal;
          }
          
          @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('http://localhost:8080/fonts/Alibaba-PuHuiTi-Heavy.ttf') format('truetype');
            font-weight: 900;
            font-style: normal;
          }
          
          /* Set Alibaba-PuHuiTi as default font */
          body {
            font-family: 'Alibaba-PuHuiTi', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          }
        `;
        document.head.appendChild(fontStyles);
      });

      // Wait for fonts to load
      await page.evaluateHandle(async () => {
        if ('fonts' in document) {
          // Wait for all fonts to be ready
          await document.fonts.ready;
          // Additional wait to ensure fonts are fully rendered
          await new Promise(resolve => setTimeout(resolve, 100));
        }
      });

      // Store test file path for snapshot naming
      (global as any).__testFilePath__ = testFile;
      
      // Set up snapshot handling
      await page.exposeFunction('__captureSnapshot__', async (testFullName: string, filename?: string, postfix?: boolean | string) => {
        const snapshots = testSnapshots.get(testFullName) || [];
        // Get or initialize per-spec counter
        const currentCount = specSnapshotCounters.get(testFullName) || 0;
        const newCount = currentCount + 1;
        specSnapshotCounters.set(testFullName, newCount);
        
        const snapshotPath = await this.captureSnapshotWithNaming(page, testFullName, filename, postfix, newCount);
        snapshots.push(snapshotPath);
        testSnapshots.set(testFullName, snapshots);
        return snapshotPath;
      });

      // Execute test and collect results
      const testResults = await page.evaluate(async (testCode: string, testName: string) => {
        console.log(`[Test] Executing ${testName}`);
        return new Promise<any[]>((resolve) => {
          const results: any[] = [];
          let currentTestName = '';
          
          // Override Jasmine's spec reporter
          (window as any).jasmineTestResults = results;
          (window as any).jasmineTestName = testName;
          
          // Create a custom Jasmine reporter
          const customReporter = {
            specStarted: (result: any) => {
              currentTestName = result.fullName;
              (window as any).__currentTestFullName__ = currentTestName;
            },
            specDone: (result: any) => {
              results.push({
                description: result.description,
                fullName: result.fullName,
                status: result.status,
                duration: result.duration,
                failedExpectations: result.failedExpectations,
                passedExpectations: result.passedExpectations
              });
            },
            jasmineDone: () => {
              resolve(results);
            }
          };

          // Initialize Jasmine
          const jasmine = (window as any).jasmine;
          const env = jasmine.getEnv();
          env.clearReporters();
          env.addReporter(customReporter);

          // Execute the test code
          try {
            eval(testCode);
            env.execute();
          } catch (error: any) {
            resolve([{
              description: 'Test execution error',
              fullName: testName,
              status: 'failed',
              failedExpectations: [{
                message: error.message,
                stack: error.stack
              }]
            }]);
          }
        });
      }, testContent, testName);

      // Process test results and capture snapshots
      for (const result of testResults) {
        const testResult: TestResult = {
          file: testFile,
          name: result.fullName || result.description,
          status: result.status,
          duration: result.duration || 0,
          error: result.failedExpectations?.[0]
        };

        // Add any snapshots captured during the test
        const snapshots = testSnapshots.get(result.fullName || result.description);
        if (snapshots && snapshots.length > 0) {
          testResult.snapshots = snapshots;
          testResult.snapshot = snapshots[0]; // Keep first snapshot for backward compatibility
        }

        results.push(testResult);

        // Log result
        const statusSymbol = testResult.status === 'passed' ? '✓' : 
                           testResult.status === 'failed' ? '✗' : '○';
        const statusColor = testResult.status === 'passed' ? chalk.green : 
                          testResult.status === 'failed' ? chalk.red : chalk.yellow;
        
        console.log(statusColor(`  ${statusSymbol} ${testResult.name}`));
        
        if (testResult.error) {
          console.log(chalk.red(`    ${testResult.error.message}`));
        }
      }

    } catch (error: any) {
      console.error(chalk.red(`Failed to run test file: ${testFile}`));
      console.error(error);
      
      results.push({
        file: testFile,
        name: path.basename(testFile),
        status: 'failed',
        duration: 0,
        error: {
          message: error.message,
          stack: error.stack
        }
      });
    } finally {
      await page.close();
    }

    return results;
  }

  private async injectTestRuntime(page: Page, testFile: string) {
    try {
      // First, try to inject Jasmine from local node_modules
      const jasminePath = require.resolve('jasmine-core/lib/jasmine-core/jasmine.js');
      const jasmineHtmlPath = require.resolve('jasmine-core/lib/jasmine-core/jasmine-html.js');
      const bootPath = require.resolve('jasmine-core/lib/jasmine-core/boot0.js');
      
      await page.addScriptTag({ path: jasminePath });
      await page.addScriptTag({ path: jasmineHtmlPath });
      await page.addScriptTag({ path: bootPath });
      
      // Wait for Jasmine to be available
      await page.waitForFunction(
        () => (window as any).jasmine !== undefined && (window as any).jasmine.getEnv !== undefined,
        { timeout: 5000 }
      );
      
      if (this.config.verbose) {
        console.log(chalk.gray('  ✓ Jasmine loaded successfully'));
      }
    } catch (error) {
      console.error(chalk.red('Failed to load Jasmine:'), error);
      throw error;
    }

    // Inject WebF mocks and runtime
    await page.evaluate((testFilePath: string) => {
      // Mock WebF APIs
      (window as any).webf = {
        methodChannel: {
          invokeMethod: async (method: string, ...args: any[]) => {
            console.log(`[MockWebF] ${method}(${JSON.stringify(args)})`);
            return Promise.resolve();
          }
        }
      };

      // Mock snapshot function that follows WebF conventions
      (window as any).snapshot = async (elementOrDelay?: any, filename?: string, postfix?: boolean | string) => {
        // Handle delay parameter
        if (typeof elementOrDelay === 'number') {
          await new Promise(resolve => setTimeout(resolve, elementOrDelay * 1000));
          elementOrDelay = null;
        }

        const target = elementOrDelay || document.body;
        const testFullName = (window as any).__currentTestFullName__ || 'unknown';
        
        console.log(`[Snapshot] Capturing for test: ${testFullName}`);
        
        // Use the exposed function to capture snapshot with proper naming
        if ((window as any).__captureSnapshot__) {
          await (window as any).__captureSnapshot__(testFullName, filename, postfix);
        }
        
        return Promise.resolve();
      };

      // Mock toBlob function for WebF compatibility
      // Since toBlob is not available in Chrome, we'll simulate it
      const toBlobImpl = async function(this: Element, quality: number = 1.0) {
        // Mark this element for snapshot
        this.setAttribute('data-snapshot-element', 'true');
        // Return a mock blob - in real WebF this would create an image
        return new Blob(['mock-image-data'], { type: 'image/png' });
      };

      // Add toBlob to Element prototype
      (Element.prototype as any).toBlob = toBlobImpl;
      (document.body as any).toBlob = toBlobImpl;
      (document.documentElement as any).toBlob = toBlobImpl;

      // Mock expectAsync with toMatchSnapshot
      (window as any).expectAsync = (actual: any) => {
        return {
          toMatchSnapshot: async (filename?: string, postfix?: boolean | string) => {
            // If actual is a Blob (from toBlob), trigger snapshot
            if (actual instanceof Blob || (actual && actual.then)) {
              const testFullName = (window as any).__currentTestFullName__ || 'unknown';
              console.log(`[Snapshot] toMatchSnapshot called for: ${testFullName}`);
              
              if ((window as any).__captureSnapshot__) {
                await (window as any).__captureSnapshot__(testFullName, filename, postfix);
              }
            }
            return Promise.resolve(true);
          }
        };
      };

      // Initialize Jasmine boot
      (window as any).jasmine.getEnv().configure({
        random: false,
        stopOnSpecFailure: false,
        stopSpecOnExpectationFailure: false
      });

      // Add global afterEach hook to clean up DOM between tests
      (window as any).afterEach(() => {
        // Clean up DOM after each test
        document.body.innerHTML = '';
        // Also clean any styles that might have been added to head (except chrome runner styles)
        const styles = document.head.querySelectorAll('style:not([data-chrome-runner])');
        styles.forEach(style => style.remove());
      });

      // Store test file path for snapshot naming
      (window as any).__testFilePath__ = testFilePath;
      if (typeof global !== 'undefined') {
        (global as any).__testFilePath__ = testFilePath;
      }

      // Mock WebF runtime imports that tests might use
      (window as any).sleep = (seconds: number) => new Promise(resolve => setTimeout(resolve, seconds * 1000));
      (window as any).requestAnimationFrame = window.requestAnimationFrame || ((cb: Function) => setTimeout(cb, 16));
      (window as any).assert_equals = (actual: any, expected: any, message?: string) => {
        expect(actual).toBe(expected);
      };
      (window as any).assert_true = (value: boolean, message?: string) => {
        expect(value).toBe(true);
      };
      (window as any).assert_false = (value: boolean, message?: string) => {
        expect(value).toBe(false);
      };
      (window as any).createElement = (tag: string, attrs?: any, children?: any[]) => {
        const el = document.createElement(tag);
        if (attrs) {
          Object.keys(attrs).forEach(key => {
            if (key === 'style' && typeof attrs[key] === 'object') {
              Object.assign(el.style, attrs[key]);
            } else if (key.startsWith('on') && typeof attrs[key] === 'function') {
              // Handle event handlers (onclick, onmousedown, etc.)
              const eventName = key.substring(2); // Remove 'on' prefix
              el.addEventListener(eventName, attrs[key]);
            } else {
              el.setAttribute(key, attrs[key]);
            }
          });
        }
        if (children) {
          children.forEach(child => {
            if (typeof child === 'string') {
              el.appendChild(document.createTextNode(child));
            } else {
              el.appendChild(child);
            }
          });
        }
        return el;
      };
      (window as any).createText = (content: string) => {
        return document.createTextNode(content);
      };
      
      // Add BODY global variable
      Object.defineProperty(window, 'BODY', {
        get() {
          return document.body;
        }
      });
      
      // Add simulateClick function for hit testing
      (window as any).simulateClick = async (x: number, y: number, target?: Element) => {
        // Use a small delay to ensure rendering is complete
        await new Promise(resolve => setTimeout(resolve, 10));
        
        const eventTarget = target || document.elementFromPoint(x, y);
        console.log(`simulateClick at (${x}, ${y}), found element:`, eventTarget?.tagName, eventTarget?.id || eventTarget?.className);
        
        if (eventTarget) {
          // Create mouse events for proper click simulation
          const mousedownEvent = new MouseEvent('mousedown', {
            bubbles: true,
            cancelable: true,
            view: window,
            clientX: x,
            clientY: y,
            screenX: x,
            screenY: y
          });
          
          const mouseupEvent = new MouseEvent('mouseup', {
            bubbles: true,
            cancelable: true,
            view: window,
            clientX: x,
            clientY: y,
            screenX: x,
            screenY: y
          });
          
          const clickEvent = new MouseEvent('click', {
            bubbles: true,
            cancelable: true,
            view: window,
            clientX: x,
            clientY: y,
            screenX: x,
            screenY: y
          });
          
          // Dispatch events in sequence
          eventTarget.dispatchEvent(mousedownEvent);
          eventTarget.dispatchEvent(mouseupEvent);
          eventTarget.dispatchEvent(clickEvent);
          
          // Give time for event handlers to process
          await new Promise(resolve => setTimeout(resolve, 10));
          
          return eventTarget;
        }
        return null;
      };
    }, testFile);
  }

  private async captureSnapshotWithNaming(
    page: Page, 
    testFullName: string, 
    filename?: string, 
    postfix?: boolean | string,
    counter: number = 1
  ): Promise<string> {
    // Generate MD5 hash of full test name (matching WebF's convention)
    const crypto = require('crypto');
    const md5Hash = crypto.createHash('md5').update(testFullName).digest('hex').slice(0, 8);
    
    // Build filename following WebF conventions
    let snapshotFilename: string;
    
    if (filename) {
      // If filename is provided, use it as base
      const postfixString = postfix === false ? '' : 
                           postfix ? String(postfix) : 
                           `${md5Hash}${counter}`;
      snapshotFilename = postfixString ? `${filename}.${postfixString}` : filename;
    } else {
      // Default naming: use the spec file path as prefix
      const testFilePath = (global as any)?.__testFilePath__ || 'test';
      
      // Calculate relative path from either chrome_runner/test or specs directory
      let relativePath: string;
      const chromeTestPath = path.join(process.cwd(), 'test');
      const specsPath = path.join(process.cwd(), '..', 'specs');
      
      if (testFilePath.startsWith(chromeTestPath)) {
        // For chrome_runner test files
        relativePath = path.relative(chromeTestPath, testFilePath);
      } else if (testFilePath.startsWith(specsPath)) {
        // For integration test spec files
        relativePath = path.relative(specsPath, testFilePath);
      } else {
        // Fallback
        relativePath = path.basename(testFilePath);
      }
      
      // Keep the extension in the path (matching WebF convention)
      const postfixString = `${md5Hash}${counter}`;
      snapshotFilename = `${relativePath}.${postfixString}`;
    }
    
    // Always add .png extension
    snapshotFilename += '.png';
    
    // Create subdirectories if needed
    const filepath = path.join(this.snapshotDir, snapshotFilename);
    const dirPath = path.dirname(filepath);
    await fs.ensureDir(dirPath);
    
    const finalPath = filepath;

    try {
      // Look for elements marked for snapshot
      // const snapshotElement = await page.$('[data-snapshot-element="true"]');
      
      // if (snapshotElement) {
      //   // Capture specific element
      //   await snapshotElement.screenshot({
      //     path: filepath,
      //     type: 'png'
      //   });
        
      //   // Remove snapshot marker
      //   await page.evaluate(el => el.removeAttribute('data-snapshot-element'), snapshotElement);
      // } else {
        
      // }
      // Wait a bit for any animations or rendering to complete
      await page.waitForTimeout(50);
      
      // Capture full page
      await page.screenshot({
        path: filepath,
        fullPage: true,
        type: 'png'
      });

      if (this.config.verbose) {
        console.log(chalk.gray(`  📸 Snapshot saved: ${snapshotFilename}`));
      }

      return finalPath;
    } catch (error: any) {
      console.error(chalk.yellow(`Failed to capture snapshot: ${error.message}`));
      return '';
    }
  }

  private async captureSnapshot(page: Page, testResult: TestResult): Promise<string> {
    // Legacy method for backward compatibility
    return this.captureSnapshotWithNaming(page, testResult.name);
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log(chalk.green('✓ Browser closed'));
    }
    
    if (this.fileServer) {
      await new Promise<void>((resolve) => {
        this.fileServer!.close(() => {
          console.log(chalk.green('✓ File server stopped'));
          resolve();
        });
      });
    }
  }

  getResults(): TestResult[] {
    return this.results;
  }

  printSummary() {
    const passed = this.results.filter(r => r.status === 'passed').length;
    const failed = this.results.filter(r => r.status === 'failed').length;
    const skipped = this.results.filter(r => r.status === 'pending' || r.status === 'disabled').length;
    const total = this.results.length;

    console.log('\n' + chalk.bold('Test Summary:'));
    console.log(chalk.green(`  ✓ Passed: ${passed}`));
    if (failed > 0) {
      console.log(chalk.red(`  ✗ Failed: ${failed}`));
    }
    if (skipped > 0) {
      console.log(chalk.yellow(`  ○ Skipped: ${skipped}`));
    }
    console.log(chalk.blue(`  Total: ${total}`));

    // List failures
    if (failed > 0) {
      console.log('\n' + chalk.red('Failed Tests:'));
      this.results
        .filter(r => r.status === 'failed')
        .forEach(r => {
          console.log(chalk.red(`  • ${r.name}`));
          if (r.error) {
            console.log(chalk.gray(`    ${r.error.message}`));
          }
        });
    }
  }
}