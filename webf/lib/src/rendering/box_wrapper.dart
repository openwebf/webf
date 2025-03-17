/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

class RenderLayoutBoxWrapper extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderLayoutBoxWrapper({
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  @override
  void performLayout() {
    super.performLayout();

    if (child is RenderBoxModel) {
      double childMarginTop = renderStyle.collapsedMarginTop;
      double childMarginBottom = renderStyle.collapsedMarginBottom;
      Size scrollableSize = (child as RenderBoxModel).scrollableSize;

      size = constraints.constrain(Size(scrollableSize.width, childMarginTop + scrollableSize.height + childMarginBottom));

      double childMarginLeft = renderStyle.marginLeft.computedValue;

      if (renderStyle.isSelfPositioned()) {
        dom.Element? containingBlockElement = renderStyle.target.getContainingBlockElement();
        if (containingBlockElement?.attachedRenderer != null) {
          if (renderStyle.position == CSSPositionType.absolute) {
            containingBlockElement!.attachedRenderer!.positionedChildren.add(child as RenderBoxModel);
          } else {
            CSSPositionedLayout.applyPositionedChildOffset(this, child as RenderBoxModel);
          }
        }
      } else {
        // No need to add padding and border for scrolling content box.
        Offset relativeOffset = Offset(childMarginLeft, childMarginTop);
        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child as RenderBoxModel);
      }
    }

    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null) {
      return;
    }
    final BoxParentData childParentData = child.parentData as BoxParentData;
    context.paintChild(child, offset + childParentData.offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? child = this.child;
    if (child == null) {
      return false;
    }
    final BoxParentData childParentData = child.parentData as BoxParentData;
    return super.hitTest(result, position: position - childParentData.offset);
  }
}

class LayoutBoxWrapper extends SingleChildRenderObjectWidget {
  final dom.Element ownerElement;

  LayoutBoxWrapper({required Widget child, required this.ownerElement}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutBoxWrapper(renderStyle: ownerElement.renderStyle);
  }
}
