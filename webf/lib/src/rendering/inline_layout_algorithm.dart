import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_formatting_context.dart';
import 'inline_item.dart';
import 'inline_box_state.dart';
import 'line_box.dart';
import 'line_breaker.dart';

/// Helper class for tracking runs during bidi reordering
class _RunInfo {
  final int start;
  final int end;
  _RunInfo(this.start, this.end);
}

/// Helper class for tracking segments during RTL base direction processing
class _Segment {
  final int start;
  final int end;
  final int level;
  _Segment(this.start, this.end, this.level);
}


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

  /// Map to track which items belong to which inline box.
  final Map<RenderBox, List<LineBoxItem>> _boxToItems = {};

  // Track per-line visual start/end X for inline boxes (padding box, excluding margins)
  // This allows creating box fragments even when an inline has no children (empty inline).
  final Map<RenderBox, double> _currentLineBoxStartX = {};
  final Map<RenderBox, double> _currentLineBoxEndX = {};

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

    // Track which boxes appear on which lines
    final boxToLines = <RenderBox, List<int>>{};
    final Set<RenderBox> openBoxes = {}; // Track currently open boxes
    
    // Global map to track all items for each box across all lines
    final globalBoxToItems = <RenderBox, List<LineBoxItem>>{};
    
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final Set<RenderBox> boxesInLine = Set.from(openBoxes); // Start with boxes open from previous line
      
      for (final itemResult in line) {
        final item = itemResult.item;
        
        if (item.isOpenTag && item.renderBox != null) {
          openBoxes.add(item.renderBox!);
          boxesInLine.add(item.renderBox!);
        } else if (item.isCloseTag && item.renderBox != null) {
          openBoxes.remove(item.renderBox!);
          boxesInLine.add(item.renderBox!);
        } else if (item.isText && item.renderBox != null) {
          boxesInLine.add(item.renderBox!);
        }
      }
      
      // Record all boxes that appear on this line
      for (final box in boxesInLine) {
        boxToLines.putIfAbsent(box, () => []).add(lineIndex);
      }
      
    }

    // Create line boxes with fragment information
    // Track which boxes are currently open as we process lines
    final Set<RenderBox> activeBoxes = {};
    
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      
      // Pass current active boxes to line creation
      final lineBox = _createLineBox(line, lineIndex, boxToLines, globalBoxToItems, Set.from(activeBoxes));
      lineBoxes.add(lineBox);
      
      // Update active boxes AFTER creating the line box
      for (final itemResult in line) {
        final item = itemResult.item;
        if (item.isOpenTag && item.renderBox != null) {
          activeBoxes.add(item.renderBox!);
        } else if (item.isCloseTag && item.renderBox != null) {
          activeBoxes.remove(item.renderBox!);
        }
      }
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
  LineBox _createLineBox(List<InlineItemResult> lineItems, int lineIndex, Map<RenderBox, List<int>> boxToLines, Map<RenderBox, List<LineBoxItem>> globalBoxToItems, Set<RenderBox> activeBoxes) {
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

          // Include vertical margins in ascent/descent per CSS inline formatting
          CSSRenderStyle? style = item.style;
          if (style == null && renderBox is RenderBoxModel) {
            style = (renderBox as RenderBoxModel).renderStyle;
          }
          final double marginTop = style?.marginTop.computedValue ?? 0.0;
          final double marginBottom = style?.marginBottom.computedValue ?? 0.0;

          final double ascentWithMargin = marginTop + baseline;
          final double descentWithMargin = (height - baseline) + marginBottom;

          maxAscent = math.max(maxAscent, ascentWithMargin);
          maxDescent = math.max(maxDescent, descentWithMargin);
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
    // print('LineBox: maxAscent=$maxAscent maxDescent=$maxDescent lineHeight=$lineHeight baseline=$baseline');

    // Reset position for this line
    _currentX = 0;
    _boxStack.clear();
    _currentLineBoxStartX.clear();
    _currentLineBoxEndX.clear();
    // Don't clear _boxToItems - we'll use globalBoxToItems instead

    // Always apply bidi reordering based on resolved levels
    // This handles both RTL and LTR base directions with mixed content
    final List<InlineItemResult> orderedItems = _reorderLineItemsForBidi(lineItems);

    // Track which inline boxes are open for each item
    final Map<InlineItemResult, Set<RenderBox>> itemToBoxes = {};
    final List<RenderBox> currentBoxes = List.from(activeBoxes); // Start with already active boxes

    // First pass: determine which boxes each item belongs to
    // This is done in logical order before bidi reordering
    for (final itemResult in lineItems) {
      final item = itemResult.item;

      if (item.isOpenTag && item.renderBox != null) {
        currentBoxes.add(item.renderBox!);
      }

      // Record which boxes this item is inside
      if (currentBoxes.isNotEmpty) {
        itemToBoxes[itemResult] = Set.from(currentBoxes);
      } else if (item.isCloseTag && item.renderBox != null) {
        // Special case for close tags when no boxes are open
        itemToBoxes[itemResult] = {item.renderBox!};
      }
      
      if (item.isCloseTag && item.renderBox != null) {
        currentBoxes.remove(item.renderBox!);
      }
    }

    // Second pass: layout items in visual order and track positions
    for (final itemResult in orderedItems) {
      final item = itemResult.item;

      if (item.isOpenTag) {
        _handleOpenTag(item, itemResult);
      } else if (item.isCloseTag) {
        _handleCloseTag(item, itemResult);
      } else if (item.isText) {
        final textItem = _addTextItem(itemResult, lineBoxItems, baseline);
        // Track this item for any boxes it belongs to
        if (itemToBoxes.containsKey(itemResult)) {
          for (final box in itemToBoxes[itemResult]!) {
            globalBoxToItems.putIfAbsent(box, () => []).add(textItem);
          }
        }
      } else if (item.isAtomicInline) {
        final atomicItem = _addAtomicItem(itemResult, lineBoxItems, baseline, maxAscent, maxDescent, lineHeight);
        // Track this item for any boxes it belongs to
        if (itemToBoxes.containsKey(itemResult)) {
          for (final box in itemToBoxes[itemResult]!) {
            globalBoxToItems.putIfAbsent(box, () => []).add(atomicItem);
          }
        }
      }
    }

    // Third pass: create box items with correct visual bounds
    _createInlineBoxes(lineItems, lineBoxItems, baseline, lineHeight, lineIndex, boxToLines, globalBoxToItems, maxAscent, maxDescent);

    // Calculate text alignment offset
    final alignmentOffset = _calculateTextAlignOffset(lineWidth, constraints.maxWidth);

    return LineBox(
      width: lineWidth,
      height: lineHeight,
      baseline: baseline,
      items: lineBoxItems,
      alignmentOffset: alignmentOffset,
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
  void _handleOpenTag(InlineItem item, InlineItemResult itemResult) {
    if (item.renderBox != null && item.shouldCreateBoxFragment) {
      final style = item.style!;

      // The inlineSize from LineBreaker already includes margin and padding
      // We need to track where the actual box content starts (after margin but before padding)
      final leftMargin = style.marginLeft.computedValue;
      final leftBorder = style.borderLeftWidth?.computedValue ?? 0.0;
      final leftPadding = style.paddingLeft.computedValue;

      // Advance by margin first
      _currentX += leftMargin;

      // Store the position after margin (where the box's border box starts)
      final boxStartX = _currentX;

      _boxStack.add(InlineBoxState(
        renderBox: item.renderBox!,
        style: style,
        startX: boxStartX,
      ));

      // Record start X for this inline box's visual (padding) area on this line
      _currentLineBoxStartX[item.renderBox!] = boxStartX;

      // Then advance by border and padding to place content
      _currentX += leftBorder;
      _currentX += leftPadding;
    } else if (item.renderBox != null) {
      // This is an open tag without box fragment - still advance by its size
      _currentX += itemResult.inlineSize;
    }
  }

  /// Handle close tag.
  void _handleCloseTag(InlineItem item, InlineItemResult itemResult) {
    if (item.renderBox != null && item.shouldCreateBoxFragment) {
      final style = item.style!;

      // Handle right padding and margin
      final rightPadding = style.paddingRight.computedValue;
      final rightBorder = style.borderRightWidth?.computedValue ?? 0.0;
      final rightMargin = style.marginRight.computedValue;


      // Find the matching open box in the stack
      for (int i = _boxStack.length - 1; i >= 0; i--) {
        if (_boxStack[i].renderBox == item.renderBox) {
          // Remove from stack but don't create box item here
          // Box items are created in _createInlineBoxes
          _boxStack.removeAt(i);
          break;
        }
      }

      // Record end X (end of border box) BEFORE adding margin
      final boxEndX = _currentX + rightPadding + rightBorder;

      // Advance by padding, border, then margin
      _currentX += rightPadding;
      _currentX += rightBorder;
      _currentX += rightMargin;

      // Save end X for this inline box on this line
      _currentLineBoxEndX[item.renderBox!] = boxEndX;


    } else if (item.renderBox != null) {
      // This is a close tag without box fragment - still advance by its size
      _currentX += itemResult.inlineSize;
    }
  }

  /// Handle close tag at line end.
  void _handleCloseTagAtLineEnd(InlineItem item, List<LineBoxItem> lineBoxItems, double baseline, double lineHeight) {
    // Find matching open box in stack
    for (int i = _boxStack.length - 1; i >= 0; i--) {
      if (_boxStack[i].renderBox == item.renderBox) {
        final boxState = _boxStack.removeAt(i);
        // Don't create box item here - it will be created in _createInlineBoxes
        break;
      }
    }
  }

  /// Close an inline box.
  void _closeBox(InlineBoxState boxState, List<LineBoxItem> lineBoxItems, double baseline, double lineHeight) {
    // This method is now only called for unclosed boxes at the end of the line
    // Don't create box item here - it will be created in _createInlineBoxes
  }

  /// Add text item to line box.
  LineBoxItem _addTextItem(InlineItemResult itemResult, List<LineBoxItem> lineBoxItems, double baseline) {
    final item = itemResult.item;
    if (itemResult.shapeResult == null) {
      // Return a dummy item if no shape result
      return TextLineBoxItem(
        offset: Offset.zero,
        size: Size.zero,
        text: '',
        style: context.container.renderStyle,
        textPainter: TextPainter(),
        inlineItem: item,
      );
    }

    final text = context.textContent.substring(itemResult.startOffset, itemResult.endOffset);
    
    // Apply Phase II: trim leading spaces at line start for normal/nowrap
    String processedText = text;
    if (item.style != null && 
        (item.style!.whiteSpace == WhiteSpace.normal || 
         item.style!.whiteSpace == WhiteSpace.nowrap ||
         item.style!.whiteSpace == WhiteSpace.preLine)) {
      // Check if this is the first text item on the line
      bool isFirstTextOnLine = true;
      for (final existingItem in lineBoxItems) {
        if (existingItem is TextLineBoxItem) {
          isFirstTextOnLine = false;
          break;
        }
      }
      
      if (isFirstTextOnLine) {
        // Trim leading spaces
        processedText = text.trimLeft();
        
        // If all text was trimmed, skip this item
        if (processedText.isEmpty && text.isNotEmpty) {
          return TextLineBoxItem(
            offset: Offset.zero,
            size: Size.zero,
            text: '',
            style: context.container.renderStyle,
            textPainter: TextPainter(),
            inlineItem: item,
          );
        }
      }
    }

    // Create text painter with processed text
    TextPainter textPainter;
    if (processedText != text) {
      // Need to create a new text painter with trimmed text
      final textSpan = CSSTextMixin.createTextSpan(processedText, item.style!);
      textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
    } else {
      // Use the existing text painter
      textPainter = itemResult.shapeResult!.glyphData as TextPainter;
    }

    // Calculate vertical position - text baseline should align with line baseline
    final y = baseline - itemResult.shapeResult!.ascent;


    // Use the actual width of the processed text
    final actualWidth = processedText != text ? textPainter.width : itemResult.inlineSize;
    
    final textItem = TextLineBoxItem(
      offset: Offset(_currentX, y),
      size: Size(actualWidth, itemResult.shapeResult!.height),
      text: processedText,
      style: item.style!,
      textPainter: textPainter,
      inlineItem: item,
    );

    // Always add to line box items (not to box stack)
    lineBoxItems.add(textItem);

    _currentX += actualWidth;
    return textItem;
  }

  /// Add atomic inline item to line box.
  LineBoxItem _addAtomicItem(InlineItemResult itemResult, List<LineBoxItem> lineBoxItems, double baseline, double maxAscent,
      double maxDescent, double lineHeight) {
    final item = itemResult.item;
    if (item.renderBox == null) {
      // Return a dummy item if no render box
      return AtomicLineBoxItem(
        offset: Offset.zero,
        size: Size.zero,
        renderBox: context.container,
      );
    }

    final renderBox = item.renderBox!;

    // Use boxSize for RenderBoxModel to avoid "size accessed beyond scope" error
    final double height = renderBox is RenderBoxModel
        ? (renderBox.boxSize?.height ?? 0.0)
        : (renderBox.hasSize ? renderBox.size.height : 0.0);

    if (height == 0) {
      // Return a dummy item if no valid size
      return AtomicLineBoxItem(
        offset: Offset.zero,
        size: Size.zero,
        renderBox: renderBox,
      );
    }

    // Get the item's baseline if available
    final itemBaseline = renderBox is RenderBoxModel
        ? renderBox.computeDistanceToActualBaseline(TextBaseline.alphabetic) ?? height
        : height;

    // Resolve style once for vertical/horizontal margins
    CSSRenderStyle? style = item.style;
    if (style == null && renderBox is RenderBoxModel) {
      style = (renderBox as RenderBoxModel).renderStyle;
    }

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
          // top of margin box = 0 => top of border box = marginTop
          y = (style?.marginTop.computedValue ?? 0.0);
          break;
        case VerticalAlign.middle:
          // Align vertical midpoint with baseline plus half x-height
          // For simplicity, use baseline - height/2 as approximation
          y = baseline - height / 2;
          break;
        case VerticalAlign.bottom:
          // Align bottom of element with bottom of line box
          // bottom of margin box = lineHeight => top of border box = lineHeight - (height + marginBottom)
          y = lineHeight - (height + (style?.marginBottom.computedValue ?? 0.0));
          break;
        case VerticalAlign.textTop:
          // Align top with top of parent's content area
          // top of margin box = baseline - maxAscent => top of border box adds marginTop
          y = (baseline - maxAscent) + (style?.marginTop.computedValue ?? 0.0);
          break;
        case VerticalAlign.textBottom:
          // Align bottom with bottom of parent's content area
          // bottom of margin box = baseline + maxDescent
          y = (baseline + maxDescent) - (height + (style?.marginBottom.computedValue ?? 0.0));
          break;
        default:
          y = baseline - itemBaseline;
      }
    }

    // Use boxSize for RenderBoxModel to avoid "size accessed beyond scope" error
    final size = renderBox is RenderBoxModel
        ? (renderBox.boxSize ?? Size.zero)
        : (renderBox.hasSize ? renderBox.size : Size.zero);

    // Apply horizontal margins for inline-block/atomic inlines
    final double marginLeft = style?.marginLeft.computedValue ?? 0.0;
    final double marginRight = style?.marginRight.computedValue ?? 0.0;

    final atomicItem = AtomicLineBoxItem(
      offset: Offset(_currentX + marginLeft, y),
      size: size,
      renderBox: renderBox,
    );

    lineBoxItems.add(atomicItem);
    // Advance currentX by full inline size (box width + margins)
    _currentX += itemResult.inlineSize;
    return atomicItem;
  }

  /// Create inline box items with correct visual bounds after bidi reordering.
  /// This solves the issue where inline box backgrounds were positioned incorrectly
  /// after bidi reordering, especially for nested LTR spans in RTL context.
  void _createInlineBoxes(List<InlineItemResult> lineItems, List<LineBoxItem> lineBoxItems, double baseline, double lineHeight, int lineIndex, Map<RenderBox, List<int>> boxToLines, Map<RenderBox, List<LineBoxItem>> globalBoxToItems, double maxAscent, double maxDescent) {
    // For this specific line, find which boxes need to be rendered
    final Set<RenderBox> boxesOnThisLine = {};
    
    // Check which boxes appear on this line according to boxToLines
    for (final entry in boxToLines.entries) {
      if (entry.value.contains(lineIndex)) {
        boxesOnThisLine.add(entry.key);
      }
    }
    
    // Store box items temporarily to sort by nesting level
    final List<BoxLineBoxItem> boxItems = [];

    // For each box on this line, calculate its visual bounds based on its content
    for (final box in boxesOnThisLine) {
      final allItems = globalBoxToItems[box] ?? [];
      
      // Filter items that belong to this line
      final items = <LineBoxItem>[];
      for (final item in lineBoxItems) {
        if (allItems.contains(item)) {
          items.add(item);
        }
      }
      
      // If there are no child items on this line (empty inline), we can still
      // create a box fragment using recorded start/end X from open/close tags.
      if (items.isEmpty) {
        // Use recorded start/end positions for this line.
        final double? startX = _currentLineBoxStartX[box];
        final double? endX = _currentLineBoxEndX[box];

        if (startX == null || endX == null) {
          // No recorded positions; skip this box.
          continue;
        }

        // Create the box fragment if style indicates it should paint.
        CSSRenderStyle? style;
        if (box is RenderBoxModel) {
          style = box.renderStyle;
        }
        if (style != null && _shouldCreateBoxFragment(style)) {
          final boxWidth = math.max(0.0, endX - startX);

          // Determine fragment position info across multiple lines
          final lines = boxToLines[box] ?? [];
          final isFirstFragment = lines.isEmpty || lines.first == lineIndex;
          final isLastFragment = lines.isEmpty || lines.last == lineIndex;

          final boxItem = BoxLineBoxItem(
            offset: Offset(startX, 0.0),
            size: Size(boxWidth, lineHeight),
            renderBox: box,
            style: style,
            children: const [],
            isFirstFragment: isFirstFragment,
            isLastFragment: isLastFragment,
            baseline: baseline,
            contentAscent: maxAscent,
            contentDescent: maxDescent,
          );

          boxItems.add(boxItem);
        }

        // Nothing else to compute for this box
        continue;
      }

      // Find the leftmost and rightmost positions of the box's content
      // This gives us the actual visual bounds after bidi reordering
      double minX = double.infinity;
      double maxX = double.negativeInfinity;

      for (final item in items) {
        // Only consider actual content items (text and atomic), not box decorations
        if (item is TextLineBoxItem || item is AtomicLineBoxItem) {
          minX = math.min(minX, item.offset.dx);
          maxX = math.max(maxX, item.offset.dx + item.size.width);
        }
      }
      

      if (minX < double.infinity && maxX > double.negativeInfinity) {
        final width = maxX - minX;

        // Get the style for this box
        CSSRenderStyle? style;
        if (box is RenderBoxModel) {
          style = box.renderStyle;
        }

        if (style != null && _shouldCreateBoxFragment(style)) {
          // Calculate box bounds - only include padding, not margins
          // Margins create space in layout but aren't part of the visual box
          final paddingLeft = style.paddingLeft.computedValue;
          final paddingRight = style.paddingRight.computedValue;
          final borderLeft = style.borderLeftWidth?.computedValue ?? 0.0;
          final borderRight = style.borderRightWidth?.computedValue ?? 0.0;

          // The box visual area starts at the border box left
          // Since content is positioned after left border + padding, subtract both
          final boxStartX = minX - paddingLeft - borderLeft;
          // The box width is content width plus paddings and borders
          final boxWidth = width + paddingLeft + paddingRight + borderLeft + borderRight;
          

          // Determine if this is the first/last fragment of a multi-line inline element
          final lines = boxToLines[box] ?? [];
          final isFirstFragment = lines.isEmpty || lines.first == lineIndex;
          final isLastFragment = lines.isEmpty || lines.last == lineIndex;

          final boxItem = BoxLineBoxItem(
            offset: Offset(boxStartX, 0.0),
            size: Size(boxWidth, lineHeight),
            renderBox: box,
            style: style,
            children: items,
            isFirstFragment: isFirstFragment,
            isLastFragment: isLastFragment,
            baseline: baseline,
            contentAscent: maxAscent,
            contentDescent: maxDescent,
          );


          // Collect box items to sort later by nesting depth
          boxItems.add(boxItem);
        }
      }
    }
    
    // Sort box items by their containment relationship
    // We need to ensure parent boxes are painted before nested boxes
    // so that nested box backgrounds appear on top
    
    // Build a dependency graph to determine painting order
    final Map<BoxLineBoxItem, Set<BoxLineBoxItem>> containedBy = {};
    
    for (final boxItem in boxItems) {
      containedBy[boxItem] = {};
      
      // Check which other boxes contain this box
      for (final otherBox in boxItems) {
        if (otherBox == boxItem) continue;
        
        // If all of this box's items are also in the other box's items,
        // then this box is nested inside the other box
        bool isContained = true;
        for (final item in boxItem.children) {
          if (!otherBox.children.contains(item)) {
            isContained = false;
            break;
          }
        }
        
        if (isContained) {
          containedBy[boxItem]!.add(otherBox);
        }
      }
    }
    
    // Sort boxes so that containers come before their contents
    boxItems.sort((a, b) {
      // If a contains b, a should come first (painted first)
      if (containedBy[b]!.contains(a)) return -1;
      // If b contains a, b should come first
      if (containedBy[a]!.contains(b)) return 1;
      // Otherwise, sort by number of containers (most nested last)
      return containedBy[a]!.length.compareTo(containedBy[b]!.length);
    });
    
    // Insert all box items at the beginning in the correct order
    // This ensures parent boxes are painted before nested boxes
    // Insert in reverse order because we're inserting at position 0
    for (int i = boxItems.length - 1; i >= 0; i--) {
      lineBoxItems.insert(0, boxItems[i]);
    }
  }

  /// Check if a box should create a box fragment (has background, border, padding, or margin).
  bool _shouldCreateBoxFragment(CSSRenderStyle style) {
    return (style.borderLeftWidth?.value != null && style.borderLeftWidth!.value! > 0) ||
           (style.borderTopWidth?.value != null && style.borderTopWidth!.value! > 0) ||
           (style.borderRightWidth?.value != null && style.borderRightWidth!.value! > 0) ||
           (style.borderBottomWidth?.value != null && style.borderBottomWidth!.value! > 0) ||
           (style.paddingLeft?.value != null && style.paddingLeft!.value! > 0) ||
           (style.paddingTop?.value != null && style.paddingTop!.value! > 0) ||
           (style.paddingRight?.value != null && style.paddingRight!.value! > 0) ||
           (style.paddingBottom?.value != null && style.paddingBottom!.value! > 0) ||
           (style.marginLeft?.value != null && style.marginLeft!.value! > 0) ||
           (style.marginTop?.value != null && style.marginTop!.value! > 0) ||
           (style.marginRight?.value != null && style.marginRight!.value! > 0) ||
           (style.marginBottom?.value != null && style.marginBottom!.value! > 0) ||
           (style.backgroundColor?.value != null);
  }

  /// Reorder line items based on bidi levels for visual order.
  List<InlineItemResult> _reorderLineItemsForBidi(List<InlineItemResult> items) {
    // Apply the Unicode Bidirectional Algorithm reordering based on resolved bidi levels

    if (items.isEmpty) return items;


    // Find the highest bidi level
    int maxLevel = 0;
    int minLevel = 999;
    for (final item in items) {
      if (item.item.bidiLevel > maxLevel) {
        maxLevel = item.item.bidiLevel;
      }
      if (item.item.bidiLevel < minLevel) {
        minLevel = item.item.bidiLevel;
      }
    }

    // If all items are at level 0 (LTR), no reordering needed
    if (maxLevel == 0) {
      return items;
    }

    final reordered = List<InlineItemResult>.from(items);

    // The key insight: we need to reverse sequences at each odd level,
    // processing from the highest level down to level 1
    for (int level = maxLevel; level >= minLevel; level--) {
      // For odd levels, find and reverse contiguous sequences at that level
      if (level % 2 == 1) {
        // Find all runs at this exact level
        List<_RunInfo> runs = [];
        int? runStart;

        for (int i = 0; i <= reordered.length; i++) {
          bool isAtLevel = i < reordered.length && reordered[i].item.bidiLevel == level;

          if (isAtLevel) {
            runStart ??= i;
          } else if (runStart != null) {
            runs.add(_RunInfo(runStart, i - 1));
            runStart = null;
          }
        }

        // Reverse each run
        for (final run in runs) {
          _reverseItemRange(reordered, run.start, run.end);
        }
      }
    }

    // For RTL base direction, the entire line needs to be processed as RTL
    if (context.container.renderStyle.direction == TextDirection.rtl) {
      // Group items by their level to maintain proper nesting
      // The trick is that we need to reverse the top-level structure
      _applyRTLBaseDirection(reordered);
    }


    return reordered;
  }

  void _applyRTLBaseDirection(List<InlineItemResult> items) {
    // For RTL base direction, we need to reverse the visual order of
    // top-level runs while preserving the internal structure of embedded runs

    // Find continuous segments at each level
    List<_Segment> segments = [];
    int currentStart = 0;
    int currentLevel = items.isEmpty ? 0 : items[0].item.bidiLevel;

    for (int i = 1; i <= items.length; i++) {
      int level = i < items.length ? items[i].item.bidiLevel : -1;

      if (level != currentLevel) {
        segments.add(_Segment(currentStart, i - 1, currentLevel));
        currentStart = i;
        currentLevel = level;
      }
    }


    // Reverse the segments array to get RTL visual order
    segments = segments.reversed.toList();

    // Rebuild the items array with segments in reversed order
    final newItems = <InlineItemResult>[];
    for (final segment in segments) {
      for (int i = segment.start; i <= segment.end; i++) {
        newItems.add(items[i]);
      }
    }

    // Copy back to original array
    for (int i = 0; i < newItems.length; i++) {
      items[i] = newItems[i];
    }
  }

  /// Helper to reverse a range of items
  void _reverseItemRange(List<InlineItemResult> items, int start, int end) {
    while (start < end) {
      final temp = items[start];
      items[start] = items[end];
      items[end] = temp;
      start++;
      end--;
    }
  }

  /// Calculate text alignment offset.
  double _calculateTextAlignOffset(double lineWidth, double availableWidth) {
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

    return offset;
  }
}
