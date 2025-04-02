/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

// Position and size of each run (line box) in flow layout.
// https://www.w3.org/TR/css-inline-3/#line-boxes
class RunMetrics {
  RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    this.baselineExtent,
    this.runChildren,
  );

  // Main size extent of the run.
  final double mainAxisExtent;

  // Cross size extent of the run.
  final double crossAxisExtent;

  // Max extent above each flex items in the run.
  final double baselineExtent;

  // All the children RenderBox of layout in the run.
  final Map<int?, RenderBox> runChildren;
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
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    addAll(children);
  }

  // Line boxes of flow layout.
  // https://www.w3.org/TR/css-inline-3/#line-boxes
  // Fow example <i>Hello<br>world.</i> will have two <i> line boxes
  RenderLineBoxes lineBoxes = RenderLineBoxes();

  @override
  void dispose() {
    super.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    lineBoxes.clear();
  }

  double get firstLineExtent {
    if (constraints is InlineBoxConstraints && !isInlineBlockLevel(this)) {
      return (constraints as InlineBoxConstraints).leftWidth;
    }
    return 0;
  }

  double get lastLineHeight {
    if (!lineBoxes.isEmpty) {
      return lineBoxes.last!.crossAxisExtent;
    }
    return 0;
  }

  double get lastLineExtent {
    if (!lineBoxes.isEmpty) {
      return lineBoxes.last!.mainAxisExtentWithoutLineJoin;
    }
    return 0;
  }

  double get lastLineExtentWithWrap {
    if (!lineBoxes.isEmpty) {
      double lineSize = lineBoxes.last!.mainAxisExtentWithoutLineJoin;
      if (lineBoxes.lineSize == 1) {
        return wrapOutContentSize(Size.fromWidth(lineSize)).width;
      }
      return wrapOutContentSizeRight(Size.fromWidth(lineSize)).width;
    }
    return 0;
  }

  bool get constraintsOverflow {
    if (constraints is MultiLineBoxConstraints) {
      return (constraints as MultiLineBoxConstraints).overflow ?? false;
    }
    return false;
  }

  int get _maxLines {
    int? maxParentLineLimit;
    int? lineClamp = renderStyle.lineClamp;
    if (constraints is MultiLineBoxConstraints) {
      maxParentLineLimit = (constraints as MultiLineBoxConstraints).maxLines;
    }
    // Forcing a break after a set number of lines.
    // https://drafts.csswg.org/css-overflow-3/#max-lines
    if (lineClamp != null || maxParentLineLimit != null) {
      return math.min(lineClamp ?? webfTextMaxLines, maxParentLineLimit ?? webfTextMaxLines);
    }
    return webfTextMaxLines;
  }

  @override
  void setupParentData(RenderBox child) {
    child.parentData = RenderLayoutParentData();
    if (child is RenderBoxModel) {
      child.parentData = CSSPositionedLayout.getPositionParentData(child, child.parentData as RenderLayoutParentData);
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
    bool isLineHeightValid = _isLineHeightValid(child);
    double? lineHeight = isLineHeightValid ? _getLineHeight(child) : 0;
    double marginVertical = 0;

    if (child is RenderBoxModel) {
      marginVertical = getChildMarginTop(child) + getChildMarginBottom(child);
    }
    Size childSize = RenderFlowLayout.getChildSize(child) ?? Size.zero;

    return lineHeight != null
        ? math.max(lineHeight, childSize.height) + marginVertical
        : childSize.height + marginVertical;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    return Offset(mainAxisOffset, crossAxisOffset);
  }

  double _getChildCrossAxisOffset(double runCrossAxisExtent, double childCrossAxisExtent) {
    return runCrossAxisExtent - childCrossAxisExtent;
  }

  double? _getLineHeight(RenderBox child) {
    CSSLengthValue? lineHeight;
    if (child is RenderTextBox) {
      lineHeight = renderStyle.lineHeight;
    } else if (child is RenderBoxModel) {
      lineHeight = child.renderStyle.lineHeight;
    } else if (child is RenderPositionPlaceholder) {
      lineHeight = child.positioned!.renderStyle.lineHeight;
    }

    if (lineHeight != null && lineHeight.type != CSSLengthType.NORMAL) {
      return lineHeight.computedValue;
    }
    return null;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    for (int i = 0; i < paintingOrder.length; i++) {
      RenderBox child = paintingOrder[i];
      if (!isPositionPlaceholder(child)) {
        final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
        final Constraints constraints = child.constraints;
        if (constraints is InlineBoxConstraints && constraints.jumpPaint) {
          continue;
        }
        if (child.hasSize) {
          context.paintChild(child, childParentData.offset + offset);
        }
      }
    }
  }

  @override
  void performLayout() {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayout(this);
    }

    doingThisLayout = true;

    _doPerformLayout();

    if (needsRelayout) {
      _doPerformLayout();
      needsRelayout = false;
    }
    doingThisLayout = false;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayout(this);
    }
  }

  void _doPerformLayout() {
    beforeLayout();

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderBox> _nonPositionedChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && childParentData.isPositioned) {
        _positionedChildren.add(child);
      } else {
        _nonPositionedChildren.add(child);
        if (child is RenderBoxModel && CSSPositionedLayout.isSticky(child)) {
          _stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    // Layout non positioned element (include element in flow and
    // placeholder of positioned element).
    _layoutChildren(_nonPositionedChildren);

    // init overflowLayout size
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // calculate all flexItem child overflow size
    addOverflowLayoutFromChildren(_nonPositionedChildren);

    // Set offset of positioned element after flex box size is set.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      addOverflowLayoutFromChild(child);
    }

    // Set offset of sticky element on each layout.
    for (RenderBoxModel child in _stickyChildren) {
      RenderBoxModel scrollContainer = child.findScrollContainer()!;
      // Sticky offset depends on the layout of scroll container, delay the calculation of
      // sticky offset to the layout stage of  scroll container if its not layouted yet
      // due to the layout order of Flutter renderObject tree is from down to up.
      if (scrollContainer.hasSize) {
        CSSPositionedLayout.applyStickyChildOffset(scrollContainer, child);
      }
    }

    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    if (isScrollContainer) {
      // Find all the sticky children when scroll container is layouted.
      stickyChildren = findStickyChildren();
      // Calculate the offset of its sticky children.
      for (RenderBoxModel stickyChild in stickyChildren) {
        CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
      }
    }

    didLayout();
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

    // Layout children to compute metrics of lines.
    _computeRunMetrics(children);

    // Set container size.
    _setContainerSize();

    // Adjust children size which depends on the container size.
    _adjustChildrenSize();

    // Set children offset based on alignment properties.
    _setChildrenOffset();

    // Set the size of scrollable overflow area for flow layout.
    _setMaxScrollableSize();
  }

  bool isLineBreakForExtentShort(double mainAxisExtent, double mainAxisExtentLimit, double childExtent) {
    // Line length is exceed container.
    // The white-space property not only specifies whether and how white space is collapsed
    // but only specifies whether lines may wrap at unforced soft wrap opportunities
    // https://www.w3.org/TR/css-text-3/#line-breaking
    if (renderStyle.whiteSpace != WhiteSpace.nowrap && mainAxisExtent + childExtent > mainAxisExtentLimit) {
      return true;
    }
    return false;
  }

  bool isLineBreak(
      RenderBox child, RenderBox? preChild, double mainAxisExtent, double mainAxisExtentLimit, double childExtent) {
    // Previous is block or current is block.
    if (isBlockLevel(child) || isBreakForBlock(preChild)) {
      return true;
    }

    // Line length is exceed container.
    // The white-space property not only specifies whether and how white space is collapsed
    // but only specifies whether lines may wrap at unforced soft wrap opportunities
    // https://www.w3.org/TR/css-text-3/#line-breaking
    if (isLineBreakForExtentShort(mainAxisExtent, mainAxisExtentLimit, childExtent)) {
      return true;
    }

    // if render is text, and layout result have more than one line, will happen break
    if (child is RenderTextBox && (child.lines > 1 || child.happenLineJoin())) {
      return true;
    }
    // Inline element maybe content size over max main axis extent, then happen break line
    // on this time, need let parent break line.
    if (child is RenderFlowLayout &&
        !isBlockLevel(child) &&
        (child.lineBoxes.happenBreakForShortSpace() ||
            child.lineBoxes.happenTextBreakMoreLine() ||
            child.happenLineJoin()) &&
        // If child constraints maxWith < last extent do not break。
        child.constraints.maxWidth > (mainAxisExtentLimit - mainAxisExtent)) {
      return true;
    }

    return false;
  }

  bool isBreakForBlock(RenderBox? preChild) {
    if (isBlockLevel(preChild) || preChild is RenderLineBreak) {
      return true;
    }
    return false;
  }

  bool isCanUseInlineBoxConstraints(RenderBox? child, double mainAxisLimit, BoxConstraints oldConstraints) {
    if (isCanLineJoinChild(child) &&
        (oldConstraints.maxWidth == mainAxisLimit || oldConstraints.maxWidth == double.infinity)) {
      return true;
    }
    return false;
  }

  // Layout children in normal flow order to calculate metrics of lines according to its constraints
  // and alignment properties.
  void _computeRunMetrics(List<RenderBox> children) {
    double mainAxisLimit = renderStyle.contentMaxConstraintsWidth;
    RenderBox? preChild;
    lineBoxes.clear();
    lineBoxes.mainAxisLimit = mainAxisLimit;
    LogicLineBox? lastRunLineBox;
    LogicLineBox runLineBox = buildNewLineBox();
    runLineBox.isFirst = true;
    int remainLines = _maxLines;
    bool happenJumpPaint = false;
    children.forEachIndexed((index, child) {
        /// avoid happen remainLines <= 0 which is invalid
        bool isLineOverflow = constraintsOverflow;
        int lastLineSize = _maxLines - (lineBoxes.innerLineLength + runLineBox.innerLineLength);

        /// if no more line last or last one line and the line has been used, next [RenderObject] can't use join line to
        /// get more line num
        if (lastLineSize <= 0 || lastLineSize == 1 && runLineBox.mainAxisExtent > 0 && runLineBox.isFirst != true) {
          isLineOverflow = true;
        }

        remainLines = math.max(lastLineSize, 1);

        final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

        // If the first line first child is not block level and parent render give line join chance
        // the first line add left place holder to create line join env
        if (!isBlockLevel(child) &&
            !isInlineBlockLevel(this) &&
            constraints is InlineBoxConstraints &&
            child == children.first) {
          runLineBox.firstLineLeftExtent = (constraints as InlineBoxConstraints).leftWidth;
        }

        BoxConstraints childConstraints;
        if (child is RenderBoxModel) {
          childConstraints = MultiLineBoxConstraints.from(remainLines, 0, isLineOverflow, child.getConstraints());

          if (!isBlockLevel(child)) {
            // Inline element use InlineBoxConstraints, support line join logic
            childConstraints = InlineBoxConstraints(
                jumpPaint: happenJumpPaint,
                overflow: isLineOverflow,
                maxLines: remainLines,
                minWidth: childConstraints.minWidth,
                maxWidth: childConstraints.maxWidth,
                minHeight: childConstraints.minHeight,
                maxHeight: childConstraints.maxHeight);
          }
        } else if (child is RenderTextBox) {
          childConstraints = child.getConstraints(remainLines);
        } else if (child is RenderPositionPlaceholder) {
          childConstraints = BoxConstraints();
        } else {
          // RenderObject of custom element need to inherit constraints from its parents
          // which adhere to flutter's rule.
          childConstraints = constraints;
        }

        // Whether child need to layout.
        bool isChildNeedsLayout = true;

        if (child.hasSize &&
            !needsRelayout &&
            (childConstraints == child.constraints) &&
            ((child is RenderBoxModel && !child.needsLayout) || (child is RenderTextBox && !child.needsLayout))) {
          isChildNeedsLayout = false;
        }

        if (isChildNeedsLayout) {
          // If mainAxisExtent is not infinity and child's constraints.maxWidth == mainAxisExtent,
          // first layout text child need use current line left extent to do first layout,
          // if happen line break next step will use mainAxisExtent layout twice,
          if (isCanUseInlineBoxConstraints(child, mainAxisLimit, childConstraints) &&
              !isBreakForBlock(preChild) &&
              runLineBox.mainAxisExtent != 0 &&
              childConstraints is InlineBoxConstraints) {
            double leftWidth = runLineBox.findLastLineRenderMainExtent();
            double lineMainExtent = runLineBox.defaultLastLineMainExtent();
            childConstraints = InlineBoxConstraints(
                jumpPaint: happenJumpPaint,
                overflow: isLineOverflow,
                maxLines: childConstraints.maxLines,
                joinLine: isLineOverflow ? 0 : 1,
                leftWidth: leftWidth,
                lineMainExtent: lineMainExtent,
                minHeight: childConstraints.minHeight,
                maxHeight: childConstraints.maxHeight,
                minWidth: childConstraints.minWidth,
                maxWidth: childConstraints.maxWidth);
          }
          bool parentUseSize = !(child is RenderBoxModel && child.isSizeTight || child is RenderPositionPlaceholder);

          if (enableWebFProfileTracking) {
            WebFProfiler.instance.pauseCurrentLayoutOp();
          }

          child.layout(childConstraints, parentUsesSize: parentUseSize);

          if (enableWebFProfileTracking) {
            WebFProfiler.instance.resumeCurrentLayoutOp();
          }
        }

        double childMainAxisExtent = RenderFlowLayout.getPureMainAxisExtent(child);
        double childCrossAxisExtent = _getCrossAxisExtent(child);

        if (isPositionPlaceholder(child)) {
          RenderPositionPlaceholder positionHolder = child as RenderPositionPlaceholder;
          RenderBoxModel? childRenderBoxModel = positionHolder.positioned;
          if (childRenderBoxModel != null) {
            RenderLayoutParentData childParentData = childRenderBoxModel.parentData as RenderLayoutParentData;
            if (childParentData.isPositioned) {
              childMainAxisExtent = childCrossAxisExtent = 0;
            }
          }
        }

        // set `happenJumpPaint=true` case below:
        // 1. flow element, css style display:inline
        // 2. text element, visualOverflow
        if (!happenJumpPaint &&
            ((child is RenderFlowLayout && isInlineLevel(child) && (child).lineBoxes.happenVisualOverflow()) ||
                (child is RenderTextBox && child.happenVisualOverflow))) {
          // happenJumpPaint = true;
        }

        // This value use to range every line render position
        // and check render is need break.Because the line happen join need
        // use pre render last line extent.Can't use the render MainAxisExtent,
        // because the render MainAxisExtent container Multi-line max extent.
        double childListLineMainAxisExtent = childMainAxisExtent;
        if (child is RenderFlowLayout && !child.lineBoxes.isEmpty && isJoinBox(child) && isJoinBox(this)) {
          childListLineMainAxisExtent = child.lastLineExtent;
        }

        // If runLineBox.mainAxisExtent > 0 and runLineBox no child, maybe happen line join,
        // but first child mainAxisExtent too big on this time can happen line break
        // RenderTextBox lines > 1, happen lien break
        if ((runLineBox.isNotEmpty || runLineBox.mainAxisExtent > 0) &&
            isLineBreak(child, preChild, runLineBox.mainAxisExtent, mainAxisLimit, childListLineMainAxisExtent) ||
            // if textBox happen linebreak need to create more lineBox
            child is RenderTextBox && child.lines > 1) {
          if (child is RenderTextBox) {
            runLineBox = processTextBoxBreak(child, runLineBox);
            childParentData.runIndex = lineBoxes.lineSize;
            preChild = child;
            return;
          }
          appendLineBox(runLineBox);

          LogicLineBox newLineBox = buildNewLineBox();
          if (isLineBreakForExtentShort(
              runLineBox.mainAxisExtentWithoutLineJoin, mainAxisLimit, childListLineMainAxisExtent)) {
            newLineBox.breakForExtentShort = true;
          }
          lastRunLineBox = runLineBox;
          runLineBox = newLineBox;
        }

        // create logicInlineBox
        LogicInlineBox? newLogicInlineBox = buildInlineBoxFromRender(child);
        if (child is RenderTextBox && newLogicInlineBox == null) {
          // null text need jump, because text lineRender is null.
          return;
        }
        assert(newLogicInlineBox != null, 'can not get useful logic box');
        runLineBox.appendInlineBox(newLogicInlineBox!, childListLineMainAxisExtent, childCrossAxisExtent,
            calculateChildCrossAxisExtent(child, newLogicInlineBox));

        childParentData.runIndex = lineBoxes.lineSize;
        preChild = child;
    });

    appendLineBox(runLineBox);
    lineBoxes.maxLines = _maxLines;
  }

  // add child to current runLine and create a new RunLine if needed
  LogicLineBox processTextBoxBreak(RenderTextBox child, LogicLineBox runLine) {
    LogicLineBox newLineBox = runLine;
    if (child.happenLineJoin()) {
      LogicTextInlineBox firstTextBox = child.lineBoxes.get(0);
      runLine.appendInlineBox(firstTextBox, firstTextBox.logicRect.width, firstTextBox.logicRect.height,
          calculateTextCrossAxisExtent(child, 0));
      if (child.lines > 1) {
        appendLineBox(runLine);
        newLineBox = appendAllInlineTextToNewLine(child, false);
      }
    } else {
      if (runLine.isNotEmpty) {
        appendLineBox(runLine);
      }
      newLineBox = appendAllInlineTextToNewLine(child, true);
    }
    return newLineBox;
  }

  // create a new lineBox, and append child's inlineBoxes to the new lineBox
  LogicLineBox appendAllInlineTextToNewLine(RenderTextBox child, bool fromFirst) {
    LogicLineBox newLineBox = buildNewLineBox();
    for (int i = fromFirst ? 0 : 1; i < child.lineBoxes.inlineBoxList.length; i++) {
      newLineBox = buildNewLineBox();
      LogicTextInlineBox curTextBox = child.lineBoxes.get(i);
      newLineBox.appendInlineBox(curTextBox, curTextBox.logicRect.width,
          curTextBox.logicRect.height, calculateTextCrossAxisExtent(child, i));

      if (i != child.lineBoxes.inlineBoxList.length - 1) {
        appendLineBox(newLineBox);
      }
    }
    return newLineBox;
  }

  LogicLineBox buildNewLineBox() {
    return LogicLineBox(
        renderObject: this, baselineExtent: 0, baselineBelowExtent: 0, crossAxisExtent: 0, mainAxisExtent: 0);
  }

  void appendLineBox(LogicLineBox line) {
    if (line.isNotEmpty) {
      lineBoxes.addLineBox(line);
    }
  }

  LogicInlineBox? buildInlineBoxFromRender(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.createLogicInlineBox();
    }
    if (child is WebFRenderImage) {
      return child.createLogicInlineBox();
    }
    if (child is RenderPreferredSize) {
      return child.createLogicInlineBox();
    }
    if (child is RenderTextBox) {
      if (child.lineBoxes.isEmpty) {
        return null;
      }
      return child.firstInlineBox;
    }
    return LogicInlineBox(renderObject: child);
  }

  List<double>? calculateChildCrossAxisExtent(RenderBox child, LogicInlineBox box) {
    RenderStyle? childRenderStyle = _getChildRenderStyle(child);
    VerticalAlign verticalAlign = VerticalAlign.baseline;
    if (childRenderStyle != null) {
      verticalAlign = childRenderStyle.verticalAlign;
    }
    bool isLineHeightValid = box.isLineHeightValid();

    // Vertical align is only valid for inline box.
    if (isLineHeightValid) {
      double childMarginTop = getChildMarginTop(child);
      double childMarginBottom = getChildMarginBottom(child);

      Size childSize = box.getChildSize()!;
      // When baseline of children not found, use boundary of margin bottom as baseline.
      double childAscent = box.getChildAscent(childMarginTop, childMarginBottom);
      double extentAboveBaseline = childAscent;
      double extentBelowBaseline = childMarginTop + childSize.height + childMarginBottom - childAscent;
      // The box Render child no content, but have line height, it is error
      // need to reset extentBelowBaseLine to zero
      // if (childAscent == 0 && childSize.height > 0) {
      //   extentBelowBaseline = 0;
      // }
      return [extentAboveBaseline, extentBelowBaseline];
    }
    return null;
  }

  List<double>? calculateTextCrossAxisExtent(RenderTextBox textBox, int lineNumber) {
    return textBox.getLineAscent(lineNumber);
  }

  List<double> calculateMaxCrossAxisExtent(double lastCrossAxisExtent, double lastAboveBaseLine,
      double lastBelowBaseLine, double childCrossAxisExtent, List<double>? baselineSize) {
    double newAboveBaseLine = lastAboveBaseLine;
    double newBelowBaseLine = lastBelowBaseLine;

    if (baselineSize != null) {
      newAboveBaseLine = math.max(
        baselineSize[0],
        newAboveBaseLine,
      );
      newBelowBaseLine = math.max(
        baselineSize[1],
        newBelowBaseLine,
      );
      return [math.max(lastCrossAxisExtent, newAboveBaseLine + newBelowBaseLine), newAboveBaseLine, newBelowBaseLine];
    } else {
      return [math.max(lastCrossAxisExtent, childCrossAxisExtent), newAboveBaseLine, newBelowBaseLine];
    }
  }

  // Set flex container size according to children size.
  void _setContainerSize({double adjustHeight = 0, double adjustWidth = 0}) {
    if (lineBoxes.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    double runMaxMainSize = happenLineJoin() ? lineBoxes.maxMainAxisSize : lineBoxes.maxMainAxisSizeWithoutLineJoin;
    double runCrossSize = lineBoxes.crossAxisSize;

    Size layoutContentSize = getContentSize(
      contentWidth: runMaxMainSize + adjustWidth,
      contentHeight: runCrossSize + adjustHeight,
    );

    size = getBoxSize(layoutContentSize);

    minContentWidth = lineBoxes.mainAxisAutoSize;
    minContentHeight = lineBoxes.crossAxisAutoSize;
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

  // Children may need to relayout when its display is block which depends on
  // the size of its container whose display is inline-block.
  // Take following as example, div of id="2" need to relayout after its container is
  // stretched by sibling div of id="1".
  //
  // <div style="display: inline-block;">
  //   <div id="1" style="width: 100px;">
  //   </div>
  //   <div id="2">
  //   </div>
  // </div>
  void _adjustChildrenSize() {
    if (lineBoxes.isEmpty) return;

    // Element of inline-block will shrink to its maximum children size
    // when its width is not specified.
    bool isInlineBlock = renderStyle.effectiveDisplay == CSSDisplay.inlineBlock;
    if (isInlineBlock) {
      for (int i = 0; i < lineBoxes.lines.length; ++i) {
        final LogicLineBox metrics = lineBoxes.lines[i];
        for (LogicInlineBox box in metrics.inlineBoxes) {
          RenderBox child = box.renderObject;
          if (child is RenderBoxModel) {
            bool isChildBlockLevel = child.renderStyle.effectiveDisplay == CSSDisplay.block ||
                child.renderStyle.effectiveDisplay == CSSDisplay.flex;
            // Element of display block will stretch to the width of its container
            // when its width is not specified.
            if (isChildBlockLevel) {
              double contentBoxWidth = isScrollingContentBox ? boxSize!.width : renderStyle.contentBoxWidth!;
              // No need to layout child when its width is identical to parent's width.
              if (child.renderStyle.borderBoxWidth == contentBoxWidth) {
                continue;
              }
              double? borderBoxLogicWidth = child.renderStyle.borderBoxLogicalWidth;
              BoxConstraints childConstraints = BoxConstraints(
                minWidth: borderBoxLogicWidth ?? contentBoxWidth,
                maxWidth: borderBoxLogicWidth ?? contentBoxWidth,
                minHeight: child.constraints.minHeight,
                maxHeight: child.constraints.maxHeight,
              );

              if (enableWebFProfileTracking) {
                WebFProfiler.instance.pauseCurrentLayoutOp();
              }

              child.layout(childConstraints, parentUsesSize: true);

              if (enableWebFProfileTracking) {
                WebFProfiler.instance.resumeCurrentLayoutOp();
              }
            }
          }
        }
      }
    }
  }

  // Set children offset based on alignment properties.
  void _setChildrenOffset() {
    if (lineBoxes.isEmpty) return;

    double runLeadingSpace = 0;
    double runBetweenSpace = 0;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize = contentSize.width;

    double totalCrossAxisAdjust = 0;

    // Set offset of children in each line.
    for (int i = 0; i < lineBoxes.lines.length; ++i) {
      final LogicLineBox runLineBox = lineBoxes.lines[i];
      final double runMainAxisExtent = runLineBox.mainAxisExtentWithoutLineJoin;
      final double runCrossAxisExtent = runLineBox.crossAxisExtent;
      final double runBaselineExtent = runLineBox.baselineExtent;
      final int runChildrenCount = runLineBox.inlineBoxes.length;
      final double mainAxisFreeSpace = math.max(0.0, mainAxisContentSize - runMainAxisExtent);
      double crossAxisLineJoinOffset = 0;
      double mainAxisLineJoinOffset = 0;

      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      // Whether inline level child exists in this run.
      bool runContainInlineChild = true;

      // int? firstChildKey = runChildren.keys.elementAt(0);
      LogicInlineBox box = runLineBox.first!;
      RenderBox? firstChild = box.renderObject;

      // process child one line happen line join
      if (i != 0 && firstChild is RenderFlowLayout && firstChild.happenLineJoin()) {
        crossAxisLineJoinOffset = runLineBox.calculateMergeLineExtent(lineBoxes.lines[i - 1]);
        totalCrossAxisAdjust += crossAxisLineJoinOffset;
      }

      // if flow container happenLineJoin, first line add main axis offset
      if (i == 0 &&
          runLineBox.length > 0 &&
          runLineBox.renderObject is RenderFlowLayout &&
          (runLineBox.renderObject as RenderFlowLayout).happenLineJoin()) {
        mainAxisLineJoinOffset = runLineBox.firstLineLeftExtent;
      }

      // Block level and inline level child can not exists at the same line,
      // so only need to loop the first child.
      if (firstChild is RenderBoxModel) {
        CSSDisplay? childEffectiveDisplay = firstChild.renderStyle.effectiveDisplay;
        runContainInlineChild = childEffectiveDisplay != CSSDisplay.block && childEffectiveDisplay != CSSDisplay.flex;
      }

      // Text-align only works on inline level children.
      if (runContainInlineChild) {
        switch (renderStyle.textAlign) {
          case TextAlign.left:
          case TextAlign.start:
            break;
          case TextAlign.right:
          case TextAlign.end:
            childLeadingSpace = mainAxisFreeSpace;
            break;
          case TextAlign.center:
            childLeadingSpace = mainAxisFreeSpace / 2.0;
            break;
          case TextAlign.justify:
            childBetweenSpace = runChildrenCount > 1 ? mainAxisFreeSpace / (runChildrenCount - 1) : 0.0;
            break;
          default:
            break;
        }
      }

      double childMainPosition = childLeadingSpace;

      for (LogicInlineBox childBox in runLineBox.inlineBoxes) {
        double usefulRunCrossAxisExtent = runCrossAxisExtent;
        // for all box which in line the first's box is happen line join, need use last line extent
        if ((crossAxisLineJoinOffset != 0 || runLineBox.isFirstInlineBoxHasMoreLine()) &&
            childBox != runLineBox.first) {
          List<double> lineExtentParams = runLineBox.findFirstLineJoinCrossAxisExtent();
          usefulRunCrossAxisExtent = runCrossAxisExtent - (lineExtentParams[0] + lineExtentParams[1]);
        }
        RenderBox childRender = childBox.renderObject;
        final double childMainAxisExtent = RenderFlowLayout.getPureMainAxisExtent(childRender);
        double marginVertical = getChildMarginTop(childRender) + getChildMarginBottom(childRender);
        final double childCrossAxisExtent = childBox.getCrossAxisExtent(renderStyle.lineHeight, marginVertical);

        // This value use to range every line render position
        double childListLineMainAxisExtent = childMainAxisExtent;
        if (childRender is RenderFlowLayout && !childRender.lineBoxes.isEmpty && isJoinBox(childRender)) {
          childListLineMainAxisExtent = childRender.lastLineExtentWithWrap;
        }
        if (childBox is LogicTextInlineBox && (childRender as RenderTextBox).lineBoxes.containLineBox(childBox)) {
          childListLineMainAxisExtent = childBox.width;
        }

        // Calculate margin auto length according to CSS spec
        // https://www.w3.org/TR/CSS21/visudet.html#blockwidth
        // margin-left and margin-right auto takes up available space
        // between element and its containing block on block-level element
        // which is not positioned and computed to 0px in other cases.
        if (childRender is RenderBoxModel) {
          RenderStyle childRenderStyle = childRender.renderStyle;
          CSSDisplay? childEffectiveDisplay = childRenderStyle.effectiveDisplay;
          CSSLengthValue marginLeft = childRenderStyle.marginLeft;
          CSSLengthValue marginRight = childRenderStyle.marginRight;

          // 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right' +
          // 'border-right-width' + 'margin-right' = width of containing block
          if (childEffectiveDisplay == CSSDisplay.block || childEffectiveDisplay == CSSDisplay.flex) {
            if (marginLeft.isAuto) {
              double remainingSpace = mainAxisContentSize - childMainAxisExtent;
              if (marginRight.isAuto) {
                childMainPosition = remainingSpace / 2;
              } else {
                childMainPosition = remainingSpace;
              }
            }
          }
        }

        // Always align to the top of run when positioning positioned element placeholder
        // @HACK(kraken): Judge positioned holder to impl top align.
        final double childCrossAxisOffset = isPositionPlaceholder(childRender)
            ? 0
            : _getChildCrossAxisOffset(usefulRunCrossAxisExtent, childCrossAxisExtent);

        Size? childSize = childBox.getChildSize();
        // Child line extent calculated according to vertical align.
        double childLineExtent = childCrossAxisOffset;

        bool isLineHeightValid = childBox.isLineHeightValid();

        if (isLineHeightValid) {
          // Distance from top to baseline of child.
          double? childMarginTop = getChildMarginTop(childRender);
          double? childMarginBottom = getChildMarginBottom(childRender);
          double childAscent = childBox.getChildAscent(childMarginTop, childMarginBottom);

          RenderStyle childRenderStyle = _getChildRenderStyle(childRender)!;
          VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

          // Leading between height of line box's content area and line height of line box.
          double lineBoxLeading = 0;
          double? lineBoxHeight = _getLineHeight(this);
          if (lineBoxHeight != null) {
            lineBoxLeading = lineBoxHeight - usefulRunCrossAxisExtent;
          }

          switch (verticalAlign) {
            case VerticalAlign.baseline:
              childLineExtent = lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case VerticalAlign.top:
              childLineExtent = 0;
              break;
            case VerticalAlign.bottom:
              childLineExtent = (lineBoxHeight ?? usefulRunCrossAxisExtent) - childSize!.height;
              break;
            // @TODO: Vertical align middle needs to calculate the baseline of the parent box plus
            //  half the x-height of the parent from W3C spec currently flutter lack the api to calculate x-height of glyph.
            //  case VerticalAlign.middle:
            //  break;
            case VerticalAlign.textBottom:
              childLineExtent = (lineBoxHeight ?? usefulRunCrossAxisExtent) - childAscent;
              break;
          }
          // Child should not exceed over the top of parent.
          childLineExtent = childLineExtent < 0 ? 0 : childLineExtent;
        }

        RenderBoxModel? childRenderBoxModel;
        if (childRender is RenderBoxModel) {
          childRenderBoxModel = childRender;
        } else if (childRender is RenderPositionPlaceholder) {
          childRenderBoxModel = childRender.positioned;
        }

        double? childMarginLeft = 0;
        double? childMarginTop = getChildMarginTop(childRenderBoxModel);

        if (childRenderBoxModel is RenderBoxModel) {
          childMarginLeft = childRenderBoxModel.renderStyle.marginLeft.computedValue;
          childMarginTop = getChildMarginTop(childRenderBoxModel);
        }

        // No need to add padding and border for scrolling content box.
        double outLineMainSize = renderStyle.paddingLeft.computedValue +
            renderStyle.effectiveBorderLeftWidth.computedValue +
            childMarginLeft;

        double usefulMainAxisLineJoinOffset = mainAxisLineJoinOffset;

        // RenderTextBox if have more one line, self process complete box
        // do not need parent render to add line join offset
        if (childRender is RenderTextBox && childRender.lines > 1) {
          usefulMainAxisLineJoinOffset = 0;
        } else if (childRender is RenderTextBox && runLineBox.firstLineLeftExtent > 0 && !happenLineJoin()) {
          // RenderTextBox only one line and only one InlineTextBox,
          // need make paint main axis offset -lineJoinOffset.
          // Because RenderTextBox layout use lineJoinOffset as placeholder,
          // which will make RenderTextBox paint offset lineJoinOffset,
          // when not happen line join, we need to fix it.
          outLineMainSize -= runLineBox.firstLineLeftExtent;
        }

        Offset relativeOffset = _getOffset(
            childMainPosition +
                usefulMainAxisLineJoinOffset +
                renderStyle.paddingLeft.computedValue +
                renderStyle.effectiveBorderLeftWidth.computedValue +
                childMarginLeft,
            crossAxisOffset +
                childLineExtent -
                crossAxisLineJoinOffset +
                renderStyle.paddingTop.computedValue +
                renderStyle.effectiveBorderTopWidth.computedValue +
                childMarginTop);

        // Apply position relative offset change.
        childBox.applyRelativeOffset(relativeOffset, outLineMainSize, childLeadingSpace);

        childMainPosition += childListLineMainAxisExtent + childBetweenSpace;
      }

      crossAxisOffset += runCrossAxisExtent + runBetweenSpace - crossAxisLineJoinOffset;
    }
    if (totalCrossAxisAdjust != 0) {
      _setContainerSize(adjustHeight: -totalCrossAxisAdjust);
    }
  }

  // Compute distance to baseline of flow layout.
  @override
  double? computeDistanceToBaseline() {
    double? lineDistance;
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isInline = effectiveDisplay == CSSDisplay.inline;
    // Margin does not work for inline element.
    double marginTop = !isInline ? renderStyle.marginTop.computedValue : 0;
    double marginBottom = !isInline ? renderStyle.marginBottom.computedValue : 0;
    bool isParentFlowLayout = parent is RenderFlowLayout;
    bool isDisplayInline = effectiveDisplay == CSSDisplay.inline ||
        effectiveDisplay == CSSDisplay.inlineBlock ||
        effectiveDisplay == CSSDisplay.inlineFlex;

    // Use margin bottom as baseline if layout has no children.
    if (lineBoxes.isEmpty) {
      if (isDisplayInline) {
        // Flex item baseline does not includes margin-bottom.
        lineDistance = isParentFlowLayout ? marginTop + boxSize!.height + marginBottom : marginTop + boxSize!.height;
        return lineDistance;
      } else {
        return null;
      }
    }

    // Use baseline of last line in flow layout and layout is inline-level
    // otherwise use baseline of first line.
    bool isLastLineBaseline = isParentFlowLayout && isDisplayInline;
    LogicLineBox lineMetrics = isLastLineBaseline ? lineBoxes.lines[lineBoxes.length - 1] : lineBoxes.lines[0];
    // Use the max baseline of the children as the baseline in flow layout.
    lineMetrics.inlineBoxes.forEach((LogicInlineBox childBox) {
      RenderBox child = childBox.renderObject;
      double? childMarginTop = getChildMarginTop(child);
      RenderLayoutParentData? childParentData = child.parentData as RenderLayoutParentData?;
      double? childBaseLineDistance;
      if (child is RenderBoxModel) {
        childBaseLineDistance = child.computeDistanceToBaseline();
      } else if (child is RenderTextBox) {
        // Text baseline not depends on its own parent but its grand parents.
        childBaseLineDistance =
            isLastLineBaseline ? child.computeDistanceToLastLineBaseline() : child.computeDistanceToFirstLineBaseline();
      }
      if (childBaseLineDistance != null && childParentData != null) {
        // Baseline of relative positioned element equals its original position
        // so it needs to subtract its vertical offset.
        Offset? relativeOffset;
        double childOffsetY = childParentData.offset.dy - childMarginTop;
        if (child is RenderBoxModel) {
          relativeOffset = CSSPositionedLayout.getRelativeOffset(child.renderStyle);
        }
        if (relativeOffset != null) {
          childOffsetY -= relativeOffset.dy;
        }
        // It needs to subtract margin-top cause offset already includes margin-top.
        childBaseLineDistance += childOffsetY;
        if (lineDistance != null)
          lineDistance = math.max(lineDistance!, childBaseLineDistance);
        else
          lineDistance = childBaseLineDistance;
      } else if (childBaseLineDistance == null && (child.parent as RenderBoxModel).hasSize) {
          lineDistance = (child.parent as RenderBoxModel).boxSize?.height;
      }
    });

    // If no inline child found, use margin-bottom as baseline.
    if (isDisplayInline && lineDistance != null) {
      lineDistance = lineDistance! + marginTop;
    }
    return lineDistance;
  }

  // Set the size of scrollable overflow area for flow layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSize() {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;

    for (LogicLineBox lineBox in lineBoxes.lines) {
      scrollableMainSizeOfLines.add(lineBox.maxMainAxisScrollableSizeOnLine);
      scrollableCrossSizeOfLines.add(lineBox.maxCrossAxisScrollableSizeOnLine + preLinesCrossSize);
      preLinesCrossSize += lineBox.crossAxisExtent;
    }

    // Max scrollable main size of all lines.
    double maxScrollableMainSizeOfLines = scrollableMainSizeOfLines.isEmpty
        ? 0
        : scrollableMainSizeOfLines.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

    RenderBoxModel container = isScrollingContentBox ? parent as RenderBoxModel : this;
    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableMainSizeOfChildren = maxScrollableMainSizeOfLines +
        renderStyle.paddingLeft.computedValue +
        (isScrollContainer ? renderStyle.paddingRight.computedValue : 0);

    // Max scrollable cross size of all lines.
    double maxScrollableCrossSizeOfLines = scrollableCrossSizeOfLines.isEmpty
        ? 0
        : scrollableCrossSizeOfLines.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableCrossSizeOfChildren = maxScrollableCrossSizeOfLines +
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
  }

  // Get distance from top to baseline of child including margin.
  double _getChildAscent(RenderBox child) {
    // Distance from top to baseline of child.
    double? childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    double? childMarginTop = 0;
    double? childMarginBottom = 0;
    if (child is RenderBoxModel) {
      childMarginTop = getChildMarginTop(child);
      childMarginBottom = getChildMarginBottom(child);
    }

    Size? childSize = _getChildSize(child);

    double baseline = parent is RenderFlowLayout
        ? childMarginTop + childSize!.height + childMarginBottom
        : childMarginTop + childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;

    return extentAboveBaseline;
  }

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? _getChildSize(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      return child.boxSize;
    } else if (child is RenderTextBox) {
      return child.boxSize;
    } else if (child.hasSize) {
      // child is WidgetElement.
      return child.size;
    }
    return null;
  }

  bool _isLineHeightValid(RenderBox child) {
    if (child is RenderTextBox) {
      return true;
    } else if (child is RenderBoxModel) {
      CSSDisplay? childDisplay = child.renderStyle.display;
      return childDisplay == CSSDisplay.inline ||
          childDisplay == CSSDisplay.inlineBlock ||
          childDisplay == CSSDisplay.inlineFlex;
    }
    return false;
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

  bool isBlockLevel(RenderBox? box) {
    return isParamsLevelNode(box, [CSSDisplay.block, CSSDisplay.flex]);
  }

  bool isInlineBlockLevel(RenderBox? box) {
    return isParamsLevelNode(box, [CSSDisplay.inlineBlock, CSSDisplay.inlineFlex]);
  }

  bool isInlineLevel(RenderBox? box) {
    return isParamsLevelNode(box, [CSSDisplay.inline]);
  }

  bool isJoinBox(RenderBox? box) {
    return !isBlockLevel(box) && !isInlineBlockLevel(box);
  }

  bool isInlineBox(RenderBox? box) {
    return isInlineBlockLevel(box) || isInlineBlockLevel(box);
  }

  bool isParamsLevelNode(RenderBox? box, List<CSSDisplay> params) {
    if (box is RenderBoxModel || box is RenderPositionPlaceholder) {
      RenderStyle? childRenderStyle = _getChildRenderStyle(box!);
      if (childRenderStyle != null) {
        CSSDisplay? childDisplay = childRenderStyle.display;
        return params.indexWhere((element) => element == childDisplay) != -1;
      }
    }
    return false;
  }

  bool isCanLineJoinChild(RenderBox? child) {
    return (child is RenderTextBox || !isBlockLevel(child));
  }

  // @Todo this is bad case need optimization
  /// \-------------------\ [span1] [runLine last child]
  /// \AAAAAAAAAAAAAAAAAAA\ [lineMainExtent]
  /// \AA [ leftWidth ]   \
  /// \-------------------\
  /// \-------------------\ [span2]
  /// \BBBBBB-------------\
  /// \-------------------\
  /// If last render hase more than one line, the render last line can happen line join
  /// but parent layout just use the line preLine width, to break.
  bool isHappenSpecialConstraints() {
    if (constraints is InlineBoxConstraints &&
        (constraints as InlineBoxConstraints).leftWidth < (constraints as InlineBoxConstraints).lineMainExtent) {
      return true;
    }
    return false;
  }

  bool happenLineJoin() {
    LogicInlineBox? child = lineBoxes.first?.first;
    double firstLineLastSpace = lineBoxes.mainAxisLimit - firstLineExtent;
    if (lineBoxes.lineSize > 1 &&
        firstLineExtent > 0 &&
        lineBoxes.firstLinePureMainAxisExtent > 0 &&
        lineBoxes.firstLinePureMainAxisExtent <= firstLineLastSpace &&
        !isBreakForBlock(child?.renderObject)) {
      return true;
    }

    if (lineBoxes.lineSize == 1 && firstLineExtent > 0) {
      RenderObject? lastRenderObject = lineBoxes.first?.last?.renderObject;
      RenderObject? firstRenderObject = lineBoxes.first?.first?.renderObject;
      if (lastRenderObject is RenderFlowLayout && lastRenderObject.happenLineJoin()) {
        return true;
      }
      if (firstRenderObject is RenderFlowLayout && firstRenderObject.happenLineJoin()) {
        return true;
      }
    }

    return false;
  }

  double getChildMarginTop(RenderBox? child) {
    if (child == null || child is! RenderBoxModel) {
      return 0;
    }
    if (child.isScrollingContentBox) {
      return 0;
    }
    double result = child.renderStyle.collapsedMarginTop;
    return result;
  }

  double getChildMarginBottom(RenderBox? child) {
    if (child == null || child is! RenderBoxModel) {
      return 0;
    }
    if (child.isScrollingContentBox) {
      return 0;
    }
    return child.renderStyle.collapsedMarginBottom;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    return defaultHitTestChildren(result, position: position);
  }

  static double getPureMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
    }

    Size childSize = getChildSize(child) ?? Size.zero;

    // For line break judge, when inline element have chance to line join
    if (child is RenderFlowLayout && child.firstLineExtent > 0) {
      return child.wrapOutContentSizeRight(Size(child.lastLineExtent, child.boxSize?.height ?? 0)).width +
          marginHorizontal;
    }

    // For TextBox only one line && lineJoin, need give pure with. Else will make parent size error, when parent
    // as display inline, and join to other line
    if (child is RenderTextBox && child.lines == 1 && child.happenLineJoin()) {
      return child.firstInlineBox.width + marginHorizontal;
    }

    return childSize.width + marginHorizontal;
  }

  static Size? getChildSize(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      return child.boxSize;
    } else if (child is RenderTextBox) {
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
    properties.add(DiagnosticsProperty('lineBoxes', lineBoxes));
  }
}

