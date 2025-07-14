import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

/// Type of inline item in the inline formatting context.
enum InlineItemType {
  /// Text content.
  text,
  /// Control character (e.g., newline, tab).
  control,
  /// Atomic inline (inline-block, replaced element).
  atomicInline,
  /// Float element.
  floatingElement,
  /// Open tag for inline element.
  openTag,
  /// Close tag for inline element.
  closeTag,
  /// Bidi control character.
  bidiControl,
  /// Line break opportunity.
  lineBreakOpportunity,
}

/// Represents a single unit in the inline formatting context.
/// Based on Blink's InlineItem concept.
class InlineItem {
  InlineItem({
    required this.type,
    required this.startOffset,
    required this.endOffset,
    this.renderBox,
    this.style,
    this.bidiLevel = 0,
  });

  /// Type of this inline item.
  final InlineItemType type;

  /// Start offset in the text content string.
  final int startOffset;

  /// End offset in the text content string.
  final int endOffset;

  /// Associated render object, if any.
  final RenderBox? renderBox;

  /// Style for this item.
  final CSSRenderStyle? style;

  /// Bidi level for this item.
  final int bidiLevel;

  /// Shaping results for text items.
  ShapeResult? shapeResult;

  /// Get the text content for this item.
  String getText(String textContent) {
    return textContent.substring(startOffset, endOffset);
  }

  /// Get the length of this item.
  int get length => endOffset - startOffset;

  /// Whether this item is empty.
  bool get isEmpty => length == 0;

  /// Whether this item represents text content.
  bool get isText => type == InlineItemType.text;

  /// Whether this item is an atomic inline.
  bool get isAtomicInline => type == InlineItemType.atomicInline;

  /// Whether this item is a float.
  bool get isFloat => type == InlineItemType.floatingElement;

  /// Whether this item is an open tag.
  bool get isOpenTag => type == InlineItemType.openTag;

  /// Whether this item is a close tag.
  bool get isCloseTag => type == InlineItemType.closeTag;

  /// Whether this item should create a box fragment.
  bool get shouldCreateBoxFragment {
    if (renderBox == null) return false;
    final renderStyle = (renderBox as RenderBoxModel?)?.renderStyle;
    if (renderStyle == null) return false;

    // Create box fragment if has borders, padding, or background
    return (renderStyle.borderLeftWidth?.value != null && renderStyle.borderLeftWidth!.value! > 0) ||
           (renderStyle.borderTopWidth?.value != null && renderStyle.borderTopWidth!.value! > 0) ||
           (renderStyle.borderRightWidth?.value != null && renderStyle.borderRightWidth!.value! > 0) ||
           (renderStyle.borderBottomWidth?.value != null && renderStyle.borderBottomWidth!.value! > 0) ||
           (renderStyle.paddingLeft?.value != null && renderStyle.paddingLeft!.value! > 0) ||
           (renderStyle.paddingTop?.value != null && renderStyle.paddingTop!.value! > 0) ||
           (renderStyle.paddingRight?.value != null && renderStyle.paddingRight!.value! > 0) ||
           (renderStyle.paddingBottom?.value != null && renderStyle.paddingBottom!.value! > 0) ||
           (renderStyle.backgroundColor?.value != null);
  }

  @override
  String toString() {
    return 'InlineItem(type: $type, offset: $startOffset-$endOffset)';
  }
}

/// Result of shaping text.
class ShapeResult {
  ShapeResult({
    required this.width,
    required this.height,
    required this.ascent,
    required this.descent,
    this.glyphData,
  });

  /// Width of the shaped text.
  final double width;

  /// Height of the shaped text.
  final double height;

  /// Ascent of the shaped text.
  final double ascent;

  /// Descent of the shaped text.
  final double descent;

  /// Glyph data for rendering.
  final dynamic glyphData;

  /// Get the baseline offset.
  double get baseline => ascent;
}

/// Result of measuring an inline item during line breaking.
class InlineItemResult {
  InlineItemResult({
    required this.item,
    required this.inlineSize,
    required this.startOffset,
    required this.endOffset,
  });

  /// The inline item.
  final InlineItem item;

  /// Inline size (width in horizontal writing mode).
  final double inlineSize;

  /// Start offset within the item.
  final int startOffset;

  /// End offset within the item.
  final int endOffset;

  /// Shaping result for text items.
  ShapeResult? shapeResult;

  /// Whether this result uses the entire item.
  bool get isFullItem =>
      startOffset == item.startOffset && endOffset == item.endOffset;

  /// Get the length of this result.
  int get length => endOffset - startOffset;
}
