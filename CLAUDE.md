# WebF Development Guide

## Repository Structure
- `bridge/`: C++ code providing JavaScript runtime and DOM API implementations, HTML parsing
- `webf/`: Dart code implementing DOM/CSS and layout/painting on top of Flutter
- `integration_tests/`: Integration tests (most test cases in integration_tests/specs)

## Search and Navigation Strategy
- When searching for implementations:
  - Start with `Grep` for specific function/class names
  - Use `Glob` for file patterns when you know the structure
  - Batch related searches in parallel when possible
- For cross-language features:
  - Search both C++ (.cc/.h) and Dart (.dart) files
  - Look for FFI bindings in bridge.dart and related files
  - Check for typedef patterns to understand the API flow
- Example search patterns:
  - Function usage: `FunctionName\(`
  - Class definition: `class ClassName`
  - FFI exports: `WEBF_EXPORT_C`

## Build Commands
- Build for macOS: `npm run build:bridge:macos` (debug) or `npm run build:bridge:macos:release` (release)
- Build for iOS: `npm run build:bridge:ios` (debug) or `npm run build:bridge:ios:release` (release)
- Build for Android: `npm run build:bridge:android` (debug) or `npm run build:bridge:android:release` (release)
- Clean build: `npm run build:clean`
- Run example: `npm run start` (flutter run in webf/example)

### Build Error Resolution
- When encountering build errors:
  - Read the full error message to identify the specific issue (missing includes, type mismatches, undefined symbols)
  - For C++ errors, check:
    - Missing header includes
    - Namespace qualifications
    - Template instantiation issues
    - FFI type compatibility (Handle vs Dart_Handle)
  - Build incrementally after each fix
  - Use `npm run build:bridge:macos` for quick iteration on macOS
- Common C++ build issues:
  - `Handle` should be `Dart_Handle` in FFI contexts
  - Lambda signatures must match expected function signatures
  - Include necessary headers for all used types

## Test Commands
- Run all tests: `npm run test` (includes bridge, Flutter, and integration tests)
- Run bridge unit tests: `node scripts/run_bridge_unit_test.js`
- Run Flutter dart tests: `cd webf && flutter test`
- Run a single Flutter test: `cd webf && flutter test test/path/to/test_file.dart`
- Run integration tests: `cd integration_tests && npm run integration`

## Lint Commands

- Lint: `npm run lint` (runs flutter analyze in webf directory)
- Format: `npm run format` (formats with 120 char line length)

## Code Style Guidelines

### Dart (webf/)
- Follow rules in webf/analysis_options.yaml
- Use single quotes for strings
- File names must use snake_case
- Class names must use PascalCase
- Variables/functions use camelCase
- Prefer final fields when applicable
- Lines should be max 120 characters

### C++ (bridge/)
- Based on Chromium style (.clang-format)
- Standard: C++17
- Column limit: 120 characters
- Use 2-space indentation

### Memory Management in FFI
- Always free allocated memory in Dart FFI:
  - Use `malloc.free()` for `toNativeUtf8()` allocations
  - Free in `finally` blocks to ensure cleanup on exceptions
  - Track ownership of allocated pointers in callbacks
- For async callbacks:
  - Consider when to free memory (in callback or after future completes)
  - Document memory ownership clearly
  - Use RAII patterns in C++ where possible
- Native value handling:
  - Free NativeValue pointers after converting with `fromNativeValue`
  - Be careful with pointer lifetime across thread boundaries
- **Dart Handle Persistence**:
  - For async operations, use `Dart_NewPersistentHandle_DL` to keep Dart objects alive
  - Convert back with `Dart_HandleFromPersistent_DL` before use
  - Always call `Dart_DeletePersistentHandle_DL` after the async operation completes
  - Example pattern:
    ```cpp
    Dart_PersistentHandle persistent = Dart_NewPersistentHandle_DL(dart_handle);
    // ... async operation ...
    Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent);
    callback(handle, result);
    Dart_DeletePersistentHandle_DL(persistent);
    ```

## Cross-Language Integration Patterns

### C++ to Dart FFI
- Function naming conventions:
  - C++ exports: `GetObjectPropertiesFromDart`
  - Dart typedefs: `NativeGetObjectPropertiesFunc`
  - Dart functions: `GetObjectPropertiesFunc`
- Async callback patterns:
  - Use `Dart_Handle` for object handles
  - Pass callbacks as function pointers
  - Return results via callback, not return value
