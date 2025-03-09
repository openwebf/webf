import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';
import 'package:collection/collection.dart';

class RenderChildSize extends RenderProxyBox {
  RenderChildSize({required this.ownerElement});

  List<RunMetrics> _lineBoxMetrics = <RunMetrics>[];

  dom.Element ownerElement;

  List<RenderBox> getRenderBoxModel() {
    dom.NodeList childNodes = ownerElement.renderStyle.target.childNodes;
    List<RenderBox> renderBoxes = [];

    for (var node in childNodes) {
      if (node.attachedRenderer != null) {
        renderBoxes.add(node.attachedRenderer!);
      }
    }

    return renderBoxes;
  }

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? _getChildSize(RenderBox child) {
    if (!child.hasSize) return null;

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

  double _getMainAxisExtent(RenderBox child) {
    Size childSize = _getChildSize(child) ?? Size.zero;
    return childSize.width;
  }


  bool isLineHeightValid(RenderBox child) {
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

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? getChildSize(RenderBox child) {
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

  // Get distance from top to baseline of child.
  double getChildAscent(RenderBox child) {
    // Distance from top to baseline of child.
    // double? childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    double? childAscent = null;
    Size? childSize = getChildSize(child);

    double baseline = childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;

    return extentAboveBaseline;
  }

  RenderStyle? getChildRenderStyle(RenderBox child) {
    RenderStyle? childRenderStyle;
    if (child is RenderTextBox) {
      childRenderStyle = ownerElement.renderStyle;
    } else if (child is RenderBoxModel) {
      childRenderStyle = child.renderStyle;
    } else if (child is RenderPositionPlaceholder) {
      childRenderStyle = child.positioned!.renderStyle;
    }
    return childRenderStyle;
  }

  bool isChildBlockLevel(RenderBox? child) {
    if (child is RenderBoxModel || child is RenderPositionPlaceholder) {
      RenderStyle? childRenderStyle = getChildRenderStyle(child!);
      if (childRenderStyle != null) {
        CSSDisplay? childDisplay = childRenderStyle.display;
        return childDisplay == CSSDisplay.block || childDisplay == CSSDisplay.flex;
      }
    }
    return false;
  }

  /// Common layout content size (including flow and flexbox layout) calculation logic
  Size getContentSize({
    required double contentWidth,
    required double contentHeight,
  }) {
    double finalContentWidth = contentWidth;
    double finalContentHeight = contentHeight;

    // Size which is specified by sizing styles
    double? specifiedContentWidth = ownerElement.renderStyle.contentBoxLogicalWidth;
    double? specifiedContentHeight = ownerElement.renderStyle.contentBoxLogicalHeight;

    if (specifiedContentWidth != null) {
      finalContentWidth = math.max(specifiedContentWidth, contentWidth);
    }
    if (specifiedContentHeight != null) {
      finalContentHeight = math.max(specifiedContentHeight, contentHeight);
    }

    CSSRenderStyle renderStyle = ownerElement.renderStyle;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isInlineBlock = effectiveDisplay == CSSDisplay.inlineBlock;
    bool isNotInline = effectiveDisplay != CSSDisplay.inline;
    double? width = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? height = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;
    double? minWidth = renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth = renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto ? null : renderStyle.minHeight.computedValue;
    double? maxHeight = renderStyle.maxHeight.isNone ? null : renderStyle.maxHeight.computedValue;

    // Constrain to min-width or max-width if width not exists.
    if (isInlineBlock && maxWidth != null && width == null) {
      double maxContentWidth = _getContentWidth(maxWidth);
      finalContentWidth = finalContentWidth > maxContentWidth ? maxContentWidth : finalContentWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      double minContentWidth = _getContentWidth(minWidth);
      finalContentWidth = finalContentWidth < minContentWidth ? minContentWidth : finalContentWidth;
    }

    // Constrain to min-height or max-height if height not exists.
    if (isNotInline && maxHeight != null && height == null) {
      double maxContentHeight = _getContentHeight(maxHeight);
      finalContentHeight = finalContentHeight > maxContentHeight ? maxContentHeight : finalContentHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      double minContentHeight = _getContentWidth(minHeight);
      finalContentHeight = finalContentHeight < minContentHeight ? minContentHeight : finalContentHeight;
    }

    Size finalContentSize = Size(finalContentWidth, finalContentHeight);
    return finalContentSize;
  }

  double _getContentWidth(double width) {
    CSSRenderStyle renderStyle = ownerElement.renderStyle;
    return width -
        (renderStyle.borderLeftWidth?.computedValue ?? 0) -
        (renderStyle.borderRightWidth?.computedValue ?? 0) -
        renderStyle.paddingLeft.computedValue -
        renderStyle.paddingRight.computedValue;
  }

  double? _getLineHeight(RenderBox child) {
    CSSLengthValue? lineHeight;
    if (child is RenderTextBox) {
      lineHeight = ownerElement.renderStyle.lineHeight;
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

  double _getContentHeight(double height) {
    CSSRenderStyle renderStyle = ownerElement.renderStyle;
    return height -
        (renderStyle.borderTopWidth?.computedValue ?? 0) -
        (renderStyle.borderBottomWidth?.computedValue ?? 0) -
        renderStyle.paddingTop.computedValue -
        renderStyle.paddingBottom.computedValue;
  }

  double _getCrossAxisExtent(RenderBox child) {
    double? lineHeight = isLineHeightValid(child) ? _getLineHeight(child) : 0;
    Size childSize = _getChildSize(child) ?? Size.zero;

    return lineHeight != null
        ? math.max(lineHeight, childSize.height)
        : childSize.height;
  }

  List<RunMetrics> _computeRunMetrics(
      List<RenderBox> children,
      ) {
    List<RunMetrics> _runMetrics = <RunMetrics>[];
    double mainAxisLimit = ownerElement.renderStyle.contentMaxConstraintsWidth;

    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    RenderBox? preChild;
    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;
    Map<int?, RenderBox> runChildren = {};

    children.forEachIndexed((int index, RenderBox child) {
      if (!child.attached) return;

      final ParentData? childParentData = child.parentData;
      int childNodeId = child.hashCode;

      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (runChildren.isNotEmpty) {
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

      // Calculate baseline extent of layout box.
      RenderStyle? childRenderStyle = getChildRenderStyle(child);
      VerticalAlign verticalAlign = VerticalAlign.baseline;
      if (childRenderStyle != null) {
        verticalAlign = childRenderStyle.verticalAlign;
      }

      bool _isLineHeightValid = isLineHeightValid(child);

      // Vertical align is only valid for inline box.
      if (verticalAlign == VerticalAlign.baseline && _isLineHeightValid) {
        Size childSize = _getChildSize(child)!;
        // When baseline of children not found, use boundary of margin bottom as baseline.
        double childAscent = getChildAscent(child);
        double extentAboveBaseline = childAscent;
        double extentBelowBaseline = childSize.height - childAscent;

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

      runChildren[childNodeId] = child;

      if (childParentData is RenderLayoutParentData) {
        childParentData.runIndex = _runMetrics.length;
      }

      preChild = child;
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
    if (_runMetrics.isEmpty) return 0.0;

    // Find the max size of lines.
    RunMetrics maxMainSizeMetrics = _runMetrics.reduce((RunMetrics curr, RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  @override
  void dispose() {
    super.dispose();
    _lineBoxMetrics.clear();
  }

  @override
  void performLayout() {
    super.performLayout();

    List<RenderBox> renderBoxes = getRenderBoxModel();
    List<RunMetrics> runMetrics = _computeRunMetrics(renderBoxes);

    double runMaxMainSize = _getRunsMaxMainSize(runMetrics);
    double runCrossSize = _getRunsCrossSize(runMetrics);

    Size layoutContentSize = getContentSize(
      contentWidth: runMaxMainSize,
      contentHeight: runCrossSize,
    );

    size = constraints.constrain(layoutContentSize);
    child!.layout(BoxConstraints.loose(size));
  }
}
