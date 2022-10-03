/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'node_to_widget_adaptor.dart';

class WebFNodeToFlutterElementAdaptor extends MultiChildRenderObjectElement {
  WebFNodeToFlutterElementAdaptor(WebFElementToWidgetAdaptor widget) : super(widget);

  @override
  WebFElementToWidgetAdaptor get widget => super.widget as WebFElementToWidgetAdaptor;

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
}
