# WebF iOS Integration Change

## Overview

This change modifies the WebF iOS build process to compile from source files directly rather than using pre-built xcframeworks. This improves maintainability, allows for better debugging, and ensures consistency across platforms.

## Key Changes

1. **QuickJS Integration**
   - Removed the pre-built `quickjs.xcframework` and `webf_bridge.xcframework`
   - Added all QuickJS source files to `webf/ios/Classes/quickjs/`
   - Updated build configuration to compile QuickJS from source

2. **HTML Parser (Gumbo) Integration**
   - Added Gumbo parser source files to `webf/ios/Classes/gumbo_parser/`
   - Updated header search paths to include Gumbo parser headers

3. **Base64 Encoding (modp_b64) Integration**
   - Added modp_b64 source files to `webf/ios/Classes/modp_b64/`
   - Updated header search paths to include modp_b64 headers

4. **Dart FFI Support**
   - Added Dart FFI header files and implementation
   - Added `dart_api_dl.c` for Dart native interface
   - Updated header search paths to include Dart headers

5. **Dynamic Library Loading**
   - Modified `dynamic_library.dart` to use `DynamicLibrary.executable()` for iOS
   - Removed iOS-specific framework path as it's no longer needed

6. **Build Configuration**
   - Updated podspec to include C++ standard (C++17)
   - Added optimization flags and preprocessor definitions
   - Increased minimum iOS version from 11.0 to 12.0
   - Removed prepare.sh script that was previously used for framework setup

## Benefits

1. **Debugging**: Compiling from source makes it easier to debug WebF on iOS
2. **Maintenance**: Eliminates the need to maintain separate pre-built binary artifacts
3. **Consistency**: Ensures the same code is used across all platforms
4. **Development**: Makes it easier to develop and test iOS-specific changes

## Technical Details

The iOS build now directly includes all necessary C/C++ source files in the Pods project, rather than using pre-compiled frameworks. This involves:

1. Mirroring the source file structure from the main project into the iOS Classes directory
2. Setting appropriate compiler flags and header search paths in the podspec
3. Using Dart FFI through the executable itself rather than a separate framework

The change also reorganizes the third-party dependencies into a more maintainable structure.