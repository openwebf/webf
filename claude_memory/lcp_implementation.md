# LCP (Largest Contentful Paint) Implementation

## Overview
Implemented LCP performance metric tracking in WebFController to measure the render time of the largest content element visible within the viewport.

## Implementation Details

### 1. WebFController Changes (webf/lib/src/launcher/controller.dart)

#### Added LCP State Variables
```dart
// LCP tracking
DateTime? _navigationStartTime;
bool _lcpReported = false;
double _largestContentfulPaintSize = 0;
double _lastReportedLCPTime = 0;
Timer? _lcpAutoFinalizeTimer;
WeakReference<Element>? _currentLCPElement;
```

#### Added Callbacks
```dart
final WebFLCPCallback? onLCP;       // Progressive LCP updates
final WebFLCPCallback? onLCPFinal;  // Final LCP when finalized
```

#### Key Methods
- `initializeLCPTracking(DateTime startTime)` - Initialize LCP tracking when viewport is laid out
- `reportLCPCandidate(Element element, double contentSize)` - Report potential LCP candidates
- `finalizeLCP()` - Finalize LCP measurement (called on user interaction or timeout)
- `notifyElementRemoved(Element element)` - Handle LCP element removal from DOM

### 2. Event Target Changes (webf/lib/src/dom/event_target.dart)

Added `_finalizeLCPOnUserInteraction()` to finalize LCP when user interacts:
- Triggers on: click, touchstart, mousedown, keydown
- Calls `controller.finalizeLCP()` to stop tracking

### 3. Rendering Integration

#### Image Element (webf/lib/src/html/img.dart)
- Reports LCP candidates after image loads successfully
- Calculates visible area and reports to controller

#### Text Elements (webf/lib/src/rendering/paragraph.dart)
- Reports text elements as LCP candidates during layout
- Only reports elements with actual text content

#### Box Model (webf/lib/src/rendering/box_model.dart)
- Added `shouldReportLCP` getter to determine if element should be tracked
- Excludes: invisible elements, elements with opacity 0, positioned outside viewport

### 4. Widget Integration (webf/lib/src/widget/webf.dart)

#### AutoManagedWebFState
- Captures LCP start time when state is created
- Initializes LCP tracking when controller is ready
- Ensures LCP tracking persists across controller replacements

### 5. DevTools Integration (webf/lib/src/devtools/inspector_panel.dart)
- Added LCP data to performance panel
- Shows: navigation start time, LCP status, largest element info, reported time

## Usage

### Basic Usage with WebFController
```dart
final controller = WebFController(
  viewportWidth: 360,
  viewportHeight: 640,
  onLCP: (double time) {
    print('LCP candidate: $time ms');
  },
  onLCPFinal: (double time) {
    print('Final LCP: $time ms');
  },
);
```

### With WebFControllerManager (Recommended)
```dart
await WebFControllerManager.instance.addWithPreload(
  name: 'my_page',
  createController: () => WebFController(
    viewportWidth: 360,
    viewportHeight: 640,
    onLCP: (time) => print('LCP: $time ms'),
    onLCPFinal: (time) => print('Final LCP: $time ms'),
  ),
  bundle: bundle,
);
```

### Using Setup Callback
```dart
await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
  name: 'my_page',
  createController: () => WebFController(),
  bundle: bundle,
  setup: (controller) {
    controller.onLCP = (time) => analytics.track('lcp', time);
    controller.onLCPFinal = (time) => analytics.track('lcp_final', time);
  },
);
```

## LCP Finalization Rules

LCP is automatically finalized when:
1. **User Interaction** - Click, tap, scroll, or key press
2. **Timeout** - 5 seconds elapsed without interaction
3. **Navigation** - Loading new content via `controller.load()`

## Testing

### Integration Tests (webf/integration_test/lcp_integration_test.dart)
1. Text content LCP tracking
2. Image loading LCP tracking
3. Navigation between pages (LCP reset)
4. User interaction finalization
5. Loading animation replacement
6. Auto-finalization timeout
7. Prerendering mode support

### Known Issues Fixed
1. Navigation test - Fixed by calling `initializeLCPTracking` in the `setup` callback when using `forceReplace: true`
2. User interaction - Events now properly trigger LCP finalization
3. Timer duration - Changed from 10s to 5s per spec
4. Controller replacement - When using WebFControllerManager with `forceReplace: true`, LCP must be initialized in the setup callback

## Important Notes

1. **Element Tracking** - Uses WeakReference to avoid memory leaks
2. **Performance** - Only tracks visible elements above minimum size
3. **Accuracy** - Reports time in milliseconds from navigation start
4. **State Management** - LCP state managed in controller, initialization in widget
5. **Controller Lifecycle** - LCP callbacks should be set via setup parameter when using WebFControllerManager

## Future Improvements

1. Add support for other Core Web Vitals (FID, CLS)
2. Expose LCP data to JavaScript via window.performance API
3. Add LCP element details to DevTools
4. Support for intersection observer-based tracking