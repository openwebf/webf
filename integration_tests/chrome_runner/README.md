# WebF Chrome Test Runner

A Node.js-driven test runner that executes WebF integration tests in isolated headless Chrome instances with automatic screenshot capture.

## Architecture

Unlike traditional browser-based test runners, this runner:
- **Node.js orchestration**: Tests are managed and executed from Node.js using Puppeteer
- **Isolated Chrome instances**: Each test file runs in a separate browser page for true isolation
- **Automatic screenshots**: Captures PNG images of rendering results after each test
- **Headless execution**: Tests run in headless Chrome by default for CI/CD compatibility
- **No DOM pollution**: Complete DOM reset between tests ensures clean test environments

## Quick Start

1. **Install Dependencies**
   ```bash
   cd integration_tests/chrome_runner
   npm install
   ```

2. **Build TypeScript**
   ```bash
   npm run build
   ```

3. **Run Tests**
   ```bash
   # Run CSS text tests (default scope)
   npm test
   
   # Run specific test scope
   npm run test:css-text
   npm run test:dom-core
   npm run test:css-layout
   npm run test:all
   
   # Run in headed mode with DevTools
   npm run test:headed
   
   # Filter tests
   npm test -- --filter="color_relative"
   ```

## Test Scopes

The Chrome runner supports multiple predefined test scopes:

### CSS & Styling Tests
- **`css-text`**: CSS text and typography tests
  - Text baseline selection
  - Locale support
  - Color relative properties
  - Text effects and gradients

- **`css-layout`**: Layout-related tests
  - Flexbox layout
  - CSS positioning
  - Box model and sizing

- **`css-visual`**: Visual effects tests
  - Backgrounds and borders
  - CSS transforms
  - Filter effects

### DOM & Browser APIs
- **`dom-core`**: Core DOM functionality
  - DOM events
  - Element manipulation
  - Node operations

- **`browser-apis`**: Browser API tests
  - Fetch API
  - Storage APIs
  - URL handling
  - XMLHttpRequest

### Comprehensive Testing
- **`rendering`**: Rendering and performance tests
- **`all`**: All available test specifications

## Configuration

### Test Scope Configuration (`config.json5`)

```json5
{
  "testScopes": {
    "css-text": {
      "description": "CSS Text and Typography tests",
      "groups": ["TextAndColorAndFilterEffect"],
      "include": [
        "specs/css/css_*_test.{js,jsx,ts,tsx}",
        "specs/css/css-text/**/*.{js,jsx,ts,tsx,html}"
      ],
      "exclude": []
    }
  },
  "defaultScope": "css-text",
  "browser": {
    "headless": false,
    "devtools": true,
    "viewport": { "width": 1200, "height": 800 }
  }
}
```

### Environment Variables

```bash
# Set test scope
TEST_SCOPE=css-layout npm run test

# Filter specific test files
WEBF_TEST_FILTER="baseline|locale" npm run test

# Production build
NODE_ENV=production npm run build
```

## CLI Options

- `--scope, -s`: Test scope to run (default: css-text)
- `--headless, -h`: Run in headless mode (default: true)
- `--devtools, -d`: Open Chrome DevTools (default: false)
- `--parallel, -p`: Run tests in parallel (default: false)
- `--verbose, -v`: Verbose output (default: false)
- `--filter, -f`: Filter test files by pattern
- `--snapshots`: Enable snapshot capture (default: true)
- `--update-snapshots`: Update baseline snapshots
- `--list-scopes`: List available test scopes
- `--help`: Show help

```bash
# List available test scopes
npm run list-scopes

# Run with verbose output
npm test -- --verbose

# Run tests in parallel
npm test -- --parallel
```

## Usage Examples

### 1. CSS Text Feature Testing
```bash
# Test all CSS text-related features
npm run test:css-text

# Test only baseline-related specs
npm run test -- --scope=css-text --filter=baseline

# Watch CSS text tests during development
npm run test:css-text -- --watch
```

### 2. Cross-Browser Testing
```bash
# Test DOM core functionality
npm run test:dom-core

# Test browser APIs compatibility
npm run test -- --scope=browser-apis
```

### 3. Comprehensive Testing
```bash
# Run all tests
npm run test:all

# Run all tests with custom filter
npm run test:all -- --filter="text|color"
```

## Browser Environment

The Chrome test runner provides:

