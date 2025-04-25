/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

/// Portal is essential to capture WebF gestures on WebF elements when the renderObject is located outside of WebF's root renderObject tree.
/// Exp: using [showModalBottomSheet] or [showDialog], it will create a standalone Widget Tree alone side with the original Widget Tree.
/// Use this widget to make the gesture dispatcher works.
class WebFEventListener extends SingleChildRenderObjectWidget {
  final dom.Element ownerElement;
  final bool hasEvent;
  final bool enableTouchEvent;

  WebFEventListener(
      {Widget? child, required this.ownerElement, Key? key, required this.hasEvent, this.enableTouchEvent = false})
      : super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (enableTouchEvent) {
      return RenderTouchEventListener(
          renderStyle: ownerElement.renderStyle, controller: ownerElement.ownerDocument.controller, hasEvent: hasEvent);
    }
    return RenderEventListener(
        controller: ownerElement.ownerDocument.controller, renderStyle: ownerElement.renderStyle, hasEvent: hasEvent);
  }

  @override
  void updateRenderObject(BuildContext context, RenderEventListener renderObject) {
    super.updateRenderObject(context, renderObject);
    if (hasEvent) {
      renderObject.enableEventCapture();
    } else {
      renderObject.disabledEventCapture();
    }
  }
}
