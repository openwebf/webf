# WebF Development Guide

## Repository Structure
- `bridge/`: C++ code providing JavaScript runtime and DOM API implementations, HTML parsing
- `webf/`: Dart code implementing DOM/CSS and layout/painting on top of Flutter
- `integration_tests/`: Integration tests (most test cases in integration_tests/specs)

## Build Commands
- Build for macOS: `npm run build:bridge:macos` (debug) or `npm run build:bridge:macos:release` (release)
- Build for iOS: `npm run build:bridge:ios` (debug) or `npm run build:bridge:ios:release` (release)
- Build for Android: `npm run build:bridge:android` (debug) or `npm run build:bridge:android:release` (release)
- Clean build: `npm run build:clean`
- Run example: `npm run start` (flutter run in webf/example)

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

