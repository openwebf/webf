# WebFController Loading State Dump API

## Overview

The Loading State Dump API provides a comprehensive way to track and visualize the loading lifecycle of a WebFController. It records critical stages from initialization through evaluation, including performance metrics, phase parameters, and detailed network activity tracking.

## API Usage

### Basic Usage

```dart
WebFController controller = WebFController(
  viewportWidth: 360,
  viewportHeight: 640,
  bundle: WebFBundle.fromUrl('https://example.com'),
);

// Get the loading state dump
String loadingState = controller.dumpLoadingState();
print(loadingState);

// Get verbose output with parameters
String verboseLoadingState = controller.dumpLoadingState(verbose: true);
print(verboseLoadingState);
```

### Tracked Phases

The API automatically records the following lifecycle phases:

1. **constructor** - WebFController instantiation
2. **init** - Controller initialization
3. **attachToFlutter** - Attachment to Flutter widget tree
4. **loadStart** - Content loading begins
5. **resolveEntrypoint** - Bundle resolution (start/end)
6. **preload** - Preloading phase (if applicable)
7. **preRender** - Pre-rendering phase (if applicable)
8. **evaluateStart** - Evaluation begins (start/end)
9. **parseHTML** - HTML parsing (start/end with duration)
10. **evaluateScripts** - JavaScript evaluation (start/end with duration)
11. **evaluateComplete** - Evaluation complete
12. **domContentLoaded** - DOM ready event
13. **buildRootView** - Flutter widget tree construction for WebF content
14. **firstPaint** - First visual change
15. **firstContentfulPaint** - First content rendered
16. **windowLoad** - All resources loaded
17. **largestContentfulPaint** - LCP metric
18. **detachFromFlutter** - Detachment from widget tree
19. **dispose** - Controller disposal

### Script Element Tracking

The API tracks individual script elements during loading:

1. **scriptQueue** - Script element queued for loading
2. **scriptLoadStart** - Script resource loading begins
3. **scriptLoadComplete** - Script resource loaded successfully
4. **scriptExecuteStart** - Script execution begins
5. **scriptExecuteComplete** - Script execution completed
6. **scriptError** - Script loading or execution error

For each script, the following information is captured:
- Source URL or `<inline>` for inline scripts
- Script type (regular script or ES module)
- Loading mode (sync, async, or defer)
- Ready state (loading, interactive, complete, error)
- Data size
- Load duration
- Execution duration
- Total duration
- Error details (if failed)

### Network Activity Tracking

The API also tracks network requests during the loading process:

1. **networkStart** - Request initiated
2. **networkComplete** - Request completed successfully
3. **networkError** - Request failed with error

For each network request, the following information is captured:
- URL
- HTTP method
- Status code
- Response size
- Content type
- Duration
- Error details (if failed)

### Output Format

The dump provides an ASCII-formatted timeline with the following sections:

