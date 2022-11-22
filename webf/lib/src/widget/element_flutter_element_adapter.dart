/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';

class WebFElementToFlutterElementAdaptor extends MultiChildRenderObjectElement {
  WebFElementToFlutterElementAdaptor(WebFElementToWidgetAdaptor widget) : super(widget);

  @override
  WebFElementToWidgetAdaptor get widget => super.widget as WebFElementToWidgetAdaptor;

  dom.Element get webFElement => widget.webFElement;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget.webFElement.createRenderer();
    super.mount(parent, newSlot);

    widget.webFElement.ensureChildAttached();

    dom.Element element = widget.webFElement;
    element.applyStyle(element.style);

    if (element.renderer != null) {
      // Flush pending style before child attached.
      element.style.flushPendingProperties();
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    dom.Element element = widget.webFElement;

    super.unmount();

    element.unmountRenderObject(dispose: false, fromFlutterWidget: true);
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant IndexedSlot<Element?> slot) {
  }
  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant IndexedSlot<Element?> oldSlot, covariant IndexedSlot<Element?> newSlot) {
  }
  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant Object? slot) {
  }
}
