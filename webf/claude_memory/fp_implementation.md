# First Paint (FP) Implementation

## Overview

First Paint (FP) is a performance metric that measures when the browser first renders any pixels that are visually different from the screen before navigation. Unlike First Contentful Paint (FCP), FP fires on ANY visual change, not just content.

## W3C Specification

According to the W3C Paint Timing spec:
- FP excludes default background paint  
- FP includes non-default background colors, borders, box shadows
- FP always occurs before or at the same time as FCP
- FP reporting is optional per spec

## Implementation Details

### 1. Core Tracking in controller.dart

Added FP tracking state and methods following the same pattern as FCP:

```dart
// Type definition
typedef FPHandler = void Function(double fpTime);

// Tracking state
bool _fpReported = false;
double _fpTime = 0;

// Public getters
bool get fpReported => _fpReported;
double get fpTime => _fpTime;

// Callback property
FPHandler? onFP;

// Reporting method
void reportFP() {
  if (_fpReported || _navigationStartTime == null) return;
  
  _fpReported = true;
  _fpTime = DateTime.now().difference(_navigationStartTime!).inMilliseconds.toDouble();
  
  if (onFP != null) {
    onFP!(_fpTime);
  }
}
```

### 2. FP Triggers

FP is reported in the following scenarios:

#### Background Colors and Gradients (box_decoration_painter.dart)
```dart
// In _paintBackgroundColor()
if (_decoration.color != null && _decoration.color!.alpha > 0) {
  renderStyle.target.ownerDocument.controller.reportFP();
} else if (_decoration.gradient != null) {
  renderStyle.target.ownerDocument.controller.reportFP();
}
```

#### Borders (box_decoration_painter.dart)
```dart
// In paintBorder()
renderStyle.target.ownerDocument.controller.reportFP();
```

#### Box Shadows (box_decoration_painter.dart)
```dart
// In _paintShadows()
if (hasShadow) {
  renderStyle.target.ownerDocument.controller.reportFP();
}
```

#### Viewport Background (viewport.dart)
```dart
// In paint() when viewport background is painted
if (background != null) {
  controller.reportFP();
}
```

### 3. FP Before FCP

To ensure FP always fires before or with FCP, all FCP reporting locations were updated:

```dart
// Report FP first (if not already reported)
controller.reportFP();
controller.reportFCP();
```

This pattern is applied in:
- img.dart (image loading)
- paragraph.dart (text rendering)
- canvas_painter.dart (canvas content)
- widget.dart (RenderWidget content)
- svg/rendering/root.dart (SVG content)
- box_decoration_painter.dart (background images)

### 4. Reset Logic

FP tracking is reset on navigation/page load in controller.dart:

```dart
// In load() method
_fpReported = false;
_fpTime = 0;
```

## Testing Strategy

FP integration tests have been created in `/webf/integration_test/integration_test/fp_integration_test.dart` and cover:

1. **FP with only background color** - Verifies FP fires for background colors without content
2. **FP with only borders** - Verifies FP fires for borders without content
3. **FP with only box shadows** - Verifies FP fires for box shadows without content
4. **FP fires before FCP** - Verifies FP timing is always ≤ FCP timing
5. **FP with gradients** - Tests CSS gradient backgrounds trigger FP
6. **FP with viewport background** - Tests viewport background color triggers FP
7. **FP reported only once** - Verifies FP fires exactly once per page load
8. **Navigation resets FP** - Verifies FP resets and fires again on navigation
9. **FP timing validation** - Multiple tests ensuring FP ≤ FCP
10. **Mixed visual elements** - Tests complex pages with multiple FP triggers
11. **Prerendering mode** - Tests FP works correctly with prerendering

### Running the Tests

```bash
cd webf && flutter test integration_test/integration_test/fp_integration_test.dart
```

## Files Modified

1. `/lib/src/launcher/controller.dart` - Core FP tracking
2. `/lib/src/rendering/box_decoration_painter.dart` - FP for backgrounds, borders, shadows
3. `/lib/src/rendering/viewport.dart` - FP for viewport background
4. `/lib/src/html/img.dart` - FP before FCP for images
5. `/lib/src/rendering/paragraph.dart` - FP before FCP for text
6. `/lib/src/html/canvas/canvas_painter.dart` - FP before FCP for canvas
7. `/lib/src/rendering/widget.dart` - FP before FCP for widgets
8. `/lib/src/svg/rendering/root.dart` - FP before FCP for SVG

## Usage

```dart
WebFController(
  onFP: (double fpTime) {
    print('First Paint occurred at: $fpTime ms');
  },
  // ... other callbacks
)
```

## Implementation Summary

The First Paint (FP) implementation in WebF is now complete and includes:

1. **Core Tracking**: FP state management in WebFController with callbacks
2. **Visual Change Detection**: Reports on backgrounds, borders, shadows, and gradients
3. **FP Before FCP**: Ensures proper metric ordering across all paint scenarios
4. **Integration Tests**: Comprehensive test coverage for all FP scenarios
5. **DevTools Support**: FP metrics displayed in WebF DevTools performance panel

The implementation follows W3C Paint Timing specifications and provides developers with a complete picture of their page's paint performance timeline.