#### Header
Shows total duration, phase count, and network statistics:
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                        WebFController Loading State Dump                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Total Duration: 523ms
║ Phases: 10
║ Network Requests: 3 (2 successful, 0 failed, 1 errors)
║ Total Network Time: 320ms
║ Total Downloaded: 45.2KB
```

#### Timeline
Lists each phase with timing and optional parameters (in verbose mode):
```
║ Timeline:
║
║ constructor                           │ +0ms    (  0.0%)
║                                       │   └─ bundle: https://example.com
║                                       │   └─ viewportWidth: 360.0
║ init                                  │ +5ms    (  1.0%)
║                                       │   ⤷ 5ms
```

#### Visual Timeline
Provides a graphical representation of key phases:
```
║ Visual Timeline:
║
║ 0ms ─────────────────────────────────────────────────── 523ms
║ ▼                                                       init
║      ▼                                                  loadStart
```

### Integration with Performance Callbacks

The loading state dump integrates with WebF's performance callbacks:

```dart
WebFController controller = WebFController(
  // ... other parameters ...
  onDOMContentLoaded: (controller) {
    print(controller.dumpLoadingState());
  },
  onLoad: (controller) {
    print(controller.dumpLoadingState());
  },
  onFP: (time, evaluated) {
    print('First Paint recorded');
  },
  onFCP: (time, evaluated) {
    print('First Contentful Paint recorded');
  },
  onLCPFinal: (time, evaluated) {
    print('LCP finalized');
    print(controller.dumpLoadingState(verbose: true));
  },
);
```

### Example Output

#### Basic Output
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                        WebFController Loading State Dump                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Total Duration: 523ms
║ Phases: 18
║ Network Requests: 4 (3 successful, 0 failed, 1 errors)
║ Total Network Time: 320ms
║ Total Downloaded: 58.7KB
║ Script Elements: 4 (3 successful, 1 failed)
╠══════════════════════════════════════════════════════════════════════════════╣
║ Timeline:
║
║ constructor                           │ +0ms    (  0.0%)
║ init                                  │ +5ms    (  1.0%)
║ attachToFlutter                       │ +10ms   (  1.9%)
║ loadStart                             │ +15ms   (  2.9%)
║ resolveEntrypoint.start               │ +20ms   (  3.8%)
║ networkStart                          │ +25ms   (  4.8%)
║ networkComplete                       │ +120ms  ( 22.9%)
║ resolveEntrypoint.end                 │ +125ms  ( 23.9%)
║ evaluateStart.start                   │ +130ms  ( 24.9%)
║ parseHTML.start                       │ +135ms  ( 25.8%)
║ networkStart                          │ +140ms  ( 26.8%)
║ networkStart                          │ +145ms  ( 27.7%)
║ networkComplete                       │ +200ms  ( 38.2%)
║ parseHTML.end                         │ +205ms  ( 39.2%)
║                                       │   ⤷ 70ms
║ evaluateScripts.start                 │ +210ms  ( 40.2%)
║ evaluateScripts.end                   │ +260ms  ( 49.7%)
║                                       │   ⤷ 50ms
║ evaluateStart.end                     │ +265ms  ( 50.7%)
║ evaluateComplete                      │ +270ms  ( 51.6%)
║ networkError                          │ +245ms  ( 46.8%)
║ networkComplete                       │ +280ms  ( 53.5%)
║ domContentLoaded                      │ +350ms  ( 67.0%)
║ buildRootView                         │ +355ms  ( 67.9%)
║ firstPaint                            │ +400ms  ( 76.5%)
║ firstContentfulPaint                  │ +450ms  ( 86.0%)
║ windowLoad                            │ +523ms  (100.0%)
║
║ Visual Timeline:
║
║ 0ms ────────────────────────────────────────────────────────────── 523ms
║ ▼                                                                  init
║   ▼                                                                loadStart
║       ▼                                                            evaluateStart
║                         ▼                                          domContentLoaded
║                               ▼                                    firstPaint
║                                     ▼                              firstContentfulPaint
║                                           ▼                        windowLoad
╚══════════════════════════════════════════════════════════════════════════════╝
```

#### Verbose Output with Network Details
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                        WebFController Loading State Dump                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Total Duration: 523ms
║ Phases: 18
║ Network Requests: 4 (3 successful, 0 failed, 1 errors)
║ Total Network Time: 320ms
║ Total Downloaded: 58.7KB
║ Script Elements: 4 (3 successful, 1 failed)
╠══════════════════════════════════════════════════════════════════════════════╣
║ Timeline:
║
║ constructor                           │ +0ms    (  0.0%)
║                                       │   └─ bundle: https://example.com
║                                       │   └─ viewportWidth: 360.0
║                                       │   └─ viewportHeight: 640.0
║ init                                  │ +5ms    (  1.0%)
║                                       │   ⤷ 5ms
║ loadStart                             │ +15ms   (  2.9%)
║                                       │   ⤷ 10ms
║ resolveEntrypoint.start               │ +20ms   (  3.8%)
║                                       │   ⤷ 5ms
║ networkStart                          │ +25ms   (  4.8%)
║                                       │   └─ url: https://example.com/index.html
║                                       │   └─ method: GET
║                                       │   └─ requestCount: 1
║ networkComplete                       │ +120ms  ( 22.9%)
║                                       │   └─ url: https://example.com/index.html
║                                       │   └─ statusCode: 200
║                                       │   └─ responseSize: 45312
║                                       │   └─ duration: 95
║                                       │   └─ contentType: text/html
║ buildRootView                         │ +355ms  ( 67.9%)
║                                       │   └─ initialRoute: /
║                                       │   └─ hasHybridRoute: false
║
║ Network Activity:
║
║ ...example.com/index.html             │ GET    │ 200 │      44.2KB │    95ms
║ ...example.com/styles.css             │ GET    │ 200 │      12.5KB │    60ms
║ ...example.com/script.js              │ GET    │ 200 │       2.0KB │    55ms
║ ...example.com/missing.png            │ GET    │ ERROR │           - │   100ms
║
║ Script Elements:
║
║ ...example.com/app.js                 │ script │ async │ OK    │       2.0KB │   120ms
║ <inline script>                       │ script │ sync  │ OK    │        256B │    10ms
║ ...example.com/module.js              │ module │ defer │ OK    │       1.5KB │    85ms
║ ...example.com/error.js               │ script │ sync  │ ERROR │           - │   5000ms
║   └─ Error: Network timeout
║
║ Visual Timeline:
║
║ 0ms ────────────────────────────────────────────────────────────── 523ms
║ ▼                                                                  init
║   ▼                                                                loadStart
║       ▼                                                            evaluateStart
║                         ▼                                          domContentLoaded
║                               ▼                                    firstPaint
║                                     ▼                              firstContentfulPaint
║                                           ▼                        windowLoad
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Network Tracking Usage

