# WebF Integration Testing Guide

## Overview
WebF uses integration tests to verify browser behavior and ensure compatibility with web standards. These tests are located in the `/integration_tests` directory.

## Test Structure

### Directory Layout
```
integration_tests/
├── specs/              # Test specifications
│   ├── css/           # CSS-related tests
│   ├── dom/           # DOM API tests
│   ├── html/          # HTML element tests
│   └── ...
├── snapshots/         # Visual regression snapshots
├── lib/               # Test framework code
└── package.json       # NPM scripts and dependencies
```

## Writing Integration Tests

### Basic Test Structure
```typescript
describe('Feature Name', () => {
  it('should behave as expected', async () => {
    // Setup DOM
    const element = createElement('div', {
      style: {
        width: '100px',
        height: '100px'
      }
    });
    
    BODY.appendChild(element);
    
    // Perform actions
    // ...
    
    // Take snapshot for visual comparison
    await snapshot();
    
    // Make assertions
    expect(element.style.width).toBe('100px');
  });
});
```

### Common Test Utilities

1. **DOM Creation:**
   ```typescript
   createElement(tagName, props, children)
   createText(content)
   ```

2. **Event Simulation:**
   ```typescript
   simulateClick(x, y)
   simulatePointer(events, pointerId)
   simulateInputText(text)
   ```

3. **Platform Features:**
   ```typescript
   simulateChangeDarkMode(isDarkMode: boolean)  // Toggle dark/light mode
   ```

4. **Style Inspection:**
   ```typescript
   getComputedStyle(element)  // Get resolved styles including CSS variables
   ```

5. **Visual Testing:**
   ```typescript
   await snapshot()  // Takes a screenshot for comparison
   ```

## Running Tests

### Run All Tests
```bash
cd integration_tests
npm run integration
```

### Run Specific Tests (Faster)
1. Use `fdescribe()` to focus on specific test suites:
   ```typescript
   fdescribe('MediaQuery prefers-color-scheme', () => {
     // Only these tests will run
   });
   ```

2. Use `fit()` to focus on specific test cases:
   ```typescript
   fit('should update CSS variables', async () => {
     // Only this test will run
   });
   ```

3. Run the tests:
   ```bash
   npm run integration
   ```

### Test Output
- **Green [PASS]**: Test passed
- **Red [FAIL]**: Test failed
- Snapshots are saved in `/integration_tests/snapshots/`

## Best Practices

### 1. Test Isolation
Each test should be independent and not rely on state from other tests:
```typescript
it('test case', async () => {
  // Setup everything needed for this test
  // Don't assume any global state
});
```

### 2. Cleanup
While tests run in isolation, it's good practice to clean up:
```typescript
it('test case', async () => {
  const element = createElement('div');
  BODY.appendChild(element);
  
  // Test logic...
  
  // Cleanup (optional, but good practice)
  element.remove();
});
```

### 3. Async Operations
Always use `async/await` for asynchronous operations:
```typescript
it('async test', async () => {
  const img = createElement('img');
  img.src = 'test.png';
  
  // Wait for image to load
  await img.decode();
  
  await snapshot();
});
```

### 4. Visual Regression
Use `await snapshot()` to catch visual regressions:
```typescript
it('visual test', async () => {
  // Setup UI
  const container = createElement('div', {
    style: {
      width: '200px',
      height: '100px',
      backgroundColor: 'red'
    }
  });
  
  BODY.appendChild(container);
  
  // Take snapshot
  await snapshot();
});
```

## Debugging Tests

### 1. Console Logging
Use `console.log()` to debug values:
```typescript
const computedStyle = getComputedStyle(element);
console.log('Background color:', computedStyle.backgroundColor);
```

### 2. Step-by-Step Snapshots
Take multiple snapshots to see progression:
```typescript
await snapshot(); // Initial state

element.style.display = 'none';
await snapshot(); // After hiding

element.style.display = 'block';
await snapshot(); // After showing
```

### 3. Check Computed Styles
Verify that styles are applied correctly:
```typescript
const styles = getComputedStyle(element);
console.log('Width:', styles.width);
console.log('CSS Variable:', styles.getPropertyValue('--my-var'));
```

## Common Patterns

### Testing CSS Variables
```typescript
it('should update CSS variables', async () => {
  const style = document.createElement('style');
  style.innerHTML = `
    :root { --color: red; }
    .test { color: var(--color); }
  `;
  document.head.appendChild(style);
  
  const element = createElement('div', { className: 'test' });
  BODY.appendChild(element);
  
  const computed = getComputedStyle(element);
  expect(computed.color).toBe('rgb(255, 0, 0)');
});
```

### Testing Media Queries
```typescript
it('should respond to media queries', async () => {
  const style = document.createElement('style');
  style.innerHTML = `
    @media (prefers-color-scheme: dark) {
      body { background: black; }
    }
  `;
  document.head.appendChild(style);
  
  simulateChangeDarkMode(true);
  
  const computed = getComputedStyle(document.body);
  expect(computed.backgroundColor).toBe('rgb(0, 0, 0)');
});
```

### Testing Visibility Changes
```typescript
it('should handle visibility changes', async () => {
  const element = createElement('div', {
    style: { display: 'none' }
  });
  
  BODY.appendChild(element);
  
  // Test while hidden
  let computed = getComputedStyle(element);
  console.log('Hidden state:', computed.display);
  
  // Show element
  element.style.display = 'block';
  
  // Test while visible
  computed = getComputedStyle(element);
  console.log('Visible state:', computed.display);
  
  await snapshot();
});
```

## Tips for Faster Development

1. **Use `fdescribe`/`fit` liberally** - Don't run all 6000+ tests when debugging
2. **Run tests locally first** - `npm run integration` before pushing
3. **Check existing tests** - Look for similar tests to understand patterns
4. **Start simple** - Write minimal test first, then add complexity
5. **Use snapshots** - Visual verification catches many issues