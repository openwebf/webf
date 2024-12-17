/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'package:webf/launcher.dart';
import 'package:webf/widget.dart';
import 'element.dart';
import 'node.dart';

mixin ElementAdapterMixin on ElementBase {
  @override
  flutter.Widget toWidget({Key? key}) {
    flutter.Widget child = Portal(
        key: key ?? flutter.ObjectKey(this), ownerElement: this as Element, child: _WebFElementWidget(this as Element));

    if ((this as Element).isRepaintBoundary) {
      child = flutter.RepaintBoundary(child: child);
    }
    return child;
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

class WebFReplacedElementWidget extends flutter.SingleChildRenderObjectWidget {
  final Element webFElement;

  WebFReplacedElementWidget({required this.webFElement, flutter.Key? key, flutter.Widget? child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    return webFElement.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement)!;
  }

  @override
  flutter.SingleChildRenderObjectElement createElement() {
    return WebFRenderReplacedRenderObjectElement(this);
  }
}

class WebFRenderReplacedRenderObjectElement extends flutter.SingleChildRenderObjectElement {
  WebFRenderReplacedRenderObjectElement(super.widget);

  @override
  WebFReplacedElementWidget get widget => super.widget as WebFReplacedElementWidget;

  // The renderObjects held by this adapter needs to be upgrade, from the requirements of the DOM tree style changes.
  void requestForBuild(RenderObjectUpdateReason reason) {
    if (reason == RenderObjectUpdateReason.updateChildNodes) return;

    visitChildElements((flutter.Element childElement) {
      if (childElement is flutter.StatefulElement) {
        childElement.markNeedsBuild();
      }
    });
  }

  @override
  void mount(flutter.Element? parent, Object? newSlot) {
    Element webFElement = widget.webFElement;
    webFElement.willAttachRenderer(this);

    super.mount(parent, newSlot);

    webFElement.didAttachRenderer(this);

    webFElement.applyStyle(webFElement.style);

    if (webFElement.ownerDocument.controller.mode != WebFLoadingMode.preRendering) {
      // Flush pending style before child attached.
      webFElement.style.flushPendingProperties();
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    Element element = widget.webFElement;
    element.willDetachRenderer(this);
    super.unmount();
    element.didDetachRenderer(this);
  }
}

class WebFRenderLayoutWidgetAdaptor extends flutter.MultiChildRenderObjectWidget {
  WebFRenderLayoutWidgetAdaptor({this.webFElement, flutter.Key? key, required List<flutter.Widget> children})
      : super(key: key, children: children) {}

  final Element? webFElement;

  @override
  WebRenderLayoutRenderObjectElement createElement() {
    WebRenderLayoutRenderObjectElement element = ExternalWebRenderLayoutWidgetElement(webFElement!, this);
    return element;
  }

  @override
  flutter.RenderObject createRenderObject(flutter.BuildContext context) {
    return webFElement!.renderStyle.getWidgetPairedRenderBoxModel(context as flutter.RenderObjectElement)!;
  }

  @override
  String toStringShort() {
    return 'RenderObjectAdapter(${webFElement?.tagName.toLowerCase()})';
  }
}

abstract class WebRenderLayoutRenderObjectElement extends flutter.MultiChildRenderObjectElement {
  WebRenderLayoutRenderObjectElement(WebFRenderLayoutWidgetAdaptor widget) : super(widget);

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
    webFElement.willAttachRenderer(this);
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
    element.willDetachRenderer(this);
    super.unmount();
    element.didDetachRenderer(this);
  }
}

class ExternalWebRenderLayoutWidgetElement extends WebRenderLayoutRenderObjectElement {
  final Element _webfElement;

  ExternalWebRenderLayoutWidgetElement(this._webfElement, WebFRenderLayoutWidgetAdaptor widget) : super(widget);

  @override
  Element get webFElement => _webfElement;
}
