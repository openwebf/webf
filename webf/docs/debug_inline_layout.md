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

When debug paint is enabled with console logging, you'll see:

```
[IFC] Open tag: margin=20.0, padding=5.0, X=108.2
[IFC] Adding text "inline element" at X=113.2, width=108.6
[IFC] Close tag: padding=5.0, margin=30.0, X=256.8
```

This helps trace the exact positioning calculations during layout.

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