/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:math' as math;
import 'dart:ui' as ui
    show Paragraph, ParagraphBuilder, ParagraphConstraints, ParagraphStyle, TextStyle, TextHeightBehavior, LineMetrics, TextLeadingDistribution, Rect;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

// Position and size of each run (line box) in flow layout.
// https://www.w3.org/TR/css-inline-3/#line-boxes
class RunMetrics {
  RunMetrics(this.mainAxisExtent, this.crossAxisExtent, this.runChildren, {this.baseline});

  // Main size extent of the run.
  final double mainAxisExtent;

  // Cross size extent of the run.
  final double crossAxisExtent;

  // All the children RenderBox of layout in the run.
  final List<RenderBox> runChildren;

  // Baseline of the run (distance from top of the run to the baseline).
  // Null if no baseline is available.
  final double? baseline;
}

/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlowLayout] to position
/// its children._
///
/// Layout for a [RenderFlowLayout] proceeds in 5 steps:
///
/// 1. Layout positioned (eg. absolute/fixed) child first cause the size of position placeholder renderObject which is
///    layouted later depends on the size of its original RenderBoxModel.
/// 2. Layout children (not including positioned child) with no constraints and compute information of line boxes.
/// 3. Set container size depends on children size and container size styles (eg. width/height).
/// 4. Set children offset based on flow container size and flow alignment styles (eg. text-align).
/// 5. Set positioned children offset based on flow container size and its offset styles (eg. top/right/bottom/right).
///
class RenderFlowLayout extends RenderLayoutBox {
  RenderFlowLayout({
    List<RenderBox>? children,
    required super.renderStyle,
  }) {
    addAll(children);
  }

  ui.Rect? _ifcSemanticBounds;

  @override
  ui.Rect get semanticBounds {
    final ui.Rect? rect = _ifcSemanticBounds;
    if (rect != null) {
      return rect;
    }
    return super.semanticBounds;
  }

  void _updateIFCSemanticBounds(ui.Rect? rect) {
    _ifcSemanticBounds = rect;
  }

  // Public helper: for IFC containers, compute the inline horizontal advance
  // (in this container's content box space) before a descendant render object
  // "marker" (typically a RenderPositionPlaceholder). Uses the paragraph-based
  // IFC to resolve the right edge of the inline element that owns the marker.
  // Returns 0 when IFC is not established or measurement is unavailable.
  double inlineAdvanceBefore(RenderObject marker) {
    if (!establishIFC || _inlineFormattingContext == null) return 0.0;

    // Ask IFC to compute advance for this descendant based on its owning inline element
    try {
      final double adv = _inlineFormattingContext!.inlineAdvanceForDescendant(marker);
      return adv;
    } catch (_) {
      // Fall back gracefully if anything goes wrong.
      return 0.0;
    }
  }

  // Line boxes of flow layout.
  // https://www.w3.org/TR/css-inline-3/#line-boxes
  // Fow example <i>Hello<br>world.</i> will have two <i> line boxes
  final List<RunMetrics> _lineMetrics = <RunMetrics>[];

  @override
  void dispose() {
    super.dispose();

    _inlineFormattingContext?.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    _lineMetrics.clear();
  }

  // Recursively ensure every render object inside IFC gets laid out.
  // Some nodes (e.g. SizedBox.shrink -> RenderConstrainedBox for <script>)
  // don't participate in IFC measurement/painting but must still be laid out
  // to avoid downstream issues (semantics/devtools traversals accessing size).
  void _ensureChildrenLaidOutRecursively(RenderBox parent) {
    void layoutIfNeeded(RenderBox node) {
      if (node.hasSize) return;

      // Use specific constraints for known special cases to avoid side-effects
      if (node is RenderTextBox) {
        // Text nodes are measured/painted by IFC; force 0-size layout
        node.layout(BoxConstraints.tight(Size.zero));
        return;
      }
      if (node is RenderEventListener) {
        // Event listener needs actual constraints for hit testing/semantics
        node.layout(contentConstraints ?? constraints);
        return;
      }

      // Default: lay out with tight zero to avoid affecting IFC results,
      // while clearing NEEDS-LAYOUT on non-participating nodes like ConstrainedBox.
      try {
        node.layout(BoxConstraints.tight(Size.zero));
      } catch (_) {
        // Fall back to container/content constraints if the node rejects tight zero.
        node.layout(contentConstraints ?? constraints);
      }
    }

    if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
      RenderBox? child = (parent as dynamic).firstChild;
      while (child != null) {
        layoutIfNeeded(child);
        _ensureChildrenLaidOutRecursively(child);
        child = (parent as dynamic).childAfter(child);
      }
    } else if (parent is RenderObjectWithChildMixin<RenderBox>) {
      final RenderBox? child = (parent as dynamic).child;
      if (child != null) {
        layoutIfNeeded(child);
        _ensureChildrenLaidOutRecursively(child);
      }
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  double _getMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
    }

    Size childSize = RenderFlowLayout.getChildSize(child) ?? Size.zero;

