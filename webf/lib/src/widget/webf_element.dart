/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFHTMLElement extends WebFRenderLayoutWidgetAdaptor {
  final String tagName;
  final WebFController controller;
  final dom.Element? parentElement;
  final Map<String, String>? inlineStyle;

  WebFHTMLElement({
    required this.tagName,
    required this.controller,
    Key? key,
    required this.parentElement,
    required List<Widget> children,
    this.inlineStyle,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    SelfOwnedWebRenderLayoutWidgetElement element = context as SelfOwnedWebRenderLayoutWidgetElement;
    return element.createRenderLayoutBox(tagName);
  }

  @override
  WebRenderLayoutRenderObjectElement createElement() {
    return SelfOwnedWebRenderLayoutWidgetElement(this, tagName, controller);
  }

  @override
  String toStringShort() {
    return 'WebFHTMLElement($tagName)';
  }
}

class SelfOwnedWebRenderLayoutWidgetElement extends WebRenderLayoutRenderObjectElement {
  SelfOwnedWebRenderLayoutWidgetElement(super.widget, this.tagName, this.controller);

  dom.Element? _webFElement;
  String tagName;
  WebFController controller;

  RenderObject createRenderLayoutBox(String tagName) {
    return _webFElement!.renderStyle.getWidgetPairedRenderBoxModel(this)!;
  }

  @override
  WebFHTMLElement get widget => super.widget as WebFHTMLElement;

  dom.Element? findClosestAncestorHTMLElement(Element? parent) {
    if (parent == null) return null;
    dom.Element? target;
    parent.visitAncestorElements((Element element) {
      if (element is WebFWidgetElementAdapterElement) {
        target = element.widget.widgetElement;
        return false;
      } else if (element is SelfOwnedWebRenderLayoutWidgetElement) {
        target = element._webFElement;
        return false;
      } else if (element is ExternalWebRenderLayoutWidgetElement) {
        target = element.webFElement;
        return false;
      }
      return true;
    });
    return target;
  }

  void fullFillInlineStyle(Map<String, String> inlineStyle) {
    inlineStyle.forEach((key, value) {
      _webFElement!.setInlineStyle(key, value);
    });
    _webFElement!.recalculateStyle();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    dom.Element element = dom.createElement(
        tagName,
        BindingContext(controller.view, controller.view.contextId, allocateNewBindingObject()));
    element.managedByFlutterWidget = true;
    element.parentOrShadowHostNode = widget.parentElement;
    element.isWidgetOwned = true;
    _webFElement = element;

    super.mount(parent, newSlot);

    dom.Element? parentElement = findClosestAncestorHTMLElement(this);

    if (parentElement != null) {
      if (widget.inlineStyle != null) {
        fullFillInlineStyle(widget.inlineStyle!);
      }

      // htmlElement!.ensureChildAttached();
      _webFElement!.applyStyle(_webFElement!.style);

      if (_webFElement!.ownerDocument.controller.mode != WebFLoadingMode.preRendering) {
        // Flush pending style before child attached.
        _webFElement!.style.flushPendingProperties();
      }
    }
  }

  @override
  void unmount() {
    _webFElement!.willDetachRenderer(this);
    super.unmount();
    _webFElement!.didDetachRenderer(this);
    _webFElement!.parentOrShadowHostNode = null;
    WebFViewController.disposeBindingObject(_webFElement!.ownerView, _webFElement!.pointer!);
    _webFElement = null;
  }

  @override
  dom.Element get webFElement => _webFElement!;
}
