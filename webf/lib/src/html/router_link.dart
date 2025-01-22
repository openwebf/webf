/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
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

  List<dom.Node> cachedChildNodes = [];

  @override
  void attachWidget(Widget widget) {
    if (isRouterLinkElement && _path.isNotEmpty) {
      ownerView.setHybridRouterView(_path, widget);
    } else {
      super.attachWidget(widget);
    }
  }

  @override
  void dispose() {
    super.dispose();
    cachedChildNodes.clear();
  }

  @override
  void detachWidget() {
    if (isRouterLinkElement && _path.isNotEmpty) {
      ownerView.removeHybridRouterView(_path);
    } else {
      super.detachWidget();
    }
  }

  @override
  void reactiveRenderer() {
    // Override default behavior to avoid reattach.
  }

  @override
  String toString() {
    return 'RouterLinkElement [path=$_path]';
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(tagName: 'DIV', children: childNodes.toWidgetList(), inlineStyle: {
      // 'overflow': 'auto',
      // 'position': 'relative'
    }, controller: ownerDocument.controller, parentElement: this);
  }
}
