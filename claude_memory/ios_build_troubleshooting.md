# iOS Build Troubleshooting Guide

## Understanding iOS Build Structure

### How iOS Builds Work in WebF
- For iOS platform, the C++ source code is compiled directly in Xcode during Flutter build
- Use `flutter build ios` command, NOT `npm run build:bridge:ios` (which is only for pre-built dynamic libraries)
- The iOS build includes C++ sources through a special linking mechanism

### iOS Classes Directory Structure
The `webf/ios/Classes/` directory contains:
1. **Link files**: Small `.cc` files that just include the actual implementation from bridge directory
2. **Pattern**: Each `.cc` file contains a single include statement like:
   ```cpp
   #include "../../../src/core/executing_context.cc"
   // or
   #include "../../../../bridge/core/devtools/devtools_bridge.cc"
   ```

## Common iOS Build Errors

### Undefined Symbol Errors
When you see errors like:
```
Error (Xcode): Undefined symbol: webf::ClassName::MethodName()
```

**Solution Steps:**
1. Find where the symbol is defined in the bridge directory
2. Check if a corresponding link file exists in `webf/ios/Classes/`
3. If missing, create a link file with the same path structure
4. The link file should only contain an include to the bridge implementation

### Example Fix
For undefined symbols from `ui_command_ring_buffer.cc`:
1. Check if `webf/ios/Classes/foundation/ui_command_ring_buffer.cc` exists
2. It should contain:
   ```cpp
   #include "../../../src/foundation/ui_command_ring_buffer.cc"
   ```
3. Ensure the include path is correct relative to the iOS Classes directory

### Build Commands
- Clean build: `flutter clean`
- Build for iOS: `flutter build ios --no-codesign`
- Never use `npm run build:bridge:ios` for fixing undefined symbols

### Important Notes
- The podspec file (`webf/ios/webf.podspec`) includes all files in `Classes/**/*`
- Test files (`*_test.cc`) should not be in the iOS Classes directory
- Always verify the actual implementation file exists in bridge before creating a link file
- Check for syntax errors in the source files if linking seems correct but build still fails