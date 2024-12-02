/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/widget.dart';

class WebFHTMLElementToFlutterElementAdaptor extends MultiChildRenderObjectElement {
  WebFHTMLElementToFlutterElementAdaptor(WebFHTMLElementToWidgetAdaptor widget) : super(widget);

  @override
  WebFHTMLElementToWidgetAdaptor get widget => super.widget as WebFHTMLElementToWidgetAdaptor;

  dom.Element get webFElement => widget.webFElement;

  @override
  void mount(Element? parent, Object? newSlot) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    super.mount(parent, newSlot);
    widget.webFElement.ensureChildAttached(this);

    dom.Element element = widget.webFElement;
    element.applyStyle(element.style);

    if (element.renderStyle.domRenderBoxModel != null) {
      if (element.ownerDocument.controller.mode != WebFLoadingMode.preRendering) {
        // Flush pending style before child attached.
        element.style.flushPendingProperties();
      }
    }
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    dom.Element element = widget.webFElement;
    // @TODO return back when widget adapter 2.0 complete.
    // element.renderStyle.unmountWidgetRenderObject(this);
    super.unmount();
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
