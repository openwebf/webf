# First Paint (FP) Implementation Plan

Based on the current FCP (First Contentful Paint) implementation in WebF, here's the analysis and plan for implementing FP (First Paint).

## Current FCP Implementation Pattern

### 1. Tracking State in Controller (controller.dart)
```dart
// FCP tracking state
bool _fcpReported = false;
double _fcpTime = 0;

// Exposed properties
bool get fcpReported => _fcpReported;
double get fcpTime => _fcpTime;

// Callback
FCPHandler? onFCP;

// Reporting method
void reportFCP() {
  if (_fcpReported || _navigationStartTime == null) return;
  
  _fcpReported = true;
  _fcpTime = DateTime.now().difference(_navigationStartTime!).inMilliseconds.toDouble();
  
  if (onFCP != null) {
    onFCP!(_fcpTime);
  }
}
```

### 2. Where FCP is Currently Triggered

FCP is reported when the first contentful element is painted:

1. **Text Content** (paragraph.dart:946)
   - Triggered when WebFRenderParagraph paints text with actual visible content
   - Checks if text has non-empty size and visible lines

2. **Images** (img.dart:536)
   - SVG images report FCP after loading and before scheduling rebuild
   - Regular images report FCP through box_decoration_painter

3. **Background Images** (box_decoration_painter.dart:537)
   - Reports FCP when background image is painted (excluding CSS gradients)
   - Only for actual images, not CSS gradients

4. **Canvas Content** (canvas_painter.dart:88)
   - Reports FCP when canvas has content painted for the first time
   - Checks if there are paint actions (actionLen > 0)

5. **SVG Content** (svg/rendering/root.dart:63)
   - Reports FCP when SVG element is painted

6. **RenderWidget Content** (rendering/widget.dart:185)
   - Reports FCP when WidgetElement with content is first painted

### 3. Initialization

- FCP tracking is initialized in `initializeLCPTracking()` along with LCP
- Reset on page load/navigation in the `load()` method
- Navigation start time is captured when viewport is laid out

## First Paint (FP) Implementation Plan

### Definition
First Paint (FP) marks the time when the browser first renders any pixels to the screen, including:
- Background colors
- Borders
- Any visual change from the blank screen

### Key Differences from FCP
- FP triggers on ANY visual change, not just content
- FP includes non-content paints like backgrounds and borders
- FP always occurs before or at the same time as FCP

### Implementation Strategy

#### 1. Add FP Tracking State to Controller
```dart
// In WebFController class
bool _fpReported = false;
double _fpTime = 0;

bool get fpReported => _fpReported;
double get fpTime => _fpTime;

FPHandler? onFP;  // typedef FPHandler = void Function(double fpTime);

void reportFP() {
  if (_fpReported || _navigationStartTime == null) return;
  
  _fpReported = true;
  _fpTime = DateTime.now().difference(_navigationStartTime!).inMilliseconds.toDouble();
  
  if (onFP != null) {
    onFP!(_fpTime);
  }
}
```

#### 2. Reset FP Tracking
- Add FP reset in `load()` method alongside FCP reset
- Reset in `initializeLCPTracking()` method

#### 3. Trigger Points for FP

Unlike FCP which only tracks content, FP should be triggered by:

1. **Box Model Paint** (box_model.dart)
   - When painting background color
   - When painting borders
   - When painting box shadows

2. **Viewport Paint** (viewport.dart)
   - When viewport background is painted

3. **Any Visual Paint**
   - Before any FCP trigger, check if FP has been reported
   - If not, report FP first

#### 4. Implementation Locations

1. **box_model.dart** - In `paintBackground()` and `paintBorder()` methods
2. **viewport.dart** - When painting viewport background
3. **Before each FCP report** - Ensure FP is reported first

### Testing Strategy

1. Create integration tests similar to FCP tests
2. Test scenarios:
   - FP with only background color
   - FP with only borders
   - FP before FCP with text content
   - FP timing should always be ≤ FCP timing
   - Navigation resets FP tracking

### Timeline
1. Add FP tracking state and callback to controller
2. Implement FP reporting in paint methods
3. Ensure FP is reported before FCP
4. Create integration tests
5. Update documentation