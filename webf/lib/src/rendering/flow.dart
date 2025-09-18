/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'inline_formatting_context.dart';
import 'line_box.dart';
import 'text.dart';
import 'event_listener.dart';
import 'package:webf/src/foundation/logger.dart';

// Toggle for verbose RenderFlowLayout sizing logs.
bool debugLogFlowEnabled = false;

// Pretty format for BoxConstraints in debug logs.
String _fmtC(BoxConstraints c) =>
    'C[minW=${c.minWidth.toStringAsFixed(1)}, maxW=${c.maxWidth.isFinite ? c.maxWidth.toStringAsFixed(1) : '∞'}, '
    'minH=${c.minHeight.toStringAsFixed(1)}, maxH=${c.maxHeight.isFinite ? c.maxHeight.toStringAsFixed(1) : '∞'}]';

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
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    addAll(children);
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
      // If IFC measured a visual size for this node, lay it out tightly to that size
      if (establishIFC && _inlineFormattingContext != null) {
        final Size? measured = _inlineFormattingContext!.measuredVisualSizeOf(node);
        if (measured != null) {
          node.layout(BoxConstraints.tight(measured), parentUsesSize: true);
          return;
        }
      }
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
    // If using inline formatting context, delegate painting to it
    if (establishIFC && _inlineFormattingContext != null) {
      // Calculate content offset (adjust for padding and border)
      final contentOffset = Offset(
        offset.dx + renderStyle.paddingLeft.computedValue + renderStyle.effectiveBorderLeftWidth.computedValue,
        offset.dy + renderStyle.paddingTop.computedValue + renderStyle.effectiveBorderTopWidth.computedValue,
      );

      if (debugLogFlowEnabled) {
        final tag = renderStyle.target.tagName.toLowerCase();
        renderingLogger.finer('[Flow] <$tag> paint IFC content at (${contentOffset.dx.toStringAsFixed(2)},'
            '${contentOffset.dy.toStringAsFixed(2)})');
      }

      // Paint the inline formatting context content
      _inlineFormattingContext!.paint(context, contentOffset);

      // Paint ALL positioned descendants (not only direct children) on top of IFC text.
      _paintPositionedDescendants(context, offset, this);
    } else {
      // Regular flow layout painting: skip RenderTextBox unless it paints itself (non-IFC)
      for (int i = 0; i < paintingOrder.length; i++) {
        RenderBox child = paintingOrder[i];
        bool shouldPaint = !isPositionPlaceholder(child);

        // Skip text boxes that are handled by IFC, but paint text boxes that paint themselves
        if (child is RenderTextBox) {
          shouldPaint = shouldPaint && (child as RenderTextBox).paintsSelf;
        }

        if (shouldPaint) {
          final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
          if (child.hasSize) {
            if (debugLogFlowEnabled) {
              String name;
              if (child is RenderBoxModel) {
                name = child.renderStyle.target.tagName.toLowerCase();
              } else {
                name = child.runtimeType.toString();
              }
              final dx = (childParentData.offset + offset).dx.toStringAsFixed(2);
              final dy = (childParentData.offset + offset).dy.toStringAsFixed(2);
              renderingLogger.finer('[Flow] paint <$name> at ($dx,$dy) size='
                  '(${child.size.width.toStringAsFixed(2)}x${child.size.height.toStringAsFixed(2)})');
            }
            context.paintChild(child, childParentData.offset + offset);
          } else if (debugLogFlowEnabled) {
            String name;
            if (child is RenderBoxModel) {
              name = child.renderStyle.target.tagName.toLowerCase();
            } else {
              name = child.runtimeType.toString();
            }
            renderingLogger.finer('[Flow] skip paint <$name>: hasSize=false');
          }
        }
      }
    }
  }

  // Recursively paint positioned descendants within this subtree. This ensures
  // absolutely/fixed positioned elements nested inside inline content are painted
  // when the container uses IFC for text.
  void _paintPositionedDescendants(PaintingContext context, Offset ancestorOffset, RenderBox parent) {
    RenderBox? first;
    RenderBox? next(RenderBox c) {
      if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
        return (parent as dynamic).childAfter(c);
      }
      return null;
    }
    if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
      first = (parent as dynamic).firstChild;
    } else if (parent is RenderObjectWithChildMixin<RenderBox>) {
      first = (parent as dynamic).child;
    }

    RenderBox? child = first;
    while (child != null) {
      // Determine paint offset accumulation. Many WebF render objects use
      // RenderLayoutParentData or subclasses; fall back to BoxParentData.
      Offset childOffset = Offset.zero;
      final Object? pd = child.parentData;
      if (pd is ContainerBoxParentData<RenderBox>) {
        childOffset = pd.offset;
      } else if (pd is BoxParentData) {
        childOffset = pd.offset;
      }
      final Offset paintOffset = ancestorOffset + childOffset;

      if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
        if (child.hasSize) {
          if (debugLogFlowEnabled) {
            final tag = child.renderStyle.target.tagName.toLowerCase();
            renderingLogger.finer('[Flow] paint positioned <$tag> at '
                '(${paintOffset.dx.toStringAsFixed(2)},${paintOffset.dy.toStringAsFixed(2)}) size='
                '(${child.size.width.toStringAsFixed(2)}x${child.size.height.toStringAsFixed(2)})');
          }
          context.paintChild(child, paintOffset);
        } else if (debugLogFlowEnabled) {
          final tag = child.renderStyle.target.tagName.toLowerCase();
          renderingLogger.finer('[Flow] skip paint positioned <$tag>: hasSize=false');
        }
      }

      // Recurse into subtree to find deeper positioned descendants.
      _paintPositionedDescendants(context, paintOffset, child);

      child = next(child!);
    }
  }

  @override
  void performLayout() {
    try {
      doingThisLayout = true;

      _doPerformLayout();

      if (needsRelayout) {
        _doPerformLayout();
        needsRelayout = false;
      }

      doingThisLayout = false;
    } catch (e, stack) {
      if (!kReleaseMode) {
        layoutExceptions = '$e\n$stack';
        reportException('performLayout', e, stack);
      }
      doingThisLayout = false;
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
    if (debugLogFlowEnabled) {
      final tag = renderStyle.target.tagName.toLowerCase();
      renderingLogger.fine('[Flow] <$tag> establishIFC=$_establishIFC constraints=$constraints contentConstraints=$contentConstraints');
    }
    if (_establishIFC) {
      _inlineFormattingContext = InlineFormattingContext(container: this);
    }

    List<RenderBoxModel> positionedChildren = [];
    List<RenderBox> nonPositionedChildren = [];
    List<RenderBoxModel> stickyChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
        positionedChildren.add(child);
      } else {
        nonPositionedChildren.add(child);
        if (child is RenderBoxModel && CSSPositionedLayout.isSticky(child)) {
          stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    // Layout non positioned element (include element in flow and
    // placeholder of positioned element).
    _layoutChildren(nonPositionedChildren);

    // init overflowLayout size
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // calculate all flexItem child overflow size
    addOverflowLayoutFromChildren(nonPositionedChildren);

    // Set offset of positioned element after flex box size is set.
    for (RenderBoxModel child in positionedChildren) {
      Element? containingBlockElement = child.renderStyle.target.getContainingBlockElement();
      if (containingBlockElement == null || containingBlockElement.attachedRenderer == null) continue;

      if (child.renderStyle.position == CSSPositionType.absolute) {
        containingBlockElement.attachedRenderer!.positionedChildren.add(child);
        if (!containingBlockElement.attachedRenderer!.needsLayout) {
          CSSPositionedLayout.applyPositionedChildOffset(containingBlockElement.attachedRenderer!, child);
        }
      } else {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);
      }
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      addOverflowLayoutFromChild(child);
    }

    // Set offset of sticky element on each layout.
    for (RenderBoxModel child in stickyChildren) {
      RenderBoxModel scrollContainer = child.findScrollContainer()!;
      // Sticky offset depends on the layout of scroll container, delay the calculation of
      // sticky offset to the layout stage of scroll container if its not layouted yet
      // due to the layout order of Flutter renderObject tree is from down to up.
      if (scrollContainer.hasSize) {
        CSSPositionedLayout.applyStickyChildOffset(scrollContainer, child);
      }
      if (scrollContainer is RenderLayoutBox) {
        scrollContainer.stickyChildren.add(child);
      } else if (scrollContainer is RenderWidget) {
        scrollContainer.stickyChildren.add(child);
      }
    }

    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    if (isScrollContainer) {
      // Calculate the offset of its sticky children.
      for (RenderBoxModel stickyChild in stickyChildren) {
        CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
      }
    }

    didLayout();
  }

  void _setContainerSizeFromIFC(Size ifcSize) {
    InlineFormattingContext inlineFormattingContext = _inlineFormattingContext!;
    Size layoutContentSize = getContentSize(
      contentWidth: ifcSize.width,
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

    if (debugLogFlowEnabled) {
      renderingLogger.fine('[Flow] IFC size=${ifcSize.width.toStringAsFixed(1)}×${ifcSize.height.toStringAsFixed(1)} '
          'contentConstraints=${contentConstraints == null ? 'null' : contentConstraints!.toString()} '
          'final contentSize=${layoutContentSize.width.toStringAsFixed(1)}×${layoutContentSize.height.toStringAsFixed(1)} '
          'box=${size.width.toStringAsFixed(1)}×${size.height.toStringAsFixed(1)}');
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

    if (establishIFC) {
      assert(_inlineFormattingContext != null);

      Size layoutSize = _inlineFormattingContext!.layout(contentConstraints!);

      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow] IFC layout with constraints=${contentConstraints} -> ${layoutSize}');
      }

      // Ensure all render objects inside IFC are laid out to avoid
      // devtools/semantics traversals encountering NEEDS-LAYOUT nodes.
      _ensureChildrenLaidOutRecursively(this);

      _setContainerSizeFromIFC(layoutSize);

      // Set the baseline value for this box
      calculateBaseline();

      // Set the size of scrollable overflow area for inline formatting context.
      _setMaxScrollableSizeFromIFC();
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
      if (disp == CSSDisplay.flex || disp == CSSDisplay.inlineFlex) {
        // Skip stretching flex containers to preserve correct shrink-to-fit of the inline-block.
        continue;
      }

      // Relayout the child wrapper with the container's content width tightly,
      // so an empty block (no content) still expands to the intended width.
      // Let height be determined by the child (e.g., specified height).
      final BoxConstraints stretch = BoxConstraints(
        minWidth: targetWidth,
        maxWidth: targetWidth,
        minHeight: 0,
        maxHeight: double.infinity,
      );
      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow] -> reflow block auto-width child ${child.runtimeType} to contentWidth='
            '${targetWidth.toStringAsFixed(2)} with ${_fmtC(stretch)}');
      }
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
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

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

      // Whether child need to layout.
      bool isChildNeedsLayout = true;

      if (child.hasSize &&
          !needsRelayout &&
          (childConstraints == child.constraints) &&
          ((child is RenderBoxModel && !child.needsLayout))) {
        isChildNeedsLayout = false;
      }

      if (isChildNeedsLayout) {
        bool parentUseSize = !(child is RenderBoxModel && child.isSizeTight || child is RenderPositionPlaceholder);
        if (debugLogFlowEnabled) {
          renderingLogger.finer('[Flow] -> layout child ${child.runtimeType} '
              'with ${_fmtC(childConstraints)} parentUsesSize=$parentUseSize');
        }
        child.layout(childConstraints, parentUsesSize: parentUseSize);
      }

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

  double _getRunsMaxMainSize(
    List<RunMetrics> runMetrics,
  ) {
    // Find the max size of lines.
    RunMetrics maxMainSizeMetrics = runMetrics.reduce((RunMetrics curr, RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Find the size in the cross axis of lines.
  double _getRunsCrossSize(
    List<RunMetrics> runMetrics,
  ) {
    double crossSize = 0;
    for (RunMetrics run in runMetrics) {
      crossSize += run.crossAxisExtent;
    }
    return crossSize;
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

          // Advance prevCollapsedBottom for following siblings in this run.
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
      final bool isOverflowVisible = rs.effectiveOverflowY == CSSOverflowType.visible || rs.effectiveOverflowY == CSSOverflowType.clip;
      final bool qualifies = rs.isLayoutBox() &&
          rs.height.isAuto &&
          rs.minHeight.isAuto &&
          rs.maxHeight.isNone &&
          rs.effectiveDisplay == CSSDisplay.block &&
          isOverflowVisible &&
          rs.paddingBottom.computedValue == 0 &&
          rs.effectiveBorderBottomWidth.computedValue == 0;
      if (qualifies) {
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
    List<RenderBox> runChildren = runMetrics.runChildren;
    double runCrossExtent = 0;
    List<double> runChildrenCrossSize = [];
    void iterateRunChildren(RenderBox runChild) {
      double runChildCrossSize = 0.0;
      if (runChild is RenderBoxModel) {
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

  // Set flex container size according to children size.
  void _setContainerSize({double adjustHeight = 0, double adjustWidth = 0}) {
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

    // logging removed
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
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double mainAxisFreeSpace = math.max(0.0, mainAxisContentSize - runMainAxisExtent);
      double crossAxisLineJoinOffset = 0;
      double mainAxisLineJoinOffset = 0;

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

      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow-Run] index=' + i.toString() +
            ' carriedPrevBottom=' + (carriedPrevCollapsedBottom?.toStringAsFixed(2) ?? 'null') +
            ' runCrossAxisExtent=' + runCrossAxisExtent.toStringAsFixed(2));
      }
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

        // Child line extent calculated according to vertical align.
        double childLineExtent = childCrossAxisOffset;

        double? childMarginLeft = 0;
        double? childMarginTop = 0;
        double? childMarginBottom = 0;

        RenderBoxModel? childRenderBoxModel;
        if (child is RenderBoxModel) {
          childRenderBoxModel = child;
        } else if (child is RenderPositionPlaceholder) {
          childRenderBoxModel = child.positioned;
        }

        if (childRenderBoxModel is RenderBoxModel) {
          final rs = childRenderBoxModel.renderStyle;
          childMarginLeft = rs.marginLeft.computedValue;
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
          if (debugLogFlowEnabled && prevCollapsedBottom != null) {
            final tag = rs.target.tagName.toLowerCase();
            renderingLogger.finer('[Flow-MarginCollapse] prevBottom=' +
                prevCollapsedBottom!.toStringAsFixed(2) +
                ' currTop=' + ((() {
                  final p = prevCollapsedBottom!;
                  if (selfTopIgnoringParent >= 0 && p >= 0) return math.max(selfTopIgnoringParent, p);
                  if (selfTopIgnoringParent <= 0 && p <= 0) return math.min(selfTopIgnoringParent, p);
                  return selfTopIgnoringParent;
                })()).toStringAsFixed(2) +
                ' contrib=' + topContribution.toStringAsFixed(2) +
                ' child=<' + tag + '>');
          }
          if (debugLogFlowEnabled) {
            renderingLogger.finer('[Flow-Child] <' + rs.target.tagName.toLowerCase() + '>' +
                ' collapsedTop=' + ownTopInExtent.toStringAsFixed(2) +
                ' collapsedBottom=' + (childMarginBottom ?? 0).toStringAsFixed(2));
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
                (childMarginTop ?? 0));
        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child);

        childMainPosition += childMainAxisExtent + childBetweenSpace;

        // Update previous collapsed bottom margin for next sibling in the run
        if (childMarginBottom != null) {
          prevCollapsedBottom = childMarginBottom;
        }
      }

      // Remove the first child's own collapsed top from the carry to avoid adding
      // both top and bottom margins of the previous run when computing the next run's start.
      final double crossAdvance = (runCrossAxisExtent - runFirstOwnTop + runFirstTopContribution) + runBetweenSpace;
      crossAxisOffset += crossAdvance;
      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow-RunEnd] index=' + i.toString() +
            ' runFirstOwnTop=' + runFirstOwnTop.toStringAsFixed(2) +
            ' crossAdvance=' + crossAdvance.toStringAsFixed(2) +
            ' newCarryPrevBottom=' + (prevCollapsedBottom?.toStringAsFixed(2) ?? 'null'));
      }
      // Carry over prev collapsed bottom margin to next run
      carriedPrevCollapsedBottom = prevCollapsedBottom;
    }
  }

  // Compute distance to baseline of flow layout: prefer cached baselines from layout.
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final bool overflowVisible = renderStyle.effectiveOverflowX == CSSOverflowType.visible &&
        renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    if (!overflowVisible) {
      return boxSize?.height;
    }
    // Use cached last baseline when available; otherwise fall back to bottom edge.
    return computeCssLastBaselineOf(baseline) ?? boxSize?.height;
  }

  // Set the size of scrollable overflow area for inline formatting context.
  void _setMaxScrollableSizeFromIFC() {
    if (_inlineFormattingContext == null) {
      scrollableSize = size;
      return;
    }

    final hasLineBoxes = _inlineFormattingContext!.lineBoxes.isNotEmpty;

    double maxScrollableWidth = 0;
    double maxScrollableHeight = 0;

    if (hasLineBoxes) {
      // Calculate the scrollable size from line boxes (legacy path)
      for (final lineBox in _inlineFormattingContext!.lineBoxes) {
        double lineWidth = 0;
        double lineHeight = lineBox.height;

        // Calculate the maximum width needed by this line
        for (final item in lineBox.items) {
          if (item is AtomicLineBoxItem || item is BoxLineBoxItem) {
            final renderBox = (item is AtomicLineBoxItem) ? item.renderBox : (item as BoxLineBoxItem).renderBox;

            if (renderBox != null) {
              double itemRight = item.offset.dx + item.size.width;

              // Add margins for RenderBoxModel
              if (renderBox is RenderBoxModel) {
                itemRight += renderBox.renderStyle.marginRight.computedValue;
              }

              lineWidth = math.max(lineWidth, itemRight);
            }
          } else if (item is TextLineBoxItem) {
            lineWidth = math.max(lineWidth, item.offset.dx + item.size.width);
          }
        }

        maxScrollableWidth = math.max(maxScrollableWidth, lineWidth);
        maxScrollableHeight += lineHeight;
      }
    } else {
      // Paragraph path: use visual longest line and total height from paragraph metrics
      final double paraWidth = _inlineFormattingContext!.paragraphVisualMaxLineWidth;
      final lines = _inlineFormattingContext!.paragraphLineMetrics;
      final double paraHeight = lines.isEmpty
          ? (_inlineFormattingContext!.paragraph?.height ?? 0)
          : lines.fold<double>(0.0, (h, lm) => h + lm.height);
      maxScrollableWidth = paraWidth;
      maxScrollableHeight = paraHeight;
      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow] scrollable from IFC paragraph: visualLongest=${paraWidth.toStringAsFixed(2)} '
            'height=${maxScrollableHeight.toStringAsFixed(2)}');
      }
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

    // Ensure scrollable size is at least as large as the container size
    double finalScrollableWidth = math.max(
        size.width -
            renderStyle.effectiveBorderLeftWidth.computedValue -
            renderStyle.effectiveBorderRightWidth.computedValue,
        maxScrollableWidth);

    double finalScrollableHeight = math.max(
        size.height -
            renderStyle.effectiveBorderTopWidth.computedValue -
            renderStyle.effectiveBorderBottomWidth.computedValue,
        maxScrollableHeight);

    scrollableSize = Size(finalScrollableWidth, finalScrollableHeight);

    if (debugLogFlowEnabled) {
      renderingLogger.finer('[Flow] scrollable from IFC: width=${finalScrollableWidth.toStringAsFixed(2)} '
          'height=${finalScrollableHeight.toStringAsFixed(2)} '
          'overflowX=${renderStyle.effectiveOverflowX} overflowY=${renderStyle.effectiveOverflowY} '
          'via=${hasLineBoxes ? 'lineBoxes' : 'paragraph'}');
    }
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
    for (RunMetrics runMetric in _lineMetrics) {
      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow-Scroll] ---- line start ----');
        renderingLogger.finer('[Flow-Scroll] preLinesCrossSize=${preLinesCrossSize.toStringAsFixed(2)} run.crossAxisExtent=${runMetric.crossAxisExtent.toStringAsFixed(2)}');
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
        }

        scrollableMainSizeOfChildren.add(preSiblingsMainSize + childScrollableSize.width + childOffsetX);
        // Exclude vertical margins; only include additional vertical offsets (relative/transform).
        scrollableCrossSizeOfChildren.add(childScrollableSize.height + childOffsetY);
        runChildrenList.add(child);
      }

      runChildren.forEach(iterateRunChildren);

      if (debugLogFlowEnabled) {
        for (int i = 0; i < runChildren.length; i++) {
          final child = runChildren[i];
          final Size? sz = _getChildSize(child);
          final RenderStyle? crs = _getChildRenderStyle(child);
          if (crs != null && sz != null) {
            final mt = getChildMarginTop(child);
            final mb = getChildMarginBottom(child);
            renderingLogger.finer('[Flow-Scroll-Child] <${crs.target.tagName.toLowerCase()}> size=${sz.width.toStringAsFixed(2)}×${sz.height.toStringAsFixed(2)} '
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

      if (debugLogFlowEnabled) {
        renderingLogger.finer('[Flow-Scroll] line childCrossMax=' +
            (scrollableCrossSizeOfChildren.reduce((a,b)=> a>b?a:b)).toStringAsFixed(2) +
            ' lineBottom=' + maxScrollableCrossSizeOfLine.toStringAsFixed(2) +
            ' preLinesCrossSize→' + preLinesCrossSize.toStringAsFixed(2));
      }
    }

    // Max scrollable main size of all lines.
    double maxScrollableMainSizeOfLines = scrollableMainSizeOfLines.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    RenderBoxModel container = this;
    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableMainSizeOfChildren = maxScrollableMainSizeOfLines +
        renderStyle.paddingLeft.computedValue +
        (isScrollContainer ? renderStyle.paddingRight.computedValue : 0);

    // Collapsed vertical stack height across runs (accounts for inter-run margin collapsing
    // and matches the positioning used during layout). This avoids double-counting margins
    // that are already included in run.crossAxisExtent and inter-run collapsing logic.
    final double collapsedCrossStack = _getRunsCrossSizeWithCollapse(_lineMetrics);

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableCrossSizeOfChildren = collapsedCrossStack +
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

    if (debugLogFlowEnabled) {
      renderingLogger.finer('[Flow-Scroll] result main=' + maxScrollableMainSize.toStringAsFixed(2) +
          ' cross=' + maxScrollableCrossSize.toStringAsFixed(2) +
          ' padding(top=' + renderStyle.paddingTop.computedValue.toStringAsFixed(2) + ', bottom=' +
          (isScrollContainer ? renderStyle.paddingBottom.computedValue.toStringAsFixed(2) : '0') + ')');
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
    // Cache CSS baselines for this element, computed from IFC line metrics.
    // Baselines are measured from the top padding/border edge as distances,
    // consistent with how computeDistanceToBaseline reports.
    final paddingTop = renderStyle.paddingTop.computedValue;
    final borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    final bool overflowVisible = renderStyle.effectiveOverflowX == CSSOverflowType.visible &&
        renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    double? firstBaseline;
    double? lastBaseline;
    if (overflowVisible) {
      final lines = _inlineFormattingContext!.paragraphLineMetrics;
      if (lines.isNotEmpty) {
        // For inline-block elements inside IFC, compute both first and last baselines:
        // - first baseline = baseline of the first in-flow line box
        // - last baseline  = baseline of the last in-flow line box
        if (renderStyle.display == CSSDisplay.inlineBlock) {
          firstBaseline = lines.first.baseline + paddingTop + borderTop;
          lastBaseline = lines.last.baseline + paddingTop + borderTop;
        } else {
          firstBaseline = lines.first.baseline + paddingTop + borderTop;
          lastBaseline = lines.last.baseline + paddingTop + borderTop;
        }
        if (debugLogInlineLayoutEnabled) {
          renderingLogger.fine('[IFC] setCssBaselines first=${firstBaseline.toStringAsFixed(2)} '
              'last=${lastBaseline.toStringAsFixed(2)} '
              'paddingTop=${paddingTop.toStringAsFixed(2)} borderTop=${borderTop.toStringAsFixed(2)}');
        }
      } else if (_inlineFormattingContext!.lineBoxes.isNotEmpty) {
        // Legacy line boxes path
        final first = _inlineFormattingContext!.lineBoxes.first;
        double y = 0;
        for (int i = 0; i < _inlineFormattingContext!.lineBoxes.length - 1; i++) {
          y += _inlineFormattingContext!.lineBoxes[i].height;
        }
        final last = _inlineFormattingContext!.lineBoxes.last;
        // For inline-block elements, compute distinct first and last baselines.
        if (renderStyle.display == CSSDisplay.inlineBlock) {
          firstBaseline = first.baseline + paddingTop + borderTop;
          lastBaseline = y + last.baseline + paddingTop + borderTop;
        } else {
          firstBaseline = first.baseline + paddingTop + borderTop;
          lastBaseline = y + last.baseline + paddingTop + borderTop;
        }
        if (debugLogInlineLayoutEnabled) {
          renderingLogger.fine('[IFC-legacy] setCssBaselines first=${firstBaseline.toStringAsFixed(2)} '
              'last=${lastBaseline.toStringAsFixed(2)}');
        }
      }
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
      // Check if any child elements have text content (establish IFC)
      double? childLastBaseline;
      bool hasChildWithText = false;

      visitChildren((child) {
        if (child is RenderFlowLayout && child.establishIFC) {
          hasChildWithText = true;
          // Ensure child baseline is calculated first
          child.calculateBaseline();
          double? baseline = child.computeCssLastBaseline();
          if (baseline != null) {
            childLastBaseline = baseline;
          }
        } else if (child is RenderEventListener) {
          // Check children of RenderEventListener (common wrapper)
          child.visitChildren((grandchild) {
            if (grandchild is RenderFlowLayout && grandchild.establishIFC) {
              hasChildWithText = true;
              // Ensure grandchild baseline is calculated first
              grandchild.calculateBaseline();
              double? baseline = grandchild.computeCssLastBaseline();
              if (baseline != null) {
                childLastBaseline = baseline;
              }
            }
          });
        }
      });

      if (hasChildWithText && childLastBaseline != null) {
        // Use child's text baseline
        firstBaseline = childLastBaseline! + paddingTop + borderTop;
        lastBaseline = firstBaseline;
      } else {
        // No in-flow line boxes inside the inline-block: per CSS 2.1 §10.8.1,
        // synthesize baseline from the bottom margin edge.
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
        if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
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
