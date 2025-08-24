const puppeteer = require('puppeteer');

(async () => {
  try {
    console.log('Launching browser...');
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox']
    });
    
    console.log('Creating page...');
    const page = await browser.newPage();
    
    console.log('Going to example.com...');
    await page.goto('https://example.com');
    
    console.log('Getting title...');
    const title = await page.title();
    console.log('Page title:', title);
    
    console.log('Closing browser...');
    await browser.close();
    
    console.log('Success!');
  } catch (error) {
    console.error('Error:', error);
  }
})();