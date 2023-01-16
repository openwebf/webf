/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/rendering/text.dart';

class LogicInlineBox {
  RenderBox renderObject;
  LogicLineBox? parentLine;
  LogicInlineBox? next;
  LogicInlineBox? pre;
  bool isDirty;

  LogicInlineBox({required this.renderObject, this.parentLine, this.isDirty = true});

  Size _getInlineBoxScrollableSize() {
    Size scrollableSize = renderObject.size;
    if (renderObject is RenderBoxModel) {
      RenderStyle childRenderStyle = (renderObject as RenderBoxModel).renderStyle;
      CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
      CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
      // Only non scroll container need to use scrollable size, otherwise use its own size.
      if (overflowX == CSSOverflowType.visible && overflowY == CSSOverflowType.visible) {
        scrollableSize = (renderObject as RenderBoxModel).scrollableSize;
      }
    }
    return scrollableSize;
  }

  bool isLineHeightValid() {
    if (renderObject is RenderTextBox) {
      return true;
    } else if (renderObject is RenderBoxModel) {
      CSSDisplay? childDisplay = (renderObject as RenderBoxModel).renderStyle.display;
      return childDisplay == CSSDisplay.inline ||
          childDisplay == CSSDisplay.inlineBlock ||
          childDisplay == CSSDisplay.inlineFlex;
    }
    return false;
  }

  double get scrollableWidth {
    return _getInlineBoxScrollableSize().width;
  }

  double get scrollableHeight {
    return _getInlineBoxScrollableSize().height;
  }

  double get relativeOffsetX {
    double childOffsetX = 0;
    if (renderObject is RenderBoxModel) {
      RenderStyle childRenderStyle = (renderObject as RenderBoxModel).renderStyle;
      Offset? relativeOffset = CSSPositionedLayout.getRelativeOffset(childRenderStyle);
      if (relativeOffset != null) {
        childOffsetX += relativeOffset.dx;
      }

      // Scrollable overflow area is defined in the following spec
      // which includes margin, position and transform offset.
      // https://www.w3.org/TR/css-overflow-3/#scrollable-overflow-region

      // Add offset of margin.
      childOffsetX += childRenderStyle.marginLeft.computedValue + childRenderStyle.marginRight.computedValue;
      final Offset? transformOffset = (childRenderStyle as CSSRenderStyle).effectiveTransformOffset;
      if (transformOffset != null) {
        childOffsetX = transformOffset.dx > 0 ? childOffsetX + transformOffset.dx : childOffsetX;
      }
    }
    return childOffsetX;
  }

  double get relativeOffsetY {
    double childOffsetY = 0;
    if (renderObject is RenderBoxModel) {
      RenderStyle childRenderStyle = (renderObject as RenderBoxModel).renderStyle;
      Offset? relativeOffset = CSSPositionedLayout.getRelativeOffset(childRenderStyle);

      // Scrollable overflow area is defined in the following spec
      // which includes margin, position and transform offset.
      // https://www.w3.org/TR/css-overflow-3/#scrollable-overflow-region

      if (renderObject.parent != null && renderObject.parent is RenderFlowLayout) {
        childOffsetY += (renderObject.parent as RenderFlowLayout).getChildMarginTop(renderObject as RenderBoxModel) +
            (renderObject.parent as RenderFlowLayout).getChildMarginBottom(renderObject as RenderBoxModel);
      }

      if (relativeOffset != null) {
        childOffsetY += relativeOffset.dy;
      }
      final Offset? transformOffset = (childRenderStyle as CSSRenderStyle).effectiveTransformOffset;
      if (transformOffset != null) {
        childOffsetY = transformOffset.dy > 0 ? childOffsetY + transformOffset.dy : childOffsetY;
      }
    }
    return childOffsetY;
  }

  double get width => renderObject.size.width;

  double get height => renderObject.size.height;

