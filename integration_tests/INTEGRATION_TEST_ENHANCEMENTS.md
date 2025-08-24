# Integration Test Runner Enhancements

## Overview

Enhanced the WebF integration test runner to support running specific test files, making it easier to develop and debug individual test cases.

## New Features

### 1. Specific Test File Execution
You can now run individual test files instead of the entire test suite:

```bash
# Run a single test file
npm run integration -- specs/css/css_text_baseline_test.ts

# Run multiple test files
npm run integration -- specs/css/css_text_baseline_test.ts specs/css/css_locale_support_test.ts
```

### 2. Enhanced Command Line Interface
- Added help command: `npm run integration -- --help`
- Better argument parsing that handles npm's `--` syntax correctly
- Clear usage examples and options documentation

### 3. Improved Build Process
- Automatic webpack building with filtering based on specified test files
- Debug output showing which test files are being built
- More efficient builds when testing specific functionality

## Implementation Details

### Modified Files

1. **`scripts/core_integration_starter.js`**
   - Added argument parsing for specific test files
   - Added help functionality
   - Integrated webpack building with filtering
   - Enhanced error handling and user feedback

2. **`webpack.config.js`**
   - Improved filtering logic to support multiple test files
   - Added debug output for better transparency
   - Enhanced pattern matching for specific files

3. **`spec_group.json5`**
   - Added pattern `"specs/css/css_*_test.{js,jsx,ts,tsx,html}"` to include new CSS test files
   - Ensures new test files are included in the TextAndColorAndFilterEffect group

4. **`package.json`**
   - Updated integration script to handle webpack building internally
   - Streamlined the build process

### Technical Implementation

The solution uses environment variables to pass filtering information to webpack:

1. **Argument Parsing**: `core_integration_starter.js` parses command line arguments to identify specific test files
2. **Environment Variable**: Sets `WEBF_TEST_FILTER` with pipe-separated file patterns  
3. **Webpack Filtering**: `webpack.config.js` uses the filter to include only matching files
4. **Test Execution**: The filtered bundle is built and executed by the WebF test runner

### Filter Logic

The filtering works by:
1. Parsing command line arguments for files starting with `specs/` and ending with `.ts`, `.js`, `.tsx`, or `.jsx`
2. Creating a filter pattern from the file paths
3. Using webpack's file filtering to include only matching files in the bundle
4. Building and executing only the specified test files

## Usage Examples

### CSS Text Mixin Tests
```bash
# Test locale-based text baseline selection
npm run integration -- specs/css/css_text_baseline_test.ts

# Test locale support and inheritance
npm run integration -- specs/css/css_locale_support_test.ts

# Test color-relative property optimization
npm run integration -- specs/css/css_color_relative_properties_test.ts

# Test background/foreground Paint support
npm run integration -- specs/css/css_text_effects_test.ts

# Test comprehensive integration
npm run integration -- specs/css/css_text_comprehensive_test.ts

# Test multiple files together
npm run integration -- specs/css/css_text_baseline_test.ts specs/css/css_locale_support_test.ts
```

### Other Test Categories
```bash
# Run specific flexbox tests
npm run integration -- specs/css/css-flexbox/flex-grow.ts

# Run multiple position tests
npm run integration -- specs/css/css-position/absolute.ts specs/css/css-position/relative.ts
```

### Development Workflow
```bash
# Get help
npm run integration -- --help

# Quick test during development
npm run integration -- specs/css/my_new_test.ts

# Test multiple related files
npm run integration -- specs/css/css-text/letter-spacing.ts specs/css/css-text/line-height.ts

# Run all tests (original behavior)
npm run integration
```

## Benefits

1. **Faster Development**: Test only what you're working on instead of the entire suite
2. **Better Debugging**: Easier to isolate and debug specific test failures
3. **Improved CI/CD**: Can run targeted tests for specific feature areas
4. **Enhanced Developer Experience**: Clear help and usage examples
5. **Backward Compatibility**: Original `npm run integration` still works for full test runs

## Future Enhancements

Potential improvements for the future:
- Support for glob patterns (e.g., `specs/css/css-text/*.ts`)
- Test result filtering and reporting
- Parallel test execution for multiple files
- Integration with VS Code for running tests from the editor
- Test watching mode for continuous development