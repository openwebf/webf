/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/gesture.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;

class RenderViewportParentData extends ContainerBoxParentData<RenderBox> {}

class RenderViewportBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderViewportBox({required Size? viewportSize, this.background, required this.controller})
      : _viewportSize = viewportSize,
        super();

  WebFController controller;

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = RenderViewportParentData();
  }

  @override
  bool get isRepaintBoundary => true;

  Color? background;

  Size? _viewportSize;
  Size? _boxSize;
  Size? get boxSize => _boxSize;

  Size get viewportSize {
    if (_viewportSize != null) return _viewportSize!;
    if (hasSize) return _boxSize!;
    return Size.zero;
  }

  set viewportSize(Size? value) {
    if (value != null && value != _viewportSize) {
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
  set size(Size value) {
    super.size = value;
    _boxSize = value;
  }

  Future<Image> toImage([double pixelRatio = 1.0]) {
    assert(isRepaintBoundary);
    final OffsetLayer offsetLayer = layer as OffsetLayer;
    return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
  }

  @override
  void performLayout() {
    if (_viewportSize != null) {
      double width = _viewportSize!.width;
      double height = _viewportSize!.height - _bottomInset;
      if (height.isNegative || height.isNaN) {
        height = _viewportSize!.height;
      }
      Size preferredSize = Size(width, height);
      size = constraints.constrain(preferredSize);
    } else {
      if (constraints.biggest.isFinite) {
        size = constraints.biggest;
      } else {
        FlutterView currentView = controller.ownerFlutterView!;
        Size preferredSize = Size(
            math.min(constraints.maxWidth, currentView.physicalSize.width / currentView.devicePixelRatio),
            math.min(constraints.maxHeight, currentView.physicalSize.height / currentView.devicePixelRatio));
        size = constraints.constrain(preferredSize);
      }
    }

    RenderObject? child = firstChild;

    if (child != null && child is! RenderBoxModel) {
      child.layout(constraints);
    } else {
      while (child != null) {
        final ContainerBoxParentData<RenderObject> childParentData =
        child.parentData as ContainerBoxParentData<RenderObject>;

        RenderBoxModel rootRenderLayoutBox = child as RenderBoxModel;

        child.layout(rootRenderLayoutBox.getConstraints().tighten(width: size.width, height: size.height));

        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
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
      
      // Report FP when viewport background is painted
      controller.reportFP();
    }

    defaultPaint(context, offset);
  }

  // WebF page can reload the whole page.
  void reload() {
    removeAll();
  }

  @override
  void dispose() {
    removeAll();
    super.dispose();
  }
}

class RootRenderViewportBox extends RenderViewportBox {
  RootRenderViewportBox({required super.viewportSize, required super.controller, super.background});
}

class RouterViewViewportBox extends RenderViewportBox {
  RouterViewViewportBox({required super.viewportSize, required super.controller});
}
