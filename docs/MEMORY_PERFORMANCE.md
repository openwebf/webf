# Memory and Performance Documentation

This document covers memory management, performance optimizations, and related fixes in the WebF codebase.

## HTTP Cache Invalidation Fix
Cache invalidation mechanism for handling corrupt image cache files.

### Problem
When cached image files become corrupted (e.g., truncated downloads, disk errors), the app would fail to load images permanently until the cache was manually cleared. The error "Exception: Invalid image data" would persist across app restarts.

### Solution
Implemented automatic cache invalidation when image decoding fails:

1. **Error Detection**: Catch image decoding failures in the HTTP cache layer
2. **Cache Removal**: Delete the corrupted cache entry from disk
3. **Retry Logic**: Allow the image to be re-downloaded on next access

### Implementation Details

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

### Key Components
- **NetworkAssetBundle.cache**: Extended to support cache removal
- **CachedNetworkImage**: Modified to detect and handle corrupt data
- **HTTPCache**: Added `remove()` method for cache invalidation

### Benefits
- Automatic recovery from corrupted cache files
- No manual intervention required
- Maintains cache performance for valid entries
- Graceful degradation with proper error handling

## Image Loading Fallback
Fallback mechanism for image loading failures.

### Problem
When images fail to load (network errors, invalid data, missing files), the app needs to gracefully handle the failure and potentially show a fallback image or error state.

### Solution
Implemented a multi-tier fallback system:

1. **Primary Loading**: Attempt to load from the specified source
2. **Cache Fallback**: Try loading from cache if network fails
3. **Error Widget**: Display error widget if all attempts fail
4. **Retry Mechanism**: Allow manual or automatic retry

### Implementation

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

### Features
- Configurable retry attempts
- Custom error widgets
- Automatic cache invalidation on decode errors
- Network state awareness
- Progressive loading indicators

### Best Practices
1. Always provide meaningful error states
2. Log failures for monitoring
3. Consider offline scenarios
4. Implement retry mechanisms for transient failures
5. Use placeholder images during loading

## Network Panel Implementation
DevTools network panel implementation details.

### Overview
The Network Panel in WebF DevTools provides real-time monitoring of all network requests made by the WebF application, similar to Chrome DevTools.

### Architecture

#### Request Interception
Network requests are intercepted at multiple levels:
1. **Dart HTTP Client**: Custom HTTP client wrapper
2. **Image Loading**: CachedNetworkImage integration  
3. **XHR/Fetch**: JavaScript API interception

#### Data Flow
```
Network Request ’ Interceptor ’ Event Dispatcher ’ DevTools Protocol ’ Chrome DevTools
```

### Implementation Details

#### Request Tracking
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

#### Response Handling
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

### Features Implemented
- Request/Response headers
- Timing information
- Response body preview
- Filtering by type
- Search functionality
- Export HAR

### Integration Points
1. **HTTP Client**: Modified to emit events
2. **DevTools Protocol**: Network domain implementation
3. **Chrome DevTools**: Standard network panel UI

## WebF DevTools Improvements
Recent improvements to WebF DevTools.

### Performance Tab Enhancements

#### Real-time Metrics
- **FPS Monitor**: Live frame rate display
- **Memory Graph**: Heap and RSS tracking
- **CPU Profiler**: Sampling-based profiler

#### Implementation
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

### Network Panel Features

#### Request Timing
- DNS lookup time
- TCP connection time  
- TLS handshake time
- Request/Response time
- Total duration

#### WebSocket Support
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

### Console Improvements

#### Rich Object Inspection
- Dart object property expansion
- Collection previews
- Function source viewing

#### Error Stack Traces
- Source map support
- Dart/JS stack merging
- Click-to-source navigation

## LCP (Largest Contentful Paint) Implementation
Implementation of LCP performance metric callbacks for WebFController.

### Overview
LCP measures the render time of the largest content element visible within the viewport. This implementation adds LCP tracking to WebFController with callback support.

### API Design