- String handling:
  - Copy strings that might be freed: `std::string(const_char_ptr)`
  - Use `toNativeUtf8()` and remember to free

### TypeScript Type Handling in Analyzer
When implementing TypeScript analysis:
- `null` can appear as both `NullKeyword` in basic types and as a `LiteralType` containing `NullKeyword`
- Always check for literal types: `if (type.kind === ts.SyntaxKind.LiteralType)`
- Handle null literals specifically:
  ```typescript
  const literalType = type as ts.LiteralTypeNode;
  if (literalType.literal.kind === ts.SyntaxKind.NullKeyword) {
    return FunctionArgumentType.null;
  }
  ```

### Thread Communication
- PostToJs: Execute on JS thread from other threads
- PostToDart: Return results to Dart isolate
- PostToJsSync: Synchronous execution (use sparingly, can cause deadlocks)

### Error Handling in Async FFI
- For async callbacks with potential errors:
  - Always provide error path in callbacks (e.g., `callback(object, nullptr)`)
  - Handle cancellation cases in async operations
  - Propagate errors through callback parameters, not exceptions
- Thread-safe error reporting:
  - Copy error messages before crossing thread boundaries
  - Use `std::string` to ensure string lifetime
  - Consider error callback separate from result callback

### Common FFI Pitfalls to Avoid
- **Handle lifetime**: Regular Dart_Handle becomes invalid after crossing threads
- **String ownership**: `const char*` from Dart may be freed after call
- **Callback lifetime**: Ensure callbacks aren't invoked after context destruction
- **Type mismatches**: `Handle` vs `Dart_Handle` in different contexts
- **Lambda captures**: Be explicit about what's captured and its lifetime
- **Synchronous deadlocks**: Avoid PostToJsSync when threads may interdepend

## Memory

- [Bridge Unit Tests](./claude_memory/bridge_unit_tests.md) - Guide for running and debugging bridge unit tests
- [CSS Variable Display None Fix](./claude_memory/css_variable_display_none_fix.md) - Fix for CSS variables in display:none elements
- [HTTP Cache Invalidation Fix](./claude_memory/http_cache_invalidation.md) - Cache invalidation mechanism for handling corrupt image cache files
- [Image Loading Fallback](./claude_memory/image_loading_fallback.md) - Fallback mechanism for image loading failures
- [iOS Build Troubleshooting](./claude_memory/ios_build_troubleshooting.md) - Guide for fixing iOS undefined symbol errors and understanding the build structure
- [iOS WebF Source Compilation](./claude_memory/ios_webf_source_compilation.md) - iOS-specific source compilation details
- [Network Panel Implementation](./claude_memory/network_panel_implementation.md) - DevTools network panel implementation details
- [UI Command Ring Buffer Design](./claude_memory/ui_command_ring_buffer_design.md) - Design documentation for the UI command ring buffer
- [UI Command Ring Buffer README](./claude_memory/ui_command_ring_buffer_readme.md) - Usage guide for the UI command ring buffer
- [WebF DevTools Improvements](./claude_memory/webf_devtools_improvements.md) - Recent improvements to WebF DevTools
- [WebF Integration Testing Guide](./claude_memory/webf_integration_testing_guide.md) - Guide for writing and running integration tests
- [WebF Package Preparation](./claude_memory/webf_package_preparation.md) - Steps for preparing WebF packages
- [WebF Text Element Update Fix](./claude_memory/webf_text_element_update_fix.md) - Fix for text element update issues
- [LCP (Largest Contentful Paint) Implementation](./claude_memory/lcp_implementation.md) - Implementation of LCP performance metric callbacks for WebFController
- [FCP (First Contentful Paint) Implementation](./claude_memory/fcp_implementation.md) - Implementation of FCP performance metric tracking for WebFController
- [FP (First Paint) Implementation](./claude_memory/fp_implementation.md) - Implementation of FP performance metric tracking for visual changes
- [Contentful Widget Detection](./claude_memory/contentful_widget_detection.md) - Detection system for ensuring FCP/LCP are only reported for widgets with actual visual content
- [DevTools Performance Metrics Display](./claude_memory/devtools_performance_metrics.md) - Unified display implementation for FP/FCP/LCP metrics in WebF DevTools


## Testing Guidelines

