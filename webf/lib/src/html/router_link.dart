/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/widget.dart';

const ROUTER_LINK = 'WEBF-ROUTER-LINK';

class RouterLinkElement extends WidgetElement {
  RouterLinkElement(super.context);

  @override
  bool isRouterLinkElement = true;

  String _path = '';

  @override
  void setAttribute(String key, String value) {
    super.setAttribute(key, value);

    if (key == 'path') {
      _path = value;
    }
  }

  @override
  void mount() {
    dispatchEvent(Event('mount'));
  }

  @override
  void unmount() {
    dispatchEvent(Event('unmount'));
  }

  @override
  void attachWidget() {
    if (isRouterLinkElement && _path.isNotEmpty) {
      ownerView.setHybridRouterView(_path, this);
      managedByFlutterWidget = true;
    } else {
      super.attachWidget();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    if (_path.isNotEmpty) {
      ownerView.removeHybridRouterView(_path);
    }
  }

  @override
  void reactiveRenderer() {
    // Override default behavior to avoid reattach.
  }

  @override
  String toString({ flutter.DiagnosticLevel minLevel = flutter.DiagnosticLevel.info }) {
    return 'RouterLinkElement [path=$_path]';
  }

  @override
  flutter.Widget build(flutter.BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(tagName: 'DIV', children: childNodes.toWidgetList(), inlineStyle: {
      // 'overflow': 'auto',
      'position': 'relative'
    }, controller: ownerDocument.controller, parentElement: this);
  }
}
