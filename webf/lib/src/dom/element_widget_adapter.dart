/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';
import 'element.dart';
import 'node.dart';

mixin ElementAdapterMixin on ElementBase {
  @override
  flutter.Widget toWidget() {
    return Portal(
        key: flutter.ObjectKey(this),
        ownerElement: this as Element,
        child: _WebFElementWidget(this as Element));
  }
}

class _WebFElementWidget extends flutter.StatefulWidget {
  final Element webFElement;

  _WebFElementWidget(this.webFElement, {flutter.Key? key}) : super(key: key) {
    webFElement.managedByFlutterWidget = true;
  }

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return _WebFElementWidgetState(webFElement);
  }

  @override
  String toStringShort() {
    String attributes = '';
    if (webFElement.id != null) {
      attributes += 'id="' + webFElement.id! + '"';
    }
    if (webFElement.className.isNotEmpty) {
      attributes += 'class="' + webFElement.className + '"';
    }

    return '<${webFElement.tagName.toLowerCase()} $attributes>';
  }
}

class _WebFElementWidgetState extends flutter.State<_WebFElementWidget> with flutter.AutomaticKeepAliveClientMixin {
  final Element _webFElement;

  _WebFElementWidgetState(this._webFElement);

  Node get webFElement => _webFElement;

  void requestForChildNodeUpdate() {
    setState(() {});
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    super.build(context);
    List<flutter.Widget> children;
    if (_webFElement.childNodes.isEmpty) {
      children = List.empty();
    } else {
      children = (webFElement.childNodes as ChildNodeList).toWidgetList();
    }

    return WebFRenderLayoutWidgetAdaptor(
      _webFElement,
      children: children,
      key: flutter.ObjectKey(_webFElement),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RenderLayoutWidgetChangeReason {

}

class WebFRenderLayoutWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  WebFRenderLayoutWidgetAdaptor(this._webFElement, {flutter.Key? key, required List<flutter.Widget> children})
      : super(key: key, children: children) {}

  final Element _webFElement;

  Element get webFElement => _webFElement;

  @override
  WebRenderLayoutWidgetElement createElement() {
    WebRenderLayoutWidgetElement element = WebRenderLayoutWidgetElement(this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    // TODO obtains renderObjects from cache, since every renderObjectElements have it's corresponding renderObjects.
    RenderBoxModel? renderObject =
        _webFElement.updateOrCreateRenderBoxModel(flutterWidgetElement: context as WebRenderLayoutWidgetElement);
    return renderObject!;
  }

  @override
  String toStringShort() {
    return 'RenderObjectAdapter(${_webFElement.tagName.toLowerCase()})';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFElement.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFElement.nodeName.toString())));
  }
}

class WebRenderLayoutWidgetElement extends flutter.MultiChildRenderObjectElement {
  WebRenderLayoutWidgetElement(WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  @override
  WebFRenderLayoutWidgetAdaptor get widget => super.widget as WebFRenderLayoutWidgetAdaptor;

  Element get webFElement => widget.webFElement;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild() {
    _WebFElementWidgetState state = findAncestorStateOfType<_WebFElementWidgetState>()!;
    state.requestForChildNodeUpdate();
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    // if (enableWebFProfileTracking) {
    //   WebFProfiler.instance.startTrackUICommand();
    // }
    super.mount(parent, newSlot);
    // widget.webFElement.ensureChildAttached(this);
    //
    // Element element = widget.webFElement;
    // element.applyStyle(element.style);
    //
    // if (element.renderStyle.domRenderBoxModel != null) {
    //   if (element.ownerDocument.controller.mode != WebFLoadingMode.preRendering) {
    //     // Flush pending style before child attached.
    //     element.style.flushPendingProperties();
    //   }
    // }
    // if (enableWebFProfileTracking) {
    //   WebFProfiler.instance.finishTrackUICommand();
    // }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = widget.webFElement;
    // @TODO return back when widget adapter 2.0 complete.
    // element.renderStyle.unmountWidgetRenderObject(this);
    super.unmount();
  }
}
