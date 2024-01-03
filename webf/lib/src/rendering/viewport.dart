/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/gesture.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;

class RenderViewportParentData extends ContainerBoxParentData<RenderViewportBox> {}

class RenderViewportBox extends RenderBox
    with
        RenderEventListenerMixin,
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderViewportBox({
    required Size viewportSize,
    this.background,
    required this.controller
  })  : _viewportSize = viewportSize,
        super();

  WebFController controller;

  // Cache all the fixed children of renderBoxModel of root element.
  Set<RenderBoxModel> fixedChildren = {};

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = RenderViewportParentData();
  }

  @override
  bool get isRepaintBoundary => true;

  Color? background;

  Size _viewportSize;

  Size get viewportSize => _viewportSize;

  set viewportSize(Size value) {
    if (value != _viewportSize) {
      _viewportSize = value;
      markNeedsLayout();
    }
  }

  double _bottomInset = 0.0;

  double get bottomInset => _bottomInset;

  set bottomInset(double value) {
    if (value != _bottomInset) {
      _bottomInset = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    double width = _viewportSize.width;
    double height = _viewportSize.height - _bottomInset;
    if (height.isNegative || height.isNaN) {
      height = _viewportSize.height;
    }
    size = constraints.constrain(Size(width, height));

    RenderObject? child = firstChild;
    while (child != null) {
      final ContainerBoxParentData<RenderObject> childParentData = child.parentData as ContainerBoxParentData<RenderObject>;

      RenderBoxModel rootRenderLayoutBox = child as RenderLayoutBox;
      child.layout(rootRenderLayoutBox.getConstraints().tighten(width: width, height: height));

      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
  }

  @override
  GestureDispatcher? get gestureDispatcher => controller.gestureDispatcher;

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry as BoxHitTestEntry);

    // Add pointer to gesture dispatcher.
    controller.gestureDispatcher.handlePointerEvent(event);

    if (event is PointerDownEvent) {
      // Set event path at begin stage and reset it at end stage on viewport render box.
      controller.gestureDispatcher.resetEventPath();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (background != null) {
      Rect rect = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        size.height,
      );
      context.canvas.drawRect(
        rect,
        Paint()..color = background!,
      );
    }

    defaultPaint(context, offset);
  }

  // WebF page can reload the whole page.
  void reload() {
    removeAll();
    fixedChildren.clear();
  }

  @override
  void dispose() {
    removeAll();
    fixedChildren.clear();
    super.dispose();
  }
}
