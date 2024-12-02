/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';
import 'element.dart';
import 'node.dart';

mixin ElementAdapterMixin on ElementBase {
  @override
  flutter.Widget toWidget() {
    return Portal(
        ownerElement: this as Element,
        child: WebFHTMLElementStatefulWidget(this as Element, key: flutter.ObjectKey(this)));
  }
}

class WebFHTMLElementStatefulWidget extends flutter.StatefulWidget {
  final Element webFElement;

  WebFHTMLElementStatefulWidget(this.webFElement, {flutter.Key? key}) : super(key: key) {
    webFElement.managedByFlutterWidget = true;
  }

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return HTMLElementState(webFElement);
  }
}

class HTMLElementState extends flutter.State<WebFHTMLElementStatefulWidget> with flutter.AutomaticKeepAliveClientMixin {
  final Set<flutter.Widget> customElementWidgets = HashSet();
  final Element _webFElement;

  bool _disposed = false;

  HTMLElementState(this._webFElement);

  Node get webFElement => _webFElement;

  void addWidgetChild(flutter.Widget widget) {
    scheduleDelayForFrameCallback();
    Future.microtask(() {
      setState(() {
        customElementWidgets.add(widget);
      });
    });
  }

  void removeWidgetChild(flutter.Widget widget) {
    scheduleDelayForFrameCallback();
    Future.microtask(() {
      if (_disposed) return;
      setState(() {
        customElementWidgets.remove(widget);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _webFElement.flutterWidgetState = this;
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    customElementWidgets.clear();
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return WebFHTMLElementToWidgetAdaptor(
      _webFElement,
      children: customElementWidgets.toList(),
      key: flutter.ObjectKey(_webFElement),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WebFHTMLElementToWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  WebFHTMLElementToWidgetAdaptor(this._webFElement, {flutter.Key? key, required List<flutter.Widget> children})
      : super(key: key, children: children) {}

  final Element _webFElement;

  Element get webFElement => _webFElement;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild() {}

  @override
  WebFHTMLElementToFlutterElementAdaptor createElement() {
    WebFHTMLElementToFlutterElementAdaptor element = WebFHTMLElementToFlutterElementAdaptor(this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    // TODO obtains renderObjects from cache, since every renderObjectElements have it's corresponding renderObjects.
    RenderBoxModel? renderObject =
        _webFElement.updateOrCreateRenderBoxModel(flutterWidgetElement: context as flutter.Element);
    return renderObject!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFElement.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFElement.nodeName.toString())));
  }
}

class WebFHTMLElementToFlutterElementAdaptor extends flutter.MultiChildRenderObjectElement {
  WebFHTMLElementToFlutterElementAdaptor(WebFHTMLElementToWidgetAdaptor widget) : super(widget);

  @override
  WebFHTMLElementToWidgetAdaptor get widget => super.widget as WebFHTMLElementToWidgetAdaptor;

  Element get webFElement => widget.webFElement;

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    super.mount(parent, newSlot);
    widget.webFElement.ensureChildAttached(this);

    Element element = widget.webFElement;
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
    Element element = widget.webFElement;
    // @TODO return back when widget adapter 2.0 complete.
    // element.renderStyle.unmountWidgetRenderObject(this);
    super.unmount();
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant flutter.IndexedSlot<flutter.Element?> slot) {}

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant flutter.IndexedSlot<flutter.Element?> oldSlot,
      covariant flutter.IndexedSlot<flutter.Element?> newSlot) {}

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant Object? slot) {}
}
