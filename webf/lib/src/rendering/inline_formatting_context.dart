import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

import 'inline_item.dart';
import 'line_box.dart';
import 'inline_items_builder.dart';
import 'bidi_resolver.dart';
import 'inline_layout_algorithm.dart';

/// Default line-height multiplier for "normal" line-height value.
/// Matches Chrome's default behavior (approximately 1.146).
/// Chrome uses 18.33px for 16px font-size: 18.33/16 ≈ 1.145833
const double defaultLineHeightMultiplier = 1.146;

/// Manages the inline formatting context for a block container.
/// Based on Blink's InlineNode.
class InlineFormattingContext {
  InlineFormattingContext({
    required this.container,
  });

  /// The block container that establishes this inline formatting context.
  final RenderLayoutBox container;

  /// The inline items in this formatting context.
  List<InlineItem> _items = [];
  List<InlineItem> get items => _items;

  /// The text content string.
  String _textContent = '';
  String get textContent => _textContent;

  /// Whether this context needs preparation.
  bool _needsCollectInlines = true;

  /// The line boxes created by layout.
  List<LineBox> _lineBoxes = [];
  List<LineBox> get lineBoxes => _lineBoxes;

  /// Mark that inline collection is needed.
  void setNeedsCollectInlines() {
    _needsCollectInlines = true;
    // Debug: Log when recollection is triggered
    // print('InlineFormattingContext: setNeedsCollectInlines called');
  }

  /// Prepare for layout by collecting inlines and shaping text.
  void prepareLayout() {
    if (_needsCollectInlines) {
      // Debug: Log preparation
      // print('InlineFormattingContext: prepareLayout - collecting inlines');
      _collectInlines();
      _resolveBidi();
      _shapeText();
      _needsCollectInlines = false;
    }
  }

  /// Collect inline items from the render tree.
  void _collectInlines() {
    final builder = InlineItemsBuilder(
      direction: container.renderStyle.direction,
    );

    builder.build(container);

    _items = builder.items;
    _textContent = builder.textContent;
  }

  /// Resolve bidirectional text.
  void _resolveBidi() {
    if (_items.isEmpty) return;

    final resolver = BidiResolver(
      text: _textContent,
      baseDirection: container.renderStyle.direction,
      items: _items,
    );

    // Resolve BiDi levels
    resolver.resolve();

    // Reorder items for visual order if needed
    _items = BidiResolver.reorderItemsForVisualOrder(_items);
  }

  /// Shape text items using Flutter's text layout.
  void _shapeText() {
    for (final item in _items) {
      if (item.type == InlineItemType.text) {
        _shapeTextItem(item);
      }
    }
  }

  /// Shape a single text item.
  void _shapeTextItem(InlineItem item) {
    final text = item.getText(_textContent);
    final style = item.style;

    if (style == null || text.isEmpty) return;

    // Note: We use Flutter's standard TextPainter here because:
    // 1. InlineFormattingContext handles CSS line-height at the line box level
    // 2. Each TextPainter only renders a single line segment (not multi-line)
    // 3. CSS line-height spacing is controlled by line box height, not text painting
    // This is actually the correct approach per CSS specifications, where line-height
    // affects the line box, not the text itself.
    //
    // WebFRenderParagraph's approach of creating multiple TextPainters per line
    // is less efficient and could be refactored to use this line box approach.

    // Create text painter for measurement using unified text rendering from CSSTextMixin
    final textSpan = CSSTextMixin.createTextSpan(text, style);
    // Use the item's direction if set, otherwise fall back to style direction
    final textDirection = item.direction ?? style.direction;
    
    // For RTL text, we need to use Paragraph API for proper bidi handling
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: textDirection,
      textWidthBasis: TextWidthBasis.parent,
    );

    // Layout to get metrics
    textPainter.layout();

    // Store shape result
    // Get the actual baseline
    final baselineDistance = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    // Use the text painter's height which includes line height
    final height = textPainter.height;


    // If baseline is null, estimate it as 80% of height (common for alphabetic baseline)
    final baseline = baselineDistance ?? (height * 0.8);

