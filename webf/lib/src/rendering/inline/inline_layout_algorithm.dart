import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_formatting_context.dart';
import 'inline_item.dart';
import 'inline_box_state.dart';
import 'line_box.dart';
import 'line_breaker.dart';

/// Performs inline layout algorithm.
/// Based on Blink's InlineLayoutAlgorithm.
class InlineLayoutAlgorithm {
  InlineLayoutAlgorithm({
    required this.context,
    required this.constraints,
  });

  /// The inline formatting context.
  final InlineFormattingContext context;

  /// Layout constraints.
  final BoxConstraints constraints;

  /// Current position in layout.
  double _currentX = 0;
  double _currentY = 0;

  /// Stack of open inline boxes.
  final List<InlineBoxState> _boxStack = [];

  /// Perform layout and return line boxes.
  List<LineBox> layout() {
    final lineBoxes = <LineBox>[];

    // Create line breaker
    final lineBreaker = LineBreaker(
      items: context.items,
      textContent: context.textContent,
      availableWidth: constraints.maxWidth,
    );

    // Break into lines
    final lines = lineBreaker.breakLines();

    // Create line boxes
    for (final line in lines) {
      final lineBox = _createLineBox(line);
      lineBoxes.add(lineBox);
    }

    return lineBoxes;
  }

  /// Create a line box from line items.
  LineBox _createLineBox(List<InlineItemResult> lineItems) {
    final lineBoxItems = <LineBoxItem>[];

    // Calculate line metrics
    double maxAscent = 0;
    double maxDescent = 0;
    double lineWidth = 0;

    // First pass: calculate metrics
    for (final itemResult in lineItems) {
      final item = itemResult.item;

      if (item.isText && itemResult.shapeResult != null) {
        maxAscent = math.max(maxAscent, itemResult.shapeResult!.ascent);
        maxDescent = math.max(maxDescent, itemResult.shapeResult!.descent);
      } else if (item.isAtomicInline && item.renderBox != null) {
        // For atomic inlines, use their height
        final height = item.renderBox!.size.height;
        maxAscent = math.max(maxAscent, height * 0.8); // Approximate baseline
        maxDescent = math.max(maxDescent, height * 0.2);
      }

      lineWidth += itemResult.inlineSize;
    }

    final lineHeight = maxAscent + maxDescent;
    final baseline = maxAscent;

    // Reset position for this line
    _currentX = 0;
    _boxStack.clear();

    // Second pass: create line box items
    for (final itemResult in lineItems) {
      final item = itemResult.item;

      if (item.isOpenTag) {
        _handleOpenTag(item);
      } else if (item.isCloseTag) {
        _handleCloseTag(item, lineBoxItems, baseline);
      } else if (item.isText) {
        _addTextItem(itemResult, lineBoxItems, baseline);
      } else if (item.isAtomicInline) {
        _addAtomicItem(itemResult, lineBoxItems, baseline);
      }
    }

    // Close any remaining open boxes
    while (_boxStack.isNotEmpty) {
      _closeBox(_boxStack.removeLast(), lineBoxItems, baseline);
    }

    // Apply text alignment
    _applyTextAlign(lineBoxItems, lineWidth, constraints.maxWidth);

    return LineBox(
      width: constraints.maxWidth,
      height: lineHeight,
      baseline: baseline,
      items: lineBoxItems,
    );
  }

  /// Handle open tag.
  void _handleOpenTag(InlineItem item) {
    if (item.renderBox != null && item.shouldCreateBoxFragment) {
      _boxStack.add(InlineBoxState(
        renderBox: item.renderBox!,
        style: item.style!,
        startX: _currentX,
      ));
    }
  }

  /// Handle close tag.
  void _handleCloseTag(InlineItem item, List<LineBoxItem> lineBoxItems, double baseline) {
    // Find matching open box in stack
    for (int i = _boxStack.length - 1; i >= 0; i--) {
      if (_boxStack[i].renderBox == item.renderBox) {
        final boxState = _boxStack.removeAt(i);
        _closeBox(boxState, lineBoxItems, baseline);
        break;
      }
    }
  }

