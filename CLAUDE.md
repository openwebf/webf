# WebF Development Guide

This is the main development guide for WebF. Content has been organized into folder-specific guides for better maintainability.

## Folder-Specific Guides
- **[C++ Development Guide](bridge/CLAUDE.md)**: C++ development, build commands, FFI patterns, iOS troubleshooting
- **[Dart/Flutter Development Guide](webf/CLAUDE.md)**: Dart development, widget testing, Flutter patterns
- **[Integration Testing Guide](integration_tests/CLAUDE.md)**: Writing and running integration tests
- **[Memory & Performance](docs/MEMORY_PERFORMANCE.md)**: Performance optimization, caching, memory management
- **[Architecture Overview](docs/ARCHITECTURE.md)**: WebF architecture pipeline and design patterns

## Table of Contents
1. [Repository Structure](#repository-structure)
2. [Search and Navigation Strategy](#search-and-navigation-strategy)
3. [Cross-Platform Development](#cross-platform-development)
4. [Testing Guidelines](#testing-guidelines)
5. [WebF CLI Code Generator](#webf-cli-code-generator)
6. [Git Submodule Operations](#git-submodule-operations)
7. [Enterprise Software Handling](#enterprise-software-handling)
8. [Technical Documentation Guidelines](#technical-documentation-guidelines)
9. [WebF Dart MCP Server Guide](#webf-dart-mcp-server-guide)

## Quick Reference

### Common Commands by Development Type
**C++ Development:**
- Build: `npm run build:bridge:macos` (or ios/android)
- Test: `node scripts/run_bridge_unit_test.js`
- Clean: `npm run build:clean`

**Dart/Flutter Development:**
- Test: `cd webf && flutter test`
- Integration test: `cd webf && flutter test integration_test/`
- Lint: `npm run lint`
- Format: `npm run format`

**Both:**
- Test all: `npm run test`
- Integration tests: `cd integration_tests && npm run integration`

## Repository Structure
- `bridge/`: C++ code providing JavaScript runtime and DOM API implementations, HTML parsing
- `webf/`: Dart code implementing DOM/CSS and layout/painting on top of Flutter
- `integration_tests/`: Integration tests (most test cases in integration_tests/specs)
- `cli/`: WebF CLI code generator for React/Vue bindings
- `scripts/`: Build and utility scripts

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


# Cross-Platform Development

This section covers development aspects that involve both C++ and Dart/Flutter code, including FFI integration and cross-language patterns.

## Test Commands (All Platforms)
- Run all tests: `npm run test` (includes bridge, Flutter, and integration tests)
- Run integration tests: `cd integration_tests && npm run integration`

## Memory Management in FFI
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

# Memory and Performance


#### Running Bridge Unit Tests
```bash
# Run all bridge unit tests (automatically builds and runs debug version)
node scripts/run_bridge_unit_test.js
```

#### Understanding Test Output
- Tests run via Google Test framework
- Green `[  PASSED  ]` indicates success
- Red `[  FAILED  ]` shows failures with details
- Summary shows total tests run and time taken

#### Common Issues
1. **Build Failures**: The script automatically builds before running tests. If build fails:
   - Check CMake configuration
   - Ensure all dependencies are installed
   - Try `npm run build:bridge:macos` first to isolate build issues

2. **Test Failures**: 
   - Check the assertion message for details
   - Use `--verbose` flag to see more output
   - Individual test files are in `bridge/test/`

#### Writing New Tests
- Add test files to `bridge/test/`
- Use Google Test macros: `TEST()`, `EXPECT_EQ()`, etc.
- Tests are automatically discovered by CMake

### CSS Variable Display None Fix
Fix for CSS variables in display:none elements.

#### Problem
CSS variables (custom properties) on elements with `display: none` were not being resolved correctly, causing JavaScript calls to `getComputedStyle()` to return empty strings instead of the actual variable values.

#### Root Cause
The render style for elements with `display: none` was not being properly computed, which meant CSS variables were not resolved in the cascade.

#### Solution
Modified `CSSStyleDeclaration::getPropertyValue()` to ensure render style is computed even for non-rendered elements:

```dart
// In webf/lib/src/css/style_declaration.dart
if (_target is Element) {
  Element element = _target as Element;
  // Ensure renderStyle is available even for display:none elements
  element.renderStyle; // This triggers style computation if needed
}
```

#### Key Files Modified
- `webf/lib/src/css/style_declaration.dart` - Added render style computation
- `integration_tests/specs/css/css-variables/variable_in_display_none.ts` - Added test case

#### Test Case
```typescript
it('should resolve CSS variables in display:none elements', async () => {
  const div = document.createElement('div');
  div.style.setProperty('--primary-color', '#007bff');
  div.style.display = 'none';
  document.body.appendChild(div);
  
  const computedStyle = getComputedStyle(div);
  const primaryColor = computedStyle.getPropertyValue('--primary-color');
  
  expect(primaryColor).toBe('#007bff'); // Should not be empty
});
```

### HTTP Cache Invalidation Fix
Cache invalidation mechanism for handling corrupt image cache files.

#### Problem
When cached image files become corrupted (e.g., truncated downloads, disk errors), the app would fail to load images permanently until the cache was manually cleared. The error "Exception: Invalid image data" would persist across app restarts.

#### Solution
Implemented automatic cache invalidation when image decoding fails:

1. **Error Detection**: Catch image decoding failures in the HTTP cache layer
2. **Cache Removal**: Delete the corrupted cache entry from disk
3. **Retry Logic**: Allow the image to be re-downloaded on next access

#### Implementation Details

```dart
// In CachedNetworkImage error handling
try {
  // Attempt to decode image
  codec = await _instantiateImageCodec(bytes, targetWidth, targetHeight);
} catch (e) {
  // If decoding fails, invalidate the cache entry
  if (e.toString().contains('Invalid image data')) {
    final cache = NetworkAssetBundle.cache;
    await cache.remove(url);
    
    // Rethrow to trigger fallback/retry mechanisms
    rethrow;
  }
}
```

#### Key Components
- **NetworkAssetBundle.cache**: Extended to support cache removal
- **CachedNetworkImage**: Modified to detect and handle corrupt data
- **HTTPCache**: Added `remove()` method for cache invalidation

#### Benefits
- Automatic recovery from corrupted cache files
- No manual intervention required
- Maintains cache performance for valid entries
- Graceful degradation with proper error handling

### Image Loading Fallback
Fallback mechanism for image loading failures.

#### Problem
When images fail to load (network errors, invalid data, missing files), the app needs to gracefully handle the failure and potentially show a fallback image or error state.

#### Solution
Implemented a multi-tier fallback system:

1. **Primary Loading**: Attempt to load from the specified source
2. **Cache Fallback**: Try loading from cache if network fails
3. **Error Widget**: Display error widget if all attempts fail
4. **Retry Mechanism**: Allow manual or automatic retry

#### Implementation

```dart
class ImageFallbackHandler {
  static Widget buildWithFallback({
    required String url,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    int maxRetries = 3,
  }) {
    return Image.network(
      url,
      errorBuilder: (context, error, stackTrace) {
        // Log error for debugging
        debugPrint('Image failed to load: $url, error: $error');
        
        // Use custom error builder if provided
        if (errorBuilder != null) {
          return errorBuilder(context, error, stackTrace);
        }
        
        // Default error widget
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
        );
      },
    );
  }
}
```

#### Features
- Configurable retry attempts
- Custom error widgets
- Automatic cache invalidation on decode errors
- Network state awareness
- Progressive loading indicators

#### Best Practices
1. Always provide meaningful error states
2. Log failures for monitoring
3. Consider offline scenarios
4. Implement retry mechanisms for transient failures
5. Use placeholder images during loading

### iOS Build Troubleshooting
Guide for fixing iOS undefined symbol errors and understanding the build structure.

#### Common iOS Build Issues

##### Undefined Symbol Errors
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

##### Build Configuration Structure
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

##### Key Files to Check
1. **webf_ios.podspec**: Defines which source files are included
2. **CMakeLists.txt**: C++ build configuration
3. **prepare.sh**: Pre-build script that sets up the environment

##### Debugging Steps
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

### iOS WebF Source Compilation
iOS-specific source compilation details.

#### iOS Build System Overview
WebF uses CocoaPods to integrate C++ code into iOS Flutter apps. The build process involves:

1. **CMake Build**: Compiles C++ bridge code
2. **Pod Integration**: Links compiled libraries with Flutter
3. **Asset Bundling**: Includes required resources

#### Source File Patterns
The `webf_ios.podspec` must include all necessary source files:

```ruby
s.source_files = [
  'Classes/**/*.{h,m,mm}',           # iOS platform code
  'bridge/**/*.{h,cc,cpp}',          # C++ bridge code
  'bridge/bindings/**/*.{h,cc}',     # Binding implementations
  'bridge/third_party/**/*.{h,c,cc}' # Third-party dependencies
]
```

#### Common Compilation Issues

##### Missing Headers
```
fatal error: 'member_installer.h' file not found
```
**Fix**: Add to `preserve_paths` and `public_header_files`

##### Symbol Visibility
```
Undefined symbols for architecture x86_64
```
**Fix**: Ensure C++ symbols are exported:
```cpp
WEBF_EXPORT_C void SomeFunction() { }
```

##### Architecture Mismatches
**Fix**: Ensure all libraries are built for required architectures:
```ruby
s.pod_target_xcconfig = {
  'VALID_ARCHS' => 'arm64 x86_64',
}
```

#### Build Optimization
1. **Precompiled Headers**: Use PCH for common includes
2. **Module Maps**: Define module boundaries
3. **Link-Time Optimization**: Enable LTO for release builds

### Network Panel Implementation
DevTools network panel implementation details.

#### Overview
The Network Panel in WebF DevTools provides real-time monitoring of all network requests made by the WebF application, similar to Chrome DevTools.

#### Architecture

##### Request Interception
Network requests are intercepted at multiple levels:
1. **Dart HTTP Client**: Custom HTTP client wrapper
2. **Image Loading**: CachedNetworkImage integration  
3. **XHR/Fetch**: JavaScript API interception

##### Data Flow
```
Network Request → Interceptor → Event Dispatcher → DevTools Protocol → Chrome DevTools
```

#### Implementation Details

##### Request Tracking
```dart
class NetworkRequestTracker {
  final Map<String, NetworkRequest> _activeRequests = {};
  
  void onRequestWillBeSent(HttpClientRequest request) {
    final requestId = generateRequestId();
    final networkRequest = NetworkRequest(
      requestId: requestId,
      url: request.uri.toString(),
      method: request.method,
      headers: request.headers,
      timestamp: DateTime.now(),
    );
    
    _activeRequests[requestId] = networkRequest;
    _dispatchToDevTools('Network.requestWillBeSent', networkRequest.toJson());
  }
}
```

##### Response Handling
```dart
void onResponseReceived(HttpClientResponse response, String requestId) {
  final networkRequest = _activeRequests[requestId];
  if (networkRequest != null) {
    networkRequest.response = NetworkResponse(
      status: response.statusCode,
      statusText: response.reasonPhrase,
      headers: response.headers,
      mimeType: response.headers.contentType?.mimeType,
    );
    
    _dispatchToDevTools('Network.responseReceived', {
      'requestId': requestId,
      'response': networkRequest.response.toJson(),
    });
  }
}
```

#### Features Implemented
- Request/Response headers
- Timing information
- Response body preview
- Filtering by type
- Search functionality
- Export HAR

#### Integration Points
1. **HTTP Client**: Modified to emit events
2. **DevTools Protocol**: Network domain implementation
3. **Chrome DevTools**: Standard network panel UI

### UI Command Ring Buffer Design
Design documentation for the UI command ring buffer.

#### Overview
The UI Command Ring Buffer is a high-performance, lock-free data structure designed to handle UI commands between the JS thread and Flutter UI thread in WebF.

#### Design Goals
1. **Lock-free**: Minimize thread contention
2. **Bounded memory**: Fixed-size buffer with overwrite semantics
3. **Cache-friendly**: Optimize for CPU cache lines
4. **Type-safe**: Compile-time command validation

#### Architecture

##### Ring Buffer Structure
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

##### Command Structure
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

#### Performance Characteristics
- **Throughput**: ~10M ops/sec on modern CPUs
- **Latency**: <100ns per operation
- **Memory**: Fixed O(1) memory usage
- **Scalability**: Single producer, single consumer

#### Usage Patterns

##### Producer (JS Thread)
```cpp
void dispatchUICommand(const UICommand& cmd) {
  if (!command_buffer_.try_push(cmd)) {
    // Handle overflow - log or implement backpressure
    handleOverflow();
  }
}
```

##### Consumer (UI Thread)
```cpp
void processUICommands() {
  UICommand cmd;
  while (command_buffer_.try_pop(cmd)) {
    executeCommand(cmd);
  }
}
```

### UI Command Ring Buffer README
Usage guide for the UI command ring buffer.

#### Quick Start

##### Including the Buffer
```cpp
#include "ui_command_buffer.h"

// Create a buffer with 1024 command slots
UICommandBuffer<1024> command_buffer;
```

##### Sending Commands
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

##### Processing Commands
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

#### Best Practices

1. **Buffer Sizing**: Choose power-of-2 sizes (512, 1024, 2048)
2. **Overflow Handling**: Implement metrics and alerts
3. **Batching**: Process multiple commands per frame
4. **Priority**: Consider separate buffers for high-priority commands

#### Performance Tuning

##### Optimal Buffer Size
```cpp
// Measure and adjust based on workload
constexpr size_t BUFFER_SIZE = 
  DEBUG_BUILD ? 512 :    // Smaller for testing
  MOBILE ? 1024 :        // Mobile constraints  
  2048;                  // Desktop performance
```

##### CPU Affinity
```cpp
// Pin threads to cores for optimal cache usage
std::thread ui_thread([]() {
  setCPUAffinity(UI_THREAD_CORE);
  runUILoop();
});
```

### WebF DevTools Improvements
Recent improvements to WebF DevTools.

#### Performance Tab Enhancements

##### Real-time Metrics
- **FPS Monitor**: Live frame rate display
- **Memory Graph**: Heap and RSS tracking
- **CPU Profiler**: Sampling-based profiler

##### Implementation
```dart
class PerformanceMonitor {
  final _fpsCounter = FPSCounter();
  final _memoryTracker = MemoryTracker();
  
  void startMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrame);
    Timer.periodic(Duration(seconds: 1), _sampleMemory);
  }
  
  void _onFrame(List<FrameTiming> timings) {
    for (final timing in timings) {
      final fps = 1000 / timing.totalSpan.inMilliseconds;
      _fpsCounter.add(fps);
      _notifyDevTools('Performance.metrics', {
        'fps': fps,
        'frameTime': timing.totalSpan.inMicroseconds,
      });
    }
  }
}
```

#### Network Panel Features

##### Request Timing
- DNS lookup time
- TCP connection time  
- TLS handshake time
- Request/Response time
- Total duration

##### WebSocket Support
```dart
class WebSocketInspector {
  void inspectWebSocket(WebSocket ws) {
    ws.listen(
      (data) => _notifyDevTools('Network.webSocketFrameReceived', {
        'requestId': ws.hashCode.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'response': {'payloadData': data.toString()},
      }),
    );
  }
}
```

#### Console Improvements

##### Rich Object Inspection
- Dart object property expansion
- Collection previews
- Function source viewing

##### Error Stack Traces
- Source map support
- Dart/JS stack merging
- Click-to-source navigation

### WebF Integration Testing Guide
Guide for writing and running integration tests.

#### Test Structure

##### Directory Layout
```
integration_tests/
├── specs/
│   ├── css/
│   │   ├── css-display/
│   │   ├── css-position/
│   │   └── css-text/
│   ├── dom/
│   │   ├── elements/
│   │   ├── events/
│   │   └── nodes/
│   └── window/
├── assets/              # Test assets (images, files)
├── tools/               # Test utilities
└── tsconfig.json
```

##### Test File Format
```typescript
describe('Feature Category', () => {
  it('should behave correctly', async (done) => {
    const element = document.createElement('div');
    element.style.width = '100px';
    document.body.appendChild(element);
    
    await snapshot();  // Visual regression test
    
    expect(element.offsetWidth).toBe(100);
    done();
  });
});
```

#### Writing Tests

##### Async Tests
```typescript
it('should load image', async (done) => {
  const img = document.createElement('img');
  img.onload = () => {
    expect(img.complete).toBe(true);
    done();
  };
  img.src = 'assets/test-image.png';
  document.body.appendChild(img);
});
```

##### Snapshot Tests
```typescript
it('should render correctly', async () => {
  const container = document.createElement('div');
  container.innerHTML = `
    <div style="width: 200px; height: 100px; background: red;">
      <span style="color: white;">Test Content</span>
    </div>
  `;
  document.body.appendChild(container);
  
  await snapshot();  // Captures visual snapshot
});
```

#### Running Tests

##### Command Line
```bash
# Run all integration tests
cd integration_tests && npm test

# Run specific test file
npm test specs/css/css-display/display.ts

# Run with specific bridge binary
npm test -- --bridge-binary-path=/path/to/webf

# Update snapshots
npm test -- --update-snapshots
```

##### Test Helpers

###### Custom Matchers
```typescript
expect.extend({
  toHaveComputedStyle(element, property, value) {
    const actual = getComputedStyle(element)[property];
    return {
      pass: actual === value,
      message: () => `Expected ${property} to be ${value}, got ${actual}`
    };
  }
});
```

###### Utility Functions
```typescript
// Wait for next frame
function nextFrame(): Promise<void> {
  return new Promise(resolve => requestAnimationFrame(resolve));
}

// Wait for element to be visible
async function waitForVisible(element: Element): Promise<void> {
  while (getComputedStyle(element).display === 'none') {
    await nextFrame();
  }
}
```

### WebF Package Preparation
Steps for preparing WebF packages.

#### Pre-release Checklist

##### Version Bumping
1. Update version in `pubspec.yaml`
2. Update version in `package.json`
3. Update CHANGELOG.md
4. Tag the release: `git tag v0.x.x`

##### Build Verification
```bash
# Clean build all platforms
npm run build:clean
npm run build:bridge:all

# Run all tests
npm test

# Verify example app
cd example && flutter run
```

##### Package Testing
```bash
# Dry run publish
cd webf && flutter pub publish --dry-run

# Check package score
flutter pub global activate pana
pana webf
```

#### Publishing Process

##### Flutter Package
```bash
cd webf
flutter pub publish
```

##### NPM Packages
```bash
# Publish bridge binaries
cd bridge/build
npm publish

# Publish CLI tools
cd cli
npm run build
npm publish
```

#### Post-release

##### Documentation
1. Update API docs
2. Update README examples
3. Create release notes
4. Announce in channels

##### Verification
```bash
# Test published package
flutter create test_app
cd test_app
# Add webf dependency
flutter pub add webf
# Verify it works
```

### WebF Text Element Update Fix
Fix for text element update issues.

#### Problem
Text nodes were not updating properly when their content changed dynamically, especially in cases involving:
- Direct textContent updates
- Text node data modifications
- Mixed content updates (text + elements)

#### Root Cause
The text node's render object wasn't properly invalidating its layout when content changed, causing stale text to be displayed.

#### Solution

##### Text Node Updates
```dart
// In TextNode class
set data(String value) {
  if (_data != value) {
    _data = value;
    
    // Force render update
    if (isRendererAttached) {
      RenderTextBox textBox = renderer as RenderTextBox;
      textBox.data = value;
      textBox.markNeedsLayout();  // Critical: mark for layout
    }
  }
}
```

##### Parent Container Updates
```dart
// Ensure parent also updates when text changes
void _notifyTextChanged() {
  Element? parent = parentElement;
  if (parent != null && parent.isRendererAttached) {
    if (parent.renderer is RenderFlowLayout) {
      (parent.renderer as RenderFlowLayout).markNeedsLayout();
    }
  }
}
```

#### Test Case
```typescript
it('should update text content dynamically', async () => {
  const div = document.createElement('div');
  const textNode = document.createTextNode('Initial');
  div.appendChild(textNode);
  document.body.appendChild(div);
  
  await snapshot();  // Snapshot 1: "Initial"
  
  textNode.data = 'Updated';
  await snapshot();  // Snapshot 2: "Updated"
  
  div.textContent = 'Replaced';
  await snapshot();  // Snapshot 3: "Replaced"
});
```

#### Key Improvements
1. Proper invalidation chain
2. Batch update optimization
3. Memory leak prevention
4. Performance monitoring

### LCP (Largest Contentful Paint) Implementation
Implementation of LCP performance metric callbacks for WebFController.

#### Overview
LCP measures the render time of the largest content element visible within the viewport. This implementation adds LCP tracking to WebFController with callback support.

#### API Design

##### WebFController API
```dart
class WebFController {
  /// Callback fired when LCP is detected
  final void Function(int lcpTime)? onLargestContentfulPaint;
  
  WebFController({
    this.onLargestContentfulPaint,
    // ... other parameters
  });
}
```

##### Usage Example
```dart
final controller = WebFController(
  onLargestContentfulPaint: (int lcpTime) {
    print('LCP occurred at: $lcpTime ms');
    analytics.track('lcp', {'time': lcpTime});
  },
);
```

#### Implementation Details

##### LCP Detection
LCP is determined by tracking the largest element during page load:

```dart
class LCPTracker {
  Element? _largestElement;
  double _largestSize = 0;
  bool _hasStopped = false;
  
  void observeElement(Element element) {
    if (_hasStopped) return;
    
    final size = _calculateElementSize(element);
    if (size > _largestSize) {
      _largestSize = size;
      _largestElement = element;
      _reportLCP();
    }
  }
  
  double _calculateElementSize(Element element) {
    final rect = element.getBoundingClientRect();
    return rect.width * rect.height;
  }
}
```

##### Triggering Conditions
LCP observation stops when:
- User interaction occurs (click, tap, keyboard)
- Page visibility changes
- Browser navigation happens

##### Integration Points
1. **RenderObject**: Track when elements become visible
2. **Image Loading**: Update LCP when images load
3. **Text Rendering**: Consider text blocks for LCP
4. **Video Elements**: Track poster frames and first frames

#### Performance Considerations
- Minimal overhead during render
- Efficient size calculations
- Proper cleanup on dispose
- Debouncing for multiple updates

### Contentful Widget Detection
Detection system for ensuring FCP/LCP are only reported for widgets with actual visual content.

#### Problem
Transparent, empty, or non-visible widgets were incorrectly triggering FCP/LCP metrics, leading to inaccurate performance measurements.

#### Solution
Implement content detection that validates widgets have actual visual content before considering them for performance metrics.

#### Detection Criteria

##### Visual Content Definition
A widget has visual content if it meets ANY of these criteria:
1. **Text**: Non-empty, visible text
2. **Images**: Loaded images with non-zero dimensions
3. **Canvas**: Canvas with drawing operations
4. **Video**: Video elements with loaded frames
5. **Backgrounds**: Non-transparent background colors or images
6. **Borders**: Visible borders with non-zero width

##### Implementation
```dart
class ContentfulDetector {
  static bool hasVisualContent(RenderBox renderBox) {
    // Check for empty size
    if (!renderBox.hasSize || renderBox.size.isEmpty) {
      return false;
    }
    
    // Check opacity
    if (renderBox is RenderOpacity && renderBox.opacity == 0) {
      return false;
    }
    
    // Check for actual content
    if (renderBox is RenderParagraph) {
      return renderBox.text.toPlainText().trim().isNotEmpty;
    }
    
    if (renderBox is RenderImage) {
      return renderBox.image != null && 
             renderBox.size.width > 0 && 
             renderBox.size.height > 0;
    }
    
    if (renderBox is RenderDecoratedBox) {
      return _hasVisibleDecoration(renderBox.decoration);
    }
    
    // Check children recursively
    if (renderBox is ContainerRenderObjectMixin) {
      return renderBox.children.any(hasVisualContent);
    }
    
    return false;
  }
}
```

#### Integration with Metrics

##### FCP Detection
```dart
void _checkFirstContentfulPaint(RenderBox box) {
  if (!_fcpReported && ContentfulDetector.hasVisualContent(box)) {
    _fcpReported = true;
    final time = DateTime.now().difference(_navigationStart).inMilliseconds;
    widget.onFirstContentfulPaint?.call(time);
  }
}
```

##### LCP Updates
```dart
void _updateLargestContentfulPaint(RenderBox box) {
  if (!ContentfulDetector.hasVisualContent(box)) {
    return; // Skip non-contentful widgets
  }
  
  final size = box.size.width * box.size.height;
  if (size > _largestContentSize) {
    _largestContentSize = size;
    _largestContentTime = DateTime.now().difference(_navigationStart).inMilliseconds;
  }
}
```

### DevTools Performance Metrics Display
Unified display implementation for FP/FCP/LCP metrics in WebF DevTools.

#### Overview
Implements a unified performance metrics display in WebF DevTools that shows FP (First Paint), FCP (First Contentful Paint), and LCP (Largest Contentful Paint) metrics in real-time.

#### UI Design

##### Metrics Panel Layout
```
Performance Metrics
├── FP:  250ms  [━━━━━━|          ]
├── FCP: 380ms  [━━━━━━━━|        ]
└── LCP: 1250ms [━━━━━━━━━━━━━━|  ]
```

##### Implementation
```dart
class PerformanceMetricsPanel extends StatefulWidget {
  final PerformanceMetrics metrics;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          MetricRow(
            label: 'First Paint',
            value: metrics.fp,
            color: Colors.green,
            maxValue: 2000,
          ),
          MetricRow(
            label: 'First Contentful Paint',
            value: metrics.fcp,
            color: Colors.blue,
            maxValue: 2000,
          ),
          MetricRow(
            label: 'Largest Contentful Paint',
            value: metrics.lcp,
            color: Colors.orange,
            maxValue: 4000,
          ),
        ],
      ),
    );
  }
}
```

#### Data Collection

##### WebFController Integration
```dart
WebFController(
  onFirstPaint: (time) {
    devTools.updateMetric('fp', time);
  },
  onFirstContentfulPaint: (time) {
    devTools.updateMetric('fcp', time);
  },
  onLargestContentfulPaint: (time) {
    devTools.updateMetric('lcp', time);
  },
);
```

##### DevTools Protocol
```dart
class PerformanceDevToolsExtension {
  void sendMetrics(Map<String, int> metrics) {
    postEvent('Performance.metrics', {
      'metrics': [
        {'name': 'FirstPaint', 'value': metrics['fp']},
        {'name': 'FirstContentfulPaint', 'value': metrics['fcp']},
        {'name': 'LargestContentfulPaint', 'value': metrics['lcp']},
      ],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

#### Features

##### Real-time Updates
- Live metric updates as page loads
- Historical graph view
- Percentile calculations

##### Performance Budgets
```dart
class PerformanceBudget {
  static const Map<String, int> budgets = {
    'fp': 1000,   // 1 second
    'fcp': 1800,  // 1.8 seconds  
    'lcp': 2500,  // 2.5 seconds
  };
  
  static Color getStatusColor(String metric, int value) {
    final budget = budgets[metric]!;
    if (value <= budget * 0.7) return Colors.green;
    if (value <= budget) return Colors.orange;
    return Colors.red;
  }
}
```

### WebF Widget Unit Test Guide
Comprehensive guide for writing widget unit tests with WebFWidgetTestUtils.

#### Overview
WebFWidgetTestUtils provides a standardized way to write unit tests for WebF widgets, handling the complex setup required for testing WebF components.

#### Basic Usage

##### Test Setup
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 100));
  });
  
  testWidgets('test description', (WidgetTester tester) async {
    // Test implementation
  });
}
```

##### Using WebFWidgetTestUtils
```dart
testWidgets('should render element correctly', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'unique-test-name-${DateTime.now().millisecondsSinceEpoch}',
    html: '''
      <div id="test-element" style="width: 100px; height: 100px;">
        Test Content
      </div>
    ''',
  );
  
  // Access controller and elements
  final controller = prepared.controller;
  final element = prepared.getElementById('test-element');
  
  expect(element, isNotNull);
  expect(element.renderStyle.width, equals(100));
});
```

#### Advanced Testing

##### Testing Async Operations
```dart
testWidgets('should handle async updates', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'async-test',
    html: '<div id="target">Initial</div>',
  );
  
  final element = prepared.getElementById('target');
  
  // Trigger async update
  element.textContent = 'Updated';
  
  // Wait for update to propagate
  await tester.pump();
  
  // Verify update
  expect(element.textContent, equals('Updated'));
});
```

##### Testing Layout Properties
```dart
testWidgets('should calculate layout correctly', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'layout-test',
    html: '''
      <div style="display: flex; width: 300px;">
        <div style="flex: 1;">Item 1</div>
        <div style="flex: 2;">Item 2</div>
      </div>
    ''',
  );
  
  await tester.pump();
  
  final container = prepared.controller.view.document.querySelector(['div']);
  final children = container.children;
  
  // Access render boxes for layout info
  final child1Box = children[0].attachedRenderer;
  final child2Box = children[1].attachedRenderer;
  
  expect(child1Box.size.width, equals(100)); // 1/3 of 300px
  expect(child2Box.size.width, equals(200)); // 2/3 of 300px
});
```

#### Best Practices

##### 1. Unique Controller Names
Always use unique controller names to avoid conflicts:
```dart
controllerName: 'test-${testName}-${DateTime.now().millisecondsSinceEpoch}'
```

##### 2. Proper Cleanup
Always clean up after tests:
```dart
tearDown(() async {
  WebFControllerManager.instance.disposeAll();
  await Future.delayed(Duration(milliseconds: 100)); // Allow file handles to close
});
```

##### 3. Wait for Layouts
When testing layout properties, ensure layout is complete:
```dart
await tester.pump(); // Trigger layout
await tester.pumpAndSettle(); // Wait for animations
```

##### 4. Error Handling
Test error conditions:
```dart
testWidgets('should handle errors gracefully', (WidgetTester tester) async {
  final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: 'error-test',
    html: '<div id="test"></div>',
  );
  
  final element = prepared.getElementById('test');
  
  // Test invalid style
  expect(
    () => element.style.setProperty('width', 'invalid'),
    throwsA(isA<FormatException>()),
  );
});
```

#### Common Patterns

##### Testing Style Changes
```dart
final element = prepared.getElementById('target');
element.style.backgroundColor = 'red';
await tester.pump();

expect(element.renderStyle.backgroundColor, equals(Color(0xFFFF0000)));
```

##### Testing Events
```dart
final button = prepared.getElementById('button');
button.addEventListener('click', (event) {
  clickCount++;
});

// Simulate click
button.dispatchEvent(Event('click'));
await tester.pump();

expect(clickCount, equals(1));
```

##### Testing Render Objects
```dart
final element = prepared.getElementById('test');
final renderBox = element.attachedRenderer as RenderFlowLayout;

expect(renderBox.establishIFC, isTrue);
expect(renderBox.size, equals(Size(100, 100)));
```

### React Methods Generation Fix
Fix for React methods generation in WebF CLI.

#### Problem
The WebF CLI was not correctly generating method bindings for React components, causing runtime errors when calling methods on WebF-generated React components.

#### Root Cause
1. TypeScript method signatures were not being properly parsed
2. Method parameters were not correctly mapped to Dart types
3. React component lifecycle methods were being treated as regular methods

#### Solution

##### Method Detection
```typescript
function isReactLifecycleMethod(methodName: string): boolean {
  const lifecycleMethods = [
    'componentDidMount',
    'componentDidUpdate',
    'componentWillUnmount',
    'shouldComponentUpdate',
    'render',
  ];
  return lifecycleMethods.includes(methodName);
}

function generateMethodBindings(methods: MethodDeclaration[]) {
  return methods
    .filter(method => !isReactLifecycleMethod(method.name))
    .map(method => generateMethodBinding(method));
}
```

##### Parameter Mapping
```typescript
function mapTypeScriptTypeToDart(tsType: ts.Type): string {
  if (tsType.flags & ts.TypeFlags.String) return 'String';
  if (tsType.flags & ts.TypeFlags.Number) return 'num';
  if (tsType.flags & ts.TypeFlags.Boolean) return 'bool';
  if (tsType.flags & ts.TypeFlags.Void) return 'void';
  
  // Handle complex types
  if (tsType.isUnion()) {
    return 'dynamic'; // Or generate union type
  }
  
  return 'dynamic';
}
```

##### Code Generation
```dart
// Generated Dart code for React component methods
class MyComponentMethods {
  final dynamic _jsObject;
  
  MyComponentMethods(this._jsObject);
  
  void updateState(String key, dynamic value) {
    callMethod(_jsObject, 'updateState', [key, value]);
  }
  
  Future<String> fetchData(int id) async {
    final result = await promiseToFuture(
      callMethod(_jsObject, 'fetchData', [id])
    );
    return result as String;
  }
}
```

#### Test Cases
```typescript
// Input TypeScript
interface MyComponent {
  updateState(key: string, value: any): void;
  fetchData(id: number): Promise<string>;
  componentDidMount(): void; // Should be excluded
}

// Output Dart should include updateState and fetchData only
```

### Widget Element Extension System
Documentation for the WidgetElement extension system.

#### Overview
The WidgetElement extension system allows custom Flutter widgets to be integrated into WebF's DOM tree, enabling developers to use Flutter widgets as if they were HTML elements.

#### Architecture

##### Registration System
```dart
class WidgetElementRegistry {
  static final Map<String, WidgetElementBuilder> _builders = {};
  
  static void register(String tagName, WidgetElementBuilder builder) {
    _builders[tagName.toLowerCase()] = builder;
  }
  
  static WidgetElement? createElement(String tagName) {
    final builder = _builders[tagName.toLowerCase()];
    return builder?.call();
  }
}
```

##### WidgetElement Base Class
```dart
abstract class WidgetElement extends Element {
  Widget? _widget;
  
  @override
  RenderObject createRenderer() {
    return RenderWidgetElement(this);
  }
  
  /// Build the Flutter widget for this element
  Widget buildWidget(BuildContext context);
  
  /// Update widget when attributes change
  void updateWidget() {
    _widget = buildWidget(context);
    _markNeedsRebuild();
  }
}
```

#### Creating Custom Elements

##### Example: Video Player Element
```dart
class VideoPlayerElement extends WidgetElement {
  String get src => getAttribute('src') ?? '';
  bool get autoplay => hasAttribute('autoplay');
  
  @override
  Widget buildWidget(BuildContext context) {
    return VideoPlayer(
      url: src,
      autoplay: autoplay,
      onReady: () {
        dispatchEvent(Event('loadedmetadata'));
      },
    );
  }
  
  @override
  void attributeChangedCallback(String name, String? oldValue, String? newValue) {
    super.attributeChangedCallback(name, oldValue, newValue);
    
    if (name == 'src' || name == 'autoplay') {
      updateWidget();
    }
  }
}

// Registration
WidgetElementRegistry.register('video-player', () => VideoPlayerElement());
```

##### Usage in HTML
```html
<video-player 
  src="https://example.com/video.mp4" 
  autoplay
  id="myPlayer">
</video-player>

<script>
  const player = document.getElementById('myPlayer');
  player.addEventListener('loadedmetadata', () => {
    console.log('Video ready!');
  });
</script>
```

#### Advanced Features

##### Two-way Data Binding
```dart
class InputElement extends WidgetElement {
  final _controller = TextEditingController();
  
  String get value => _controller.text;
  set value(String v) {
    _controller.text = v;
    dispatchEvent(Event('input'));
  }
  
  @override
  Widget buildWidget(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (text) {
        dispatchEvent(Event('input'));
      },
    );
  }
}
```

##### Method Exposure
```dart
class ChartElement extends WidgetElement {
  final _chartKey = GlobalKey<ChartState>();
  
  void updateData(List<double> data) {
    _chartKey.currentState?.updateData(data);
  }
  
  @override
  Widget buildWidget(BuildContext context) {
    return Chart(key: _chartKey);
  }
  
  // Expose method to JavaScript
  @override
  dynamic getProperty(String name) {
    if (name == 'updateData') {
      return allowInterop(updateData);
    }
    return super.getProperty(name);
  }
}
```

#### Best Practices

1. **Attribute Observation**: Only observe attributes that affect the widget
2. **Memory Management**: Dispose controllers and subscriptions
3. **Event Dispatching**: Follow W3C event standards
4. **Performance**: Minimize widget rebuilds
5. **Accessibility**: Implement ARIA attributes when applicable


## Testing Guidelines

### Unit Tests (webf/test)
- See [Dart/Flutter Development Guide](webf/CLAUDE.md) for WebF widget unit testing with WebFWidgetTestUtils
- See [Integration Testing Guide](integration_tests/CLAUDE.md) for integration test patterns

### Integration Tests
- See [Integration Testing Guide](integration_tests/CLAUDE.md) for writing and running integration tests

### Flutter Integration Tests (webf/integration_test)
- See [Dart/Flutter Development Guide](webf/CLAUDE.md) for Flutter integration test details


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

## Performance Optimization
- See [Memory & Performance Guide](docs/MEMORY_PERFORMANCE.md) for optimization strategies and guidelines

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
webf codegen [output-dir] --flutter-package-src=<path> [--framework=react|vue] [--package-name=<name>] [--publish-to-npm] [--npm-registry=<url>]

# Examples
webf codegen my-typings --flutter-package-src=../webf_cupertino_ui
webf codegen --flutter-package-src=../webf_cupertino_ui  # Uses temporary directory
webf codegen my-typings --flutter-package-src=../webf_cupertino_ui --publish-to-npm
webf codegen --flutter-package-src=../webf_cupertino_ui --publish-to-npm --npm-registry=https://custom.registry.com/

# Interactive publishing (prompts after generation)
webf codegen my-typings --flutter-package-src=../webf_cupertino_ui
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

## WebF Architecture
- See [Architecture Overview](docs/ARCHITECTURE.md) for the complete WebF architecture pipeline diagram and explanation

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

# WebF Dart MCP Server Guide

## Overview
The webf_dart MCP server provides a comprehensive dependency graph analysis system for the WebF codebase. It maintains a graph of code entities (nodes) and their relationships (edges) across multiple programming languages.

## Core Statistics (as of current snapshot)
- **Total Nodes**: 8,244 (representing classes, methods, functions, files, etc.)
- **Total Edges**: 14,570 (representing relationships between entities)
- **Languages Supported**: Dart, C++, JavaScript, TypeScript, Swift, Java, Kotlin
- **Extraction Quality Score**: 75%

## Key MCP Tools Categories

### 1. Search and Navigation
- `mcp__webf_dart__get_node_by_name`: Find nodes by name pattern
- `mcp__webf_dart__get_nodes_by_directory`: Get all nodes in a directory
- `mcp__webf_dart__search_graph`: Advanced search with filters
- `mcp__webf_dart__search_by_pattern`: Structural pattern search (e.g., `class:*Controller`)
- `mcp__webf_dart__find_similar_nodes`: Find nodes similar to a given node

### 2. Dependency Analysis
- `mcp__webf_dart__get_dependencies`: Get what a node depends on
- `mcp__webf_dart__get_dependents`: Get what depends on a node
- `mcp__webf_dart__analyze_impact`: Analyze impact of changes to a file
- `mcp__webf_dart__get_call_chain`: Find function call paths between nodes
- `mcp__webf_dart__analyze_circular_dependencies`: Detect circular dependencies

### 3. Cross-Language Support
- `mcp__webf_dart__get_ffi_bindings`: Get FFI bindings between languages
- `mcp__webf_dart__trace_ffi_call_chain`: Trace calls across language boundaries
- `mcp__webf_dart__analyze_cross_language_dependencies`: Analyze dependencies between languages
- `mcp__webf_dart__analyze_ffi_interfaces`: Analyze FFI struct and function mappings

### 4. Code Quality Analysis
- `mcp__webf_dart__analyze_code_smells`: Detect god classes, feature envy, etc.
- `mcp__webf_dart__suggest_refactoring_candidates`: Identify refactoring opportunities
- `mcp__webf_dart__find_unused_code`: Find dead code
- `mcp__webf_dart__analyze_naming_consistency`: Check naming conventions
- `mcp__webf_dart__analyze_test_coverage`: Map test coverage

### 5. Architecture Analysis
- `mcp__webf_dart__analyze_architectural_layers`: Validate layer boundaries
- `mcp__webf_dart__analyze_coupling_metrics`: Calculate coupling between modules
- `mcp__webf_dart__suggest_module_boundaries`: Recommend better organization
- `mcp__webf_dart__get_module_metrics`: Get comprehensive module metrics

### 6. Performance Analysis
- `mcp__webf_dart__analyze_hot_paths`: Find frequently called code
- `mcp__webf_dart__find_n_plus_one_patterns`: Detect N+1 query patterns
- `mcp__webf_dart__analyze_memory_patterns`: Find potential memory issues

### 7. Type and Inheritance Analysis
- `mcp__webf_dart__get_overrides`: Find method override chains
- `mcp__webf_dart__analyze_inheritance_hierarchy`: Analyze class hierarchies
- `mcp__webf_dart__get_type_relationships`: Find TYPE_OF relationships
- `mcp__webf_dart__search_mixins`: Search for Dart mixins
- `mcp__webf_dart__search_structs`: Search for struct definitions

### 8. Project Insights
- `mcp__webf_dart__get_metrics`: Get overall project metrics
- `mcp__webf_dart__get_extraction_metrics`: Get extraction statistics
- `mcp__webf_dart__validate_extraction`: Validate graph quality
- `mcp__webf_dart__analyze_framework_usage`: Analyze framework usage patterns

## Usage Patterns

### Finding Code
```
# Find a specific class or function
mcp__webf_dart__get_node_by_name(name="WebFController")

# Search with patterns
mcp__webf_dart__search_by_pattern(structural_pattern="class:*Controller")

# Explore a directory
mcp__webf_dart__get_nodes_by_directory(directory="/webf/lib/src/css")
```

### Analyzing Dependencies
```
# Get dependencies of a node
mcp__webf_dart__get_dependencies(node_name="RenderStyle", max_depth=2)

# Analyze impact of changes
mcp__webf_dart__analyze_impact(file_path="/webf/lib/src/css/render_style.dart")

# Find circular dependencies
mcp__webf_dart__analyze_circular_dependencies(granularity="class")
```

### Code Quality
```
# Find code smells
mcp__webf_dart__analyze_code_smells(god_class_threshold=20)

# Suggest refactoring
mcp__webf_dart__suggest_refactoring_candidates(complexity_threshold=10)

# Check naming consistency
mcp__webf_dart__analyze_naming_consistency()
```

## Key Insights

### Most Complex Files
1. `/webf/lib/src/css/render_style.dart` - 206 nodes
2. `/webf/lib/src/rendering/box_model.dart` - 166 nodes
3. `/webf/lib/src/bridge/to_native.dart` - 165 nodes
4. `/webf/lib/src/html/html.dart` - 137 nodes
5. `/webf/lib/src/css/style_declaration.dart` - 124 nodes

### Language Distribution
- **Dart**: 6,681 nodes (81.1%) with highest edge density (18.65 edges/node)
- **JavaScript**: 1,018 nodes (12.3%)
- **C++**: 464 nodes (5.6%)
- **TypeScript**: 81 nodes (1.0%)

### Common Methods
Most frequently called: `add`, `toString`, `assert`, `remove`, `clear`, `contains`, `call`, `hasProperty`

## Important Notes

1. **FFI Analysis**: The system supports FFI analysis but currently shows no active FFI bindings. This might indicate:
   - FFI relationships need explicit extraction
   - The codebase uses a different Dart-C++ communication mechanism
   - The graph needs regeneration with FFI support enabled

2. **Circular Dependencies**: 577 circular dependencies detected, which may need attention

3. **Node Types**: The system tracks various node types including:
   - Classes, Methods, Functions
   - Files, Modules, Packages
   - Virtual nodes (framework components)
   - Structs, Mixins, Interfaces

4. **Extraction Quality**: 75% quality score indicates room for improvement in graph extraction

## Best Practices

1. **Start with search**: Use search tools to find relevant nodes before analysis
2. **Use appropriate depth**: Limit traversal depth to avoid overwhelming results
3. **Check extraction quality**: Validate that the graph accurately represents your code
4. **Combine tools**: Use multiple analysis tools together for comprehensive insights
5. **Monitor metrics**: Regular metric checks help maintain code quality

## Common Use Cases

1. **Understanding a feature**: Find the main class, analyze its dependencies
2. **Refactoring planning**: Identify impact, find circular dependencies, suggest boundaries
3. **Code review**: Check naming consistency, find code smells, analyze complexity
4. **Performance optimization**: Find hot paths, analyze memory patterns
5. **Documentation**: Generate outlines, find incomplete implementations