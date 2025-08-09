# C++ Development Guide (bridge/)

This guide covers C++ development in the `bridge/` directory, which contains the JavaScript runtime, DOM API implementations, and HTML parsing logic.

## Build Commands
- Build for macOS: `npm run build:bridge:macos` (debug) or `npm run build:bridge:macos:release` (release)
- Build for iOS: `npm run build:bridge:ios` (debug) or `npm run build:bridge:ios:release` (release)
- Build for Android: `npm run build:bridge:android` (debug) or `npm run build:bridge:android:release` (release)
- Clean build: `npm run build:clean`

## Build Error Resolution
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

## C++ Code Style
- Based on Chromium style (.clang-format)
- Standard: C++17
- Column limit: 120 characters
- Use 2-space indentation

## C++ Testing
- Run bridge unit tests: `node scripts/run_bridge_unit_test.js`
- See Bridge Unit Tests section for detailed guide

## Important C++ Files and Patterns
- `webf_bridge.cc`: Main bridge entry point
- `executing_context.cc`: JavaScript context management
- `binding_object.h`: Base class for JS bindings
- `WEBF_EXPORT_C`: Macro for exporting C functions to Dart FFI

## Bridge Unit Tests
Guide for running and debugging bridge unit tests.

### Running Bridge Unit Tests
```bash
# Run all bridge unit tests (automatically builds and runs debug version)
node scripts/run_bridge_unit_test.js
```

### Understanding Test Output
- Tests run via Google Test framework
- Green `[  PASSED  ]` indicates success
- Red `[  FAILED  ]` shows failures with details
- Summary shows total tests run and time taken

### Common Issues
1. **Build Failures**: The script automatically builds before running tests. If build fails:
   - Check CMake configuration
   - Ensure all dependencies are installed
   - Try `npm run build:bridge:macos` first to isolate build issues

2. **Test Failures**: 
   - Check the assertion message for details
   - Use `--verbose` flag to see more output
   - Individual test files are in `bridge/test/`

### Writing New Tests
- Add test files to `bridge/test/`
- Use Google Test macros: `TEST()`, `EXPECT_EQ()`, etc.
- Tests are automatically discovered by CMake

## iOS Build Troubleshooting
Guide for fixing iOS undefined symbol errors and understanding the build structure.

### Common iOS Build Issues

#### Undefined Symbol Errors
When encountering undefined symbol errors like:
```
Undefined symbols for architecture arm64:
  "_InvokeBindingObject", referenced from:
      webf::MemberMutationCallback::Fire(...) 
```

**Root Cause**: Missing source files in iOS build configuration

**Solution**:
1. Check `ios/webf_ios.podspec` for missing source files
2. Add missing files to the `source_files` pattern:
   ```ruby
   s.source_files = 'Classes/**/*', 'bridge/**/*.{h,cc,cpp,m,mm}'
   ```
3. Clean and rebuild:
   ```bash
   cd ios && pod install --repo-update
   cd example/ios && pod install --repo-update
   flutter clean && flutter build ios
   ```

#### Build Configuration Structure
```
webf/
├── ios/
│   ├── webf_ios.podspec      # Main pod specification
│   ├── Classes/              # iOS-specific code
│   └── prepare.sh            # Build preparation script
├── bridge/                   # C++ source files
│   ├── bindings/
│   │   └── qjs/
│   │       └── member_installer.cc  # Often missing file
│   └── CMakeLists.txt
```

#### Key Files to Check
1. **webf_ios.podspec**: Defines which source files are included
2. **CMakeLists.txt**: C++ build configuration
3. **prepare.sh**: Pre-build script that sets up the environment

#### Debugging Steps
1. **Verify File Inclusion**:
   ```bash
   # Check if file is included in build
   grep -r "member_installer" ios/
   ```

