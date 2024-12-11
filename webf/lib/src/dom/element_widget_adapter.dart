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
        key: flutter.ObjectKey(this), ownerElement: this as Element, child: _WebFElementWidget(this as Element));
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
    if (webFElement.childNodes.isEmpty) {
      children = List.empty();
    } else {
      children = (webFElement.childNodes as ChildNodeList).toWidgetList();
    }

    return WebFRenderLayoutWidgetAdaptor(
      webFElement: _webFElement,
      children: children,
      key: flutter.ObjectKey(_webFElement),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RenderLayoutWidgetChangeReason {}

class WebFRenderLayoutWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  WebFRenderLayoutWidgetAdaptor({this.webFElement, flutter.Key? key, required List<flutter.Widget> children})
      : super(key: key, children: children) {}

  final Element? webFElement;

  @override
  WebRenderLayoutWidgetElement createElement() {
    WebRenderLayoutWidgetElement element = ExternalWebRenderLayoutWidgetElement(webFElement!, this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    RenderBoxModel? renderObject = (context as WebRenderLayoutWidgetElement)
        .webFElement
        .updateOrCreateRenderBoxModel(flutterWidgetElement: context);
    return renderObject!;
  }

  @override
  String toStringShort() {
    return 'RenderObjectAdapter(${webFElement?.tagName.toLowerCase()})';
  }
}

abstract class WebRenderLayoutWidgetElement extends flutter.MultiChildRenderObjectElement {
  WebRenderLayoutWidgetElement(WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  @override
  WebFRenderLayoutWidgetAdaptor get widget => super.widget as WebFRenderLayoutWidgetAdaptor;

  Element get webFElement;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild() {
    _WebFElementWidgetState state = findAncestorStateOfType<_WebFElementWidgetState>()!;
    state.requestForChildNodeUpdate();
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    webFElement.didAttachRenderer();

    webFElement.applyStyle(webFElement.style);

    if (webFElement.ownerDocument.controller.mode != WebFLoadingMode.preRendering) {
      // Flush pending style before child attached.
      webFElement.style.flushPendingProperties();
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = webFElement;
    element.willDetachRenderer();
    super.unmount();
    element.didDetachRenderer();
  }
}

class ExternalWebRenderLayoutWidgetElement extends WebRenderLayoutWidgetElement {
  final Element _webfElement;

  ExternalWebRenderLayoutWidgetElement(this._webfElement, WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  @override
  Element get webFElement => _webfElement;
}
