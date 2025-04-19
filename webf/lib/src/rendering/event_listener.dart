/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/launcher.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;

class RenderPortalsParentData extends RenderLayoutParentData {}

class RenderEventListener extends RenderBoxModel
    with
        RenderObjectWithChildMixin<RenderBox>,
        RenderProxyBoxMixin<RenderBox> {
  RenderEventListener({
    required CSSRenderStyle renderStyle,
    required this.controller
  }) : super(renderStyle: renderStyle) {
    _gestureDispatcher = GestureDispatcher(renderStyle.target);
  }

  WebFController controller;

  late GestureDispatcher _gestureDispatcher;
  GestureDispatcher? get gestureDispatcher => _gestureDispatcher;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderPortalsParentData) {
      child.parentData = RenderPortalsParentData();
    }
  }

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    parent?.markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();

    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // Set the size of scrollable overflow area for Portal.
    if (child is RenderBoxModel) {
      scrollableSize = (child as RenderBoxModel).scrollableSize;
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);

    _gestureDispatcher.handlePointerEvent(event);

    if (event is PointerDownEvent) {
      rawPointerListener.recordEventTarget(renderStyle.target);
    }
  }
}
