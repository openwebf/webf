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

- [HTTP Cache Invalidation Fix](./claude_memory/http_cache_invalidation.md) - Cache invalidation mechanism for handling corrupt image cache files

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

### Implementation Review Checklist
Before marking any FFI/cross-language task as complete, verify:
- [ ] Memory management: All allocated memory has corresponding free calls
- [ ] Dart handles: Persistent handles used for async operations
- [ ] String lifetime: Strings copied when crossing thread boundaries  
- [ ] Error paths: All error conditions handled gracefully
- [ ] Thread safety: No shared mutable state without synchronization
- [ ] Build success: Code compiles without warnings
- [ ] Existing patterns: Implementation follows codebase conventions