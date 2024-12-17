/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFHTMLElement extends WebFRenderLayoutWidgetAdaptor {
  final String tagName;
  final WebFController controller;
  final Map<String, String>? inlineStyle;

  WebFHTMLElement({
    required this.tagName,
    required this.controller,
    Key? key,
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
  void mount(Element? parent, Object? newSlot) {
    dom.Element element = dom.createElement(
        tagName,
        BindingContext(controller.view, controller.view.contextId, allocateNewBindingObject()));
    element.managedByFlutterWidget = true;
    _webFElement = element;

    super.mount(parent, newSlot);
  }

  @override
  dom.Element get webFElement => _webFElement!;
}