enum BoxCrossSizeType {
  NORMAL,
  AUTO,
}

class RenderLineBoxes {
  final List<LogicLineBox> _lineBoxList = [];
  double mainAxisLimit = 0;
  int maxLines = webfTextMaxLines;

  addLineBox(LogicLineBox lineBox) {
    if (_lineBoxList.isEmpty) {
      lineBox.isFirst = true;
    }
    _lineBoxList.add(lineBox);
  }

  LogicLineBox? get first {
    return _lineBoxList.isNotEmpty ? _lineBoxList[0] : null;
  }

  bool happenVisualOverflow() {
    return _lineBoxList.where((element) => element.happenVisualOverflow()).isNotEmpty;
  }

  double get firstLinePureMainAxisExtent {
    return _lineBoxList.first.mainAxisExtentWithoutLineJoin;
  }

  deleteLineBoxes() {}

  bool happenTextBreakMoreLine() {
    for (int i = 0; i < _lineBoxList.length - 1 && _lineBoxList.length > 1; i++) {
      LogicInlineBox? lineLastBox = _lineBoxList[i].last;
      LogicInlineBox? nextLineFirstBox = _lineBoxList[i + 1].first;
      if (lineLastBox is LogicTextInlineBox &&
          nextLineFirstBox is LogicTextInlineBox &&
          lineLastBox.renderObject == nextLineFirstBox.renderObject) {
        return true;
      }
    }
    return false;
  }