### WebF API Mocking
- Mock implementations of WebF-specific APIs
- Pointer event simulation
- Method channel simulation
- DOM extensions (toBlob, etc.)

### Test Utilities
- Snapshot testing support
- Performance measurement
- Console output capture
- Live reload for development

### Browser DevTools Integration
- Full Chrome DevTools support
- JavaScript debugging
- Network monitoring
- Performance profiling

## Test Development

### Writing Tests
Tests are written using standard Jasmine syntax and WebF test utilities:

```typescript
describe('CSS Text Features', () => {
  it('should apply correct text baseline for CJK languages', (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'zh-CN');
    container.innerHTML = '<p>中文文本</p>';
    document.body.appendChild(container);

    requestAnimationFrame(() => {
      const p = container.querySelector('p');
      expect(p.getBoundingClientRect().height).toBeGreaterThan(0);
      
      snapshot(); // Take visual snapshot
      document.body.removeChild(container);
      done();
    });
  });
});
```

### Available Test Utilities
All utilities from `integration_tests/runtime/global.ts` are available:

- `snapshot()`: Visual regression testing
- `sleep(seconds)`: Async delays
- `simulateClick(x, y)`: Pointer simulation
- `createElement()`: DOM creation helpers
- `setElementStyle()`: Style utilities
- Test assertions: `assert_equals`, `assert_true`, etc.

## Snapshot Testing

The Chrome runner provides comprehensive snapshot testing capabilities:

### Taking Snapshots

```typescript
// Basic snapshot of the body
await snapshot();

// Snapshot with delay (in seconds)
await snapshot(0.5);

// Snapshot of specific element
const element = document.getElementById('my-element');
await snapshot(element);

// Snapshot with custom filename
await snapshot(null, 'my-custom-snapshot');

// Snapshot with timestamp postfix
await snapshot(null, 'test-snapshot', true);
```

### Snapshot Storage

- Snapshots are saved to `chrome_runner/snapshots/<test-scope>/`
- Each test scope has its own subdirectory
- Files are named using the test name and a counter
- Images are saved as PNG files with html2canvas

### Viewing Snapshots

1. **During Testing**: Click the "📸 View Snapshots" button in the test UI
2. **Snapshot Gallery**: Browse all captured snapshots in a grid view
3. **Full Screen View**: Click any snapshot to view it full screen
4. **File Access**: Snapshots are also accessible at `http://localhost:8080/snapshots/`

### Snapshot API

The test server provides several endpoints:

- `POST /api/snapshot`: Upload a new snapshot
- `GET /api/snapshots`: List all snapshots for current scope
- `GET /snapshots/<path>`: Serve snapshot images

### Example with CSS Text Tests

```typescript
it('should apply correct text baseline for Chinese text', async (done) => {
  const container = document.createElement('div');
  container.setAttribute('lang', 'zh-CN');
  container.innerHTML = '<p style="font-size: 24px;">中文文本测试</p>';
  document.body.appendChild(container);

  await sleep(0.1);
  
  // Capture snapshot of the rendered Chinese text
  await snapshot();
  
  // Capture snapshot of just the container
  await snapshot(container, 'chinese-text-baseline');
  
  document.body.removeChild(container);
  done();
});

## Test Execution Flow

1. **Node.js CLI** loads test configuration and finds test files
2. **Puppeteer** launches Chrome browser (headless or headed)
3. **For each test file**:
   - Create new isolated browser page
   - Inject Jasmine test framework
   - Inject WebF API mocks
   - Execute test specs
   - Capture screenshots for each test
   - Collect test results
4. **Report generation** with results and snapshot paths
5. **Cleanup** browser instances

## Output

- **Console**: Real-time test execution with colored output
- **Screenshots**: Saved to `__expected__/{scope}/` following WebF naming conventions
- **JSON Report**: Detailed results in `test-report.json`

## Snapshot API

The Chrome runner provides a snapshot API that follows the same conventions as WebF's `toMatchSnapshot`:

### Basic Usage

```typescript
// Capture snapshot of the entire page
await snapshot();

// Capture snapshot with delay (in seconds)
await snapshot(0.5);

// Capture snapshot of specific element
const element = document.getElementById('my-element');
await snapshot(element);

// Capture snapshot with custom filename
await snapshot(null, 'my_custom_name');

