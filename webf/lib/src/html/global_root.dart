/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

// ignore: constant_identifier_names
const GLOBAL_ROOT = 'WEBF-GLOBAL-ROOT';

class GlobalRootElement extends WidgetElement {
  GlobalRootElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {DISPLAY: BLOCK};

  @override
  flutter.Key get key => const flutter.ValueKey('WEBF_GLOBAL_ROOT');

  @override
  void connectedCallback() {
    super.connectedCallback();
    ownerView.setGlobalRoot(this);
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    ownerView.removeGlobalRoot(this);
  }

  @override
  WebFWidgetElementState createState() {
    return GlobalRootElementState(this);
  }
}

class GlobalRootElementState extends WebFWidgetElementState {
  GlobalRootElementState(super.widgetElement);

  @override
  GlobalRootElement get widgetElement => super.widgetElement as GlobalRootElement;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    List<flutter.Widget> children = [];
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

    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'GLOBAL_ROOT',
            inlineStyle: const {'position': 'relative'},
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: children));
  }
}
