/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFHTMLElement extends WebFRenderLayoutWidgetAdaptor {
  final String tagName;
  final Map<String, String>? inlineStyle;

  WebFHTMLElement({
    required this.tagName,
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
  WebRenderLayoutWidgetElement createElement() {
    return SelfOwnedWebRenderLayoutWidgetElement(this);
  }

  @override
  String toStringShort() {
    return 'WebFHTMLElement($tagName)';
  }
}

class SelfOwnedWebRenderLayoutWidgetElement extends WebRenderLayoutWidgetElement {
  SelfOwnedWebRenderLayoutWidgetElement(super.widget);

  dom.Element? _webFElement;

  RenderObject createRenderLayoutBox(String tagName) {
    WebFContextInheritElement? webfContext =
        getElementForInheritedWidgetOfExactType<WebFContext>() as WebFContextInheritElement;
    dom.Element element = dom.createElement(
        tagName,
        BindingContext(
            webfContext.controller!.view, webfContext.controller!.view.contextId, allocateNewBindingObject()));
    element.managedByFlutterWidget = true;
    _webFElement = element;
    return element.createRenderer(this);
  }

  @override
  dom.Element get webFElement => _webFElement!;
}
