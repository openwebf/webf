/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

const ROUTER_LINK = 'WEBF-ROUTER-LINK';

class RouterLinkElement extends WidgetElement {
  RouterLinkElement(super.context);

  @override
  bool isRouterLinkElement = true;

  String _path = '';

  String get path => _path;
  set path(String value) {
    _path = value;
    ownerView.setHybridRouterView(_path, this);
  }

  @override
  void setAttribute(String key, String value) {
    super.setAttribute(key, value);

    if (key == 'path') {
      path = value;
    }
  }

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
  // https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
  static final StaticDefinedBindingPropertyMap _routeLinkProperties = {
    'path': StaticDefinedBindingProperty(
        getter: (element) => castToType<RouterLinkElement>(element).path,
        setter: (element, value) => castToType<RouterLinkElement>(element).path = value),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _routeLinkProperties];

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

  String? getRenderObjectTree() {
    return state?.getRenderObjectTree();
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    if (_path.isNotEmpty) {
      ownerView.removeHybridRouterView(_path);
    }
  }

  @override
  String toString({flutter.DiagnosticLevel minLevel = flutter.DiagnosticLevel.info}) {
    return 'RouterLinkElement [path=$_path]';
  }

  @override
  WebFWidgetElementState createState() {
    return RouterLinkElementState(this);
  }
}

class RouterLinkElementState extends WebFWidgetElementState {
  RouterLinkElementState(super.widgetElement);

  @override
  RouterLinkElement get widgetElement => super.widgetElement as RouterLinkElement;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    List<flutter.Widget> children = [];
    if (widgetElement.childNodes.isEmpty) {
      children = [];
    } else {
      widgetElement.childNodes.forEach((node) {
        if (node is Element &&
            (node.renderStyle.position == CSSPositionType.sticky ||
                node.renderStyle.position == CSSPositionType.absolute)) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          children.add(node.toWidget());
          return;
        } else if (node is Element && node.renderStyle.position == CSSPositionType.fixed) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
        } else {
          children.add(node.toWidget());
        }
      });
    }

    return WebFHTMLElement(
        tagName: 'DIV',
        children: children,
        inlineStyle: {'position': 'relative'},
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement);
  }
}
