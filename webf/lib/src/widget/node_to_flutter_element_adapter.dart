/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'node_to_widget_adaptor.dart';

class WebFNodeToFlutterElementAdaptor extends RenderObjectElement {
  WebFNodeToFlutterElementAdaptor(RenderObjectWidget widget) : super(widget);

  @override
  WebFNodeToWidgetAdaptor get widget => super.widget as WebFNodeToWidgetAdaptor;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget.webFNode.createRenderer();
    super.mount(parent, newSlot);

    widget.webFNode.ensureChildAttached();

    if (widget.webFNode is dom.Element) {
      dom.Element element = (widget.webFNode as dom.Element);
      element.applyStyle(element.style);

      if (element.renderer != null) {
        // Flush pending style before child attached.
        element.style.flushPendingProperties();
      }
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    dom.Node node = widget.webFNode;

    super.unmount();

    if (node is dom.Element) {
      node.unmountRenderObject(dispose: false);
    }
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {}
}
