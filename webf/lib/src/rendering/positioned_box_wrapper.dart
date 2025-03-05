/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;
import 'package:webf/dom.dart' as dom;

class RenderPositionedBoxWrapper extends RenderBoxModel
    with ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>>{
  RenderPositionedBoxWrapper({
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  void _layoutNonPositionedChildren(RenderBox child) {
    child.layout(constraints, parentUsesSize: true);
    size = child.size;
    scrollableSize = (child as RenderBoxModel).scrollableSize;
  }

  @override
  void performLayout() {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayout(this);
    }

    // Positioned Box wrapper behavior as an RenderProxyBox for non positioned children.
    // Avoid deflate padding and margin from box model.
    contentConstraints = constraints;

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderBox> _nonPositionedChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    int childIndex = 0;
    while (child != null) {
      if (childIndex == 0) {
        _nonPositionedChildren.add(child);
      } else {
        _positionedChildren.add(child as RenderBoxModel);
      }

      childIndex++;
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      child = childParentData.nextSibling;
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    assert(_nonPositionedChildren.length == 1);
    _layoutNonPositionedChildren(_nonPositionedChildren.first);

    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // calculate all flexItem child overflow size
    addOverflowLayoutFromChildren(_nonPositionedChildren);

    // Set offset of positioned element after flex box size is set.
    for (RenderBoxModel child in _positionedChildren) {
      dom.Element? containingBlockElement = child.renderStyle.target.getContainingBlockElement();
      if (containingBlockElement == null || containingBlockElement.attachedRenderer == null) continue;

      if (child.renderStyle.position == CSSPositionType.absolute) {
        containingBlockElement.attachedRenderer!.absolutePositionedChildren.add(child);
      } else {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);
      }
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      addOverflowLayoutFromChild(child);
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayout(this);
    }
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  RawPointerListener get rawPointerListener {
    return renderStyle.target.ownerDocument.viewport!.rawPointerListener;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);

    if (event is PointerDownEvent) {
      rawPointerListener.recordEventTarget(renderStyle.target);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
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

class PositionedBoxWrapper extends MultiChildRenderObjectWidget {
  final dom.Element ownerElement;

  PositionedBoxWrapper({required List<Widget> children, required this.ownerElement}) : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPositionedBoxWrapper(renderStyle: ownerElement.renderStyle);
  }
}