    return childSize.width + marginHorizontal;
  }

  double _getCrossAxisExtent(RenderBox child) {
    double marginVertical = 0;

    if (child is RenderBoxModel) {
      marginVertical = getChildMarginTop(child) + getChildMarginBottom(child);
    } else if (child is RenderPositionPlaceholder) {
      // Include the mapped element's vertical margins for sticky placeholders so
      // run cross-size accounts for the collapsed margins between runs.
      final RenderBoxModel? mapped = child.positioned;
      if (mapped != null && mapped.renderStyle.position == CSSPositionType.sticky) {
        marginVertical = getChildMarginTop(mapped) + getChildMarginBottom(mapped);
      }
    }

    Size childSize = RenderFlowLayout.getChildSize(child) ?? Size.zero;

    return childSize.height + marginVertical;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    return Offset(mainAxisOffset, crossAxisOffset);
  }

  double _getChildCrossAxisOffset(double runCrossAxisExtent, double childCrossAxisExtent) {
    return runCrossAxisExtent - childCrossAxisExtent;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    // If using inline formatting context, delegate painting to it first.
    if (establishIFC && _inlineFormattingContext != null) {
      // Calculate content offset (adjust for padding and border)
      final contentOffset = Offset(
        offset.dx + renderStyle.paddingLeft.computedValue + renderStyle.effectiveBorderLeftWidth.computedValue,
        offset.dy + renderStyle.paddingTop.computedValue + renderStyle.effectiveBorderTopWidth.computedValue,
      );

      // Paint the inline formatting context content
      _inlineFormattingContext!.paint(context, contentOffset);

      // Paint outside list marker if needed after IFC content
      _paintListMarkerIfNeeded(context, offset, contentOffset);

      // Paint positioned direct children in proper stacking order.
      for (final RenderBox child in paintingOrder) {
        if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
          final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
          if (child.hasSize) context.paintChild(child, pd.offset + offset);
        }
      }
      return;
    }

    // Regular flow layout painting: skip RenderTextBox unless it paints itself (non-IFC)
    Offset accumulateOffsetFromDescendant(RenderObject descendant, RenderObject ancestor) {
      Offset sum = Offset.zero;
      RenderObject? cur = descendant;
      while (cur != null && cur != ancestor) {
        final Object? pd = (cur is RenderBox) ? (cur.parentData) : null;
        if (pd is ContainerBoxParentData) {
          sum += (pd).offset;
        } else if (pd is RenderLayoutParentData) {
          sum += (pd).offset;
        }
        cur = cur.parent;
      }
      return sum;
    }

    for (int i = 0; i < paintingOrder.length; i++) {
      RenderBox child = paintingOrder[i];
      bool shouldPaint = !isPositionPlaceholder(child);

      // Skip text boxes that are handled by IFC, but paint text boxes that paint themselves
      if (child is RenderTextBox) {
        shouldPaint = shouldPaint && (child).paintsSelf;
      }

      if (!shouldPaint) continue;

      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (!child.hasSize) continue;

      bool restoreFlag = false;
      bool previous = false;
      // Only suppress descendants' positive stacking when painting the document root
      // (where we promote descendant positives to this level).
      final bool promoteHere = (renderStyle).isDocumentRootBox();
      if (promoteHere && child is RenderBoxModel) {
        final CSSRenderStyle rs = child.renderStyle;
        final int? zi = rs.zIndex;
        final bool isPositive = zi != null && zi > 0;
        if (!isPositive) {
          previous = rs.suppressPositiveStackingFromDescendants;
          rs.suppressPositiveStackingFromDescendants = true;
          if (child is RenderLayoutBox) {
            child.markChildrenNeedsSort();
          } else if (child is RenderWidget) {
            child.markChildrenNeedsSort();
          }
          restoreFlag = true;
        }
      }

      final bool direct = identical(child.parent, this);
      final Offset localOffset = direct ? childParentData.offset : accumulateOffsetFromDescendant(child, this);
      context.paintChild(child, localOffset + offset);

      if (restoreFlag && child is RenderBoxModel) {
        (child.renderStyle).suppressPositiveStackingFromDescendants = previous;
        if (child is RenderLayoutBox) {
          child.markChildrenNeedsSort();
        } else if (child is RenderWidget) {
          child.markChildrenNeedsSort();
        }
      }
    }

    // Non-IFC flow: still attempt to paint outside marker if applicable
    _paintListMarkerIfNeeded(context, offset, offset + Offset(
      renderStyle.paddingLeft.computedValue + renderStyle.effectiveBorderLeftWidth.computedValue,
      renderStyle.paddingTop.computedValue + renderStyle.effectiveBorderTopWidth.computedValue,
    ));
  }

  // Determine effective list-style-type for an LI element
  String? _effectiveListStyleTypeFor(Element el) {
    String getProp(CSSStyleDeclaration s, String camel, String kebab) {
      final v1 = s.getPropertyValue(camel);
      if (v1.isNotEmpty) return v1;
      return s.getPropertyValue(kebab);
    }
    final t = getProp(el.style, 'listStyleType', 'list-style-type');
    if (t.isNotEmpty) return t;
    final p = el.parentElement;
    if (p != null) {
      final pt = getProp(p.style, 'listStyleType', 'list-style-type');
      if (pt.isNotEmpty) return pt;
      if (p is OListElement) return 'decimal';
      if (p is UListElement) return 'disc';
    }
    return null;
  }

  String _effectiveListStylePositionFor(Element el) {
    String getProp(CSSStyleDeclaration s, String camel, String kebab) {
      final v1 = s.getPropertyValue(camel);
      if (v1.isNotEmpty) return v1;
      return s.getPropertyValue(kebab);
    }
    final t = getProp(el.style, 'listStylePosition', 'list-style-position');
    if (t.isNotEmpty) return t;
    final p = el.parentElement;
    if (p != null) {
      final pt = getProp(p.style, 'listStylePosition', 'list-style-position');
      if (pt.isNotEmpty) return pt;
    }
    return 'outside';
  }

  int _listIndexFor(Element el) {
    final p = el.parentElement;
    if (p == null) return 1;
    int idx = 0;
    for (final child in p.children) {
      if (child is LIElement) idx++;
      if (identical(child, el)) break;
    }
    return idx == 0 ? 1 : idx;
  }

  String _alphaFromIndex(int n, {bool upper = false}) {
    int num = n;
    final sb = StringBuffer();
    while (num > 0) {
      num--;
      final rem = num % 26;
      sb.writeCharCode((upper ? 65 : 97) + rem);
      num ~/= 26;
    }
    return sb
        .toString()
        .split('')
        .reversed
        .join();
  }

  String _romanFromIndex(int n, {bool upper = false}) {
    if (n <= 0) return upper ? 'N' : 'n';
    final map = const [
      [1000, 'M'],
      [900, 'CM'],
      [500, 'D'],
      [400, 'CD'],
      [100, 'C'],
      [90, 'XC'],
      [50, 'L'],
      [40, 'XL'],
      [10, 'X'],
      [9, 'IX'],
      [5, 'V'],
      [4, 'IV'],
      [1, 'I'],
    ];
    int num = n;
    final sb = StringBuffer();
    for (final pair in map) {
      final val = pair[0] as int;
      final sym = pair[1] as String;
      while (num >= val) {
        sb.write(sym);
        num -= val;
      }
    }
    final s = sb.toString();
    return upper ? s : s.toLowerCase();
  }

  ui.TextStyle _uiTextStyleFromCss(CSSRenderStyle rs) {
    final families = rs.fontFamily;
    if (families != null && families.isNotEmpty) {
      CSSFontFace.ensureFontLoaded(families[0], rs.fontWeight, rs);
    }
    final bool clipText = rs.backgroundClip == CSSBackgroundBoundary.text;
    final double fs = rs.fontSize.computedValue;
    final double nonNegativeFontSize = fs.isFinite && fs >= 0 ? fs : 0.0;
    return ui.TextStyle(
      color: clipText ? null : rs.color.value,
      decoration: rs.textDecorationLine,
      decorationColor: rs.textDecorationColor?.value,
      decorationStyle: rs.textDecorationStyle,
      fontWeight: rs.fontWeight,
      fontStyle: rs.fontStyle,
      textBaseline: CSSText.getTextBaseLine(),
      fontFamily: (families != null && families.isNotEmpty) ? families.first : null,
      fontFamilyFallback: families,
      fontSize: nonNegativeFontSize,
      letterSpacing: rs.letterSpacing?.computedValue,
      wordSpacing: rs.wordSpacing?.computedValue,
      // Do not apply CSS line-height here; markers align via baseline offsets.
      locale: CSSText.getLocale(),
      background: CSSText.getBackground(),
      foreground: CSSText.getForeground(),
      shadows: rs.textShadow,
    );
  }

  void _paintListMarkerIfNeeded(PaintingContext context, Offset borderOffset, Offset contentOffset) {
    // Only for <li> elements
    final Element el = renderStyle.target;
    if (el is! LIElement) return;

    // Respect list-style-position; only handle outside here.
    final pos = _effectiveListStylePositionFor(el);
    if (pos != 'outside') return;

    final type = _effectiveListStyleTypeFor(el);
    if (type == null || type == 'none') return;

    // Build paragraphs for marker components with stable spacing (no kerning between '.' and digits)
    final ts = _uiTextStyleFromCss(renderStyle);
    ui.Paragraph buildPara(String text) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textDirection: TextDirection.ltr,
        textHeightBehavior: const ui.TextHeightBehavior(
          applyHeightToFirstAscent: true,
          applyHeightToLastDescent: true,
          leadingDistribution: ui.TextLeadingDistribution.even,
        ),
        maxLines: 1,
      ));
      pb.pushStyle(ts);
      pb.addText(text);
      final para = pb.build();
      para.layout(const ui.ParagraphConstraints(width: 1000000.0));
      return para;
    }

    // Fixed outside gap between marker and border box
    final double spaceW = buildPara(' ').maxIntrinsicWidth;

    // Components
    ui.Paragraph? dotPara;
    ui.Paragraph? numPara;
    double markerBaseline;
    if (type == 'disc') {
      dotPara = buildPara('•');
      markerBaseline = dotPara.alphabeticBaseline;
    } else {
      final idx = _listIndexFor(el);
      String numText;
      switch (type) {
        case 'decimal':
          numText = idx.toString();
          break;
        case 'lower-alpha':
          numText = _alphaFromIndex(idx, upper: false);
          break;
        case 'upper-alpha':
          numText = _alphaFromIndex(idx, upper: true);
          break;
        case 'lower-roman':
          numText = _romanFromIndex(idx, upper: false);
          break;
        case 'upper-roman':
          numText = _romanFromIndex(idx, upper: true);
          break;
        default:
          numText = idx.toString();
          break;
      }
      dotPara = buildPara('.');
      numPara = buildPara(numText);
      markerBaseline = math.max(dotPara.alphabeticBaseline, numPara.alphabeticBaseline);
    }

    // Compute baseline Y: align to first line of content if available
    double baselineY;
    if (_inlineFormattingContext != null && _inlineFormattingContext!.paragraphLineMetrics.isNotEmpty) {
      baselineY = contentOffset.dy + _inlineFormattingContext!.paragraphLineMetrics.first.baseline;
    } else {
      // Approximate using font metrics
      baselineY = contentOffset.dy + markerBaseline;
    }

    final bool isRTL = renderStyle.direction == TextDirection.rtl;
    final double baseX = isRTL
        ? borderOffset.dx + size.width + spaceW
        : borderOffset.dx - spaceW; // will subtract widths per component
    final double drawY = baselineY - markerBaseline;

    if (type == 'disc') {
      final double dotW = dotPara.maxIntrinsicWidth;
      final double x = isRTL ? baseX : baseX - dotW;
      context.canvas.drawParagraph(dotPara, Offset(x, drawY));
    } else {
      final double dotW = dotPara.maxIntrinsicWidth;
      final double numW = numPara!.maxIntrinsicWidth;
      if (isRTL) {
        final double xDot = baseX;
        final double xNum = xDot + dotW;
        context.canvas.drawParagraph(dotPara, Offset(xDot, drawY));
        context.canvas.drawParagraph(numPara, Offset(xNum, drawY));
      } else {
        final double xNum = baseX - numW - dotW;
        final double xDot = xNum + numW;
        context.canvas.drawParagraph(numPara, Offset(xNum, drawY));
        context.canvas.drawParagraph(dotPara, Offset(xDot, drawY));
      }
    }
  }

  // Removed nested DFS positioned painting. With positioned elements
  // reparented to their containing block, painting simply iterates
  // direct children as needed.

  @override
  void performLayout() {
    try {
      _doPerformLayout();

      if (needsRelayout) {
        _doPerformLayout();
        needsRelayout = false;
      }
    } catch (e, stack) {
      if (!kReleaseMode) {
        layoutExceptions = '$e\n$stack';
        reportException('performLayout', e, stack);
      }
      rethrow;
    }
  }

  bool _establishIFC = false;

  bool get establishIFC => _establishIFC;

  InlineFormattingContext? _inlineFormattingContext;

  /// Get the inline formatting context if established
  InlineFormattingContext? get inlineFormattingContext => _inlineFormattingContext;

  void _doPerformLayout() {
    beforeLayout();


    _establishIFC = renderStyle.shouldEstablishInlineFormattingContext();
    if (_establishIFC) {
      _inlineFormattingContext = InlineFormattingContext(container: this);
    }

    List<RenderBoxModel> positionedChildren = [];
    List<RenderBoxModel> stickyChildren = [];
    List<RenderBoxModel> absFixedChildren = [];
    List<RenderBox> nonPositionedChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && (child.renderStyle.isSelfPositioned() || child.renderStyle.isSelfStickyPosition())) {
        positionedChildren.add(child);
        if (child.renderStyle.isSelfStickyPosition()) {
          stickyChildren.add(child);
        } else {
          absFixedChildren.add(child);
        }
      } else {
        nonPositionedChildren.add(child);
      }
      child = childParentData.nextSibling;
    }

    // Pre-layout sticky positioned children so their placeholders can reserve
    // correct flow space during the subsequent non-positioned layout pass.
    // This keeps sticky sizing in sync with normal-flow sizing while still
    // treating them as positioned for offset/painting.
    for (RenderBoxModel sticky in stickyChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, sticky);
    }

    // Layout non positioned element (include element in flow and
    // placeholder of positioned element).
    _layoutChildren(nonPositionedChildren);

    // init overflowLayout size
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // calculate all flexItem child overflow size
    addOverflowLayoutFromChildren(nonPositionedChildren);

    // Now that the container size and placeholder static positions are known,
    // lay out out-of-flow positioned children. This ensures percentage sizes
    // (e.g., width/height: 100%) resolve against the containing block's final
    // padding box dimensions, matching browser behavior for inline-block
    // shrink-to-fit containers with positioned overlays.
    // Lay out absolute/fixed positioned children after container size is known,
    // preserving existing behavior for percentage resolution.
    for (RenderBoxModel child in absFixedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    // Apply offset for positioned elements that are direct children (containing block = this).
    // Do not let out-of-flow positioned children expand scrollable area when this
    // container is a scroll container; per CSS, abspos/fixed do not contribute to
    // scroll range of overflow boxes.
    for (RenderBoxModel child in positionedChildren) {
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
      // Apply sticky paint-time offset (no-op for non-sticky).
      CSSPositionedLayout.applyStickyChildOffset(this, child);
      // Do not expand scroll range for sticky; its placeholder accounts for flow size.
      if (child.renderStyle.position != CSSPositionType.sticky) {
        // Let positioned children contribute to scrollable size; filtering
        // for intersection with the scrollport is handled inside extendMaxScrollableSize.
        extendMaxScrollableSize(child);
        addOverflowLayoutFromChild(child);
      }
    }

    didLayout();
  }

  void _setContainerSizeFromIFC(Size ifcSize) {
    InlineFormattingContext inlineFormattingContext = _inlineFormattingContext!;
    double usedContentWidth = ifcSize.width;
    // CSS shrink-to-fit width for inline-block with auto width:
    // used = min( max(min-content, available), max-content )
    if (renderStyle.effectiveDisplay == CSSDisplay.inlineBlock && renderStyle.width.isAuto) {
      final double avail = (contentConstraints != null && contentConstraints!.hasBoundedWidth)
          ? contentConstraints!.maxWidth
          : (constraints.hasBoundedWidth ? constraints.maxWidth : double.nan);
      if (avail.isFinite) {
        final double minContent = inlineFormattingContext.paragraphMinIntrinsicWidth;
        final double maxContent = inlineFormattingContext.paragraphMaxIntrinsicWidth;
        // Guard against degenerate values
        final double clampedMin = minContent.isFinite && minContent > 0 ? minContent : 0;
        final double clampedMax = maxContent.isFinite && maxContent > 0 ? maxContent : clampedMin;
        final double step1 = math.max(clampedMin, avail);
        final double shrinkToFit = math.min(step1, clampedMax);
        usedContentWidth = shrinkToFit;
        // If the paragraph was initially shaped with a different width, lock the
        // container content logical width first so percentage children can resolve,
        // then rebuild IFC (includes atomic placeholder re-measure).
        // Reflow paragraph to the final used width when the initially shaped width
        // differs. This can happen even when ifcSize.width already equals usedContentWidth
        // (e.g., shrink-to-fit chose the intrinsic width) but the paragraph was
        // originally shaped with a larger bounded width, leaving a non-zero line-left
        // (textAlign:center/right). Rebuilding at the used width resets line-left to 0.
        final double shapedWidth = inlineFormattingContext.paragraph?.width ?? ifcSize.width;
        if ((ifcSize.width - usedContentWidth).abs() > 0.5 || (shapedWidth - usedContentWidth).abs() > 0.5) {
          // Make this container a definite percentage reference for descendants.
          renderStyle.contentBoxLogicalWidth = usedContentWidth;
          inlineFormattingContext.relayoutParagraphToWidth(usedContentWidth);
        }
      }
    }

    Size layoutContentSize = getContentSize(
      contentWidth: usedContentWidth,
      contentHeight: ifcSize.height,
    );

    size = getBoxSize(layoutContentSize);

    // For IFC, min-content width should reflect the paragraph's
    // min intrinsic width (approximate CSS min-content), not the
    // max-content width (longestLine). Using longestLine here would
    // clamp flex items' auto min-size too large and prevent shrinking.
    final double minIntrW = inlineFormattingContext.paragraphMinIntrinsicWidth;
    minContentWidth = minIntrW;
    minContentHeight = ifcSize.height;

  }

  // There are 3 steps for layout children.
  // 1. Layout children to generate line boxes metrics.
  // 2. Set flex container size according to children size and its own size styles.
  // 3. Align children according to alignment properties.
  void _layoutChildren(List<RenderBox> children) {
    // If no child exists, stop layout.
    if (children.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    if (establishIFC) {
      assert(_inlineFormattingContext != null);

      // Use content constraints for IFC, but if this element has been given a
      // tight width by its parent (e.g., as a flex item after resolving flex),
      // shape the paragraph to that tight content width instead of any stale
      // pre-flex content constraint (such as an author-specified width).
      BoxConstraints ifcConstraints = contentConstraints!;
      // Do not reserve space for classic scrollbars. WebF treats scrollbars
      // as overlay, so available inline-size for line breaking remains the
      // content box width. This keeps layout deterministic across platforms.
      if (constraints.hasTightWidth) {
        final double tightContentMaxWidth = math.max(
          0.0,
          constraints.maxWidth -
              renderStyle.effectiveBorderLeftWidth.computedValue -
              renderStyle.effectiveBorderRightWidth.computedValue -
              renderStyle.paddingLeft.computedValue -
              renderStyle.paddingRight.computedValue,
        );
        if (tightContentMaxWidth.isFinite && tightContentMaxWidth >= 0) {
          ifcConstraints = BoxConstraints(
            minWidth: 0,
            maxWidth: tightContentMaxWidth,
            minHeight: ifcConstraints.minHeight,
            maxHeight: ifcConstraints.maxHeight,
          );
        }
      }

      Size layoutSize = _inlineFormattingContext!.layout(ifcConstraints);

      // Ensure all render objects inside IFC are laid out to avoid
      // devtools/semantics traversals encountering NEEDS-LAYOUT nodes.
      _ensureChildrenLaidOutRecursively(this);

      _setContainerSizeFromIFC(layoutSize);

      // Set the baseline value for this box
      calculateBaseline();

      // Set the size of scrollable overflow area for inline formatting context.
      _setMaxScrollableSizeFromIFC();
      _positionInlineAnchorsFromIFC(children);
    } else {
      // Layout children to compute metrics of lines.
      _doRegularFlowLayout(children);

      // Set container size.
      _setContainerSize();

      // For inline-block containers with auto width, after computing the
      // shrink-to-fit content width, stretch block-level auto-width children
      // to the container's content width so they visually fill the line.
      // This matches browsers where a block child inside an auto-width
      // inline-block expands to the container’s shrink-to-fit width.
      final bool stretched = _reflowAutoWidthBlockChildrenToContentWidth(children);

      // If any child was stretched, refresh run metrics from current child sizes
      // and recompute container size so offsets and box sizes reflect updates
      if (stretched) {
        _refreshRunMetricsFromChildSizes();
        _setContainerSize();
      }

      // Set children offset based on alignment properties.
      _setChildrenOffset();

      // Set the size of scrollable overflow area for flow layout.
      _setMaxScrollableSize();

      // Set the baseline value for this box
      calculateBaseline();
    }
  }

  // Refresh stored run metrics to reflect current child sizes without re-laying out
  // children. This preserves any manual reflow (e.g., tightened widths) applied
  // to children in the current pass.
  void _refreshRunMetricsFromChildSizes() {
    for (int i = 0; i < _lineMetrics.length; i++) {
      final run = _lineMetrics[i];
      double newMain = 0;
      for (final RenderBox child in run.runChildren) {
        newMain += RenderFlowLayout.getPureMainAxisExtent(child);
      }
      _lineMetrics[i] = RunMetrics(newMain, run.crossAxisExtent, run.runChildren, baseline: run.baseline);
    }
  }

  void _positionInlineAnchorsFromIFC(List<RenderBox> children) {
    if (!_establishIFC || _inlineFormattingContext == null) return;
    final double contentLeft = renderStyle.paddingLeft.computedValue +
        renderStyle.effectiveBorderLeftWidth.computedValue;
    final double contentTop = renderStyle.paddingTop.computedValue +
        renderStyle.effectiveBorderTopWidth.computedValue;

    for (final RenderBox child in children) {
      RenderBoxModel? inlineBox;
      RenderBox assignTarget = child;
      if (child is RenderEventListener) {
        final RenderBox? inner = child.child;
        if (inner is RenderBoxModel) {
          inlineBox = inner;
        }
      } else if (child is RenderBoxModel) {
        inlineBox = child;
      }

      if (inlineBox == null) continue;
      if (inlineBox.renderStyle.effectiveDisplay != CSSDisplay.inline) continue;
      final String tag = inlineBox.renderStyle.target.tagName.toUpperCase();
      if (tag != 'A') continue;

      final ui.Rect? rect = _inlineFormattingContext!.inlineElementBoundingRect(inlineBox);
      if (rect == null) continue;

      final RenderLayoutParentData parentData = assignTarget.parentData as RenderLayoutParentData;
      parentData.offset = Offset(contentLeft + rect.left, contentTop + rect.top);
      if (inlineBox is RenderFlowLayout) {
        inlineBox._updateIFCSemanticBounds(ui.Rect.fromLTWH(0, 0, rect.width, rect.height));
      }
    }
  }

  bool _reflowAutoWidthBlockChildrenToContentWidth(List<RenderBox> children) {
    // Only applies to inline-block containers with auto width.
    if (renderStyle.effectiveDisplay != CSSDisplay.inlineBlock || !renderStyle.width.isAuto) {
      return false;
    }
    final double targetWidth = contentSize.width;
    if (!targetWidth.isFinite || targetWidth <= 0) return false;

    bool any = false;

    for (final child in children) {
      RenderBoxModel? childBoxModel;
      if (child is RenderBoxModel) {
        childBoxModel = child;
      } else if (child is RenderEventListener) {
        final RenderBox? wrapped = child.child;
        if (wrapped is RenderBoxModel) childBoxModel = wrapped;
      }
      if (childBoxModel == null) continue;

      final CSSRenderStyle crs = childBoxModel.renderStyle;
      // Stretch only block-level auto-width children; do not touch inline-level (e.g., inline-block),
      // replaced, or flex containers (flex container inside inline-block contributes its own
      // min/max content widths to shrink-to-fit and must not be force-stretched here).
      final CSSDisplay disp = crs.effectiveDisplay;
      final bool isBlockLevel = disp == CSSDisplay.block || disp == CSSDisplay.flex;
      if (!isBlockLevel || !crs.width.isAuto) continue;
      // Do not stretch replaced elements like <img>. Their used width with
      // width:auto should be based on intrinsic dimensions (subject to min/max),
      // not the container's shrink-to-fit width. Stretching here caused images
      // to incorrectly expand to the inline-block's available line width.
      if (crs.isSelfRenderReplaced()) {
        continue;
      }
      if (disp == CSSDisplay.inlineFlex) {
        // Skip inline-level flex containers; only stretch block-level children.
        continue;
      }

      // Relayout the child wrapper with the container's content width tightly,
      // so an empty block (no content) still expands to the intended width.
      // Preserve the child's cross-axis minimum (e.g., CSS min-height) or its
      // previously measured height so that vertical alignment inside flex/grid
      // (e.g., align-items:center) continues to take effect after this pass.
      double preservedMinH = 0.0;
      final CSSRenderStyle crs2 = childBoxModel.renderStyle;
      if (crs2.minHeight.isNotAuto) preservedMinH = crs2.minHeight.computedValue;
          final BoxConstraints stretch = BoxConstraints(
        minWidth: targetWidth,
        maxWidth: targetWidth,
        minHeight: preservedMinH,
        maxHeight: double.infinity,
      );
      // Layout the visible wrapper so offsets/painting use the updated size.
      child.layout(stretch, parentUsesSize: true);
      any = true;
    }
    return any;
  }

  static RenderFlowLayout? getRenderFlowLayoutNext(RenderObject renderObject) {
    if (renderObject is RenderFlowLayout) {
      return renderObject;
    } else if (renderObject is RenderBoxModel && renderObject.renderStyle.isSelfRenderFlowLayout()) {
      return renderObject.renderStyle.target.attachedRenderer! as RenderFlowLayout;
    }
    return null;
  }

  // Layout children in normal flow order to calculate metrics of lines according to its constraints
  // and alignment properties.
  void _doRegularFlowLayout(List<RenderBox> children) {
    _lineMetrics.clear();
    children.forEachIndexed((index, child) {
      BoxConstraints childConstraints;
      if (child is RenderBoxModel) {
        childConstraints = child.getConstraints();
      } else if (child is RenderTextBox) {
        // In non-IFC (block) layout, text should measure itself within the
        // available content box width so that CSS text-overflow can work.
        // Prefer the finite bound between contentConstraints and our own
        // constraints; fall back to the latter when contentConstraints are
        // unbounded (e.g., during flex intrinsic measuring passes).
        if (!establishIFC) {
          final BoxConstraints cc = contentConstraints ?? constraints;
          final double maxW = cc.hasBoundedWidth ? cc.maxWidth : constraints.maxWidth;
          final double maxH = cc.hasBoundedHeight ? cc.maxHeight : constraints.maxHeight;
          childConstraints = BoxConstraints(
            minWidth: 0,
            maxWidth: maxW.isFinite ? maxW : double.infinity,
            minHeight: 0,
            maxHeight: maxH.isFinite ? maxH : double.infinity,
          );
        } else {
          // IFC path: the container measures/paints the text; keep the text node 0-sized.
          childConstraints = BoxConstraints.tight(Size.zero);
        }
      } else if (child is RenderPositionPlaceholder) {
        childConstraints = BoxConstraints();
      } else if (child is RenderConstrainedBox) {
        childConstraints = child.additionalConstraints;
      } else {
        // RenderObject of custom element need to inherit constraints from its parents
        // which adhere to flutter's rule.
        childConstraints = constraints;
      }

      bool parentUseSize = !(child is RenderBoxModel && child.isSizeTight || child is RenderPositionPlaceholder);
      child.layout(childConstraints, parentUsesSize: parentUseSize);

      double childMainAxisExtent = RenderFlowLayout.getPureMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (isPositionPlaceholder(child)) {
        RenderPositionPlaceholder positionHolder = child as RenderPositionPlaceholder;
        RenderBoxModel? childRenderBoxModel = positionHolder.positioned;
        if (childRenderBoxModel != null) {
          if (childRenderBoxModel.renderStyle.isSelfPositioned()) {
            childMainAxisExtent = childCrossAxisExtent = 0;
          }
        }
      }

      // Capture CSS baseline from child's own layout cache (avoid layout-time baseline queries)
      double? childBaseline;
      if (child is RenderBoxModel) {
        childBaseline = child.computeCssFirstBaseline();
      }

      _lineMetrics.add(RunMetrics(childMainAxisExtent, childCrossAxisExtent, [child], baseline: childBaseline));
    });
  }

  double _getRunsMaxMainSize(List<RunMetrics> runMetrics,) {
    // Find the max size of lines.
    RunMetrics maxMainSizeMetrics = runMetrics.reduce((RunMetrics curr, RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Compute the total cross-axis content size accounting for inter-run
  // vertical margin collapsing (prev sibling bottom vs current top).
  // Mirrors the positioning logic in _setChildrenOffset so that the
  // final container height matches the actually collapsed layout.
  double _getRunsCrossSizeWithCollapse(List<RunMetrics> runMetrics) {
    double crossSize = 0;

    double? carriedPrevCollapsedBottom;
    double? lastPrevCollapsedBottom;
    for (int i = 0; i < runMetrics.length; i++) {
      final RunMetrics run = runMetrics[i];

      // Track previous child's collapsed bottom within the run,
      // seeded from the previous run's carry.
      double? prevCollapsedBottom = carriedPrevCollapsedBottom;
      // Track the first child's own top value as it was counted in
      // run.crossAxisExtent (ownTopInExtent), and the effective top
      // contribution after collapsing with the previous run's bottom
      // (runFirstTopContribution). We subtract the former and add the
      // latter to align the cross-size with the actual positioned gaps.
      double runFirstOwnTopInExtent = 0;
      double runFirstTopContribution = 0;
      bool firstTopCaptured = false;

      // Iterate run children to update prevCollapsedBottom and capture first child margins.
      for (final RenderBox child in run.runChildren) {
        // Out-of-flow placeholders must not participate in sibling margin collapsing,
        // except for position: sticky which behaves like in-flow for layout (margins collapse).
        if (child is RenderPositionPlaceholder) {
          final CSSPositionType? pos = child.positioned?.renderStyle.position;
          final bool isStickyPH = pos == CSSPositionType.sticky;
          if (!isStickyPH) {
            continue;
          }
        }
        RenderBoxModel? childRenderBoxModel;
        if (child is RenderBoxModel) {
          childRenderBoxModel = child;
        } else if (child is RenderPositionPlaceholder) {
          childRenderBoxModel = child.positioned;
        }

        if (childRenderBoxModel != null) {
          // The top margin that was actually counted in run.crossAxisExtent for this child.
          final double ownTopInExtent = getChildMarginTop(childRenderBoxModel);
          // The element's own top ignoring parent collapse (collapsed with its first child only).
          final double selfTopIgnoringParent = childRenderBoxModel.renderStyle.collapsedMarginTopIgnoringParent;

          // Compute the effective additional spacing before this run relative to the
          // previous run's collapsed bottom using formatting-context adjacency.
          double topContribution;
          if (prevCollapsedBottom == null) {
            topContribution = ownTopInExtent;
          } else {
            if (selfTopIgnoringParent >= 0 && prevCollapsedBottom >= 0) {
              topContribution = math.max(selfTopIgnoringParent, prevCollapsedBottom) - prevCollapsedBottom;
            } else if (selfTopIgnoringParent <= 0 && prevCollapsedBottom <= 0) {
              topContribution = math.min(selfTopIgnoringParent, prevCollapsedBottom) - prevCollapsedBottom;
            } else {
              topContribution = selfTopIgnoringParent;
            }
          }

          if (!firstTopCaptured) {
            runFirstOwnTopInExtent = ownTopInExtent;
            runFirstTopContribution = topContribution;
            firstTopCaptured = true;
          }

          // Advance prevCollapsedBottom for following in-flow siblings in this run.
          prevCollapsedBottom = getChildMarginBottom(childRenderBoxModel);
        }
      }

      // Cross advance for this run equals the positioned height increment
      // used when placing the next run: runCrossAxisExtent minus the first
      // child's own collapsed top, plus the effective top contribution after
      // collapsing with the previous run's bottom.
      final double crossAdvance = run.crossAxisExtent - runFirstOwnTopInExtent + runFirstTopContribution;
      crossSize += crossAdvance;

      // Carry prev collapsed bottom to next run for inter-run collapsing.
      carriedPrevCollapsedBottom = prevCollapsedBottom;
      lastPrevCollapsedBottom = prevCollapsedBottom;
    }

    // If the container qualifies for bottom-margin collapsing with its last
    // in-flow child, do not count that final collapsed bottom into its content
    // height. This mirrors how the parent’s bottom margin collapses with the
    // last child per CSS 2.1, and prevents an extra gap at the bottom.
    if (lastPrevCollapsedBottom != null) {
      final rs = renderStyle;
      final bool isOverflowVisible = rs.effectiveOverflowY == CSSOverflowType.visible ||
          rs.effectiveOverflowY == CSSOverflowType.clip;
      final bool qualifies = rs.isLayoutBox() &&
          rs.height.isAuto &&
          rs.minHeight.isAuto &&
          rs.maxHeight.isNone &&
          rs.effectiveDisplay == CSSDisplay.block &&
          isOverflowVisible &&
          rs.paddingBottom.computedValue == 0 &&
          rs.effectiveBorderBottomWidth.computedValue == 0;
      // Do not collapse the container's bottom with its last child when the
      // container is a flex item. Flex items establish an independent
      // formatting context for their contents per CSS Flexbox; their children's
      // margins must not collapse with the flex item itself.
      if (qualifies && !rs.isParentRenderFlexLayout() && !rs.isSelfPositioned()) {
        crossSize -= lastPrevCollapsedBottom;
      }
    }

    return crossSize;
  }

  // Record the main size of all lines.
  void _recordRunsMainSize(RunMetrics runMetrics, List<double> runMainSize) {
    List<RenderBox> runChildren = runMetrics.runChildren;
    double runMainExtent = 0;
    void iterateRunChildren(RenderBox runChild) {
      double runChildMainSize = 0.0;
      // For automatic minimum size, use each child's min-content contribution
      // in border-box, plus horizontal margins, instead of the child's used size.
      if (runChild is RenderBoxModel) {
        final double childMarginLeft = runChild.renderStyle.marginLeft.computedValue;
        final double childMarginRight = runChild.renderStyle.marginRight.computedValue;
        final double childPaddingBorderH = runChild.renderStyle.padding.horizontal + runChild.renderStyle.border.horizontal;
        double childMinContent = runChild.minContentWidth + childPaddingBorderH;
        if (!childMinContent.isFinite || childMinContent <= 0) {
          // Fallback to current used width when min-content is unavailable.
          childMinContent = runChild.boxSize?.width ?? 0.0;
        }
        runChildMainSize = childMinContent + childMarginLeft + childMarginRight;
      }
      runMainExtent += runChildMainSize;
    }

    runChildren.forEach(iterateRunChildren);
    runMainSize.add(runMainExtent);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(List<RunMetrics> runMetrics,) {
    double autoMinSize = 0;

    // Main size of each run.
    List<double> runMainSize = [];

    // Calculate the max main size of all runs.
    for (RunMetrics runMetrics in runMetrics) {
      _recordRunsMainSize(runMetrics, runMainSize);
    }

    if (runMainSize.isNotEmpty) {
      autoMinSize = runMainSize.reduce((double curr, double next) {
        return curr > next ? curr : next;
      });
    }

    return autoMinSize;
  }


  // Set flex container size according to children size.
  void _setContainerSize({double adjustHeight = 0, double adjustWidth = 0}) {
    // Special handling: when this element is inline-level and participates in
    // the parent's inline formatting context, size it to the union of its visual
    // fragments as measured by the parent IFC rather than from its own flow runs.
    final bool isInlineSelf = renderStyle.effectiveDisplay == CSSDisplay.inline;
    final RenderBoxModel? p = renderStyle.getAttachedRenderParentRenderStyle()?.attachedRenderBoxModel;
    if (isInlineSelf && p is RenderFlowLayout && p.establishIFC && p.inlineFormattingContext != null) {
      final InlineFormattingContext ifc = p.inlineFormattingContext!;
        // Width: max per-line fragment width of this inline element.
      double w = ifc.inlineElementMaxLineWidth(this);
        // Height: sum of unique line heights that the element spans.
      double h = ifc.inlineElementTotalHeight(this);
      // Fallback to legacy metrics if IFC did not record a range for this element.
      if ((w <= 0 || !w.isFinite) || (h <= 0 || !h.isFinite)) {
        if (_lineMetrics.isEmpty) {
          _setContainerSizeWithNoChild();
          return;
        }
          w = _getRunsMaxMainSize(_lineMetrics);
          h = _getRunsCrossSizeWithCollapse(_lineMetrics);
      }

      Size layoutContentSize = getContentSize(
        contentWidth: w + adjustWidth,
        contentHeight: h + adjustHeight,
      );
      size = getBoxSize(layoutContentSize);

      // Use IFC-driven sizes for min-content as well to better reflect visuals when inline.
      minContentWidth = w;
      minContentHeight = h;
      return;
    }

    if (_lineMetrics.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    double runMaxMainSize = _getRunsMaxMainSize(_lineMetrics);
    // Compute cross size with proper margin collapsing across runs so
    // the box height aligns with the actual positioned children.
    double runCrossSize = _getRunsCrossSizeWithCollapse(_lineMetrics);

    Size layoutContentSize = getContentSize(
      contentWidth: runMaxMainSize + adjustWidth,
      contentHeight: runCrossSize + adjustHeight,
    );

    size = getBoxSize(layoutContentSize);

    minContentWidth = _getMainAxisAutoSize(_lineMetrics);
    // Keep min-content height consistent with collapsed cross size to
    // avoid overestimating intrinsic size and leaving extra space.
    minContentHeight = runCrossSize;
  }

  // Set size when layout has no child.
  void _setContainerSizeWithNoChild() {
    Size layoutContentSize = getContentSize(
      contentWidth: 0,
      contentHeight: 0,
    );

    setMaxScrollableSize(layoutContentSize);
    size = scrollableSize = getBoxSize(layoutContentSize);
  }

  // Set children offset based on alignment properties.
  void _setChildrenOffset() {
    if (_lineMetrics.isEmpty) return;


    double runLeadingSpace = 0;
    double runBetweenSpace = 0;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize = contentSize.width;

    // Carry collapsed bottom margin across runs so sibling margin collapsing works
    // even when a block-level child is placed in its own run.
    double? carriedPrevCollapsedBottom;

    // Set offset of children in each line.
    for (int i = 0; i < _lineMetrics.length; ++i) {
      final RunMetrics metrics = _lineMetrics[i];
      final double runCrossAxisExtent = metrics.crossAxisExtent;

      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      double childMainPosition = childLeadingSpace;

      // Track previous child's collapsed bottom margin; init with carried value from previous run
      double? prevCollapsedBottom = carriedPrevCollapsedBottom;
      // Track the first child's own collapsed top margin in this run so we can remove it
      // from the crossAxisOffset carry to avoid double-counting across runs.
      double runFirstOwnTop = 0;
      double runFirstTopContribution = 0;
      bool firstOwnTopCaptured = false;
      for (RenderBox child in metrics.runChildren) {
        final double childMainAxisExtent = _getMainAxisExtent(child);
        final double childCrossAxisExtent = _getCrossAxisExtent(child);

        // Calculate margin auto length according to CSS spec
        // https://www.w3.org/TR/CSS21/visudet.html#blockwidth
        // margin-left and margin-right auto takes up available space
        // between element and its containing block on block-level element
        // which is not positioned and computed to 0px in other cases.
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSDisplay? childEffectiveDisplay = childRenderStyle.effectiveDisplay;
          CSSLengthValue marginLeft = childRenderStyle.marginLeft;
          CSSLengthValue marginRight = childRenderStyle.marginRight;

          // 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right' +
          // 'border-right-width' + 'margin-right' = width of containing block
          if (childEffectiveDisplay == CSSDisplay.block || childEffectiveDisplay == CSSDisplay.flex) {
            final double remainingSpace = mainAxisContentSize - childMainAxisExtent;
            if (marginLeft.isAuto) {
              if (marginRight.isAuto) {
                childMainPosition = remainingSpace / 2;
              } else {
                childMainPosition = remainingSpace;
              }
            } else if (!marginRight.isAuto) {
              // Neither margin is auto; per CSS 2.1 §10.3.3 the extra space is added to
              // the end-side margin: right in LTR, left in RTL. Implement this by
              // shifting the child to the start in LTR (no-op) and to the left by the
              // remaining space in RTL.
              if (remainingSpace > 0 && renderStyle.direction == TextDirection.rtl) {
                childMainPosition += remainingSpace;
              }
            }
          }
        }

        // Always align to the top of run when positioning positioned element placeholder
        // @HACK(kraken): Judge positioned holder to impl top align.
        final double childCrossAxisOffset =
        isPositionPlaceholder(child) ? 0 : _getChildCrossAxisOffset(runCrossAxisExtent, childCrossAxisExtent);

        // Child line extent calculated according to vertical align.
        double childLineExtent = childCrossAxisOffset;

        double? childMarginLeft = 0;
        double? childMarginTop = 0;
        double? childMarginBottom = 0;

        RenderBoxModel? childRenderBoxModel;
        final bool isPlaceholder = child is RenderPositionPlaceholder;
        final bool isStickyPlaceholder = isPlaceholder &&
            ((child).positioned?.renderStyle.position == CSSPositionType.sticky);
        if (child is RenderBoxModel) {
          childRenderBoxModel = child;
        } else if (isPlaceholder) {
          // Use the positioned element's render style for horizontal margin and width calculations
          // so the placeholder's X offset reflects margin-left/right. We'll skip vertical collapsing below.
          childRenderBoxModel = (child).positioned;
        }

        if (childRenderBoxModel is RenderBoxModel) {
          final rs = childRenderBoxModel.renderStyle;
          childMarginLeft = rs.marginLeft.computedValue;
          if (!isPlaceholder || isStickyPlaceholder) {
            // The top margin as counted in the run's cross extent for this child.
            final double ownTopInExtent = getChildMarginTop(childRenderBoxModel);
            // Use the element's self/first-child collapsed top (ignoring parent collapse)
            // to compute inter-run collapsing relative to the previous run's bottom.
            final double selfTopIgnoringParent = rs.collapsedMarginTopIgnoringParent;
            // Collapsed bottom of previous sibling in this run
            final double? prevBottom = prevCollapsedBottom;
            // Compute top contribution as collapse(selfTopIgnoringParent, prevBottom) - prevBottom
            double topContribution;
            if (prevBottom == null) {
              topContribution = ownTopInExtent;
            } else {
              if (selfTopIgnoringParent >= 0 && prevBottom >= 0) {
                topContribution = math.max(selfTopIgnoringParent, prevBottom) - prevBottom;
              } else if (selfTopIgnoringParent <= 0 && prevBottom <= 0) {
                topContribution = math.min(selfTopIgnoringParent, prevBottom) - prevBottom;
              } else {
                topContribution = selfTopIgnoringParent;
              }
            }
            if (!firstOwnTopCaptured) {
              runFirstOwnTop = ownTopInExtent;
              runFirstTopContribution = topContribution;
              firstOwnTopCaptured = true;
            }
            childMarginTop = topContribution;
            childMarginBottom = getChildMarginBottom(childRenderBoxModel);

          } else {
            // Absolute/fixed placeholders do not participate in vertical margin collapsing.
            childMarginTop = 0;
            childMarginBottom = 0;
          }
        }

        // No need to add padding and border for scrolling content box.
        Offset relativeOffset = _getOffset(
            childMainPosition +
            renderStyle.paddingLeft.computedValue +
            renderStyle.effectiveBorderLeftWidth.computedValue +
                childMarginLeft,
            crossAxisOffset +
            childLineExtent +
            renderStyle.paddingTop.computedValue +
            renderStyle.effectiveBorderTopWidth.computedValue +
                childMarginTop);
        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child);

        childMainPosition += childMainAxisExtent + childBetweenSpace;

        // Update previous collapsed bottom margin for next in-flow sibling in the run
        if (childRenderBoxModel != null && (!isPlaceholder || isStickyPlaceholder)) {
          prevCollapsedBottom = childMarginBottom;
        }
      }

      // Remove the first child's own collapsed top from the carry to avoid adding
      // both top and bottom margins of the previous run when computing the next run's start.
      final double crossAdvance = (runCrossAxisExtent - runFirstOwnTop + runFirstTopContribution) + runBetweenSpace;
      crossAxisOffset += crossAdvance;
      // Carry over prev collapsed bottom margin to next run
      carriedPrevCollapsedBottom = prevCollapsedBottom;
    }
  }

  // Compute distance to baseline of flow layout: prefer cached baselines from layout.
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final double? first = computeCssFirstBaselineOf(baseline);
    if (first != null) {
      return first;
    }
    final double? last = computeCssLastBaselineOf(baseline);
    if (last != null) {
      return last;
    }
    return boxSize?.height;
  }

  // Set the size of scrollable overflow area for inline formatting context.
  void _setMaxScrollableSizeFromIFC() {
    if (_inlineFormattingContext == null) {
      scrollableSize = size;
      return;
    }

    double maxScrollableWidth = 0;
    double maxScrollableHeight = 0;
    {
      // Paragraph path: use visual longest line and total height from paragraph metrics,
      // then extend horizontally to include atomic boxes that overflow their own inline
      // width (scrollable width beyond the placeholder width).
      final double paraWidth = _inlineFormattingContext!.paragraphVisualMaxLineWidth;
      final lines = _inlineFormattingContext!.paragraphLineMetrics;
      final double paraHeight = lines.isEmpty
          ? (_inlineFormattingContext!.paragraph?.height ?? 0)
          : lines.fold<double>(0.0, (h, lm) => h + lm.height);
      // Include extra vertical overflow from atomic inline boxes: relative/transform offsets
      // and intrinsic overflow (child scrollable height beyond its line box height).
      final double extraRelTransform = _inlineFormattingContext!.additionalPositiveYOffsetFromAtomicPlaceholders();
      final double extraAtomicOverflow = _inlineFormattingContext!.additionalOverflowHeightFromAtomicPlaceholders();
      final double extraY = math.max(extraRelTransform, extraAtomicOverflow);
      final double extraX = _inlineFormattingContext!.additionalPositiveXOverflowFromAtomicPlaceholders();
      maxScrollableWidth = paraWidth + extraX;
      maxScrollableHeight = paraHeight + extraY;
    }

    // Add padding to scrollable size
    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    double paddingLeft = renderStyle.paddingLeft.computedValue;
    double paddingTop = renderStyle.paddingTop.computedValue;
    double paddingRight = isScrollContainer ? renderStyle.paddingRight.computedValue : 0;
    double paddingBottom = isScrollContainer ? renderStyle.paddingBottom.computedValue : 0;

    maxScrollableWidth += paddingLeft + paddingRight;
    maxScrollableHeight += paddingTop + paddingBottom;

    // Compute viewport (content + padding) size inside borders
    final double viewportW = size.width -
        renderStyle.effectiveBorderLeftWidth.computedValue -
        renderStyle.effectiveBorderRightWidth.computedValue;
    final double viewportH = size.height -
        renderStyle.effectiveBorderTopWidth.computedValue -
        renderStyle.effectiveBorderBottomWidth.computedValue;

    // Decide effective scrollable extents per axis based on overflow policy.
    // For hidden/clip, do not create additional scrollable area; clamp to viewport.
    // For auto/scroll/visible, allow content-driven overflow region so ancestors
    // can account for visual overflow.
    final CSSOverflowType effOX = renderStyle.effectiveOverflowX;
    final CSSOverflowType effOY = renderStyle.effectiveOverflowY;

    double finalScrollableWidth;
    if (effOX == CSSOverflowType.hidden || effOX == CSSOverflowType.clip) {
      finalScrollableWidth = viewportW;
    } else {
      finalScrollableWidth = math.max(viewportW, maxScrollableWidth);
    }

    double finalScrollableHeight;
    if (effOY == CSSOverflowType.hidden || effOY == CSSOverflowType.clip) {
      finalScrollableHeight = viewportH;
    } else {
      finalScrollableHeight = math.max(viewportH, maxScrollableHeight);
    }

    scrollableSize = Size(finalScrollableWidth, finalScrollableHeight);
  }

  // Set the size of scrollable overflow area for flow layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSize() {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Track whether any child contributes extra vertical overflow beyond its own box
    // (e.g., descendant overflow increasing effective height, or positive relative/transform Y).
    bool hasChildCrossOverflow = false;
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;
    for (RunMetrics runMetric in _lineMetrics) {
      if (DebugFlags.debugLogScrollableEnabled) {
        renderingLogger.finer('[Flow-Scroll] ---- line start ----');
        renderingLogger.finer(
            '[Flow-Scroll] preLinesCrossSize=${preLinesCrossSize.toStringAsFixed(2)} run.crossAxisExtent=${runMetric
                .crossAxisExtent.toStringAsFixed(2)}');
      }
      List<RenderBox> runChildren = runMetric.runChildren;

      List<RenderBox> runChildrenList = [];
      // Scrollable main size collection of each child in the line.
      List<double> scrollableMainSizeOfChildren = [];
      // Scrollable cross size collection of each child in the line.
      List<double> scrollableCrossSizeOfChildren = [];

      void iterateRunChildren(RenderBox child) {
        // Total main size of previous siblings.
        double preSiblingsMainSize = 0;
        for (RenderBox sibling in runChildrenList) {
          if (sibling is RenderBoxModel) {
            preSiblingsMainSize += sibling.boxSize!.width;
          }
        }

        Size childScrollableSize = Size.zero;

        double childOffsetX = 0;
        double childOffsetY = 0;

        if (child is RenderBoxModel) {
          childScrollableSize = child.boxSize!;
          RenderStyle childRenderStyle = child.renderStyle;
          CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
          CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
          // Only non scroll container need to use scrollable size, otherwise use its own size.
          if (overflowX == CSSOverflowType.visible && overflowY == CSSOverflowType.visible) {
            childScrollableSize = child.scrollableSize;
          }

          // Scrollable overflow area is defined in the following spec
          // which includes margin, position and transform offset.
          // https://www.w3.org/TR/css-overflow-3/#scrollable-overflow-region

          // Add horizontal margins to main axis size (X).
          childOffsetX += childRenderStyle.marginLeft.computedValue + childRenderStyle.marginRight.computedValue;
          // Do NOT add vertical margins here; run.crossAxisExtent already accounts for
          // inter-run margin collapsing and contributes to preLinesCrossSize. Including
          // margins again here would double-count and inflate the vertical scrollable size.

          // Add offset of position relative.
          // Offset of position absolute and fixed is added in layout stage of positioned renderBox.
          Offset? relativeOffset = CSSPositionedLayout.getRelativeOffset(childRenderStyle);
          if (relativeOffset != null) {
            childOffsetX += relativeOffset.dx;
            childOffsetY += relativeOffset.dy;
          }

          // Add offset of transform.
          final Offset? transformOffset = child.renderStyle.effectiveTransformOffset;
          if (transformOffset != null) {
            childOffsetX = transformOffset.dx > 0 ? childOffsetX + transformOffset.dx : childOffsetX;
            childOffsetY = transformOffset.dy > 0 ? childOffsetY + transformOffset.dy : childOffsetY;
          }

          // Detect additional vertical overflow contributed by this child beyond its own box.
          double baseChildHeight = child.boxSize?.height ?? 0.0;
          if (childScrollableSize.height > baseChildHeight + 0.5 || childOffsetY > 0.5) {
            hasChildCrossOverflow = true;
          }
        } else if (child is RenderTextBox) {
          // When the container is a scroll container (overflow not visible), a text
          // child should contribute its full laid-out height (across all lines) to the
          // scrollable size rather than the clipped box height. Measure text height
          // using the container's content width.
          final bool containerScrolls = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
              renderStyle.effectiveOverflowY != CSSOverflowType.visible;
          if (containerScrolls) {
            final double availW = (contentConstraints?.maxWidth.isFinite == true)
                ? contentConstraints!.maxWidth
                : (constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity);
            final Size textFull = child.computeFullTextSizeForWidth(
                availW.isFinite ? availW : (getChildSize(child)?.width ?? 0));
            // Width contribution should not exceed the available content width.
            final double usedW = getChildSize(child)?.width ??
                math.min(textFull.width, availW.isFinite ? availW : textFull.width);
            childScrollableSize = Size(usedW, textFull.height);
            if (DebugFlags.debugLogScrollableEnabled) {
              renderingLogger.finer(
                  '[Flow-Scroll] text child fullSize=${textFull.width.toStringAsFixed(2)}×${textFull.height
                      .toStringAsFixed(2)} '
                      'usedW=${usedW.toStringAsFixed(2)} availW=${(availW.isFinite ? availW : double.infinity)
                      .toStringAsFixed(2)}');
            }
            if (textFull.height > (getChildSize(child)?.height ?? 0) + 0.5) {
              hasChildCrossOverflow = true;
            }
          } else {
            // Not a scroll container: use the actual box size.
            childScrollableSize = getChildSize(child) ?? Size.zero;
          }
        }

        scrollableMainSizeOfChildren.add(preSiblingsMainSize + childScrollableSize.width + childOffsetX);
        // Exclude vertical margins; only include additional vertical offsets (relative/transform).
        scrollableCrossSizeOfChildren.add(childScrollableSize.height + childOffsetY);
        runChildrenList.add(child);
      }

      runChildren.forEach(iterateRunChildren);

      if (DebugFlags.debugLogScrollableEnabled) {
        for (int i = 0; i < runChildren.length; i++) {
          final child = runChildren[i];
          final Size? sz = _getChildSize(child);
          final RenderStyle? crs = _getChildRenderStyle(child);
          if (crs != null && sz != null) {
            final mt = getChildMarginTop(child);
            final mb = getChildMarginBottom(child);
            renderingLogger.finer(
                '[Flow-Scroll-Child] <${crs.target.tagName.toLowerCase()}> size=${sz.width.toStringAsFixed(2)}×${sz
                    .height.toStringAsFixed(2)} '
                    'mt=${mt.toStringAsFixed(2)} mb=${mb.toStringAsFixed(2)}');
          }
        }
      }

      // Max scrollable main size of all the children in the line.
      double maxScrollableMainSizeOfLine = scrollableMainSizeOfChildren.reduce((double curr, double next) {
        return curr > next ? curr : next;
      });

      // Max scrollable cross size of all the children in the line.
      double maxScrollableCrossSizeOfLine = preLinesCrossSize +
          scrollableCrossSizeOfChildren.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

      scrollableMainSizeOfLines.add(maxScrollableMainSizeOfLine);
      scrollableCrossSizeOfLines.add(maxScrollableCrossSizeOfLine);
      preLinesCrossSize += runMetric.crossAxisExtent;

      if (DebugFlags.debugLogScrollableEnabled) {
        renderingLogger.finer('[Flow-Scroll] line childCrossMax=${(scrollableCrossSizeOfChildren.reduce((a, b) => a > b ? a : b)).toStringAsFixed(2)} lineBottom=${maxScrollableCrossSizeOfLine.toStringAsFixed(2)} preLinesCrossSize→${preLinesCrossSize.toStringAsFixed(2)}');
      }
    }

    // Max scrollable main size of all lines.
    double maxScrollableMainSizeOfLines = scrollableMainSizeOfLines.isEmpty
        ? 0.0
        : scrollableMainSizeOfLines.reduce((double curr, double next) => curr > next ? curr : next);

    RenderBoxModel container = this;
    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableMainSizeOfChildren = maxScrollableMainSizeOfLines +
        renderStyle.paddingLeft.computedValue +
        (isScrollContainer ? renderStyle.paddingRight.computedValue : 0);

    // Prefer collapsed stack height to avoid double-counting margins between block siblings.
    // For the special case of a single RenderTextBox child inside a scroll container,
    // use the measured full text height to capture multi-line overflow.
    final double collapsedCrossStack = _getRunsCrossSizeWithCollapse(_lineMetrics);

    final double linesCrossMax = scrollableCrossSizeOfLines.isEmpty
        ? 0.0
        : scrollableCrossSizeOfLines.reduce((double curr, double next) => curr > next ? curr : next);

    // Prefer collapsed (margin-aware) cross size when this container is not a scroll container
    // and children do not contribute extra overflow. This avoids double-counting collapsed
    // margins across runs. Elevate to the deeper visual bottom when scrolling is enabled
    // or when any child increases cross overflow.
    // Use collapsed stack height by default to avoid double-counting margins across runs.
    // Only elevate to a deeper visual bottom when a child contributes additional
    // vertical overflow (e.g., relative/transform offsets or intrinsic overflow),
    // which is captured by linesCrossMax.
    final bool needsExtendedCross = hasChildCrossOverflow;
    final double chosenCross = needsExtendedCross
        ? math.max(collapsedCrossStack, linesCrossMax)
        : collapsedCrossStack;

    double maxScrollableCrossSizeOfChildren = chosenCross +
        renderStyle.paddingTop.computedValue +
        (isScrollContainer ? renderStyle.paddingBottom.computedValue : 0);

    double maxScrollableMainSize = math.max(
        size.width -
            container.renderStyle.effectiveBorderLeftWidth.computedValue -
            container.renderStyle.effectiveBorderRightWidth.computedValue,
        maxScrollableMainSizeOfChildren);
    double maxScrollableCrossSize = math.max(
        size.height -
            container.renderStyle.effectiveBorderTopWidth.computedValue -
            container.renderStyle.effectiveBorderBottomWidth.computedValue,
        maxScrollableCrossSizeOfChildren);

    assert(maxScrollableMainSize.isFinite);
    assert(maxScrollableCrossSize.isFinite);
    scrollableSize = Size(maxScrollableMainSize, maxScrollableCrossSize);

    if (DebugFlags.debugLogScrollableEnabled) {
      renderingLogger.finer('[Flow-Scroll] result main=${maxScrollableMainSize.toStringAsFixed(2)} cross=${maxScrollableCrossSize.toStringAsFixed(2)} padding(top=${renderStyle.paddingTop.computedValue.toStringAsFixed(2)}, bottom=${isScrollContainer ? renderStyle.paddingBottom.computedValue.toStringAsFixed(2) : '0'})');
    }
  }

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? _getChildSize(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      return child.boxSize;
    } else if (child.hasSize) {
      // child is WidgetElement.
      return child.size;
    }
    return null;
  }

  RenderStyle? _getChildRenderStyle(RenderBox child) {
    RenderStyle? childRenderStyle;
    if (child is RenderTextBox) {
      childRenderStyle = renderStyle;
    } else if (child is RenderBoxModel) {
      childRenderStyle = child.renderStyle;
    } else if (child is RenderPositionPlaceholder) {
      childRenderStyle = child.positioned?.renderStyle;
    }
    return childRenderStyle;
  }

  double getChildMarginTop(RenderBox? child) {
    if (child == null || child is! RenderBoxModel) {
      return 0;
    }
    // Default to the child's own collapsed top (which may include
    // parent collapsing when the child is the first in-flow child).
    // Call sites that are resolving sibling adjacency will adjust to
    // use the sibling-oriented top when appropriate.
    double result = child.renderStyle.collapsedMarginTop;
    return result;
  }

  double getChildMarginBottom(RenderBox? child) {
    if (child == null || child is! RenderBoxModel) {
      return 0;
    }
    // Use sibling-oriented collapsed bottom that does not prematurely
    // collapse with the parent. This ensures correct spacing when the
    // following in-flow content is represented by an anonymous block
    // created at layout time (e.g., inline text sequences).
    return child.renderStyle.collapsedMarginBottomForSibling;
  }


  void setUpChildBaselineForIFC() {
    if (_inlineFormattingContext == null) {
      setCssBaselines(first: null, last: null);
      return;
    }

    // Cache CSS baselines for this element, computed from IFC line metrics.
    // Baselines are measured from the top padding/border edge as distances,
    // consistent with how computeDistanceToActualBaseline reports.
    final double paddingTop = renderStyle.paddingTop.computedValue;
    final double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    double? firstBaseline;
    double? lastBaseline;

    final List<ui.LineMetrics> paraLines = _inlineFormattingContext!.paragraphLineMetrics;
    if (paraLines.isNotEmpty) {
      firstBaseline = paraLines.first.baseline + paddingTop + borderTop;
      lastBaseline = paraLines.last.baseline + paddingTop + borderTop;
    } else {
      // Fallback: no line boxes produced (empty content). Synthesize from bottom margin edge for inline-block.
      final double marginBottom = renderStyle.marginBottom.computedValue;
      final double fallback = (boxSize?.height ?? size.height) + marginBottom;
      firstBaseline = fallback;
      lastBaseline = fallback;
    }

    setCssBaselines(first: firstBaseline, last: lastBaseline);
  }

  void setUpChildBaselineForBFC() {
    // Cache CSS baselines for non-IFC flow: use line metrics when overflow is visible.
    final paddingTop = renderStyle.paddingTop.computedValue;
    final borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    final bool overflowVisible = renderStyle.effectiveOverflowX == CSSOverflowType.visible &&
        renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    double? firstBaseline;
    double? lastBaseline;

    // Special handling for inline-block elements
    if (renderStyle.display == CSSDisplay.inlineBlock && boxSize != null) {
      // Search for in-flow descendants that expose a CSS baseline:
      //  - Prefer inline formatting contexts (line boxes) when present.
      //  - Otherwise, use flex/grid container baselines if available.
      // If none exist anywhere inside, synthesize from the bottom margin edge.
      double? descendantBaseline = _findDescendantBaseline();
      if (descendantBaseline != null) {
        firstBaseline = descendantBaseline;
        lastBaseline = descendantBaseline;
      } else {
        final double marginBottom = renderStyle.marginBottom.computedValue;
        firstBaseline = boxSize!.height + marginBottom;
        lastBaseline = firstBaseline;
      }
    } else if (overflowVisible && _lineMetrics.isNotEmpty) {
      if (_lineMetrics.first.baseline != null) {
        firstBaseline = _lineMetrics.first.baseline! + paddingTop + borderTop;
      }
      double yOffset = 0;
      for (int i = 0; i < _lineMetrics.length; i++) {
        final line = _lineMetrics[i];
        if (line.baseline != null) {
          lastBaseline = yOffset + line.baseline! + paddingTop + borderTop;
        }
        if (i < _lineMetrics.length - 1) {
          yOffset += line.crossAxisExtent;
        }
      }
    } else if (boxSize != null) {
      // No in-flow line boxes found: per CSS 2.1 §10.8.1, synthesize baseline from
      // the bottom margin edge for block-level boxes.
      final double marginBottom = renderStyle.marginBottom.computedValue;
      firstBaseline = boxSize!.height + marginBottom;
      lastBaseline = firstBaseline;
    }
    setCssBaselines(first: firstBaseline, last: lastBaseline);
  }

  // Find the baseline of the last in-flow descendant that exposes a CSS baseline.
  // Prefers IFC (line boxes); otherwise accepts container baselines (e.g., flex/grid).
  // Returns the baseline measured from this box's border-box top, or null if none found.
  double? _findDescendantBaseline() {
    double? result;

    void dfs(RenderObject node) {
      if (node is! RenderBox) return;

      // Skip out-of-flow positioned boxes entirely
      if (node is RenderBoxModel) {
        final CSSPositionType pos = node.renderStyle.position;
        if (pos == CSSPositionType.absolute || pos == CSSPositionType.fixed) {
          return;
        }
      }

      double? baselineFrom(RenderBoxModel model, double? b) {
        if (b == null) return null;
        final Offset offset = getLayoutTransformTo(model, this, excludeScrollOffset: true);
        final double collapsedWithParent = model.renderStyle.collapsedMarginTop;
        final double ignoringParent = model.renderStyle.collapsedMarginTopIgnoringParent;
        final double marginAdjustment = ignoringParent > collapsedWithParent
            ? (ignoringParent - collapsedWithParent)
            : 0.0;
        return offset.dy + marginAdjustment + b;
      }

      // Prefer IFC baselines (line boxes)
      if (node is RenderFlowLayout && node.establishIFC) {
        final double? b = node.computeCssLastBaseline();
        final double? candidate = baselineFrom(node, b);
        if (candidate != null && (result == null || candidate > result!)) {
          result = candidate;
        }
      }
      // Accept flex container cached baselines as a fallback
      if (node is RenderFlexLayout) {
        final double? b = node.computeCssLastBaselineOf(TextBaseline.alphabetic);
        final double? candidate = baselineFrom(node, b);
        if (candidate != null && (result == null || candidate > result!)) {
          result = candidate;
        }
      }

      // Recurse into children
      node.visitChildren(dfs);
    }

    visitChildren(dfs);
    return result;
  }

  @override
  void calculateBaseline() {
    if (establishIFC) {
      setUpChildBaselineForIFC();
    } else {
      setUpChildBaselineForBFC();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // When using Inline Formatting Context, delegate hit testing to IFC for inline content
    if (establishIFC && _inlineFormattingContext != null) {
      // 1) Hit test positioned/out-of-flow children first (z-order aware)
      for (int i = paintingOrder.length - 1; i >= 0; i--) {
        final RenderBox child = paintingOrder[i];
        // Only consider positioned elements when using IFC
        if (child is RenderBoxModel && (child.renderStyle.isSelfPositioned() || child.renderStyle.isSelfStickyPosition())) {
          final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
          final bool isHit = result.addWithPaintOffset(
            offset: childParentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              return child.hitTest(result, position: transformed);
            },
          );
          if (isHit) return true;
        }
      }

      // 2) Hit test inline content within the container's content box
      final Offset contentOffset = Offset(
        renderStyle.paddingLeft.computedValue + renderStyle.effectiveBorderLeftWidth.computedValue,
        renderStyle.paddingTop.computedValue + renderStyle.effectiveBorderTopWidth.computedValue,
      );

      final Offset local = position - contentOffset;
      return _inlineFormattingContext!.hitTest(result, position: local);
    }

    // Fallback to default behavior for regular flow layout
    return defaultHitTestChildren(result, position: position);
  }


  static double getPureMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
    }

    Size childSize = getChildSize(child) ?? Size.zero;

    return childSize.width + marginHorizontal;
  }

  static Size? getChildSize(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      return child.boxSize;
    } else if (child.hasSize) {
      // child is WidgetElement.
      return child.size;
    }
    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('establishIFC',
        value: establishIFC,
        ifTrue: 'inline formatting context',
        ifFalse: 'block layout'));

    if (_inlineFormattingContext != null) {
      _inlineFormattingContext!.debugFillProperties(properties);
    }
    properties.add(DiagnosticsProperty('first child baseline', computeCssFirstBaseline()));
    properties.add(DiagnosticsProperty('last child baseline', computeCssLastBaseline()));
  }

}

// Render flex layout with self repaint boundary.
class RenderRepaintBoundaryFlowLayoutNext extends RenderFlowLayout {
  RenderRepaintBoundaryFlowLayoutNext({
    super.children,
    required super.renderStyle,
  });

  @override
  bool get isRepaintBoundary => true;
}
