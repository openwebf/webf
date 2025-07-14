import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_item.dart';
import 'inline_items_builder.dart';
import 'inline_layout_algorithm.dart';
import 'line_box.dart';

/// Manages the inline formatting context for a block container.
/// Based on Blink's InlineNode.
class InlineFormattingContext {
  InlineFormattingContext({
    required this.container,
  });

  /// The block container that establishes this inline formatting context.
  final RenderBox container;

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
  }

  /// Prepare for layout by collecting inlines and shaping text.
  void prepareLayout() {
    if (_needsCollectInlines) {
      _collectInlines();
      _shapeText();
      _needsCollectInlines = false;
    }
  }

  /// Collect inline items from the render tree.
  void _collectInlines() {
    final builder = InlineItemsBuilder(
      direction: _getTextDirection(),
    );

    builder.build(container);

    _items = builder.items;
    _textContent = builder.textContent;
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

    // Create text painter for measurement
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: _createTextStyle(style),
      ),
      textDirection: _getTextDirection(),
    );

    // Layout to get metrics
    textPainter.layout();

    // Store shape result
    item.shapeResult = ShapeResult(
      width: textPainter.width,
      height: textPainter.height,
      ascent: textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
      descent: textPainter.height - textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
      glyphData: textPainter,
    );
  }

  /// Create TextStyle from CSSRenderStyle.
  TextStyle _createTextStyle(CSSRenderStyle renderStyle) {
    return TextStyle(
      color: renderStyle.color.value,
      fontSize: renderStyle.fontSize.computedValue,
      fontWeight: renderStyle.fontWeight,
      fontStyle: renderStyle.fontStyle == FontStyle.italic ? ui.FontStyle.italic : ui.FontStyle.normal,
      fontFamily: renderStyle.fontFamily?.isNotEmpty == true ? renderStyle.fontFamily![0] : null,
      fontFamilyFallback: renderStyle.fontFamily,
      letterSpacing: renderStyle.letterSpacing?.computedValue,
      wordSpacing: renderStyle.wordSpacing?.computedValue,
      height: renderStyle.lineHeight?.computedValue != null ? renderStyle.lineHeight!.computedValue / renderStyle.fontSize.computedValue : null,
      decoration: _getTextDecoration(renderStyle),
      decorationColor: renderStyle.textDecorationColor?.value,
      decorationStyle: _getTextDecorationStyle(renderStyle),
      // decorationThickness: renderStyle.textDecorationThickness?.computedValue,
    );
  }

  /// Get text decoration from render style.
  TextDecoration _getTextDecoration(CSSRenderStyle renderStyle) {
    TextDecoration decoration = TextDecoration.none;

    return renderStyle.textDecorationLine ?? TextDecoration.none;

    return decoration;
  }

  /// Get text decoration style.
  ui.TextDecorationStyle _getTextDecorationStyle(dynamic renderStyle) {
    switch (renderStyle.textDecorationStyle) {
      case TextDecorationStyle.solid:
        return ui.TextDecorationStyle.solid;
      case TextDecorationStyle.double:
        return ui.TextDecorationStyle.double;
      case TextDecorationStyle.dotted:
        return ui.TextDecorationStyle.dotted;
      case TextDecorationStyle.dashed:
        return ui.TextDecorationStyle.dashed;
      case TextDecorationStyle.wavy:
        return ui.TextDecorationStyle.wavy;
      default:
        return ui.TextDecorationStyle.solid;
    }
  }

  /// Get text direction.
  TextDirection _getTextDirection() {
    if (container is RenderBoxModel) {
      final renderStyle = (container as RenderBoxModel).renderStyle;
      // TODO: Add direction support
      return TextDirection.ltr;
    }
    return TextDirection.ltr;
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
      width = width.clamp(width, lineBox.width);
      height += lineBox.height;
    }

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
}
