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
  List<RunMetrics> _lineBoxMetrics = <RunMetrics>[];

  @override
  void dispose() {
    super.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    _lineBoxMetrics.clear();
  }

  @override
  void setupParentData(RenderBox child) {
    child.parentData = RenderLayoutParentData();
    if (child is RenderBoxModel) {
      child.parentData = CSSPositionedLayout.getPositionParentData(child, child.parentData as RenderLayoutParentData);
    }
  }

  double _getMainAxisExtent(RenderBox child) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._getMainAxisExtent');
    }

    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
    }

    Size childSize = _getChildSize(child) ?? Size.zero;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }

    return childSize.width + marginHorizontal;
  }

  double _getCrossAxisExtent(RenderBox child) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._getCrossAxisExtent');
    }
    bool isLineHeightValid = _isLineHeightValid(child);
    double? lineHeight = isLineHeightValid ? _getLineHeight(child) : 0;
    double marginVertical = 0;

    if (child is RenderBoxModel) {
      marginVertical = _getChildMarginTop(child) + _getChildMarginBottom(child);
    }
    Size childSize = _getChildSize(child) ?? Size.zero;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }

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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.beforeLayout');
    }

    beforeLayout();

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }

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

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._layoutChildren');
    }

    // Layout non positioned element (include element in flow and
    // placeholder of positioned element).
    _layoutChildren(_nonPositionedChildren);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.initOverflowLayout');
    }

    // init overflowLayout size
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.addOverflowLayoutFromChildren');
    }

    // calculate all flexItem child overflow size
    addOverflowLayoutFromChildren(_nonPositionedChildren);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.applyPositionedChildOffset');
    }

    // Set offset of positioned element after flex box size is set.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      addOverflowLayoutFromChild(child);
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.applyStickyChildOffset');
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

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.didLayout');
    }

    didLayout();

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }
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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._computeRunMetrics');
    }

    List<RunMetrics> _runMetrics = _computeRunMetrics(children);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._setContainerSize');
    }

    // Set container size.
    _setContainerSize(_runMetrics);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._adjustChildrenSize');
    }

    // Adjust children size which depends on the container size.
    _adjustChildrenSize(_runMetrics);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._setChildrenOffset');
    }

    // Set children offset based on alignment properties.
    _setChildrenOffset(_runMetrics);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._setMaxScrollableSize');
    }

    // Set the size of scrollable overflow area for flow layout.
    _setMaxScrollableSize(_runMetrics);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }
  }

  // Layout children in normal flow order to calculate metrics of lines according to its constraints
  // and alignment properties.
  List<RunMetrics> _computeRunMetrics(
    List<RenderBox> children,
  ) {
    List<RunMetrics> _runMetrics = <RunMetrics>[];
    double mainAxisLimit = renderStyle.contentMaxConstraintsWidth;

    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    RenderBox? preChild;
    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;
    Map<int?, RenderBox> runChildren = {};


    WhiteSpace? whiteSpace = renderStyle.whiteSpace;


    children.forEachIndexed((int index, RenderBox child) {
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._computeRunMetrics.child[$index]');
      }

      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      int childNodeId = child.hashCode;

      BoxConstraints childConstraints;
      if (child is RenderBoxModel) {
        childConstraints = child.getConstraints();
      } else if (child is RenderTextBox) {
        childConstraints = child.getConstraints();
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
        bool parentUseSize = !(child is RenderBoxModel && child.isSizeTight || child is RenderPositionPlaceholder);

        if (enableWebFProfileTracking) {
          WebFProfiler.instance.pauseCurrentLayoutOp();
        }

        child.layout(childConstraints, parentUsesSize: parentUseSize);

        if (enableWebFProfileTracking) {
          WebFProfiler.instance.resumeCurrentLayoutOp();
        }
      }

      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (enableWebFProfileTracking) {
        WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.computeChildMainAxisExtent');
      }

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
      if (runChildren.isNotEmpty &&
          // Current is block.
          (_isChildBlockLevel(child) ||
              // Previous is block.
              _isChildBlockLevel(preChild) ||
              // Line length is exceed container.
              // The white-space property not only specifies whether and how white space is collapsed
              // but only specifies whether lines may wrap at unforced soft wrap opportunities
              // https://www.w3.org/TR/css-text-3/#line-breaking
              (whiteSpace != WhiteSpace.nowrap && (runMainAxisExtent + childMainAxisExtent > mainAxisLimit)) ||
              // Previous is linebreak.
              preChild is RenderLineBreak)) {
        _runMetrics.add(RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          maxSizeAboveBaseline,
          runChildren,
        ));
        runChildren = {};
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;
      }
      runMainAxisExtent += childMainAxisExtent;

      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackLayoutStep();
        WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout.computeChildCrossAxisExtent');
      }

      // Calculate baseline extent of layout box.
      RenderStyle? childRenderStyle = _getChildRenderStyle(child);
      VerticalAlign verticalAlign = VerticalAlign.baseline;
      if (childRenderStyle != null) {
        verticalAlign = childRenderStyle.verticalAlign;
      }

      bool isLineHeightValid = _isLineHeightValid(child);

      // Vertical align is only valid for inline box.
      if (verticalAlign == VerticalAlign.baseline && isLineHeightValid) {
        double childMarginTop = 0;
        double childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = _getChildMarginTop(child);
          childMarginBottom = _getChildMarginBottom(child);
        }

        Size childSize = _getChildSize(child)!;
        // When baseline of children not found, use boundary of margin bottom as baseline.
        double childAscent = _getChildAscent(child);
        double extentAboveBaseline = childAscent;
        double extentBelowBaseline = childMarginTop + childSize.height + childMarginBottom - childAscent;

        maxSizeAboveBaseline = math.max(
          extentAboveBaseline,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          extentBelowBaseline,
          maxSizeBelowBaseline,
        );
        childCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      }

      if (runCrossAxisExtent > 0 && childCrossAxisExtent > 0) {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      } else if (runCrossAxisExtent < 0 && childCrossAxisExtent < 0) {
        runCrossAxisExtent = math.min(runCrossAxisExtent, childCrossAxisExtent);
      } else {
        runCrossAxisExtent = runCrossAxisExtent + childCrossAxisExtent;
      }

      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackLayoutStep();
      }

      runChildren[childNodeId] = child;

      childParentData.runIndex = _runMetrics.length;
      preChild = child;

      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackLayoutStep();
      }
    });

    if (runChildren.isNotEmpty) {
      _runMetrics.add(RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        maxSizeAboveBaseline,
        runChildren,
      ));
    }

    _lineBoxMetrics = _runMetrics;

    return _runMetrics;
  }

  // Find the size in the cross axis of lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsCrossSize(
    List<RunMetrics> _runMetrics,
  ) {
    double crossSize = 0;
    for (RunMetrics run in _runMetrics) {
      crossSize += run.crossAxisExtent;
    }
    return crossSize;
  }

  // Find the max size in the main axis of lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsMaxMainSize(
    List<RunMetrics> _runMetrics,
  ) {
    // Find the max size of lines.
    RunMetrics maxMainSizeMetrics = _runMetrics.reduce((RunMetrics curr, RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Set flex container size according to children size.
  void _setContainerSize(
    List<RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    double runMaxMainSize = _getRunsMaxMainSize(_runMetrics);
    double runCrossSize = _getRunsCrossSize(_runMetrics);

    Size layoutContentSize = getContentSize(
      contentWidth: runMaxMainSize,
      contentHeight: runCrossSize,
    );

    size = getBoxSize(layoutContentSize);

    minContentWidth = _getMainAxisAutoSize(_runMetrics);
    minContentHeight = _getCrossAxisAutoSize(_runMetrics);
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
  void _adjustChildrenSize(
    List<RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) return;

    // Element of inline-block will shrink to its maximum children size
    // when its width is not specified.
    bool isInlineBlock = renderStyle.effectiveDisplay == CSSDisplay.inlineBlock;
    if (isInlineBlock) {
      for (int i = 0; i < _runMetrics.length; ++i) {
        final RunMetrics metrics = _runMetrics[i];
        final Map<int?, RenderBox> runChildren = metrics.runChildren;
        final List<RenderBox> runChildrenList = runChildren.values.toList();

        for (RenderBox child in runChildrenList) {
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
  void _setChildrenOffset(
    List<RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) return;

    double runLeadingSpace = 0;
    double runBetweenSpace = 0;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize = contentSize.width;

    // Set offset of children in each line.
    for (int i = 0; i < _runMetrics.length; ++i) {
      final RunMetrics metrics = _runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final Map<int?, RenderBox> runChildren = metrics.runChildren;
      final List<RenderBox> runChildrenList = runChildren.values.toList();
      final int runChildrenCount = metrics.runChildren.length;
      final double mainAxisFreeSpace = math.max(0.0, mainAxisContentSize - runMainAxisExtent);

      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      // Whether inline level child exists in this run.
      bool runContainInlineChild = true;

      int? firstChildKey = runChildren.keys.elementAt(0);
      RenderBox? firstChild = runChildren[firstChildKey];
      // Block level and inline level child can not exists at the same run,
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

      for (RenderBox child in runChildrenList) {
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
        final double childCrossAxisOffset =
            isPositionPlaceholder(child) ? 0 : _getChildCrossAxisOffset(runCrossAxisExtent, childCrossAxisExtent);

        Size? childSize = _getChildSize(child);
        // Child line extent calculated according to vertical align.
        double childLineExtent = childCrossAxisOffset;

        bool isLineHeightValid = _isLineHeightValid(child);
        if (isLineHeightValid) {
          // Distance from top to baseline of child.
          double childAscent = _getChildAscent(child);

          RenderStyle childRenderStyle = _getChildRenderStyle(child)!;
          VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

          // Leading between height of line box's content area and line height of line box.
          double lineBoxLeading = 0;
          double? lineBoxHeight = _getLineHeight(this);
          if (lineBoxHeight != null) {
            lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
          }

          switch (verticalAlign) {
            case VerticalAlign.baseline:
              childLineExtent = lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case VerticalAlign.top:
              childLineExtent = 0;
              break;
            case VerticalAlign.bottom:
              childLineExtent = (lineBoxHeight ?? runCrossAxisExtent) - childSize!.height;
              break;
            // @TODO: Vertical align middle needs to calculate the baseline of the parent box plus
            //  half the x-height of the parent from W3C spec currently flutter lack the api to calculate x-height of glyph.
            //  case VerticalAlign.middle:
            //  break;
          }
          // Child should not exceed over the top of parent.
          childLineExtent = childLineExtent < 0 ? 0 : childLineExtent;
        }

        double? childMarginLeft = 0;
        double? childMarginTop = 0;

        RenderBoxModel? childRenderBoxModel;
        if (child is RenderBoxModel) {
          childRenderBoxModel = child;
        } else if (child is RenderPositionPlaceholder) {
          childRenderBoxModel = child.positioned;
        }

        if (childRenderBoxModel is RenderBoxModel) {
          childMarginLeft = childRenderBoxModel.renderStyle.marginLeft.computedValue;
          childMarginTop = _getChildMarginTop(childRenderBoxModel);
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
      }

      crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
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
    if (_lineBoxMetrics.isEmpty) {
      if (isDisplayInline) {
        // Flex item baseline does not includes margin-bottom.
        Size? boxSize = isScrollingContentBox ? (parent as RenderBoxModel).boxSize : this.boxSize;
        lineDistance = isParentFlowLayout ? marginTop + boxSize!.height + marginBottom : marginTop + boxSize!.height;
        return lineDistance;
      } else {
        return null;
      }
    }

    // Use baseline of last line in flow layout and layout is inline-level
    // otherwise use baseline of first line.
    bool isLastLineBaseline = isParentFlowLayout && isDisplayInline;
    RunMetrics lineMetrics = isLastLineBaseline ? _lineBoxMetrics[_lineBoxMetrics.length - 1] : _lineBoxMetrics[0];
    // Use the max baseline of the children as the baseline in flow layout.
    lineMetrics.runChildren.forEach((int? hashCode, RenderBox child) {
      double? childMarginTop = child is RenderBoxModel ? _getChildMarginTop(child) : 0;
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
      }
    });

    // If no inline child found, use margin-bottom as baseline.
    if (isDisplayInline && lineDistance != null) {
      lineDistance = lineDistance! + marginTop;
    }
    return lineDistance;
  }

  // Record the main size of all lines.
  void _recordRunsMainSize(RunMetrics runMetrics, List<double> runMainSize) {
    Map<int?, RenderBox> runChildren = runMetrics.runChildren;
    double runMainExtent = 0;
    void iterateRunChildren(int? hashCode, RenderBox runChild) {
      double runChildMainSize = 0.0;
      if (runChild is RenderTextBox) {
        runChildMainSize = runChild.minContentWidth;
      }
      // Should add horizontal margin of child to the main axis auto size of parent.
      if (runChild is RenderBoxModel) {
        runChildMainSize = runChild.boxSize?.width ?? 0.0;
        double childMarginLeft = runChild.renderStyle.marginLeft.computedValue;
        double childMarginRight = runChild.renderStyle.marginRight.computedValue;
        runChildMainSize += childMarginLeft + childMarginRight;
      }
      runMainExtent += runChildMainSize;
    }

    runChildren.forEach(iterateRunChildren);
    runMainSize.add(runMainExtent);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(
    List<RunMetrics> runMetrics,
  ) {
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

  // Record the cross size of all lines.
  void _recordRunsCrossSize(RunMetrics runMetrics, List<double> runCrossSize) {
    Map<int?, RenderBox> runChildren = runMetrics.runChildren;
    double runCrossExtent = 0;
    List<double> runChildrenCrossSize = [];
    void iterateRunChildren(int? hashCode, RenderBox runChild) {
      double runChildCrossSize = 0.0;
      if (runChild is RenderTextBox) {
        runChildCrossSize = runChild.minContentHeight;
      } else if (runChild is RenderBoxModel) {
        runChildCrossSize = runChild.boxSize?.height ?? 0.0;
      }
      runChildrenCrossSize.add(runChildCrossSize);
    }

    runChildren.forEach(iterateRunChildren);
    runCrossExtent = runChildrenCrossSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    runCrossSize.add(runCrossExtent);
  }

  // Get auto min size in the cross axis which equals the cross axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getCrossAxisAutoSize(
    List<RunMetrics> runMetrics,
  ) {
    double autoMinSize = 0;
    // Cross size of each run.
    List<double> runCrossSize = [];

    // Calculate the max cross size of all runs.
    for (RunMetrics runMetrics in runMetrics) {
      _recordRunsCrossSize(runMetrics, runCrossSize);
    }

    // Get the sum of lines.
    for (double crossSize in runCrossSize) {
      autoMinSize += crossSize;
    }

    return autoMinSize;
  }

  // Set the size of scrollable overflow area for flow layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSize(List<RunMetrics> runMetrics) {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;

    for (RunMetrics runMetric in runMetrics) {
      Map<int?, RenderBox> runChildren = runMetric.runChildren;

      List<RenderBox> runChildrenList = [];
      // Scrollable main size collection of each child in the line.
      List<double> scrollableMainSizeOfChildren = [];
      // Scrollable cross size collection of each child in the line.
      List<double> scrollableCrossSizeOfChildren = [];

      void iterateRunChildren(int? hashCode, RenderBox child) {
        // Total main size of previous siblings.
        double preSiblingsMainSize = 0;
        for (RenderBox sibling in runChildrenList) {
          if (sibling is RenderBoxModel) {
            preSiblingsMainSize += sibling.boxSize!.width;
          } else if (sibling is RenderTextBox) {
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

          // Add offset of margin.
          childOffsetX += childRenderStyle.marginLeft.computedValue + childRenderStyle.marginRight.computedValue;
          childOffsetY += _getChildMarginTop(child) + _getChildMarginBottom(child);

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
        } else if (child is RenderTextBox) {
          childScrollableSize = child.boxSize!;
        }

        scrollableMainSizeOfChildren.add(preSiblingsMainSize + childScrollableSize.width + childOffsetX);
        scrollableCrossSizeOfChildren.add(childScrollableSize.height + childOffsetY);
        runChildrenList.add(child);
      }

      runChildren.forEach(iterateRunChildren);

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
    }

    // Max scrollable main size of all lines.
    double maxScrollableMainSizeOfLines = scrollableMainSizeOfLines.reduce((double curr, double next) {
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
    double maxScrollableCrossSizeOfLines = scrollableCrossSizeOfLines.reduce((double curr, double next) {
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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._getChildAscent');
    }
    // Distance from top to baseline of child.
    double? childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    double? childMarginTop = 0;
    double? childMarginBottom = 0;
    if (child is RenderBoxModel) {
      childMarginTop = _getChildMarginTop(child);
      childMarginBottom = _getChildMarginBottom(child);
    }

    Size? childSize = _getChildSize(child);

    double baseline = parent is RenderFlowLayout
        ? childMarginTop + childSize!.height + childMarginBottom
        : childMarginTop + childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }

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
      childRenderStyle = child.positioned!.renderStyle;
    }
    return childRenderStyle;
  }

  bool _isChildBlockLevel(RenderBox? child) {
    if (child is RenderBoxModel || child is RenderPositionPlaceholder) {
      RenderStyle? childRenderStyle = _getChildRenderStyle(child!);
      if (childRenderStyle != null) {
        CSSDisplay? childDisplay = childRenderStyle.display;
        return childDisplay == CSSDisplay.block || childDisplay == CSSDisplay.flex;
      }
    }
    return false;
  }

  double _getChildMarginTop(RenderBoxModel child) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderFlowLayout._getChildMarginTop');
    }
    if (child.isScrollingContentBox) {
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackLayoutStep();
      }

      return 0;
    }
    double result = child.renderStyle.collapsedMarginTop;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }
    return result;
  }

  double _getChildMarginBottom(RenderBoxModel child) {
    if (child.isScrollingContentBox) {
      return 0;
    }
    return child.renderStyle.collapsedMarginBottom;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    return defaultHitTestChildren(result, position: position);
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
