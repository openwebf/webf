/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFHTMLElementToWidgetAdaptor extends StatefulWidget {
  final dom.Element _webFElement;
  WebFHTMLElementToWidgetAdaptor(this._webFElement, {Key? key}): super(key: key) {
    _webFElement.flutterWidget = this;
    _webFElement.managedByFlutterWidget = true;
  }

  @override
  State<StatefulWidget> createState() {
    return HTMLElementState(_webFElement);
  }
}

class HTMLElementState extends State<WebFHTMLElementToWidgetAdaptor> {
  final Set<Widget> customElementWidgets = HashSet();
  final dom.Element _webFElement;

  bool _disposed = false;

  HTMLElementState(this._webFElement);
  dom.Node get webFElement => _webFElement;

  void addWidgetChild(Widget widget) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        customElementWidgets.add(widget);
      });
    });
  }
  void removeWidgetChild(Widget widget) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
