/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/launcher.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;

class RenderPortalsParentData extends ContainerBoxParentData<RenderPortal> {}

class RenderPortal extends RenderBoxModel
    with
        RenderEventListenerMixin,
        RenderObjectWithChildMixin<RenderBox>,
        RenderProxyBoxMixin<RenderBox> {
  RenderPortal({
    required CSSRenderStyle renderStyle,
    required this.controller
  }) : super(renderStyle: renderStyle);

  WebFController controller;

  final GestureDispatcher _gestureDispatcher = GestureDispatcher();

  @override
  GestureDispatcher? get gestureDispatcher => _gestureDispatcher;

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = RenderPortalsParentData();
  }

  @override
  void performLayout() {
    super.performLayout();


    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);

    _gestureDispatcher.handlePointerEvent(event);

    // controller!.gestureDispatcher.handlePointerEvent(event);
    if (event is PointerDownEvent) {
      // Set event path at begin stage and reset it at end stage on viewport render box.
      _gestureDispatcher.resetEventPath();
    }
  }
}
