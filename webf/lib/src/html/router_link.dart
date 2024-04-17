/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
  void attachWidget(Widget widget) {
    if (isRouterLinkElement && _path.isNotEmpty) {
      ownerView.setHybridRouterView(_path, widget);
    } else {
      super.attachWidget(widget);
    }
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return WebFHTMLElement(tagName: 'DIV', children: children);
  }
}