### Unit Tests (webf/test)
- Always call `setupTest()` in the `setUp()` method, not directly in `main()`
- When testing with WebFController, wait for initialization: `await controller.controlledInitCompleter.future;`
- Import tests in `webf_test.dart` and add them to the appropriate test group
- Use mock bundles from `test/src/foundation/mock_bundle.dart` for testing

### Integration Tests (integration_tests/specs)
- Place tests in appropriate directories under `specs/`
- Use TypeScript (.ts extension)
- Use `done()` callback for async tests
- Use `snapshot()` for visual regression tests
- Test assets should reference files in `assets/` directory
- Use `fdescribe()` instead of `describe()` to run only specific test specs (Jasmine feature)
- Use `fit()` instead of `it()` to run only specific test cases

### Flutter Integration Tests (webf/integration_test)
- LCP integration tests: `webf/integration_test/integration_test/lcp_integration_test.dart`
- FCP integration tests: `webf/integration_test/integration_test/fcp_integration_test.dart`
- FP integration tests: `webf/integration_test/integration_test/fp_integration_test.dart`
- Run with: `cd webf && flutter test integration_test/integration_test/test_name.dart`


### Test-Driven Development Workflow
1. Run tests frequently during development: `npm test`
2. When fixing failing tests:
   - Run specific test files: `npm test -- test/analyzer.test.ts`
   - Fix one test at a time and verify before moving to the next
   - Use focused debugging scripts when needed to understand behavior
3. For modules that read files at load time:
   - Mock fs before importing the module
   - Set up default mocks in the test file before any imports that use them

### Module Mocking Patterns
When testing modules that read files at load time:
```typescript
// Mock fs BEFORE importing the module
jest.mock('fs');
import fs from 'fs';
const mockFs = fs as jest.Mocked<typeof fs>;

// Set up file reading mocks
mockFs.readFileSync = jest.fn().mockImplementation((path) => {
  // Return appropriate content based on path
});

// NOW import the module that uses fs
import { moduleUnderTest } from './module';
```

### Threading and Async Patterns
- When working with cross-thread communication (UI thread, JS thread, Dart thread):
  - Identify potential deadlocks from sync calls between threads
  - Prefer async patterns with callbacks over sync blocking calls
  - Use PostToJs/PostToDart for async thread communication
  - Document thread ownership clearly in comments
- For Dart FFI async patterns:
  - Follow the invokeModuleEvent pattern for async callbacks
  - Use Completer<T> for async return values
  - Ensure proper cleanup of native resources in callbacks

### DevTools Integration
- When working with DevTools/debugging features:
  - Remote object inspection may require async patterns to avoid deadlocks
  - Use RemoteObjectRegistry for object tracking
  - Consider thread context when accessing JS objects from DevTools
  - Test with actual DevTools UI interactions, not just unit tests
- Common patterns:
  - GetObjectProperties operations should be async
  - Property evaluation may trigger cross-thread calls
  - Always validate context IDs before operations

### Common Testing Patterns
```dart
// Unit test setup
setUp(() {
  setupTest();
});

// Controller initialization
final controller = WebFController(
  viewportWidth: 360,
  viewportHeight: 640,
  bundle: WebFBundle.fromContent('<html></html>', contentType: ContentType.html),
);
await controller.controlledInitCompleter.future;
```

## Performance Optimization Guidelines

### Caching Strategies
1. **Identify Repeated Operations**: Look for operations that:
   - Parse the same files multiple times
   - Perform identical type conversions
   - Read file contents repeatedly

2. **Implement Caching**:
   ```typescript
   // File content cache
   const cache = new Map<string, CachedType>();

   // Cache with validation
   if (cache.has(key)) {
     return cache.get(key);
   }
   const result = expensiveOperation();
   cache.set(key, result);
   ```

3. **Provide Cache Clearing**: Always implement a clear function:
   ```typescript
   export function clearCaches() {
     cache.clear();
   }
   ```

### Batch Processing
For file operations, process in batches to maximize parallelism:
```typescript
async function processFilesInBatch<T>(
  items: T[],
  batchSize: number,
  processor: (item: T) => Promise<void>
): Promise<void> {
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    await Promise.all(batch.map(processor));
  }
}
```

### Implementation Review Checklist
Before marking any FFI/cross-language task as complete, verify:
- [ ] Memory management: All allocated memory has corresponding free calls
- [ ] Dart handles: Persistent handles used for async operations
- [ ] String lifetime: Strings copied when crossing thread boundaries
- [ ] Error paths: All error conditions handled gracefully
- [ ] Thread safety: No shared mutable state without synchronization
- [ ] Build success: Code compiles without warnings
- [ ] Existing patterns: Implementation follows codebase conventions