    // print('  Baseline distance: $baselineDistance, calculated baseline: $baseline');
    item.shapeResult = ShapeResult(
      width: textPainter.width,
      height: height,
      ascent: baseline,
      descent: height - baseline,
      glyphData: textPainter,
    );
  }

  /// Perform layout with given constraints.
  Size layout(BoxConstraints constraints) {
    // Prepare items if needed
    prepareLayout();

    // Create layout algorithm
    final algorithm = InlineLayoutAlgorithm(
      context: this,
      constraints: constraints,
    );

    // Run layout
    _lineBoxes = algorithm.layout();

    // Calculate total size
    double width = 0;
    double height = 0;

    for (final lineBox in _lineBoxes) {
      width = math.max(width, lineBox.width);
      height += lineBox.height;
    }

    // Update RenderBox parentData offsets based on line box layout
    _updateChildOffsets();

    return Size(width, height);
  }

  /// Paint the inline content.
  void paint(PaintingContext context, Offset offset) {
    double y = offset.dy;

    for (final lineBox in _lineBoxes) {
      lineBox.paint(context, Offset(offset.dx, y));
      y += lineBox.height;
    }
  }

  /// Hit test the inline content.
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    double y = 0;

    for (final lineBox in _lineBoxes) {
      if (position.dy >= y && position.dy < y + lineBox.height) {
        return lineBox.hitTest(
          result,
          position: Offset(position.dx, position.dy - y),
        );
      }
      y += lineBox.height;
    }

    return false;
  }

  /// Get baseline for first line.
  double? getDistanceToBaseline(TextBaseline baseline) {
    if (_lineBoxes.isEmpty) return null;
    return _lineBoxes.first.baseline;
  }

  /// Update child RenderBox parentData offsets based on line box layout.
  void _updateChildOffsets() {
    double lineY = 0;

    for (final lineBox in _lineBoxes) {
      // Find the minimum y offset in this line to ensure no negative positions
      double minY = 0;
      for (final item in lineBox.items) {
        if (item.offset.dy < minY) {
          minY = item.offset.dy;
        }
      }

      // Calculate adjustment to ensure all items have non-negative y positions
      final yAdjustment = minY < 0 ? -minY : 0;

      for (final item in lineBox.items) {
        RenderBox? renderBox;

        if (item is AtomicLineBoxItem) {
          renderBox = item.renderBox;
        } else if (item is BoxLineBoxItem) {
          renderBox = item.renderBox;
        }

        if (renderBox != null) {
          // Find the actual child of the inline formatting context
          // by walking up the parent chain
          RenderBox? directChild = renderBox;
          while (directChild != null && directChild.parent != container) {
            directChild = directChild.parent as RenderBox?;
          }

          // Update the direct child's parent data offset
          // Apply the y adjustment to ensure no negative positions
          if (directChild != null) {
            final parentData = directChild.parentData;
            if (parentData is BoxParentData) {
              parentData.offset = Offset(
                item.offset.dx,
                lineY + item.offset.dy + yAdjustment
              );
            }
          }
        }
      }
      lineY += lineBox.height;
    }
  }

  void dispose() {
    _items.clear();
    _lineBoxes.clear();
  }

  /// Add debugging information for the inline formatting context.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty<RenderLayoutBox>('container', container));
    properties.add(IntProperty('itemCount', _items.length));
    properties.add(IntProperty('lineBoxCount', _lineBoxes.length));
    properties.add(StringProperty('textContent', _textContent,
        showName: true,
        quoted: true,
        ifEmpty: '<empty>',
        style: DiagnosticsTreeStyle.singleLine));
    properties.add(FlagProperty('needsCollectInlines',
        value: _needsCollectInlines,
        ifTrue: 'needs collect',
        ifFalse: 'collected'));

    // Add line box details
    if (_lineBoxes.isNotEmpty) {
      properties.add(DiagnosticsProperty<List<String>>(
        'lineBoxes',
        _lineBoxes.map((lineBox) =>
          'LineBox(width: ${lineBox.width.toStringAsFixed(1)}, '
          'height: ${lineBox.height.toStringAsFixed(1)}, '
          'baseline: ${lineBox.baseline.toStringAsFixed(1)}, '
          'items: ${lineBox.items.length})'
        ).toList(),
        style: DiagnosticsTreeStyle.singleLine,
      ));
    }

    // Add inline item details
    if (_items.isNotEmpty) {
      final itemSummary = <String, int>{};
      for (final item in _items) {
        final type = item.type.toString().split('.').last;
        itemSummary[type] = (itemSummary[type] ?? 0) + 1;
      }
      properties.add(DiagnosticsProperty<Map<String, int>>(
        'itemTypes',
        itemSummary,
        style: DiagnosticsTreeStyle.singleLine,
      ));
    }
  }
}