  double getMainAxisExtent() {
    double marginHorizontal = 0;
    if (renderObject is RenderBoxModel) {
      marginHorizontal = (renderObject as RenderBoxModel).renderStyle.marginLeft.computedValue +
          (renderObject as RenderBoxModel).renderStyle.marginRight.computedValue;
    }

    Size childSize = getChildSize() ?? Size.zero;

    return childSize.width + marginHorizontal;
  }

  double getCrossAxisExtent(CSSLengthValue? lineHeightFromParent, double? marginVertical) {
    double? lineHeight = isLineHeightValid() ? getLineHeight(lineHeightFromParent) : 0;
    double marginV = 0;

    if (renderObject is RenderBoxModel) {
      marginV = marginVertical ?? 0;
    }
    Size childSize = getChildSize() ?? Size.zero;

    return lineHeight != null ? math.max(lineHeight, childSize.height) + marginV : childSize.height + marginV;
  }

  Size? getChildSize() {
    if (renderObject is RenderBoxModel) {
      return (renderObject as RenderBoxModel).boxSize;
    } else if (renderObject is RenderPositionPlaceholder) {
      return (renderObject as RenderPositionPlaceholder).boxSize;
    } else if (renderObject.hasSize) {
      // child is WidgetElement.
      return renderObject.size;
    }
    return null;
  }

  double? getLineHeight(CSSLengthValue? lineHeightFromParent) {
    CSSLengthValue? lineHeight;
    if (renderObject is RenderTextBox || renderObject is RenderBoxModel) {
      lineHeight = lineHeightFromParent;
    } else if (renderObject is RenderPositionPlaceholder) {
      lineHeight = (renderObject as RenderPositionPlaceholder).positioned!.renderStyle.lineHeight;
    }
    if (lineHeight != null && lineHeight.type != CSSLengthType.NORMAL) {
      return lineHeight.computedValue;
    }
    return null;
  }

  double getChildAscent(double marginTop, double marginBottom) {
    // Distance from top to baseline of child.
    double? childAscent = renderObject.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    Size? childSize = getChildSize();
    double baseline = renderObject.parent is RenderFlowLayout
        ? marginTop + childSize!.height + marginBottom
        : marginTop + childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;

    return extentAboveBaseline;
  }

  void applyRelativeOffset(Offset? relativeOffset, double outLineMainSize, double outLineCrossSize) {
    RenderLayoutParentData? boxParentData = renderObject.parentData as RenderLayoutParentData?;

    if (boxParentData != null) {
      Offset? styleOffset;
      // Text node does not have relative offset
      if (renderObject is RenderBoxModel) {
        styleOffset = CSSPositionedLayout.getRelativeOffset((renderObject as RenderBoxModel).renderStyle);
      }

      if (relativeOffset != null) {
        if (styleOffset != null) {
          boxParentData.offset = relativeOffset.translate(styleOffset.dx, styleOffset.dy);
        } else {
          boxParentData.offset = relativeOffset;
        }
      } else {
        boxParentData.offset = styleOffset!;
      }
    }
  }
}

class LogicTextInlineBox extends LogicInlineBox {
  Rect logicRect;

  LogicTextInlineBox({required this.logicRect, required RenderTextBox renderObject, parentLine, isDirty = true})
      : super(renderObject: renderObject, parentLine: parentLine, isDirty: isDirty);

  get isLineBreak {
    return false;
  }

  @override
  double get scrollableWidth {
    return logicRect.width;
  }

  @override
  double get scrollableHeight {
    return logicRect.height;
  }

  @override
  double get relativeOffsetX {
    return 0;
  }

  @override
  double get relativeOffsetY {
    return 0;
  }

  @override
  double get width => logicRect.width;

  @override
  double get height => logicRect.height;

  @override
  Size? getChildSize() {
    return logicRect.size;
  }

  @override
  double getChildAscent(double marginTop, double marginBottom) {
    double? childAscent = (renderObject as RenderTextBox)
        .getLineAscent((renderObject as RenderTextBox).textInLineBoxes.findIndex(this))![0];
    return childAscent;
  }