2. **Clean Build**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   cd ios && rm -rf Pods Podfile.lock
   flutter clean
   ```

3. **Verbose Build**:
   ```bash
   flutter build ios --verbose
   ```

## iOS WebF Source Compilation
iOS-specific source compilation details.

### iOS Build System Overview
WebF uses CocoaPods to integrate C++ code into iOS Flutter apps. The build process involves:

1. **CMake Build**: Compiles C++ bridge code
2. **Pod Integration**: Links compiled libraries with Flutter
3. **Asset Bundling**: Includes required resources

### Source File Patterns
The `webf_ios.podspec` must include all necessary source files:

```ruby
s.source_files = [
  'Classes/**/*.{h,m,mm}',           # iOS platform code
  'bridge/**/*.{h,cc,cpp}',          # C++ bridge code
  'bridge/bindings/**/*.{h,cc}',     # Binding implementations
  'bridge/third_party/**/*.{h,c,cc}' # Third-party dependencies
]
```

### Common Compilation Issues

#### Missing Headers
```
fatal error: 'member_installer.h' file not found
```
**Fix**: Add to `preserve_paths` and `public_header_files`

#### Symbol Visibility
```
Undefined symbols for architecture x86_64
```
**Fix**: Ensure C++ symbols are exported:
```cpp
WEBF_EXPORT_C void SomeFunction() { }
```

#### Architecture Mismatches
**Fix**: Ensure all libraries are built for required architectures:
```ruby
s.pod_target_xcconfig = {
  'VALID_ARCHS' => 'arm64 x86_64',
}
```

### Build Optimization
1. **Precompiled Headers**: Use PCH for common includes
2. **Module Maps**: Define module boundaries
3. **Link-Time Optimization**: Enable LTO for release builds

## UI Command Ring Buffer Design
Design documentation for the UI command ring buffer.

### Overview
The UI Command Ring Buffer is a high-performance, lock-free data structure designed to handle UI commands between the JS thread and Flutter UI thread in WebF.

### Design Goals
1. **Lock-free**: Minimize thread contention
2. **Bounded memory**: Fixed-size buffer with overwrite semantics
3. **Cache-friendly**: Optimize for CPU cache lines
4. **Type-safe**: Compile-time command validation

### Architecture

#### Ring Buffer Structure
```cpp
template <typename T, size_t Size>
class RingBuffer {
  static_assert((Size & (Size - 1)) == 0, "Size must be power of 2");
  
private:
  alignas(64) std::atomic<size_t> head_{0};  // Producer position
  alignas(64) std::atomic<size_t> tail_{0};  // Consumer position
  alignas(64) T buffer_[Size];               // Command storage
  
public:
  bool try_push(const T& item);
  bool try_pop(T& item);
};
```

#### Command Structure
```cpp
struct UICommand {
  enum Type : uint8_t {
    CREATE_ELEMENT = 0,
    UPDATE_STYLE = 1,
    REMOVE_ELEMENT = 2,
    // ... more types
  };
  
  Type type;
  uint32_t target_id;
  union {
    CreateElementData create;
    UpdateStyleData style;
    RemoveElementData remove;
  } data;
};
```

### Performance Characteristics
- **Throughput**: ~10M ops/sec on modern CPUs
- **Latency**: <100ns per operation
- **Memory**: Fixed O(1) memory usage
- **Scalability**: Single producer, single consumer

### Usage Patterns

#### Producer (JS Thread)
```cpp
void dispatchUICommand(const UICommand& cmd) {
  if (!command_buffer_.try_push(cmd)) {
    // Handle overflow - log or implement backpressure
    handleOverflow();
  }
}
```

#### Consumer (UI Thread)
```cpp
void processUICommands() {
  UICommand cmd;
  while (command_buffer_.try_pop(cmd)) {
    executeCommand(cmd);
  }
}
```

## UI Command Ring Buffer Usage Guide

### Quick Start

#### Including the Buffer
```cpp
#include "ui_command_buffer.h"

// Create a buffer with 1024 command slots
UICommandBuffer<1024> command_buffer;
```

#### Sending Commands
```cpp
// From JS thread
void sendCreateElement(uint32_t id, const char* tag_name) {
  UICommand cmd;
  cmd.type = UICommand::CREATE_ELEMENT;
  cmd.target_id = id;
  strncpy(cmd.data.create.tag_name, tag_name, 63);
  
  if (!command_buffer.try_push(cmd)) {
    LOG(ERROR) << "Command buffer full!";
  }
}
```

#### Processing Commands
```cpp
// On UI thread - typically called each frame
void onFrame() {
  UICommand cmd;
  int processed = 0;
  
  while (command_buffer.try_pop(cmd) && processed < MAX_COMMANDS_PER_FRAME) {
    switch (cmd.type) {
      case UICommand::CREATE_ELEMENT:
        createElement(cmd.target_id, cmd.data.create.tag_name);
        break;
      // ... handle other command types
    }
    processed++;
  }
}
```

### Best Practices

1. **Buffer Sizing**: Choose power-of-2 sizes (512, 1024, 2048)
2. **Overflow Handling**: Implement metrics and alerts
3. **Batching**: Process multiple commands per frame
4. **Priority**: Consider separate buffers for high-priority commands

### Performance Tuning

#### Optimal Buffer Size
```cpp
// Measure and adjust based on workload
constexpr size_t BUFFER_SIZE = 
  DEBUG_BUILD ? 512 :    // Smaller for testing
  MOBILE ? 1024 :        // Mobile constraints  
  2048;                  // Desktop performance
```

#### CPU Affinity
```cpp
// Pin threads to cores for optimal cache usage
std::thread ui_thread([]() {
  setCPUAffinity(UI_THREAD_CORE);
  runUILoop();
});
```

## FFI Integration Patterns

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

### Memory Management in FFI
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