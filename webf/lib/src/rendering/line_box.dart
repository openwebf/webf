import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_item.dart';

/// Represents a line box in the inline formatting context.
/// Based on Blink's PhysicalLineBoxFragment.
class LineBox {
  LineBox({
    required this.width,
    required this.height,
    required this.baseline,
    required this.items,
    this.alignmentOffset = 0.0,
  });

  /// Width of the line box.
  final double width;

  /// Height of the line box.
  final double height;

  /// Baseline position from top of line box.
  final double baseline;

  /// Items in this line box.
  final List<LineBoxItem> items;

  /// Horizontal offset for text alignment.
  final double alignmentOffset;

  /// Paint this line box.
  void paint(PaintingContext context, Offset offset) {
    // Apply alignment offset to the entire line
    final alignedOffset = offset.translate(alignmentOffset, 0);
    for (final item in items) {
      item.paint(context, alignedOffset);
    }
  }

  /// Hit test this line box.
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Hit-test in reverse paint order so visually topmost/nested items get priority
    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      if (item.hitTest(result, position: position)) {
        return true;
      }
    }
    return false;
  }

  /// Add debugging information for the line box.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('baseline', baseline));
    properties.add(DoubleProperty('alignmentOffset', alignmentOffset));
    properties.add(IntProperty('itemCount', items.length));

    // Add item details
    if (items.isNotEmpty) {
      final itemTypes = <String, int>{};
      for (final item in items) {
        final typeName = item.runtimeType.toString();
        itemTypes[typeName] = (itemTypes[typeName] ?? 0) + 1;
      }
      properties.add(DiagnosticsProperty<Map<String, int>>(
        'itemTypes',
        itemTypes,
        style: DiagnosticsTreeStyle.sparse,
      ));
    }
  }
}

/// Base class for items in a line box.
abstract class LineBoxItem {
  LineBoxItem({
    required this.offset,
    required this.size,
  });

  /// Offset of this item relative to line box.
  Offset offset;

  /// Size of this item.
  final Size size;

  /// Paint this item.
  void paint(PaintingContext context, Offset lineOffset);

  /// Hit test this item.
  bool hitTest(BoxHitTestResult result, {required Offset position});

  /// Check if position is within this item.
  bool contains(Offset position) {
    return position.dx >= offset.dx &&
           position.dx < offset.dx + size.width &&
           position.dy >= offset.dy &&
           position.dy < offset.dy + size.height;
  }
}

/// Text item in a line box.
class TextLineBoxItem extends LineBoxItem {
  TextLineBoxItem({
    required super.offset,
    required super.size,
    required this.text,
    required this.style,
    required this.textPainter,
    required this.inlineItem,
  });

  /// The text content.
  final String text;

  /// Text style.
  final CSSRenderStyle style;

  /// Text painter for rendering.
  final TextPainter textPainter;

  /// Associated inline item.
  final InlineItem inlineItem;

  @override
  void paint(PaintingContext context, Offset lineOffset) {
    final paintOffset = lineOffset + offset;
    textPainter.paint(context.canvas, paintOffset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!contains(position)) return false;

    // Add to hit test result if there's an associated render box
    if (inlineItem.renderBox != null) {
      result.add(BoxHitTestEntry(inlineItem.renderBox!, position - offset));
      return true;
    }

    return false;
  }
}

/// Box item in a line box (for inline elements with borders/background).
class BoxLineBoxItem extends LineBoxItem {
  BoxLineBoxItem({
    required super.offset,
    required super.size,
    required this.renderBox,
    required this.style,
    this.children = const [],
    this.isFirstFragment = true,
    this.isLastFragment = true,
    required this.baseline,
    required this.contentAscent,
    required this.contentDescent,
  });

  /// The render box.
  final RenderBox renderBox;

  /// Box style.
  final CSSRenderStyle style;

  /// Child items within this box.
  final List<LineBoxItem> children;

  /// Whether this is the first fragment of a multi-line inline element.
  final bool isFirstFragment;

  /// Whether this is the last fragment of a multi-line inline element.
  final bool isLastFragment;
  
  /// Baseline position within the line box.
  final double baseline;
  
  /// Content ascent (from font metrics).
  final double contentAscent;
  
  /// Content descent (from font metrics).
  final double contentDescent;

  @override
  void paint(PaintingContext context, Offset lineOffset) {
    final paintOffset = lineOffset + offset;

    // Paint background and borders
    _paintBoxDecorations(context, paintOffset);

    // Don't paint children here - they're painted as part of the line items
    // This avoids painting text twice
  }

