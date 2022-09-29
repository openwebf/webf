/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';

/// Creates an element that is hosted by a [RenderObject].
class WebFRenderObjectToWidgetElement<T extends RenderObject> extends SingleChildRenderObjectElement {
  WebFRenderObjectToWidgetElement(WebFRenderObjectToWidgetAdapter<T> widget) : super(widget);

  @override
  WebFRenderObjectToWidgetAdapter get widget => super.widget as WebFRenderObjectToWidgetAdapter<T>;

  @override
  RenderObjectWithChildMixin<RenderObject> get renderObject => super.renderObject as RenderObjectWithChildMixin<RenderObject>;

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    renderObject.child = null;
  }
}
