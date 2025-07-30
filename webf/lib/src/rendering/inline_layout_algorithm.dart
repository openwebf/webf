import 'dart:math' as math;
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

  /// Stack of open inline boxes.
  final List<InlineBoxState> _boxStack = [];

  /// Perform layout and return line boxes.
  List<LineBox> layout() {
    final lineBoxes = <LineBox>[];

    // First, layout all atomic inline items before line breaking
    _layoutAtomicInlineItems();

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

  /// Layout all atomic inline items to ensure they have proper sizes.
  void _layoutAtomicInlineItems() {
    // Keep track of already laid out boxes to avoid duplicate layouts
    final Set<RenderBox> layoutCompleted = {};

    for (final item in context.items) {
      if (item.isAtomicInline && item.renderBox != null) {
        final layoutBox = item.renderBox!;

        // Determine constraints based on the actual render box that needs constraints
        BoxConstraints childConstraints = layoutBox.getConstraints();
        // Layout the box - if it's RenderEventListener, it will propagate to its child
        layoutBox.layout(childConstraints, parentUsesSize: true);
        layoutCompleted.add(layoutBox);
      }
    }
  }

  /// Create a line box from line items.
  LineBox _createLineBox(List<InlineItemResult> lineItems) {
    final lineBoxItems = <LineBoxItem>[];

    // Calculate line metrics
    double maxAscent = 0;
    double maxDescent = 0;
    double lineWidth = 0;
    double maxLineHeight = 0;

    // Get container's line-height as default
    final containerStyle = context.container.renderStyle;
    maxLineHeight = _calculateCSSLineHeight(containerStyle);

    // First pass: calculate metrics
    for (final itemResult in lineItems) {
      final item = itemResult.item;

      if (item.isText && itemResult.shapeResult != null) {
        // print('  Item ascent: ${itemResult.shapeResult!.ascent}, descent: ${itemResult.shapeResult!.descent}');
        maxAscent = math.max(maxAscent, itemResult.shapeResult!.ascent);
        maxDescent = math.max(maxDescent, itemResult.shapeResult!.descent);

        // Calculate the CSS line-height for this item
        if (item.style != null) {
          final cssLineHeight = _calculateCSSLineHeight(item.style!);
          maxLineHeight = math.max(maxLineHeight, cssLineHeight);
        }
      } else if (item.isAtomicInline && item.renderBox != null) {
        // For atomic inlines, get baseline from the render box
        final renderBox = item.renderBox!;

        // Use boxSize for RenderBoxModel to avoid "size accessed beyond scope" error
        final double height = renderBox is RenderBoxModel
            ? (renderBox.boxSize?.height ?? 0.0)
            : (renderBox.hasSize ? renderBox.size.height : 0.0);

        if (height > 0) {
          // Try to get actual baseline if available
          double baseline = 0;
          if ((renderBox is RenderBoxModel && renderBox.boxSize != null)) {
            // Get baseline from the render box
            final computedBaseline = renderBox.computeDistanceToActualBaseline(TextBaseline.alphabetic);
            if (computedBaseline != null) {
              baseline = computedBaseline;
            } else {
              // For replaced elements (images, etc.), baseline is at the bottom
              // For inline-block without content, also use bottom
              baseline = height.toDouble();
            }
          } else {
            // Fallback to bottom edge
            baseline = height.toDouble();
          }

          maxAscent = math.max(maxAscent, baseline);
          maxDescent = math.max(maxDescent, height - baseline);
        }
      }

      lineWidth += itemResult.inlineSize;
    }

    // Calculate final line height based on CSS line-height property
    double fontMetricsHeight = maxAscent + maxDescent;

    // Use the larger of CSS line-height or natural font metrics
    double calculatedLineHeight = math.max(fontMetricsHeight, maxLineHeight);

    // Ensure minimum line height for empty lines or when metrics are not available
    if (calculatedLineHeight == 0 && lineItems.isNotEmpty) {
      // Use a default line height based on the container's font size
      calculatedLineHeight = 16.0; // Default to 16px if no metrics available
    }

    final lineHeight = calculatedLineHeight;

    // Calculate baseline position based on line height
    // When line-height is larger than font metrics, center the text vertically
    double baseline;
    if (maxLineHeight > fontMetricsHeight && fontMetricsHeight > 0) {
      // Add half the extra space above the text
      final extraSpace = maxLineHeight - fontMetricsHeight;
      baseline = maxAscent + (extraSpace / 2);
    } else {
      baseline = maxAscent;
    }

    // Debug line box metrics
    // print('LineBox: maxAscent=$maxAscent maxDescent=$maxDescent lineHeight=$lineHeight');

    // Reset position for this line
    _currentX = 0;
    _boxStack.clear();

    // Second pass: create line box items
    for (final itemResult in lineItems) {
      final item = itemResult.item;

      if (item.isOpenTag) {
        _handleOpenTag(item);
      } else if (item.isCloseTag) {
        _handleCloseTag(item, lineBoxItems, baseline, lineHeight);
      } else if (item.isText) {
        _addTextItem(itemResult, lineBoxItems, baseline);
      } else if (item.isAtomicInline) {
        _addAtomicItem(itemResult, lineBoxItems, baseline, maxAscent, maxDescent, lineHeight);
      }
    }

    // Close any remaining open boxes
    while (_boxStack.isNotEmpty) {
      _closeBox(_boxStack.removeLast(), lineBoxItems, baseline, lineHeight);
    }

    // Apply text alignment
    _applyTextAlign(lineBoxItems, lineWidth, constraints.maxWidth);

    return LineBox(
      width: lineWidth,
      height: lineHeight,
      baseline: baseline,
      items: lineBoxItems,
    );
  }

  /// Calculate the CSS line-height in pixels.
  double _calculateCSSLineHeight(CSSRenderStyle style) {
    final lineHeight = style.lineHeight;
    final fontSize = style.fontSize.computedValue;

    if (lineHeight.type == CSSLengthType.NORMAL) {
      // "normal" line-height - use natural font metrics
      return 0; // Will use font metrics
    }

    if (lineHeight.value == null) {
      return 0;
    }

    // For em values (including unitless numbers which are converted to em), multiply by font size
    if (lineHeight.type == CSSLengthType.EM) {
      return fontSize * lineHeight.value!;
    }

    // For percentage values, the value is already normalized (e.g., 150% = 1.5)
    // The computed value is already calculated correctly
    if (lineHeight.type == CSSLengthType.PERCENTAGE) {
      return lineHeight.computedValue;
    }

    // For absolute values (px, pt, etc.), use computed value
    return lineHeight.computedValue;
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
  void _handleCloseTag(InlineItem item, List<LineBoxItem> lineBoxItems, double baseline, double lineHeight) {
    // Find matching open box in stack
    for (int i = _boxStack.length - 1; i >= 0; i--) {
      if (_boxStack[i].renderBox == item.renderBox) {
        final boxState = _boxStack.removeAt(i);
        _closeBox(boxState, lineBoxItems, baseline, lineHeight);
        break;
      }
    }
  }

  /// Close an inline box.
  void _closeBox(InlineBoxState boxState, List<LineBoxItem> lineBoxItems, double baseline, double lineHeight) {
    final width = _currentX - boxState.startX;

    if (width > 0) {
      // Use the actual line height for the box
      final height = lineHeight;
      // Position the box so its bottom aligns with the baseline + descent
      final y = 0.0; // Top of line box

      lineBoxItems.add(BoxLineBoxItem(
        offset: Offset(boxState.startX, y),
        size: Size(width, height),
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

    // Calculate vertical position - text baseline should align with line baseline
    final y = baseline - itemResult.shapeResult!.ascent;

    final textItem = TextLineBoxItem(
      offset: Offset(_currentX, y),
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
  void _addAtomicItem(InlineItemResult itemResult, List<LineBoxItem> lineBoxItems, double baseline, double maxAscent,
      double maxDescent, double lineHeight) {
    final item = itemResult.item;
    if (item.renderBox == null) return;

    final renderBox = item.renderBox!;

    // Use boxSize for RenderBoxModel to avoid "size accessed beyond scope" error
    final double height = renderBox is RenderBoxModel
        ? (renderBox.boxSize?.height ?? 0.0)
        : (renderBox.hasSize ? renderBox.size.height : 0.0);

    if (height == 0) return; // Skip if no valid size

    // Get the item's baseline if available
    final itemBaseline = renderBox is RenderBoxModel
        ? renderBox.computeDistanceToActualBaseline(TextBaseline.alphabetic) ?? height
        : height;

    // Calculate vertical position based on alignment
    double y = 0;
    if (item.style != null) {
      switch (item.style!.verticalAlign) {
        case VerticalAlign.baseline:
          // Align item's baseline with line baseline
          y = baseline - itemBaseline;
          break;
        case VerticalAlign.top:
          // Align top of element with top of line box
          y = 0;
          break;
        case VerticalAlign.middle:
          // Align vertical midpoint with baseline plus half x-height
          // For simplicity, use baseline - height/2 as approximation
          y = baseline - height / 2;
          break;
        case VerticalAlign.bottom:
          // Align bottom of element with bottom of line box
          y = lineHeight - height;
          break;
        case VerticalAlign.textTop:
          // Align top with top of parent's content area
          y = baseline - maxAscent;
          break;
        case VerticalAlign.textBottom:
          // Align bottom with bottom of parent's content area
          y = baseline + maxDescent - height;
          break;
        default:
          y = baseline - itemBaseline;
      }
    }

    // Use boxSize for RenderBoxModel to avoid "size accessed beyond scope" error
    final size = renderBox is RenderBoxModel
        ? (renderBox.boxSize ?? Size.zero)
        : (renderBox.hasSize ? renderBox.size : Size.zero);

    final atomicItem = AtomicLineBoxItem(
      offset: Offset(_currentX, y),
      size: size,
      renderBox: renderBox,
    );

    lineBoxItems.add(atomicItem);
    _currentX += itemResult.inlineSize;
  }

  /// Apply text alignment to line box items.
  void _applyTextAlign(List<LineBoxItem> items, double lineWidth, double availableWidth) {
    if (items.isEmpty) return;

    final containerStyle = (context.container as RenderBoxModel).renderStyle;

    double offset = 0;
    
    // Determine the effective text alignment
    TextAlign effectiveAlign = containerStyle.textAlign;
    
    // Handle TextAlign.start based on text direction
    if (effectiveAlign == TextAlign.start) {
      effectiveAlign = containerStyle.direction == TextDirection.rtl 
          ? TextAlign.right 
          : TextAlign.left;
    }

    switch (effectiveAlign) {
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
      case TextAlign.left:
      case TextAlign.start:
      default:
        // Left alignment, no offset needed
        break;
    }

    if (offset > 0) {
      for (final item in items) {
        item.offset = item.offset.translate(offset, 0);
      }
    }
  }
}
