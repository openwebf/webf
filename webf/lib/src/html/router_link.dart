/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

// ignore: constant_identifier_names
const ROUTER_LINK = 'WEBF-ROUTER-LINK';

class RouterLinkElement extends WidgetElement {
  RouterLinkElement(BindingContext? context) : super(context) {
    if (context != null) {
      ownerView.window.watchViewportSizeChangeForElement(this);
    }
  }

  @override
  Map<String, dynamic> get defaultStyle => {DISPLAY: BLOCK};

  @override
  bool get allowsInfiniteWidth => true;

  @override
  bool get isRouterLinkElement => true;

  String path = '';

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);

    if (qualifiedName == 'path') {
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
  flutter.Key get key => flutter.ValueKey('WEBF_ROUTER_LINK_$path');


  @override
  void connectedCallback() {
    super.connectedCallback();
    if (path.isNotEmpty) {
      ownerView.setHybridRouterView(path, this);
    }

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
    if (path.isNotEmpty) {
      ownerView.removeHybridRouterView(path);
    }
  }

  @override
  String toString({flutter.DiagnosticLevel minLevel = flutter.DiagnosticLevel.info}) {
    return 'RouterLinkElement [path=$path]';
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
      for (var node in widgetElement.childNodes) {
        if (node is Element &&
            (node.renderStyle.position == CSSPositionType.sticky ||
                node.renderStyle.position == CSSPositionType.absolute)) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
          children.add(node.toWidget());
          continue;
        } else if (node is Element && node.renderStyle.position == CSSPositionType.fixed) {
          children.add(PositionPlaceHolder(node.holderAttachedPositionedElement!, node));
        } else {
          children.add(node.toWidget());
        }
      }
    }

    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'ROUTER_LINK',
            inlineStyle: {'position': 'relative'},
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: children));
  }
}
