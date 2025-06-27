/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

/// RenderBox of a widget element whose content is rendering by Flutter Widgets.
class RenderWidget extends RenderBoxModel
    with ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderWidget({required super.renderStyle});

  // Cache sticky children to calculate the base offset of sticky children
  final Set<RenderBoxModel> stickyChildren = {};

  @override
  BoxSizeType get widthSizeType {
    bool widthDefined = renderStyle.width.isNotAuto || renderStyle.minWidth.isNotAuto;
    return widthDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  BoxSizeType get heightSizeType {
    bool heightDefined = renderStyle.height.isNotAuto || renderStyle.minHeight.isNotAuto;
    return heightDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  void setupParentData(RenderBox child) {
    child.parentData = RenderLayoutParentData();
  }

  void _layoutChild(RenderBox child) {
    // To maximum compact with Flutter, We needs to limit the maxWidth and maxHeight constraints to
    // the viewportSize, as same as the MaterialApp does.
    Size viewportSize = renderStyle.target.ownerDocument.viewport!.viewportSize;
    BoxConstraints childConstraints = BoxConstraints(
        minWidth: contentConstraints!.minWidth,
        maxWidth: contentConstraints!.hasTightWidth
            ? contentConstraints!.maxWidth
            : math.min(viewportSize.width, contentConstraints!.maxWidth),
        minHeight: contentConstraints!.minHeight,
        maxHeight: contentConstraints!.hasTightHeight
            ? contentConstraints!.maxHeight
            : math.min(viewportSize.height, contentConstraints!.maxHeight));

    child.layout(childConstraints, parentUsesSize: true);

    Size childSize = child.size;

    setMaxScrollableSize(childSize);
    size = getBoxSize(childSize);

    minContentWidth = renderStyle.intrinsicWidth;
    minContentHeight = renderStyle.intrinsicHeight;

    _setChildrenOffset(child);
  }

  void _setChildrenOffset(RenderBox child) {
    double borderLeftWidth = renderStyle.borderLeftWidth?.computedValue ?? 0.0;
    double borderTopWidth = renderStyle.borderTopWidth?.computedValue ?? 0.0;

    double paddingLeftWidth = renderStyle.paddingLeft.computedValue;
    double paddingTopWidth = renderStyle.paddingTop.computedValue;

    Offset offset = Offset(borderLeftWidth + paddingLeftWidth, borderTopWidth + paddingTopWidth);
    // Apply position relative offset change.
    CSSPositionedLayout.applyRelativeOffset(offset, child);
  }

  @override
  void performLayout() {
    beforeLayout();

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderBox> _nonPositionedChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
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

    if (_nonPositionedChildren.isNotEmpty) {
      _layoutChild(_nonPositionedChildren.first);
    } else {
      performResize();
    }

    for (RenderBoxModel child in _positionedChildren) {
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
    }

    // // Calculate the offset of its sticky children.
    // for (RenderBoxModel stickyChild in stickyChildren) {
    //   CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
    // }

    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
    didLayout();
  }

  @override
  void performResize() {
    double width = 0, height = 0;
    final Size attempingSize = constraints.biggest;
    if (attempingSize.width.isFinite) {
      width = attempingSize.width;
    }
    if (attempingSize.height.isFinite) {
      height = attempingSize.height;
    }

    size = constraints.constrain(Size(width, height));
    assert(size.isFinite);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  @override
  void dispose() {
    super.dispose();
    stickyChildren.clear();
  }


  /// Compute distance to baseline of replaced element
  @override
  double computeDistanceToBaseline() {
    double marginTop = renderStyle.marginTop.computedValue;
    double marginBottom = renderStyle.marginBottom.computedValue;

    // Use margin-bottom as baseline if layout has no children
    return marginTop + boxSize!.height + marginBottom;
  }

  /// This class mixin [RenderProxyBoxMixin], which has its' own paint method,
  /// override it to layout box model paint.
  @override
  void paint(PaintingContext context, Offset offset) {
    // Check if the widget element has disabled box model painting
    if (renderStyle.target is WidgetElement) {
      final widgetElement = renderStyle.target as WidgetElement;
      if (widgetElement.disableBoxModelPaint) {
        // Call performPaint directly without box model painting
        performPaint(context, offset);
        return;
      }
    }
    
    // Default behavior: paint with box model
    paintBoxModel(context, offset);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    // Report FCP/LCP when RenderWidget with contentful Flutter widget is first painted
    if (renderStyle.target is WidgetElement && firstChild != null && hasSize && !size.isEmpty) {
      final widgetElement = renderStyle.target as WidgetElement;

      // Check if the widget contains contentful content and get the actual visible area
      double contentfulArea = _getContentfulPaintArea(widgetElement);
      if (contentfulArea > 0) {
        // Report FP first (if not already reported)
        widgetElement.ownerDocument.controller.reportFP();
        widgetElement.ownerDocument.controller.reportFCP();

        // Report LCP candidate with the actual contentful area
        widgetElement.ownerDocument.controller.reportLCPCandidate(widgetElement, contentfulArea);
      }
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

      Offset childPaintOffset = childParentData.offset;
      if (child is RenderBoxModel && child.renderStyle.position == CSSPositionType.fixed) {
        Offset totalScrollOffset = getTotalScrollOffset();
        childPaintOffset += totalScrollOffset;
      }

      context.paintChild(child, offset + childPaintOffset);
      child = childParentData.nextSibling;
    }
  }

  /// Gets the total visible area of contentful paint children.
  /// Returns 0 if no contentful paint is found.
  double _getContentfulPaintArea(WidgetElement widgetElement) {
    // Only check render objects created directly by the WidgetElement's state build() method
    // This uses a special method that skips any RenderBoxModel or RenderWidget children
    return ContentfulWidgetDetector.getContentfulPaintAreaFromFlutterWidget(firstChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    if (renderStyle.transformMatrix != null) {
      return hitTestIntrinsicChild(result, firstChild, position!);
    }

    RenderBox? child = lastChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);

          if (child is RenderBoxModel) {
            CSSPositionType positionType = child.renderStyle.position;
            if (positionType == CSSPositionType.fixed) {
              Offset totalScrollOffset = (this as RenderBoxModel).getTotalScrollOffset();
              transformed -= totalScrollOffset;
            }
          }

          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }

      child = childParentData.previousSibling;
    }

    return false;
  }
}

class RenderRepaintBoundaryWidget extends RenderWidget {
  RenderRepaintBoundaryWidget({required super.renderStyle});

  @override
  bool get isRepaintBoundary => true;
}
