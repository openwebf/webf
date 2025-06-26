# LCP Reporting Locations in WebF

This document details where LCP (Largest Contentful Paint) is fired in the WebF codebase and how LCP completion is handled.

## Where LCP is Reported

LCP candidates are reported from multiple locations in the WebF rendering pipeline:

### 1. Images (lib/src/html/img.dart)

**Location**: `_handleImageFrame()` method
- Triggered when image frames are loaded and decoded
- Reports LCP after the first frame is loaded
- Calls `_reportLCPCandidate()` in a post-frame callback

**LCP Calculation**:
```dart
void _reportLCPCandidate() {
  if (naturalWidth > 0 && 
      naturalHeight > 0 && 
      renderStyle.attachedRenderBoxModel != null &&
      !renderStyle.attachedRenderBoxModel!.size.isEmpty) {
    double visibleArea = renderStyle.attachedRenderBoxModel!.calculateVisibleArea();
    if (visibleArea > 0) {
      ownerDocument.controller.reportLCPCandidate(this, visibleArea);
    }
  }
}
```

**Also Reports**:
- FP (First Paint) when image is first painted
- FCP (First Contentful Paint) when image is first painted

### 2. Text Content (lib/src/rendering/paragraph.dart)

**Location**: `_reportLCPCandidate()` method in `WebFRenderParagraph`
- Called during the paint phase
- Calculates actual text bounding box area

**LCP Calculation**:
```dart
double _calculateTextBoundingBoxArea(RenderTextBox parentTextBox) {
  // Calculates the actual text bounds based on line renders
  // Finds min/max bounds of all text lines
  // Creates intersection with viewport
  // Returns visible text area in pixels
}
```

**Also Reports**:
- FP when text is painted with visible content
- FCP in `_reportFCP()` method

### 3. Background Images (lib/src/rendering/box_decoration_painter.dart)

**Location**: `_paintBackgroundImage()` method
- Triggered when background images are painted
- Reports LCP based on the visible area of the background image rect

**LCP Reporting**:
```dart
// Report LCP candidate for background images
double visibleArea = rect.width * rect.height;
if (visibleArea > 0) {
  renderStyle.target.ownerDocument.controller.reportLCPCandidate(renderStyle.target, visibleArea);
}
```

**Also Reports**:
- FP when background image is painted
- FCP when background image is painted

### 4. Flutter Widgets (lib/src/rendering/widget.dart)

**Location**: `performPaint()` method in `WebFRenderParagraph`
- For RenderWidget containing Flutter content
- Uses `ContentfulWidgetDetector` to determine if widget has contentful content

**LCP Reporting**:
```dart
double contentfulArea = _getContentfulPaintArea(widgetElement);
if (contentfulArea > 0) {
  widgetElement.ownerDocument.controller.reportFP();
  widgetElement.ownerDocument.controller.reportFCP();
  widgetElement.ownerDocument.controller.reportLCPCandidate(widgetElement, contentfulArea);
}
```

## How LCP is Finalized

LCP measurement continues until it is finalized, which happens in two ways:

### 1. User Interaction (lib/src/dom/event_target.dart)

**Method**: `_finalizeLCPOnUserInteraction()`
- Called during event dispatch in `_executeDispatchEvent()`
- Triggers on user interaction events:
  - click
  - touchstart
  - mousedown
  - keydown

**Implementation**:
```dart
void _finalizeLCPOnUserInteraction(Event event) {
  if (event.type == EVENT_CLICK || 
      event.type == EVENT_TOUCH_START || 
      event.type == 'mousedown' || 
      event.type == EVENT_KEY_DOWN) {
    if (this is Node) {
      final Node node = this as Node;
      node.ownerDocument.controller.finalizeLCP();
    } else if (this is Window) {
      final Window window = this as Window;
      window.document.controller.finalizeLCP();
    }
  }
}
```

### 2. Auto-finalization Timer

**Location**: `initializePerformanceTracking()` in WebFController
- Sets up a 5-second timer when tracking is initialized
- Ensures LCP is finalized even without user interaction

**Implementation**:
```dart
metrics.lcpAutoFinalizeTimer = Timer(Duration(seconds: 5), () {
  if (!metrics.lcpReported) {
    finalizeLCP();
  }
});
```

## Key Methods in WebFController

### reportLCPCandidate()
- Records potential LCP candidates if they're larger than previous ones
- Updates `largestContentfulPaintSize` and `currentLCPElement`
- Fires progressive `onLCP` callbacks
- Stores weak reference to the LCP element

### finalizeLCP()
- Marks LCP as reported to prevent further candidates
- Fires `onLCPFinal` callback with the last recorded LCP time
- Cancels auto-finalization timer
- Uses the last reported LCP time (not the finalization time)

### initializePerformanceTracking()
- Called when viewport is first laid out
- Sets navigation start time for the current route
- Resets all performance metrics
- Sets up 5-second auto-finalization timer

## Additional Performance Metrics

### First Paint (FP)
Reported for non-default visual changes:
- Background colors (non-transparent)
- Gradients
- Borders
- Box shadows

### First Contentful Paint (FCP)
Reported alongside LCP for actual content:
- Images
- Text with visible content
- Background images
- SVG images
- Contentful Flutter widgets

## Route-Specific Tracking

All LCP reporting is route-aware, with metrics tracked separately for each route:
- Metrics are initialized when a route is pushed
- Each route maintains its own LCP candidates and timers
- Both legacy and route-aware callbacks are fired
- Metrics are cleaned up when routes are removed