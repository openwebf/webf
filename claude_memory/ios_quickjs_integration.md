# iOS QuickJS Integration

## Overview
This document describes the iOS QuickJS integration implementation for the WebF project. The integration involves creating mirror C files in iOS that include the original QuickJS source files from the src/ directory.

## Implementation Details

### Directory Structure
The QuickJS source files are mirrored in the iOS project with the following structure:
- ios/Classes/quickjs/ - Contains the main QuickJS C files
  - core/ - Contains core implementation files
    - builtins/ - Contains JavaScript builtins implementation files

### Integration Approach
Each C file in the iOS directory includes the corresponding original C file from the src/third_party/quickjs/ directory, allowing for consistent code while maintaining compatibility with the iOS build system.

For example:
- ios/Classes/quickjs/cutils.c includes src/third_party/quickjs/src/cutils.c
- ios/Classes/quickjs/core/memory.c includes src/third_party/quickjs/src/core/memory.c
- ios/Classes/quickjs/core/builtins/js-array.c includes src/third_party/quickjs/src/core/builtins/js-array.c

### Benefits
- Avoids code duplication
- Ensures changes in the original source are automatically reflected in the iOS build
- Simplifies maintenance as only the original source needs to be updated

### Migration Notes
The implementation replaced the previous approach of using precompiled frameworks:
- Removed ios/Frameworks/quickjs.xcframework
- Removed ios/Frameworks/webf_bridge.xcframework
- Removed ios/prepare.sh

## Building and Running
The iOS project can now be built using the standard Flutter build process, and the QuickJS JavaScript runtime functionality is integrated directly through the source code includes.