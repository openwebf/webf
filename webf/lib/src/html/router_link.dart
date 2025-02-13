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
      ownerView.setHybridRouterView(_path, this);
    }
  }

  @override
  flutter.Key get key => flutter.ValueKey('WEBF_ROUTER_LINK_$_path');

  @override
  void mount() {
    dispatchEvent(Event('mount'));
  }

  @override
  void unmount() {
    dispatchEvent(Event('unmount'));
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
  String toString({ flutter.DiagnosticLevel minLevel = flutter.DiagnosticLevel.info }) {
    return 'RouterLinkElement [path=$_path]';
  }

  @override
  flutter.Widget build(flutter.BuildContext context, ChildNodeList childNodes) {
    WebFRouterViewState? routerViewState = context.findAncestorStateOfType<WebFRouterViewState>();
    WebFState? webFState = context.findAncestorStateOfType<WebFState>();

    if ((webFState != null && webFState.widget.controller.initialRoute == _path) || routerViewState != null) {
      return WebFHTMLElement(tagName: 'DIV', children: childNodes.toWidgetList(), inlineStyle: {
        // 'overflow': 'auto',
        'position': 'relative'
      }, controller: ownerDocument.controller, parentElement: this);
    }

    return flutter.SizedBox.shrink();
  }
}