  /// Close an inline box.
  void _closeBox(InlineBoxState boxState, List<LineBoxItem> lineBoxItems, double baseline) {
    final width = _currentX - boxState.startX;

    if (width > 0) {
      // Calculate vertical position based on vertical-align
      final y = _getVerticalPosition(boxState.style, baseline, 0);

      lineBoxItems.add(BoxLineBoxItem(
        offset: Offset(boxState.startX, y),
        size: Size(width, baseline * 1.2), // Approximate height
        renderBox: boxState.renderBox,
        style: boxState.style,
        children: boxState.children,
      ));
    }
  }

  /// Add text item to line box.
  void _addTextItem(InlineItemResult itemResult, List<LineBoxItem> lineBoxItems, double baseline) {
    final item = itemResult.item;
    if (itemResult.shapeResult == null) return;

    final text = context.textContent.substring(itemResult.startOffset, itemResult.endOffset);

    // Create text painter
    final textPainter = itemResult.shapeResult!.glyphData as TextPainter;

    // Calculate vertical position
    final y = _getVerticalPosition(item.style!, baseline, itemResult.shapeResult!.ascent);

    final textItem = TextLineBoxItem(
      offset: Offset(_currentX, y.toDouble()),
      size: Size(itemResult.inlineSize, itemResult.shapeResult!.height),
      text: text,
      style: item.style!,
      textPainter: textPainter,
      inlineItem: item,
    );

    // Add to current box if any
    if (_boxStack.isNotEmpty) {
      _boxStack.last.children.add(textItem);
    } else {
      lineBoxItems.add(textItem);
    }

    _currentX += itemResult.inlineSize;
  }

  /// Add atomic inline item to line box.
  void _addAtomicItem(InlineItemResult itemResult, List<LineBoxItem> lineBoxItems, double baseline) {
    final item = itemResult.item;
    if (item.renderBox == null) return;

    final renderBox = item.renderBox!;
    final height = renderBox.size.height;

    // Calculate vertical position
    final y = item.style != null ? _getVerticalPosition(item.style!, baseline, height) : 0;

    final atomicItem = AtomicLineBoxItem(
      offset: Offset(_currentX, y.toDouble()),
      size: renderBox.size,
      renderBox: renderBox,
    );

    lineBoxItems.add(atomicItem);
    _currentX += itemResult.inlineSize;
  }

  /// Get vertical position based on vertical-align.
  double _getVerticalPosition(CSSRenderStyle style, double baseline, double itemHeight) {
    switch (style.verticalAlign) {
      case VerticalAlign.baseline:
        return baseline - itemHeight;
      case VerticalAlign.top:
        return 0;
      case VerticalAlign.middle:
        return (baseline - itemHeight / 2);
      case VerticalAlign.bottom:
        return baseline * 2 - itemHeight; // Approximate line height
      case VerticalAlign.textTop:
        return baseline - itemHeight;
      case VerticalAlign.textBottom:
        return baseline;
      default:
        return baseline - itemHeight;
    }
  }

  /// Apply text alignment to line box items.
  void _applyTextAlign(List<LineBoxItem> items, double lineWidth, double availableWidth) {
    if (items.isEmpty) return;

    final containerStyle = context.container is RenderBoxModel ?
        (context.container as RenderBoxModel).renderStyle : null;

    if (containerStyle == null) return;

    double offset = 0;

    switch (containerStyle.textAlign) {
      case TextAlign.center:
        offset = (availableWidth - lineWidth) / 2;
        break;
      case TextAlign.right:
      case TextAlign.end:
        offset = availableWidth - lineWidth;
        break;
      case TextAlign.justify:
        // TODO: Implement justify alignment
        break;
      default:
        // Left alignment, no offset needed
        break;
    }

    if (offset > 0) {
      for (final item in items) {
        item.offset.translate(offset, 0);
      }
    }
  }

  /// Default style for items without style.
  // CSSRenderStyle get _defaultStyle => CSSRenderStyle();
}
