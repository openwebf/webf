# FCP (First Contentful Paint) Implementation

## Overview
Implemented FCP performance metric tracking in WebFController to measure when the browser first renders any text, image (including background images), SVG, or non-white canvas content.

## Implementation Details

### 1. WebFController Changes (webf/lib/src/launcher/controller.dart)

#### Added FCP State Variables
```dart
// FCP tracking
bool _fcpReported = false;
double _fcpTime = 0;
```

**Important**: FCP state is reset in both `load()` method and `initializeLCPTracking()` method to ensure proper tracking when controllers are reused.

#### Added Callback
```dart
typedef FCPHandler = void Function(double fcpTime);
FCPHandler? onFCP;  // Callback when FCP occurs
```

#### Added Public Getters
```dart
bool get fcpReported => _fcpReported;
double get fcpTime => _fcpTime;
```

#### Key Method
```dart
void reportFCP() {
  // Don't report if already reported or not initialized
  if (_fcpReported || _navigationStartTime == null) return;
  
  _fcpReported = true;
  _fcpTime = DateTime.now().difference(_navigationStartTime!).inMilliseconds.toDouble();
  
  // Fire the FCP callback
  if (onFCP != null) {
    onFCP!(_fcpTime);
  }
}
```

#### Load Method Reset
The `load()` method now resets FCP state when loading new content:
```dart
// Reset FCP tracking for new navigation
_fcpReported = false;
_fcpTime = 0;
```

### 2. Content Type Integration

#### RenderWidget (webf/lib/src/rendering/widget.dart)
Added FCP and LCP reporting in `performPaint()` for WidgetElement content:
```dart
// Report FCP when RenderWidget with content is first painted
if (renderStyle.target is WidgetElement && firstChild != null && hasSize && !size.isEmpty) {
  final widgetElement = renderStyle.target as WidgetElement;
  widgetElement.ownerDocument.controller.reportFCP();
  
  // Report LCP candidate for RenderWidget
  double visibleArea = size.width * size.height;
  if (visibleArea > 0) {
    widgetElement.ownerDocument.controller.reportLCPCandidate(widgetElement, visibleArea);
  }
}
```

#### Text Content (webf/lib/src/rendering/paragraph.dart)
Added `_reportFCP()` method that reports FCP when text with actual visible content is painted:
```dart
void _reportFCP() {
  // Report FCP when text is painted with actual content
  if (parent is RenderTextBox && !size.isEmpty && _lineRenders.isNotEmpty) {
    final RenderTextBox parentTextBox = parent as RenderTextBox;
    final Element element = parentTextBox.renderStyle.target;
    
    // Check if this text has actual visible content
    bool hasVisibleContent = false;
    for (int i = 0; i < _lineRenders.length; i++) {
      if (_lineRenders[i].lineRect.width > 0 && _lineRenders[i].fontHeight > 0) {
        hasVisibleContent = true;
        break;
      }
    }
    
    if (hasVisibleContent) {
      element.ownerDocument.controller.reportFCP();
    }
  }
}
```

#### Image Elements (webf/lib/src/html/img.dart)
Reports FCP when images (including SVG images) are loaded and painted:
```dart
// In _handleImageFrame for regular images
SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
  _dispatchLoadEvent();
  _reportLCPCandidate();
  // Report FCP when image is first painted
  ownerDocument.controller.reportFCP();
});

// In _loadSVGImage for SVG images
SchedulerBinding.instance.addPostFrameCallback((_) {
  renderStyle.requestWidgetToRebuild(UpdateRenderReplacedUpdateReason());
  // Report FCP when SVG image is first painted
  ownerDocument.controller.reportFCP();
});
```

#### Inline SVG Elements (webf/lib/src/svg/rendering/root.dart)
Reports FCP when inline SVG content is painted:
```dart
void performPaint(PaintingContext context, Offset offset) {
  // Report FCP when SVG content is first painted
  if (renderStyle.target is SVGSVGElement && hasSize && !size.isEmpty) {
    final svgElement = renderStyle.target as SVGSVGElement;
    svgElement.ownerDocument.controller.reportFCP();
  }
  // ... rest of paint logic
}
```

#### Canvas Elements (webf/lib/src/html/canvas/canvas_painter.dart)
Reports FCP when canvas has content painted:
```dart
Picture picture = pictureRecorder.endRecording();
if (actionLen > 0) {
  paintedPictures.add(picture);
  
  // Report FCP when canvas has content painted for the first time
  if (context != null && context!.canvas != null) {
    context!.canvas.ownerDocument.controller.reportFCP();
  }
}
```

#### Background Images (webf/lib/src/rendering/box_decoration_painter.dart)
Reports both FCP and LCP when CSS background images are painted:
```dart
// Report FCP when background image is painted (excluding CSS gradients)
if (_imagePainter!._image != null && !rect.isEmpty) {
  renderStyle.target.ownerDocument.controller.reportFCP();
  
  // Report LCP candidate for background images
  double visibleArea = rect.width * rect.height;
  if (visibleArea > 0) {
    renderStyle.target.ownerDocument.controller.reportLCPCandidate(renderStyle.target, visibleArea);
  }
}
```

## Usage

### Basic Usage with WebFController
```dart
final controller = WebFController(
  viewportWidth: 360,
  viewportHeight: 640,
  onFCP: (double time) {
    print('First Contentful Paint: $time ms');
  },
);
```

### With WebFControllerManager
```dart
await WebFControllerManager.instance.addWithPreload(
  name: 'my_page',
  createController: () => WebFController(
    viewportWidth: 360,
    viewportHeight: 640,
    onFCP: (time) => analytics.track('fcp', time),
  ),
  bundle: bundle,
);
```

## FCP Triggering Rules

FCP is reported when the first of any of these content types is painted:
1. **RenderWidget** - WidgetElement content rendered by Flutter widgets
2. **Text** - Any visible text content with non-zero size
3. **Images** - Both regular images and SVG images when loaded
4. **Inline SVG** - When SVG elements are rendered
5. **Canvas** - When canvas has content drawn to it
6. **Background Images** - CSS background images loaded via url() (excludes CSS gradients)

## Integration Tests

Created comprehensive integration tests in `webf/integration_test/integration_test/fcp_integration_test.dart`:
1. Text content FCP tracking
2. Image loading FCP tracking
3. SVG content (both as image and inline)
4. Canvas content with drawing operations
5. FCP reported only once per page load
6. Navigation resets FCP
7. Invisible content doesn't trigger FCP
8. Mixed content types
9. Prerendering mode support
10. CSS background images (excludes CSS gradients)
11. RenderWidget content tracking

## Important Notes

1. **Single Report** - FCP is reported only once per page load, when the first content is painted
2. **Navigation Reset** - FCP state is reset when navigating to a new page via `controller.load()`
3. **Visibility Check** - Only visible content triggers FCP (not display:none, visibility:hidden, or opacity:0)
4. **Performance** - FCP tracking has minimal overhead as it only checks once per paint operation
5. **Accuracy** - Reports time in milliseconds from navigation start

## Differences from LCP

Unlike LCP which tracks the largest content and can update multiple times:
- FCP fires only once when the first content appears
- FCP doesn't track size, only presence of content
- FCP is simpler with no candidate tracking or finalization
- FCP typically occurs before LCP

## Future Improvements

1. Expose FCP data to JavaScript via window.performance API
2. Add FCP data to DevTools performance panel
3. Support for FCP in web workers
4. Add support for other Core Web Vitals metrics