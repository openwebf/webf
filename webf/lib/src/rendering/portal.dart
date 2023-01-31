/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/launcher.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;

class RenderPortalsParentData extends ContainerBoxParentData<RenderPortal> {}

class RenderPortal extends RenderBox
    with
        RenderEventListenerMixin,
        RenderObjectWithChildMixin<RenderBox>,
        RenderProxyBoxMixin<RenderBox> {
  RenderPortal({
    required this.controller
  });

  WebFController controller;

  final GestureDispatcher _gestureDispatcher = GestureDispatcher();

  @override
  GestureDispatcher? get gestureDispatcher => _gestureDispatcher;

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = RenderPortalsParentData();
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
