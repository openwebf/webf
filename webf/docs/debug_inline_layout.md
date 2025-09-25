# Debug Paint for Inline Formatting Context

WebF provides a debug visualization feature for the inline formatting context that helps developers understand and debug inline layout issues.

## Overview

The debug paint feature visualizes:
- Line box boundaries
- Text baselines
- Text item bounds
- Inline element bounds (spans, etc.)
- Margin areas
- Padding areas
- Atomic inline elements (images, inline-blocks)

## Enabling Debug Paint

```dart
import 'package:webf/rendering.dart';

// Enable debug paint globally
debugPaintInlineLayoutEnabled = true;

// Create your WebF widget - it will now show debug visualizations
WebF(
  bundle: WebFBundle.fromString(htmlContent),
)
```

## Visual Guide

When debug paint is enabled, you'll see:

- **Green outline**: Line box bounds - shows the full area of each line
- **Red line**: Baseline - where text sits on the line
- **Blue outline**: Text item bounds - individual text fragments
- **Magenta outline**: Inline box bounds (e.g., `<span>` elements)
- **Red semi-transparent fill**: Left margin area
- **Green semi-transparent fill**: Right margin area  
- **Blue semi-transparent fill**: Padding area
- **Orange outline**: Atomic inline elements (inline-block, images)

## Example Usage

```dart
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _debugEnabled = false;

  void _toggleDebug() {
    setState(() {
      _debugEnabled = !_debugEnabled;
      debugPaintInlineLayoutEnabled = _debugEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Inline Layout Debug'),
          actions: [
            IconButton(
              icon: Icon(_debugEnabled ? Icons.visibility : Icons.visibility_off),
              onPressed: _toggleDebug,
            ),
          ],
        ),
        body: WebF(
          bundle: WebFBundle.fromString('''
            <div style="width: 300px; padding: 20px;">
              Text before <span style="margin: 10px 20px; padding: 5px; background: lightblue;">
                inline element with margins
              </span> text after
            </div>
          '''),
        ),
      ),
    );
  }
}
```

## Use Cases

### Debugging Margin Issues

When inline margins aren't creating the expected visual gaps:

```html
<span style="margin-left: 20px; margin-right: 30px;">text</span>
```

The debug paint will show:
- Red fill on the left (20px margin)
- Green fill on the right (30px margin)
- Whether the margins are being calculated correctly

### Understanding Line Box Heights

Debug paint shows:
- The full height of each line box (green outline)
- Where the baseline sits (red line)
- How inline elements affect line height

### Debugging Text Alignment

The baseline visualization helps debug:
- Vertical alignment of inline elements
- Text baseline alignment issues
- Line height calculations

### Troubleshooting Padding and Borders

The debug paint clearly shows:
- Blue fill for padding areas
- How padding affects the content box
- The relationship between margins, borders, and padding

## Console Output

When debug logging for inline layout is enabled by features/groups, you'll see grouped messages:

```
[IFC/Paragraph/Metrics] visualLongestLine=256.80 (base=248.40)
[IFC/Flow/Decision] decision <div> inline=true block=false effectiveDisplay=block → establishIFC=true
[IFC/Paragraph/Sizing] size result width=300.00 height=46.00 baseParaH=38.00 extraY(rel/transform)=0.00 extraY(atomicOverflow)=8.00
[IFC/Paragraph/Offsets] compute VA offset kind=textRun line=0 ascent=12.00 descent=3.00 h=14.00 va=middle → baselineOffset=11.50
```

This helps trace the exact positioning calculations during layout.

### Log Grouping

Inline layout logs are grouped by implementation and feature to make scanning easier:

- Implementations: `Paragraph` (new paragraph-based IFC), `Legacy` (legacy line boxes), `Flow` (flow decisions around IFC)
- Features: `Decision`, `Sizing`, `Baselines`, `Offsets`, `Scrollable`, `Painting`, `Placeholders`, `Text`, `Metrics`

All grouped logs are controlled by InlineLayoutLog filters and use the `WebF.Rendering` logger.

## Selective Logging

You can enable only parts of the inline layout logs by feature and implementation:

```dart
import 'package:webf/foundation.dart';

void main() {
  // Only log sizing and baselines from the Paragraph IFC
  InlineLayoutLog.enableImpls({ InlineImpl.paragraphIFC });
  InlineLayoutLog.enableFeatures({ InlineFeature.sizing, InlineFeature.baselines });

  // To allow all logs again:
  InlineLayoutLog.enableAll();

  // To temporarily silence all inline logs without touching the global flag:
  // InlineLayoutLog.disableAll();
}
```

Feature keys: `Decision`, `Sizing`, `Baselines`, `Offsets`, `Scrollable`, `Painting`, `Placeholders`, `Text`, `Metrics`.

Note: There is no global switch for inline layout logs; use the filters above or the DevTools UI to enable by kind.

Implementation keys: `Paragraph` (new), `Legacy` (legacy line boxes), `Flow` (IFC establishment decisions).

## Best Practices

1. **Development Only**: Only enable debug paint during development
2. **Performance**: Debug paint has a small performance impact, disable in production
3. **Combined Debugging**: Use with Flutter's built-in debug tools for comprehensive debugging
4. **Screenshots**: Take screenshots with debug paint enabled to analyze layout issues

## Limitations

- Debug paint only works for elements using inline formatting context
- Block-level elements have their own layout and aren't visualized by this tool
- The visualization is painted on top of the actual content

## Related Debugging Tools

- Flutter Inspector: For widget tree inspection
- `debugPaintSizeEnabled`: Flutter's built-in size debugging
- Layout Explorer: For analyzing flex and constraint issues