### Incremental Development Approach
1. Make one logical change at a time
2. Build after each change: `npm run build`
3. Run relevant tests after each change
4. Commit working states before moving to the next feature
5. When debugging complex issues:
   - Create minimal reproduction scripts
   - Use console.log or debugger strategically
   - Clean up debug code before finalizing

## Enterprise Software Handling

### WebF Enterprise Dependencies
- WebF Enterprise is a closed-source product requiring subscription
- Dependency configuration:
  ```yaml
  dependencies:
    webf:
      hosted: https://dart.cloudsmith.io/openwebf/webf-enterprise/
      version: ^0.22.0
  ```
- For local development, use path dependencies
- Always clarify subscription requirements in documentation
- Use logger libraries instead of print statements in production code

### Documentation Patterns
- Clearly distinguish between open source and enterprise features
- Include WebF Enterprise badges/notices in README files
- Explain that WebF builds Flutter apps, not web applications
- When referencing demos that require WebF, clarify they're not traditional web demos

## WebF CLI Code Generator

### Overview
The WebF CLI (`cli/`) is a powerful code generation tool that creates type-safe bindings between Flutter/Dart and JavaScript frameworks (React, Vue). It analyzes TypeScript definition files and generates corresponding Dart classes and JavaScript/TypeScript components.

### Usage
```bash
# Generate code with auto-creation of project if needed
webf codegen generate [output-dir] --flutter-package-src=<path> [--framework=react|vue] [--package-name=<name>] [--publish-to-npm] [--npm-registry=<url>]

# Examples
webf codegen generate my-typings --flutter-package-src=../webf_cupertino_ui
webf codegen generate --flutter-package-src=../webf_cupertino_ui  # Uses temporary directory
webf codegen generate my-typings --flutter-package-src=../webf_cupertino_ui --publish-to-npm
webf codegen generate --flutter-package-src=../webf_cupertino_ui --publish-to-npm --npm-registry=https://custom.registry.com/

# Interactive publishing (prompts after generation)
webf codegen generate my-typings --flutter-package-src=../webf_cupertino_ui
# CLI will ask: "Would you like to publish this package to npm?"
# If yes, CLI will ask: "NPM registry URL (leave empty for default npm registry):"
```

### Key Features
1. **Auto-creation**: Automatically detects if a project needs to be created
2. **Interactive prompts**: Asks for framework and package name when not provided
3. **Metadata synchronization**: Reads version and description from Flutter package's pubspec.yaml
4. **Automatic build**: Runs `npm run build` automatically after code generation
5. **NPM publishing**: Supports automatic publishing to npm registries with `--publish-to-npm`
6. **Custom registries**: Use `--npm-registry` to specify custom npm registries
7. **Framework detection**: Auto-detects framework from existing package.json dependencies

### Development
- See `cli/CLAUDE.md` for detailed CLI development guidelines
- Run CLI tests: `cd cli && npm test`
- Build CLI: `cd cli && npm run build`

## Git Submodule Operations

### Migrating to Submodules
When converting a directory to a git submodule:
1. Clone the destination repository to a temporary location outside the current repo
2. Copy all files from the source directory to the cloned repository
3. Commit and push changes to the remote repository
4. Remove the original directory from the main repository
5. Add as submodule: `git submodule add <repository-url> <path>`
6. Use `git -C` for operations on external repositories when needed

### Working with Submodules
- Update submodules: `git submodule update --init --recursive`
- Work within submodule: Changes are tracked separately
- Commit submodule pointer changes in parent repository
- Always verify `.gitmodules` file is correctly configured

## Technical Documentation Guidelines

### README Optimization
When writing documentation for Flutter packages that use web technologies:
1. **Clarify the technology stack**: Explain that WebF enables building Flutter apps with web tech, not web apps
2. **Set clear expectations**: If examples require WebF to run, state this prominently
3. **Provide complete quick-start examples**: Include WebFControllerManager initialization
4. **Structure information hierarchically**: Most important info (requirements, limitations) first
5. **Use clear section headers**: "What is WebF?", "Prerequisites", etc.

### Code Examples in Documentation
- Always show complete, runnable examples
- Include necessary imports and initialization code
- For WebF: Always show WebFControllerManager setup
- Test all code examples before including in documentation

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