#### WebFController API
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

#### Usage Example
```dart
final controller = WebFController(
  onLargestContentfulPaint: (int lcpTime) {
    print('LCP occurred at: $lcpTime ms');
    analytics.track('lcp', {'time': lcpTime});
  },
);
```

### Implementation Details

#### LCP Detection
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

#### Triggering Conditions
LCP observation stops when:
- User interaction occurs (click, tap, keyboard)
- Page visibility changes
- Browser navigation happens

#### Integration Points
1. **RenderObject**: Track when elements become visible
2. **Image Loading**: Update LCP when images load
3. **Text Rendering**: Consider text blocks for LCP
4. **Video Elements**: Track poster frames and first frames

### Performance Considerations
- Minimal overhead during render
- Efficient size calculations
- Proper cleanup on dispose
- Debouncing for multiple updates

## Contentful Widget Detection
Detection system for ensuring FCP/LCP are only reported for widgets with actual visual content.

### Problem
Transparent, empty, or non-visible widgets were incorrectly triggering FCP/LCP metrics, leading to inaccurate performance measurements.

### Solution
Implement content detection that validates widgets have actual visual content before considering them for performance metrics.

### Detection Criteria

#### Visual Content Definition
A widget has visual content if it meets ANY of these criteria:
1. **Text**: Non-empty, visible text
2. **Images**: Loaded images with non-zero dimensions
3. **Canvas**: Canvas with drawing operations
4. **Video**: Video elements with loaded frames
5. **Backgrounds**: Non-transparent background colors or images
6. **Borders**: Visible borders with non-zero width

#### Implementation
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

### Integration with Metrics

#### FCP Detection
```dart
void _checkFirstContentfulPaint(RenderBox box) {
  if (!_fcpReported && ContentfulDetector.hasVisualContent(box)) {
    _fcpReported = true;
    final time = DateTime.now().difference(_navigationStart).inMilliseconds;
    widget.onFirstContentfulPaint?.call(time);
  }
}
```

#### LCP Updates
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

## DevTools Performance Metrics Display
Unified display implementation for FP/FCP/LCP metrics in WebF DevTools.

### Overview
Implements a unified performance metrics display in WebF DevTools that shows FP (First Paint), FCP (First Contentful Paint), and LCP (Largest Contentful Paint) metrics in real-time.

### UI Design

#### Metrics Panel Layout
```
Performance Metrics
   FP:  250ms  [|          ]
   FCP: 380ms  [|        ]
   LCP: 1250ms [|  ]
```

#### Implementation
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

### Data Collection

#### WebFController Integration
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

#### DevTools Protocol
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

### Features

#### Real-time Updates
- Live metric updates as page loads
- Historical graph view
- Percentile calculations

#### Performance Budgets
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

## Performance Optimization Guidelines

### Caching Strategies
1. **Identify Repeated Operations**: Look for operations that:
   - Parse the same files multiple times
   - Perform identical type conversions
   - Read file contents repeatedly

2. **Implement Caching**:
   ```typescript
   // File content cache
   const cache = new Map<string, CachedType>();

   // Cache with validation
   if (cache.has(key)) {
     return cache.get(key);
   }
   const result = expensiveOperation();
   cache.set(key, result);
   ```

3. **Provide Cache Clearing**: Always implement a clear function:
   ```typescript
   export function clearCaches() {
     cache.clear();
   }
   ```

### Batch Processing
For file operations, process in batches to maximize parallelism:
```typescript
async function processFilesInBatch<T>(
  items: T[],
  batchSize: number,
  processor: (item: T) => Promise<void>
): Promise<void> {
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    await Promise.all(batch.map(processor));
  }
}
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

### Incremental Development Approach
1. Make one logical change at a time
2. Build after each change: `npm run build`
3. Run relevant tests after each change
4. Commit working states before moving to the next feature
5. When debugging complex issues:
   - Create minimal reproduction scripts
   - Use console.log or debugger strategically
   - Clean up debug code before finalizing