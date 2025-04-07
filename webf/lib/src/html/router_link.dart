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
  String get path => _path;

  @override
  void setAttribute(String key, String value) {
    super.setAttribute(key, value);

    if (key == 'path') {
      _path = value;
      ownerView.setHybridRouterView(_path, this);
    }
  }

  @override
  flutter.Key get key => flutter.ValueKey('WEBF_ROUTER_LINK_$_path');

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    if (path == ownerDocument.controller.initialRoute) {
      dispatchEvent(Event('pode'));
    }
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    if (_path.isNotEmpty) {
      ownerView.removeHybridRouterView(_path);
    }
  }

  @override
  String toString({ flutter.DiagnosticLevel minLevel = flutter.DiagnosticLevel.info }) {
    return 'RouterLinkElement [path=$_path]';
  }

  @override
  flutter.Widget build(flutter.BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(tagName: 'DIV', children: childNodes.toWidgetList(), inlineStyle: {
      'position': 'relative'
    }, controller: ownerDocument.controller, parentElement: this);
  }
}