### Programmatic Network Tracking

The LoadingStateDumper automatically tracks network requests during bundle resolution. For custom network tracking:

```dart
// Access the dumper directly
final dumper = controller.loadingStateDumper;

// Record a custom network request
dumper.recordNetworkRequestStart(
  'https://api.example.com/data',
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
);

// Record completion
dumper.recordNetworkRequestComplete(
  'https://api.example.com/data',
  statusCode: 200,
  responseSize: 1024,
  contentType: 'application/json',
);

// Record error
dumper.recordNetworkRequestError(
  'https://api.example.com/data',
  'Connection timeout',
);
```

### Analyzing Network Performance

```dart
// Get all network requests
final networkRequests = controller.loadingStateDumper.networkRequests;

// Filter successful requests
final successful = networkRequests.where((r) => r.isSuccessful).toList();

// Calculate average response time
final avgResponseTime = networkRequests
    .where((r) => r.duration != null)
    .map((r) => r.duration!.inMilliseconds)
    .reduce((a, b) => a + b) / networkRequests.length;

print('Average response time: ${avgResponseTime}ms');
```

## Script Element Tracking

The LoadingStateDumper automatically tracks individual script elements as they load and execute:

### Automatic Script Tracking

Script elements are automatically tracked by the WebFController during HTML parsing and script loading:

```dart
// Scripts are tracked automatically when loading HTML content
WebFController controller = WebFController(
  bundle: WebFBundle.fromUrl('https://example.com/page-with-scripts.html'),
);

// After loading, get script statistics
final dumper = controller.loadingStateDumper;
print('Total scripts: ${dumper.scriptElements.length}');
print('Successful scripts: ${dumper.successfulScriptsCount}');
print('Failed scripts: ${dumper.failedScriptsCount}');
```

### Analyzing Script Performance

```dart
// Get all script elements
final scripts = controller.loadingStateDumper.scriptElements;

// Filter by type
final modules = scripts.where((s) => s.isModule).toList();
final asyncScripts = scripts.where((s) => s.isAsync).toList();
final inlineScripts = scripts.where((s) => s.isInline).toList();

// Analyze performance
for (final script in scripts) {
  if (script.isSuccessful) {
    print('Script: ${script.source}');
    print('  Load time: ${script.loadDuration?.inMilliseconds}ms');
    print('  Execute time: ${script.executeDuration?.inMilliseconds}ms');
    print('  Total time: ${script.totalDuration?.inMilliseconds}ms');
    print('  Size: ${script.dataSize} bytes');
  }
}

// Find slowest scripts
final sortedByDuration = scripts
    .where((s) => s.totalDuration != null)
    .toList()
  ..sort((a, b) => b.totalDuration!.compareTo(a.totalDuration!));

print('Slowest scripts:');
for (final script in sortedByDuration.take(5)) {
  print('  ${script.source}: ${script.totalDuration!.inMilliseconds}ms');
}
```

### Script Information in Dump

When verbose mode is enabled, the dump includes a detailed script elements section showing:
- Script source (URL or `<inline>`)
- Script type (script or module)
- Loading mode (sync, async, or defer)
- Status (OK or ERROR)
- Data size
- Total duration
- Error details (if failed)

## Error Tracking

The LoadingStateDumper automatically tracks errors and exceptions that occur during the loading process:

### Recording Errors

```dart
// Errors are automatically recorded by WebFController
// But you can also manually record errors:
final dumper = controller.loadingStateDumper;

// Record an error for a specific phase
dumper.recordError(
  'parseHTML',
  Exception('Invalid HTML structure'),
  stackTrace: stackTrace,
  context: {
    'file': 'index.html',
    'line': 42,
  }
);

// Record an error for the current phase
dumper.recordCurrentPhaseError(
  Exception('Unexpected error'),
  context: {'detail': 'some context'}
);
```

### Error Information in Dump

