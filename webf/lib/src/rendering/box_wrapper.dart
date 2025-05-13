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
  double? computeDistanceToBaseline() {
    return renderStyle.attachedRenderBoxModel!.computeDistanceToBaseline();
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
            if (!containingBlockElement.attachedRenderer!.needsLayout) {
              CSSPositionedLayout.applyPositionedChildOffset(containingBlockElement.attachedRenderer!, child as RenderBoxModel);
            }
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
    if (!hasSize || !contentVisibilityHitTest(result, position: position) || renderStyle.isVisibilityHidden) {
      return false;
    }

    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription("Unfortunately, this object's geometry is not known at this time, "
                'probably because it has never been laid out. '
                'This means it cannot be accurately hit-tested.'),
            ErrorHint('If you are trying '
                'to perform a hit test during the layout phase itself, make sure '
                "you only hit test nodes that have completed layout (e.g. the node's "
                'children, after their layout() method has been called).'),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription('Although this node is not marked as needing layout, '
              'its size is not set.'),
          ErrorHint('A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'),
        ]);
      }
      return true;
    }());

    // Determine whether the hittest position is within the visible area of the node in scroll.
    if ((clipX || clipY) && !size.contains(position)) {
      return false;
    }

    if (child == null) {
      return false;
    }

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    bool isHit = result.addWithPaintOffset(offset: childParentData.offset, position: position, hitTest: (result, position) {
      // addWithPaintOffset is to add an offset to the child node, the calculation itself does not need to bring an offset.
      if (hasSize && hitTestChildren(result, position: position) || hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
      return false;
    });
    return isHit;
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
