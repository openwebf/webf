# Contentful Widget Detection Implementation

## Overview
Implemented a contentful widget detection system to ensure FCP (First Contentful Paint) and LCP (Largest Contentful Paint) are only reported for RenderWidget instances that contain actual visual content, not just layout containers.

## Key Files Modified

### `/lib/src/widget/contentful_widget_detector.dart` (NEW)
- Created utility class to detect contentful painting in widgets and render objects
- Key methods:
  - `hasContentfulPaintFromFlutterWidget(RenderObject?)` - Checks if render object tree has contentful paint, excluding WebF elements
  - `getContentfulPaintAreaFromFlutterWidget(RenderObject?)` - Returns largest contentful child area for LCP calculation
  - `isContentfulWidget(Widget)` - Checks widget tree for contentful elements
- Detects various contentful elements:
  - Text (RenderParagraph with non-empty text)
  - Images (RenderImage with loaded image)
  - Custom painting (RenderCustomPaint with painter)
  - Decorations (backgrounds, borders, gradients, shadows)
  - Progress indicators
  - Physical models with elevation
  - ShaderMask and BackdropFilter

### `/lib/src/rendering/widget.dart`
- Updated `performPaint` method to use ContentfulWidgetDetector with area calculation:
  ```dart
  void performPaint(PaintingContext context, Offset offset) {
    // ... existing code ...
    
    if (!_hasReportedMetrics && widgetElement != null) {
      double contentfulArea = _getContentfulPaintArea(widgetElement);
      if (contentfulArea > 0) {
        _hasReportedMetrics = true;
        widgetElement.ownerDocument.controller.reportFP();
        widgetElement.ownerDocument.controller.reportFCP();
        widgetElement.ownerDocument.controller.reportLCPCandidate(widgetElement, contentfulArea);
      }
    }
  }

  double _getContentfulPaintArea(WidgetElement widgetElement) {
    return ContentfulWidgetDetector.getContentfulPaintAreaFromFlutterWidget(child);
  }
  ```
- Only reports FCP/LCP for widgets with actual visual content created by Flutter widgets
- Excludes render objects from nested RenderBoxModel or RenderWidget instances
- Uses actual contentful child area for accurate LCP measurement

### `/test/src/widget/contentful_widget_detector_test.dart` (NEW)
- Comprehensive unit tests for ContentfulWidgetDetector
- Tests detection of:
  - Text widgets (Text, RichText, SelectableText)
  - Image widgets (Image, Icon, etc.)
  - Graphics widgets (CustomPaint, CircleAvatar, etc.)
  - Decorated containers
  - Progress indicators
  - Layout widgets with contentful children
  - Invisible/transparent widgets (should not be contentful)
- All 14 tests passing

### `/integration_test/integration_test/widget_fcp_lcp_test.dart` (NEW)
- Integration tests for widget FCP/LCP reporting
- Tests that:
  - Contentful widgets (e.g., Text) trigger FCP/LCP
  - Non-contentful widgets (e.g., empty SizedBox) do not trigger FCP/LCP
  - LCP updates when larger contentful widgets are added
- Uses custom WebF widget elements for testing

### `/lib/widget.dart`
- Added export for ContentfulWidgetDetector

## Implementation Details

### Contentful Detection Logic
1. **Inherently Contentful Widgets**: Text, Images, CustomPaint, decorated containers with visible properties
2. **Layout Widgets**: Recursively check children for contentful elements
3. **Visibility Handling**: Skip fully transparent or offstage widgets
4. **RenderObject Detection**: Checks actual render properties (e.g., text content, image loading state)
5. **Area Calculation**: For LCP, uses the largest single contentful element's area, not the RenderWidget's total size

### Key Design Decisions
- Separated inherent contentfulness from recursive child checking to avoid infinite recursion
- Used both widget-level and render object-level detection for accuracy
- Only visible content triggers metrics (opacity > 0, not offstage)
- Added `hasContentfulPaintFromFlutterWidget` method that specifically excludes RenderBoxModel and RenderWidget
- Ensures only render objects created by the WidgetElement's state build() method are checked for contentful painting
- **Correct LCP Area Calculation**: `getContentfulPaintAreaFromFlutterWidget` returns the largest contentful child's area rather than the RenderWidget's full size, ensuring accurate LCP metrics when contentful children are smaller than their container
- **One-time Reporting**: Added `_hasReportedMetrics` flag to prevent duplicate FCP/LCP reports

## Usage
The contentful detection is automatically applied when RenderWidget paints. Only widgets containing actual visual content will trigger FCP and LCP metrics, preventing false positives from empty layout containers.

## Testing
- All unit tests pass (14 tests in contentful_widget_detector_test.dart)
- Integration tests created but require proper test environment setup
- Tests cover both positive cases (contentful widgets) and negative cases (non-contentful widgets)