  bool happenBreakForShortSpace() {
    return _lineBoxList.where((element) => element.breakForExtentShort).toList().isNotEmpty;
  }

  clear() {
    _lineBoxList.forEach((item) {
      item.dispose();
    });
    _lineBoxList.clear();
  }

  double _crossAxisSizeByType(BoxCrossSizeType type) {
    double size = 0;
    int remainLines = maxLines;
    for (int i = 0; i < _lineBoxList.length && remainLines > 0; i++) {
      LogicLineBox lineBox = _lineBoxList[i];
      size += (type == BoxCrossSizeType.NORMAL ? lineBox.crossAxisExtent : lineBox.lineCrossAxisAutoSize);
      remainLines -= lineBox.innerLineLength;
      if (remainLines <= 0 && i + 1 < _lineBoxList.length) {  // last lineBox happenLineJoin, add crossAxisExtent
        LogicLineBox nextLineBox = _lineBoxList[i + 1];
        if (nextLineBox.happenLineJoin) {
          size += (type == BoxCrossSizeType.NORMAL ? nextLineBox.crossAxisExtent : nextLineBox.lineCrossAxisAutoSize);
        }
        break;
      }
    }
    return size;
  }

  int get lineSize {
    return _lineBoxList.length;
  }

  bool get isEmpty {
    return lineSize == 0;
  }