  void _paintBoxDecorations(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Get padding values
    final paddingTop = style.paddingTop.computedValue;
    final paddingBottom = style.paddingBottom.computedValue;
    // Use effective border widths so border-style: none results in zero width
    final borderTop = style.effectiveBorderTopWidth.computedValue;
    final borderBottom = style.effectiveBorderBottomWidth.computedValue;

    // For inline elements, the background covers the content area plus padding
    // and, by default, the border box (background-clip: border-box)
    // The content height is based on font metrics, not line height
    final contentHeight = contentAscent + contentDescent;
    
    // Calculate where the content top is based on the baseline
    // The baseline position is relative to the line box top
    final contentTop = offset.dy + baseline - contentAscent;

    // The painted rect includes padding and borders around the content
    final paintRect = Rect.fromLTWH(
      offset.dx,
      contentTop - paddingTop - borderTop,  // Extend upward by padding and top border
      size.width,
      contentHeight + paddingTop + paddingBottom + borderTop + borderBottom,  // Content + padding + borders
    );

    // Paint background unless background-clip:text (handled by IFC glyph mask)
    if (style.backgroundColor?.value != null && style.backgroundClip != CSSBackgroundBoundary.text) {
      final paint = Paint()
        ..color = style.backgroundColor!.value;
      canvas.drawRect(paintRect, paint);
    }

    // Paint borders on the padding box
    if ((style.effectiveBorderLeftWidth.computedValue > 0) ||
        (style.effectiveBorderTopWidth.computedValue > 0) ||
        (style.effectiveBorderRightWidth.computedValue > 0) ||
        (style.effectiveBorderBottomWidth.computedValue > 0)) {
      _paintBorder(canvas, paintRect);
    }
  }

  void _paintBorder(Canvas canvas, Rect rect) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top border
    if (style.effectiveBorderTopWidth.computedValue > 0) {
      paint.color = style.borderTopColor?.value ?? const Color(0xFF000000);
      final borderRect = Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.right,
        rect.top + style.effectiveBorderTopWidth.computedValue
      );
      canvas.drawRect(borderRect, paint);
    }

    // Right border - only paint if this is the last fragment
    if (isLastFragment && style.effectiveBorderRightWidth.computedValue > 0) {
      paint.color = style.borderRightColor?.value ?? const Color(0xFF000000);
      final borderRect = Rect.fromLTRB(
        rect.right - style.effectiveBorderRightWidth.computedValue,
        rect.top,
        rect.right,
        rect.bottom
      );
      canvas.drawRect(borderRect, paint);
    }

    // Bottom border
    if (style.effectiveBorderBottomWidth.computedValue > 0) {
      paint.color = style.borderBottomColor?.value ?? const Color(0xFF000000);
      final borderRect = Rect.fromLTRB(
        rect.left,
        rect.bottom - style.effectiveBorderBottomWidth.computedValue,
        rect.right,
        rect.bottom
      );
      canvas.drawRect(borderRect, paint);
    }

    // Left border - only paint if this is the first fragment
    if (isFirstFragment && style.effectiveBorderLeftWidth.computedValue > 0) {
      paint.color = style.borderLeftColor?.value ?? const Color(0xFF000000);
      final borderRect = Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.left + style.effectiveBorderLeftWidth.computedValue,
        rect.bottom
      );
      canvas.drawRect(borderRect, paint);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Get padding values
    final paddingTop = style.paddingTop.computedValue;
    final paddingBottom = style.paddingBottom.computedValue;
    // Border widths
    final borderTop = style.borderTopWidth?.computedValue ?? 0.0;
    final borderBottom = style.borderBottomWidth?.computedValue ?? 0.0;

    // Use the same bounds calculation as paint
    final contentHeight = contentAscent + contentDescent;
    final contentTop = offset.dy + baseline - contentAscent;

    // Check against the actual painted bounds
    final bounds = Rect.fromLTWH(
      offset.dx,
      contentTop - paddingTop - borderTop,
      size.width,
      contentHeight + paddingTop + paddingBottom + borderTop + borderBottom,
    );

    if (!bounds.contains(position)) return false;

    // Check children first
    for (final child in children) {
      if (child.hitTest(result, position: position)) {
        return true;
      }
    }

    // Add this box to hit test
    final localPosition = position - offset;
    result.add(BoxHitTestEntry(renderBox, localPosition));
    return true;
  }
}

/// Atomic inline item in a line box (inline-block, replaced element).
class AtomicLineBoxItem extends LineBoxItem {
  AtomicLineBoxItem({
    required super.offset,
    required super.size,
    required this.renderBox,
  });

  /// The render box.
  final RenderBox renderBox;

  @override
  void paint(PaintingContext context, Offset lineOffset) {
    final paintOffset = lineOffset + offset;
    context.paintChild(renderBox, paintOffset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!contains(position)) return false;

    return renderBox.hitTest(result, position: position - offset);
  }
}