// Capture snapshot with timestamp postfix
await snapshot(null, 'test_snapshot', true);

// Capture snapshot with custom postfix
await snapshot(null, 'test_snapshot', 'v2');
```

### Using toMatchSnapshot

```typescript
// Capture element using toBlob and toMatchSnapshot
const element = document.querySelector('.my-component');
await expectAsync(element.toBlob(1.0)).toMatchSnapshot('component_snapshot');

// With postfix
await expectAsync(document.body.toBlob()).toMatchSnapshot('body', true);
```

### Snapshot Naming Convention

Following WebF's `toMatchSnapshot` rules:
1. Test names are sanitized (non-alphanumeric chars become underscores)
2. Default format: `{sanitized_test_name}_{counter}.png`
3. Custom filename: `{custom_name}.png`
4. With timestamp postfix: `{name}_{timestamp}.png`
5. With string postfix: `{name}_{postfix}.png`

### Output Directory

All snapshots are saved in `__expected__/{scope}/` directory:
- `__expected__/css-text/` for CSS text tests
- `__expected__/dom-core/` for DOM tests
- etc.

## Integration with CI/CD

### Headless Mode
Tests run in headless mode by default, making them perfect for CI/CD pipelines:

```bash
# Run tests in CI
npm test

# Check exit code
echo $?  # 0 for success, 1 for failures
```

### Test Report
The JSON report (`test-report.json`) contains:
- Test results (passed/failed/skipped)
- Execution duration
- Error details
- Screenshot paths

## Architecture

### Directory Structure
```
chrome_runner/
├── src/                    # TypeScript source files
│   ├── cli.ts             # CLI interface
│   ├── test-runner.ts     # Main test orchestrator
│   └── types.ts           # TypeScript definitions
├── lib/                    # Compiled JavaScript (generated)
├── snapshots/              # Test screenshots (generated)
│   └── {scope}/           # Scope-specific snapshots
├── config.json5            # Test scope configuration
├── tsconfig.json          # TypeScript configuration
└── package.json           # Dependencies and scripts
```

### Key Components

1. **CLI (cli.ts)**
   - Parses command line arguments
   - Loads test configuration
   - Discovers test files based on scope
   - Initiates test execution

2. **Test Runner (test-runner.ts)**
   - Manages Puppeteer browser instances
   - Executes tests in isolated pages
   - Captures screenshots
   - Collects and reports results

3. **Types (types.ts)**
   - TypeScript interfaces for configuration
   - Test result structures
   - Report formats

## Troubleshooting

### Common Issues

1. **Tests not loading**
   ```bash
   # Check if specs are found
   npm run build
   # Look for webpack output showing included files
   ```

2. **WebF APIs not working**
   - Check browser console for mock API messages
   - Verify chrome-runtime.ts is loaded

3. **Build failures**
   ```bash
   # Clean and rebuild
   npm run clean
   npm install
   npm run build
   ```

### Debug Mode
```bash
# Enable verbose logging
DEBUG=1 npm run test

# Use browser DevTools
npm run test -- --no-build
# Then open http://localhost:8080 with DevTools
```

## Contributing

To add new test scopes or enhance the runner:

1. Update `config.json5` with new scope definitions
2. Modify `webpack.config.js` if needed for new file patterns
3. Enhance `chrome-runtime.ts` for additional WebF API mocking
4. Update this README with new features

## Advantages of Node.js-Driven Architecture

### Test Isolation
- Each test file runs in a completely fresh browser context
- No DOM state pollution between tests
- Automatic cleanup after each test
- True parallel execution capability

### Automation Benefits
- Headless execution by default for CI/CD
- Automatic screenshot capture
- Structured JSON reports
- Exit codes for build systems

### Development Features
- Run tests in headed mode with `--no-headless`
- Open DevTools with `--devtools`
- Filter tests with `--filter`
- Verbose logging with `--verbose`

## Troubleshooting

### Common Issues

1. **Chrome download fails**
   ```bash
   # Puppeteer will download Chrome on first run
   # If it fails, try:
   PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install
   ```

2. **Tests timeout**
   ```bash
   # Increase timeout in config.json5
   "testRunner": {
     "timeout": 60000  // 60 seconds
   }
   ```

3. **Screenshot capture fails**
   - Check disk space in snapshots directory
   - Verify write permissions
   - Try disabling with `--no-snapshots`