  List<LogicLineBox> get lines {
    return _lineBoxList;
  }

  int get length => _lineBoxList.length;

  int get innerLineLength {
    if (_lineBoxList.isEmpty) {
      return 0;
    }
    return _lineBoxList.map((lineBox) => lineBox.innerLineLength).reduce((value, element) => value + element);
  }

  LogicLineBox? get last {
    if (_lineBoxList.isNotEmpty) return _lineBoxList.last;
    return null;
  }

  @override
  String toString() {
    return 'RenderLineBoxes(lines: $lineSize)';
  }

  // @TODO: add cache to avoid recalculate in one layout stage.
  double get maxMainAxisSize {
    return _lineBoxList
        .map((box) => box.mainAxisExtent > mainAxisLimit ? mainAxisLimit : box.mainAxisExtent)
        .reduce((value, extent) => value < extent ? extent : value);
  }

  double get maxMainAxisSizeWithoutLineJoin {
    return _lineBoxList
        .map((box) => box.mainAxisExtentWithoutLineJoin)
        .reduce((value, extent) => value < extent ? extent : value);
  }

  // @TODO: add cache to avoid recalculate in one layout stage.
  // Find the size in the cross axis of lines.
  double get crossAxisSize {
    return _crossAxisSizeByType(BoxCrossSizeType.NORMAL);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double get mainAxisAutoSize {
    return _lineBoxList
        .map((e) => e.lineMainAxisAutoSize)
        .reduce((double curr, double next) => curr > next ? curr : next);
  }

  // Get auto min size in the cross axis which equals the cross axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double get crossAxisAutoSize {
    return _crossAxisSizeByType(BoxCrossSizeType.AUTO);
  }
}

// Render flex layout with self repaint boundary.
class RenderRepaintBoundaryFlowLayout extends RenderFlowLayout {
  RenderRepaintBoundaryFlowLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(
          children: children,
          renderStyle: renderStyle,
        );

  @override
  bool get isRepaintBoundary => true;
}
