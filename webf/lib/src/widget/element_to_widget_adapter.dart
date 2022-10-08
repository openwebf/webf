/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFElementWidget extends StatefulWidget {
  final dom.Element _webFElement;
  WebFElementWidget(this._webFElement, {Key? key}): super(key: key) {
    _webFElement.flutterWidget = this;
    _webFElement.managedByFlutterWidget = true;
  }

  @override
  State<StatefulWidget> createState() {
    return WebFElementState(_webFElement);
  }
}

class WebFElementState extends State<WebFElementWidget> {
  final Set<Widget> customElementWidgets = HashSet();
  final dom.Element _webFElement;

  bool _disposed = false;

  WebFElementState(this._webFElement);
  dom.Node get webFElement => _webFElement;

  void addWidgetChild(Widget widget) {
    Future.microtask(() {
      setState(() {
        customElementWidgets.add(widget);
      });
    });
  }
  void removeWidgetChild(Widget widget) {
    Future.microtask(() {
      if (_disposed) return;
      setState(() {
        customElementWidgets.remove(widget);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _webFElement.flutterWidgetState = this;
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    customElementWidgets.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WebFElementToWidgetAdaptor(_webFElement, children: customElementWidgets.toList());
  }
}

class WebFElementToWidgetAdaptor extends MultiChildRenderObjectWidget {
  WebFElementToWidgetAdaptor(this._webFElement, {Key? key, required List<Widget> children})
      : super(key: key, children: children) {
  }

  final dom.Element _webFElement;
  dom.Element get webFElement => _webFElement;

  @override
  WebFElementToFlutterElementAdaptor createElement() {
    _webFElement.flutterElement = WebFElementToFlutterElementAdaptor(this);
    return _webFElement.flutterElement!;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _webFElement.renderer!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFElement.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFElement.nodeName.toString())));
  }
}