  @override
  void applyRelativeOffset(Offset? relativeOffset, double outLineMainSize, double outLineCrossSize) {
    RenderLayoutParentData? boxParentData = renderObject.parentData as RenderLayoutParentData?;
    if (boxParentData != null) {
      int index = (renderObject as RenderTextBox).textInLineBoxes.findIndex(this);
      if (relativeOffset != null) {
        // set RenderTextBox offset when update first LogicTextInlineBox offset
        if (index == 0) {
          boxParentData.offset = Offset(outLineMainSize, relativeOffset.dy);
        }
        // for every LogicTextInlineBox update offset
        // logicRect = Rect.fromLTWH(relativeOffsetX, relativeOffsetY, logicRect.width, logicRect.height);
      }
    }
  }
}

class LogicLineBox {
  RenderBox renderObject;
  LogicLineBox? next;
  LogicLineBox? pre;
  bool isFirstLine;
  bool isLastLine;
  List<LogicInlineBox> inlineBoxes = [];
  double mainAxisExtent;
  double crossAxisExtent;
  double baselineExtent;
  double baselineBelowExtent;

  LogicLineBox({
    required this.renderObject,
    this.isFirstLine = false,
    this.isLastLine = false,
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.baselineExtent,
    required this.baselineBelowExtent,
  });

  appendInlineBox(LogicInlineBox box,double childMainAxisExtent, double childCrossAxisExtent, List<double>? baselineSize) {
    box.parentLine = this;
    inlineBoxes.add(box);
    mainAxisExtent += childMainAxisExtent;
    List<double> newCrossAxisSize = calculateMaxCrossAxisExtent(
        crossAxisExtent, baselineExtent, baselineBelowExtent, childCrossAxisExtent, baselineSize);
    crossAxisExtent = newCrossAxisSize[0];
    baselineExtent = newCrossAxisSize[1];
    baselineBelowExtent = newCrossAxisSize[2];
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

  bool get isNotEmpty {
    return inlineBoxes.isNotEmpty;
  }

  double get lineMainAxisAutoSize {
    double runMainExtent = 0;
    for (int i = 0; i < inlineBoxes.length; i++) {
      LogicInlineBox box = inlineBoxes[i];
      RenderBox render = box.renderObject;
      double runChildMainSize = box.renderObject.size.width;
      if (render is RenderTextBox) {
        runChildMainSize = render.autoMinWidth;
      }
      // Should add horizontal margin of child to the main axis auto size of parent.
      if (render is RenderBoxModel) {
        double childMarginLeft = render.renderStyle.marginLeft.computedValue;
        double childMarginRight = render.renderStyle.marginRight.computedValue;
        runChildMainSize += childMarginLeft + childMarginRight;
      }
      runMainExtent += runChildMainSize;
    }
    return runMainExtent;
  }

  double get lineCrossAxisAutoSize {
    double runCrossExtent = 0;
    for (int i = 0; i < inlineBoxes.length; i++) {
      LogicInlineBox box = inlineBoxes[i];
      RenderBox render = box.renderObject;

      double runChildCrossSize = render.size.height;
      if (render is RenderTextBox && box is LogicTextInlineBox) {
        runChildCrossSize = box.logicRect.height;
      }
      if (runChildCrossSize > runCrossExtent) {
        runCrossExtent = runChildCrossSize;
      }
    }
    return runCrossExtent;
  }

  double get maxMainAxisScrollableSizeOnLine {
    double preSiblingsMainSize = 0;
    double maxWidth = 0;
    for (int i = 0; i < inlineBoxes.length; i++) {
      LogicInlineBox box = inlineBoxes[i];
      double width = preSiblingsMainSize + box.width + box.relativeOffsetX;
      if (width > maxWidth) {
        maxWidth = width;
      }
      preSiblingsMainSize += box.width;
    }
    return maxWidth;
  }

  double get maxCrossAxisScrollableSizeOnLine {
    double maxHeight = 0;
    for (int i = 0; i < inlineBoxes.length; i++) {
      LogicInlineBox box = inlineBoxes[i];
      double height = box.height + box.relativeOffsetY;
      if (height > maxHeight) {
        maxHeight = height;
      }
    }
    return maxHeight;
  }
}
