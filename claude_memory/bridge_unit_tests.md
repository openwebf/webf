# Bridge Unit Tests

## Running Bridge Unit Tests

### Quick Run
```bash
node scripts/run_bridge_unit_test.js
```

### Build and Run Manually

#### macOS
1. Build the test executable:
   ```bash
   npm run build:bridge:macos
   ```
   
2. Run the test executable directly:
   ```bash
   ./bridge/build/macos/lib/x86_64/webf_unit_test
   ```

#### Linux
1. Build the test executable:
   ```bash
   npm run build:bridge:linux
   ```
   
2. Run the test executable directly:
   ```bash
   ./bridge/build/linux/lib/webf_unit_test
   ```

#### Windows
1. Build the test executable:
   ```bash
   npm run build:bridge:windows
   ```
   
2. Run the test executable directly:
   ```bash
   ./bridge/build/windows/lib/webf_unit_test.exe
   ```

## Test Executable Locations

The `webf_unit_test` executable is built as part of the bridge build process and is located at:

- **macOS**: `bridge/build/macos/lib/x86_64/webf_unit_test`
- **Linux**: `bridge/build/linux/lib/webf_unit_test`
- **Windows**: `bridge/build/windows/lib/webf_unit_test.exe`

## Build Requirements

The unit test executable is only built when:
- Using QuickJS engine (not JSC)
- Build mode is Debug (not Release)
- CMake is configured with `-DENABLE_TEST=true` (automatically set in build scripts)

## Test Source Files

Unit tests are defined in the following locations:
- `bridge/bindings/qjs/*_test.cc`
- `bridge/core/dom/*_test.cc`
- `bridge/core/html/*_test.cc`
- `bridge/core/frame/*_test.cc`
- `bridge/core/css/*_test.cc`
- `bridge/core/timing/*_test.cc`
- `bridge/foundation/*_test.cc`
- `bridge/core/devtools/*_test.cc`

All test files are listed in `bridge/test/test.cmake` under the `WEBF_UNIT_TEST_SOURCE` variable.

## Test Framework

The unit tests use Google Test (gtest) framework. The test executable includes:
- All bridge source code
- Test framework polyfill
- Google Test library
- Test-specific environment setup

## Environment Variables

When building, the following environment variables affect the test build:
- `WEBF_JS_ENGINE`: Set to `quickjs` (default) or `jsc`
- `WEBF_BUILD`: Set to `Debug` (default) or `Release`
- `LIBRARY_OUTPUT_DIR`: Custom output directory for the executable

## Debugging Tests

To debug unit tests:
1. Build in Debug mode (default)
2. Run the executable directly with a debugger:
   ```bash
   lldb ./bridge/build/macos/lib/x86_64/webf_unit_test  # macOS
   gdb ./bridge/build/linux/lib/webf_unit_test           # Linux
   ```

## Running Specific Tests

The test executable supports Google Test command line options:
```bash
# Run tests matching a pattern
./bridge/build/macos/lib/x86_64/webf_unit_test --gtest_filter=*Console*

# List all tests
./bridge/build/macos/lib/x86_64/webf_unit_test --gtest_list_tests

# Run tests with verbose output
./bridge/build/macos/lib/x86_64/webf_unit_test --gtest_print_time=1
```