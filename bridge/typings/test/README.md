# WebF Typings Tests

This directory contains comprehensive tests for the WebF TypeScript typings.

## Test Files

- **`global-webf-api.test.ts`** - Tests for the global `webf` object and its APIs
- **`dom-bom-typings.test.ts`** - Tests for DOM and BOM (Browser Object Model) typings
- **`module-import.test.ts`** - Tests for ES module imports of WebF types

## Running Tests

From the typings directory:

```bash
# Install dependencies
npm install

# Run all tests
npm test

# Or compile tests without the test runner
npm run test:compile
```

## What the Tests Verify

### Global WebF API Tests
- `webf` global object availability
- Method channel communication
- Module invocation (sync and async)
- Hybrid history navigation
- Module event listeners
- Idle callback scheduling

### DOM/BOM Typings Tests
- Document manipulation
- Element creation and properties
- Event handling
- Canvas API
- Fetch API
- Storage APIs (localStorage, sessionStorage, asyncStorage)
- URL and URLSearchParams
- WebSocket
- XMLHttpRequest
- ResizeObserver and MutationObserver
- Performance API
- And many more browser APIs

### Module Import Tests
- ES module imports work correctly
- Named exports are properly typed
- Type-only imports compile correctly
- All exported types are accessible

## Writing New Tests

When adding new typings, make sure to:

1. Add test cases to the appropriate test file
2. Test both global access and module imports
3. Verify type inference works correctly
4. Check that invalid usage produces type errors

Example test pattern:

```typescript
// Test basic usage
const element: HTMLElement = document.createElement('div');

// Test type inference
const inferred = document.querySelector('.class'); // Should infer Element | null

// Test method signatures
element.addEventListener('click', (e: MouseEvent) => {
  console.log(e.clientX); // Should have MouseEvent properties
});
```

## Troubleshooting

If tests fail:

1. Check that `webf.d.ts` and `polyfill.d.ts` are generated correctly
2. Ensure TypeScript version is compatible (5.0+)
3. Verify that the `index.d.ts` properly references both type files
4. Look at the specific error messages for type mismatches