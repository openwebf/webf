/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
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
  final RenderBoxModel? renderBox;

  /// Style for this item.
  final CSSRenderStyle? style;

  /// Bidi level for this item.
  int bidiLevel;
  
  /// Text direction for this item (used for element-level direction changes).
  TextDirection? direction;

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

    // Don't create box fragments for EventListener wrappers
    // They share styles with their children but shouldn't paint backgrounds
    if (renderBox is RenderEventListener) {
      return false;
    }

    final renderStyle = (renderBox)?.renderStyle;
    if (renderStyle == null) return false;

    // Create box fragment if has borders, padding, or background
    return (renderStyle.borderLeftWidth?.value != null && renderStyle.borderLeftWidth!.value! > 0) ||
           (renderStyle.borderTopWidth?.value != null && renderStyle.borderTopWidth!.value! > 0) ||
           (renderStyle.borderRightWidth?.value != null && renderStyle.borderRightWidth!.value! > 0) ||
           (renderStyle.borderBottomWidth?.value != null && renderStyle.borderBottomWidth!.value! > 0) ||
           (renderStyle.paddingLeft.value != null && renderStyle.paddingLeft.value! > 0) ||
           (renderStyle.paddingTop.value != null && renderStyle.paddingTop.value! > 0) ||
           (renderStyle.paddingRight.value != null && renderStyle.paddingRight.value! > 0) ||
           (renderStyle.paddingBottom.value != null && renderStyle.paddingBottom.value! > 0) ||
           (renderStyle.backgroundColor?.value != null);
  }

  @override
  String toString() {
    return 'InlineItem(type: $type, offset: $startOffset-$endOffset)';
  }

  /// Add debugging information for the inline item.
  void debugFillProperties(DiagnosticPropertiesBuilder properties, String textContent) {
    properties.add(EnumProperty<InlineItemType>('type', type));
    properties.add(IntProperty('startOffset', startOffset));
    properties.add(IntProperty('endOffset', endOffset));
    properties.add(IntProperty('length', length));
    properties.add(IntProperty('bidiLevel', bidiLevel));
    
    if (direction != null) {
      properties.add(EnumProperty<TextDirection>('direction', direction));
    }
    
    if (isText && textContent.isNotEmpty) {
      final text = getText(textContent);
      final displayText = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      properties.add(StringProperty('text', displayText, quoted: true));
    }
    
    if (renderBox != null) {
      properties.add(DiagnosticsProperty<RenderBoxModel>('renderBox', renderBox));
    }
    
    if (shapeResult != null) {
      properties.add(DiagnosticsProperty<ShapeResult>('shapeResult', shapeResult,
          description: 'w=${shapeResult!.width.toStringAsFixed(1)}, '
              'h=${shapeResult!.height.toStringAsFixed(1)}, '
              'ascent=${shapeResult!.ascent.toStringAsFixed(1)}'));
    }
    
    if (shouldCreateBoxFragment) {
      properties.add(FlagProperty('shouldCreateBoxFragment',
          value: true,
          ifTrue: 'creates box fragment'));
    }
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
