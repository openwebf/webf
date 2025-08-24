# WebF Integration Testing Guide

This guide covers integration testing in the `integration_tests/` directory.

## Test Structure

### Directory Layout
```
integration_tests/
├── specs/
│   ├── css/
│   │   ├── css-display/
│   │   ├── css-position/
│   │   └── css-text/
│   ├── dom/
│   │   ├── elements/
│   │   ├── events/
│   │   └── nodes/
│   └── window/
├── assets/              # Test assets (images, files)
├── tools/               # Test utilities
└── tsconfig.json
```

### Test File Format
```typescript
describe('Feature Category', () => {
  it('should behave correctly', async (done) => {
    const element = document.createElement('div');
    element.style.width = '100px';
    document.body.appendChild(element);
    
    await snapshot();  // Visual regression test
    
    expect(element.offsetWidth).toBe(100);
    done();
  });
});
```

## Writing Tests

### Async Tests
```typescript
it('should load image', async (done) => {
  const img = document.createElement('img');
  img.onload = () => {
    expect(img.complete).toBe(true);
    done();
  };
  img.src = 'assets/test-image.png';
  document.body.appendChild(img);
});
```

### Snapshot Tests
```typescript
it('should render correctly', async () => {
  const container = document.createElement('div');
  container.innerHTML = `
    <div style="width: 200px; height: 100px; background: red;">
      <span style="color: white;">Test Content</span>
    </div>
  `;
  document.body.appendChild(container);
  
  await snapshot();  // Captures visual snapshot
});
```

## Running Tests

### Command Line
```bash
# Run all integration tests
cd integration_tests && npm run integration

# Run specific test file
npm run integration -- specs/css/css-display/display.ts

# Run the filtered test specs
npm run integration -- --filter <filter string>
```

### Snapshot Viewer
```bash
# View failed snapshots interactively
npm run snapshot-viewer

# View with custom port
npm run snapshot-viewer -- --port 4000

# View specific snapshot directory
npm run snapshot-viewer -- --dir ./custom-snapshots
```

### Test Helpers

#### Custom Matchers
```typescript
expect.extend({
  toHaveComputedStyle(element, property, value) {
    const actual = getComputedStyle(element)[property];
    return {
      pass: actual === value,
      message: () => `Expected ${property} to be ${value}, got ${actual}`
    };
  }
});
```

#### Utility Functions
```typescript
// Wait for next frame
function nextFrame(): Promise<void> {
  return new Promise(resolve => requestAnimationFrame(resolve));
}

// Wait for element to be visible
async function waitForVisible(element: Element): Promise<void> {
  while (getComputedStyle(element).display === 'none') {
    await nextFrame();
  }
}
```

## Test Guidelines

### Integration Tests (integration_tests/specs)
- Place tests in appropriate directories under `specs/`
- Use TypeScript (.ts extension)
- Use `done()` callback for async tests
- Use `snapshot()` for visual regression tests
  - this function will always success if there are no local snapshot file found.
- Use `simulateClick` with corrdinates for hit testing tests
- Test assets should reference files in `assets/` directory
- Use `fdescribe()` instead of `describe()` to run only specific test specs (Jasmine feature)
- Use `fit()` instead of `it()` to run only specific test cases

### Common Patterns

#### CSS Variable Display None Fix
Fix for CSS variables in display:none elements.

##### Problem
CSS variables (custom properties) on elements with `display: none` were not being resolved correctly, causing JavaScript calls to `getComputedStyle()` to return empty strings instead of the actual variable values.

##### Test Case
```typescript
it('should resolve CSS variables in display:none elements', async () => {
  const div = document.createElement('div');
  div.style.setProperty('--primary-color', '#007bff');
  div.style.display = 'none';
  document.body.appendChild(div);
  
  const computedStyle = getComputedStyle(div);
  const primaryColor = computedStyle.getPropertyValue('--primary-color');
  
  expect(primaryColor).toBe('#007bff'); // Should not be empty
});
```

#### WebF Text Element Update Fix
Fix for text element update issues.

##### Problem
Text nodes were not updating properly when their content changed dynamically, especially in cases involving:
- Direct textContent updates
- Text node data modifications
- Mixed content updates (text + elements)

##### Test Case
```typescript
it('should update text content dynamically', async () => {
  const div = document.createElement('div');
  const textNode = document.createTextNode('Initial');
  div.appendChild(textNode);
  document.body.appendChild(div);
  
  await snapshot();  // Snapshot 1: "Initial"
  
  textNode.data = 'Updated';
  await snapshot();  // Snapshot 2: "Updated"
  
  div.textContent = 'Replaced';
  await snapshot();  // Snapshot 3: "Replaced"
});
```

### Visual Regression Testing
- Use `await snapshot()` to capture the current rendering
- Snapshots are stored as images for comparison
- Failed snapshots generate diff images
- The max width of testing window is 340px
- Test specs will always pass if there are no existing snapshots
- If the test specs are works as expected, should add the snapshot file to the Git.

### Performance Testing
- Measure operations in performance-critical tests
- Use `performance.now()` for timing
- Consider multiple runs for consistency

### Error Testing
```typescript
it('should handle errors gracefully', async () => {
  const element = document.createElement('div');
  
  expect(() => {
    element.style.width = 'invalid';
  }).toThrow();
});
```

## Best Practices

1. **Test Organization**: Group related tests in describe blocks
2. **Test Independence**: Each test should be independent
3. **Cleanup**: Remove created elements after tests
4. **Descriptive Names**: Use clear, descriptive test names
5. **Focus on Behavior**: Test behavior, not implementation
6. **Edge Cases**: Include edge cases and error conditions

## Debugging Failed Tests

1. **Check Console Output**: Look for error messages
2. **Inspect Snapshots**: Compare actual vs expected images
3. **Add Logging**: Use `console.log` for debugging
4. **Isolate Tests**: Use `fit()` to run single test
5. **Check Assets**: Ensure test assets are available

## Test Coverage Areas

### CSS Tests
- Display properties
- Positioning and layout
- Text rendering
- Box model
- Flexbox/Grid
- Animations/Transitions

### DOM Tests
- Element creation/removal
- Attribute manipulation
- Event handling
- Node relationships
- Document methods

### Window/Global Tests
- Window properties
- Global methods
- Navigation
- Storage APIs
- Timers

## Performance Considerations

1. **Batch DOM Operations**: Minimize reflows
2. **Reuse Elements**: When appropriate
3. **Async Operations**: Use proper async patterns
4. **Resource Loading**: Test with realistic assets
5. **Memory Cleanup**: Prevent memory leaks