When errors occur, they appear in the dump output:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                        WebFController Loading State Dump                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Total Duration: 523ms
║ Phases: 18
║ ⚠️  Errors: 2
║ Network Requests: 4 (2 successful, 0 failed, 2 errors)
╠══════════════════════════════════════════════════════════════════════════════╣
║ Timeline:
║ ...
║
║ ⚠️  Errors and Exceptions:
║
║ ERROR at +120ms during resolveEntrypoint:
║   Type: NetworkException
║   Message: Failed to fetch bundle from https://example.com/app.js
║   Context:
║     bundle: https://example.com/app.js
║     errorType: NetworkException
║   Stack trace:
║     #0      WebFBundle.resolve (package:webf/src/bundle.dart:42:5)
║     #1      WebFController._resolveEntrypoint (package:webf/src/controller.dart:1234:7)
║     ...
║
║ ERROR at +355ms during buildRootView:
║   Type: String
║   Message: The route path for /unknown was not found
║   Context:
║     initialRoute: /unknown
║     errorType: RouteNotFoundError
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Common Error Scenarios

1. **Network Errors** - Failed bundle fetching, timeouts
2. **Parsing Errors** - Invalid HTML/JavaScript syntax
3. **Evaluation Errors** - JavaScript runtime errors
4. **Build Errors** - Flutter widget tree construction failures
5. **Route Errors** - Missing hybrid routes

### Using Error Information for Debugging

```dart
// Check if any errors occurred
if (controller.loadingStateDumper.hasErrors) {
  final errors = controller.loadingStateDumper.errors;
  for (final error in errors) {
    print('Error in ${error.phase}: ${error.error}');
    if (error.context != null) {
      print('Context: ${error.context}');
    }
  }
}

// Get detailed dump when errors occur
controller.onLoadError = (FlutterError error, StackTrace stack) {
  // The error is automatically recorded in LoadingStateDumper
  print(controller.dumpLoadingState(verbose: true));
};
```

## Use Cases

1. **Performance Analysis** - Identify bottlenecks in the loading process and network latency
2. **Debugging** - Track the exact sequence of loading phases, network requests, and errors
3. **Monitoring** - Log loading states for production monitoring with network metrics and error tracking
4. **Testing** - Verify loading phase sequence, network behavior, and error handling in tests
5. **Optimization** - Find opportunities to improve loading performance and reduce network overhead
6. **Network Analysis** - Monitor request patterns, response times, and download sizes
7. **Error Diagnosis** - Quickly identify when and where errors occur in the loading lifecycle
8. **Troubleshooting** - Use the complete loading timeline with errors to diagnose complex issues

#### Network Activity Section (Verbose Mode)
Shows detailed information about each network request:
```
║ Network Activity:
║
║ ...example.com/bundle.js              │ GET    │ 200 │      45.2KB │   120ms
║ ...example.com/styles.css             │ GET    │ 200 │      12.5KB │    45ms
║ ...example.com/api/data               │ POST   │ 404 │       512B │    89ms
║ ...example.com/missing.png            │ GET    │ ERROR │           - │   5000ms
```

Each row displays:
- URL (truncated if too long, showing last 40 characters)
- HTTP method
- Status code (or ERROR/PENDING)
- Response size
- Request duration

## DevTools Integration

The Loading State Dump is integrated into WebF DevTools for visual debugging:

### Accessing in DevTools

1. Open the WebF Inspector floating panel (visible in debug mode)
2. Navigate to the Controllers tab
3. Click the timeline icon (⏱️) next to any controller
4. View the loading timeline in a modal dialog

### DevTools Features

- **Visual Timeline**: See the loading state dump in a formatted view
- **Error Highlighting**: Errors are highlighted with red indicators
- **Quick Stats**: View total duration, phase count, network requests, and errors
- **Copy to Clipboard**: Copy the entire dump for sharing or logging
- **Monospace Formatting**: Easy-to-read timeline with proper alignment

### Example DevTools View

```
┌─────────────────────────────────────────────────┐
│ Loading State Timeline - html/css               │
├─────────────────────────────────────────────────┤
│ ⚠️ 2 error(s) occurred during loading           │
├─────────────────────────────────────────────────┤
│ [Timeline content displayed here]               │
├─────────────────────────────────────────────────┤
│ Total Duration: 523ms │ Phases: 18 │           │
│ Network: 4 │ Errors: 2 │                       │
└─────────────────────────────────────────────────┘
```

## Implementation Details

The Loading State Dump API is implemented using:
- `LoadingStateDumper` class for phase recording and formatting
- `LoadingNetworkRequest` class for tracking individual network requests
- `LoadingError` class for capturing error details with context
- Integration points throughout the WebFController lifecycle
- Automatic timestamp recording for each phase
- Duration calculation between phases
- Network request tracking with start/complete/error states
- Error tracking with stack traces and context information
- ASCII art formatting for visual representation
- DevTools integration for visual debugging

The API has minimal performance impact as it only records timestamps and parameters during the loading process.