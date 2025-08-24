#!/usr/bin/env node

// Simple test runner to debug the issue
import puppeteer from 'puppeteer';
import path from 'path';
import fs from 'fs-extra';

async function runSimpleTest() {
  console.log('Starting simple test runner...');
  
  const browser = await puppeteer.launch({
    headless: false,
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });
  
  console.log('Browser launched');
  
  const page = await browser.newPage();
  console.log('New page created');
  
  // Navigate to a blank page
  await page.goto('about:blank');
  console.log('Navigated to blank page');
  
  // Inject Jasmine
  const jasminePath = require.resolve('jasmine-core/lib/jasmine-core/jasmine.js');
  const jasmineContent = await fs.readFile(jasminePath, 'utf-8');
  
  await page.evaluate((jasmineCode) => {
    const script = document.createElement('script');
    script.textContent = jasmineCode;
    document.head.appendChild(script);
  }, jasmineContent);
  
  console.log('Jasmine injected');
  
  // Check if Jasmine is available
  const hasJasmine = await page.evaluate(() => {
    return typeof (window as any).jasmine !== 'undefined';
  });
  
  console.log('Jasmine available:', hasJasmine);
  
  // Run a simple test
  const testResult = await page.evaluate(() => {
    const jasmine = (window as any).jasmine;
    const env = jasmine.getEnv();
    
    describe('Simple Test', () => {
      it('should work', () => {
        expect(1 + 1).toBe(2);
      });
    });
    
    return new Promise((resolve) => {
      env.addReporter({
        jasmineDone: (result: any) => {
          resolve(result);
        }
      });
      
      env.execute();
    });
  });
  
  console.log('Test result:', testResult);
  
  await browser.close();
}

runSimpleTest().catch(console.error);