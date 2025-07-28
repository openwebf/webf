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
  });

  /// Width of the line box.
  final double width;

  /// Height of the line box.
  final double height;

  /// Baseline position from top of line box.
  final double baseline;

  /// Items in this line box.
  final List<LineBoxItem> items;

  /// Paint this line box.
  void paint(PaintingContext context, Offset offset) {
    for (final item in items) {
      item.paint(context, offset);
    }
  }

  /// Hit test this line box.
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    for (final item in items) {
      if (item.hitTest(result, position: position)) {
        return true;
      }
    }
    return false;
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
  });

  /// The render box.
  final RenderBox renderBox;

  /// Box style.
  final CSSRenderStyle style;

  /// Child items within this box.
  final List<LineBoxItem> children;

  @override
  void paint(PaintingContext context, Offset lineOffset) {
    final paintOffset = lineOffset + offset;

    // Paint background and borders
    _paintBoxDecorations(context, paintOffset);

    // Paint children
    for (final child in children) {
      child.paint(context, lineOffset);
    }
  }

  void _paintBoxDecorations(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Paint background
    if (style.backgroundColor?.value != null) {
      final paint = Paint()
        ..color = style.backgroundColor!.value;
      canvas.drawRect(rect, paint);
    }

    // Paint borders
    if ((style.borderLeftWidth?.value != null && style.borderLeftWidth!.value! > 0) ||
        (style.borderTopWidth?.value != null && style.borderTopWidth!.value! > 0) ||
        (style.borderRightWidth?.value != null && style.borderRightWidth!.value! > 0 ) ||
        (style.borderBottomWidth?.value != null && style.borderBottomWidth!.value! > 0)) {
      _paintBorder(canvas, rect);
    }
  }

  void _paintBorder(Canvas canvas, Rect rect) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Top border
    if (style.borderTopWidth?.value != null && style.borderTopWidth!.value! > 0) {
      paint.color = style.borderTopColor?.value ?? const Color(0xFF000000);
      paint.strokeWidth = style.borderTopWidth!.value!;
      canvas.drawLine(rect.topLeft, rect.topRight, paint);
    }

    // Right border
    if (style.borderRightWidth?.value != null && style.borderRightWidth!.value! > 0) {
      paint.color = style.borderRightColor?.value ?? const Color(0xFF000000);
      paint.strokeWidth = style.borderRightWidth!.value!;
      canvas.drawLine(rect.topRight, rect.bottomRight, paint);
    }

    // Bottom border
    if (style.borderBottomWidth?.value != null && style.borderBottomWidth!.value! > 0) {
      paint.color = style.borderBottomColor?.value ?? const Color(0xFF000000);
      paint.strokeWidth = style.borderBottomWidth!.value!;
      canvas.drawLine(rect.bottomLeft, rect.bottomRight, paint);
    }

    // Left border
    if (style.borderLeftWidth?.value != null && style.borderLeftWidth!.value! > 0) {
      paint.color = style.borderLeftColor?.value ?? const Color(0xFF000000);
      paint.strokeWidth = style.borderLeftWidth!.value!;
      canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!contains(position)) return false;

    // Check children first
    for (final child in children) {
      if (child.hitTest(result, position: position)) {
        return true;
      }
    }

    // Add this box to hit test
    result.add(BoxHitTestEntry(renderBox, position - offset));
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
