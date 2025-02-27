/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
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
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      addOverflowLayoutFromChild(child);
    }
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return super.hitTest(result, position: position);
  }

  @override
  bool defaultHitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return super.defaultHitTestChildren(result, position: position);
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
