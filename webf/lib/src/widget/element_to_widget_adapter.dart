/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

class WebFHTMLElementStatefulWidget extends StatefulWidget {
  final dom.Element webFElement;
  WebFHTMLElementStatefulWidget(this.webFElement, {Key? key}): super(key: key) {
    webFElement.managedByFlutterWidget = true;
  }

  @override
  State<StatefulWidget> createState() {
    return HTMLElementState(webFElement);
  }
}

class HTMLElementState extends State<WebFHTMLElementStatefulWidget> with AutomaticKeepAliveClientMixin {
  final Set<Widget> customElementWidgets = HashSet();
  final dom.Element _webFElement;

  bool _disposed = false;

  HTMLElementState(this._webFElement);

  dom.Node get webFElement => _webFElement;

  void addWidgetChild(Widget widget) {
    scheduleDelayForFrameCallback();
    Future.microtask(() {
      setState(() {
        customElementWidgets.add(widget);
      });
    });
  }

  void removeWidgetChild(Widget widget) {
    scheduleDelayForFrameCallback();
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
    return WebFHTMLElementToWidgetAdaptor(
      _webFElement,
      children: customElementWidgets.toList(),
      key: ObjectKey(_webFElement.hashCode),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WebFHTMLElementToWidgetAdaptor extends MultiChildRenderObjectWidget {
  WebFHTMLElementToWidgetAdaptor(this._webFElement, {Key? key, required List<Widget> children})
      : super(key: key, children: children) {}

  final dom.Element _webFElement;

  dom.Element get webFElement => _webFElement;

  @override
  WebFHTMLElementToFlutterElementAdaptor createElement() {
    WebFHTMLElementToFlutterElementAdaptor element = WebFHTMLElementToFlutterElementAdaptor(this);
    _webFElement.flutterWidgetElement = element;
    return element;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    RenderBoxModel? renderObject = _webFElement.updateOrCreateRenderBoxModel(
        forceUpdate: true, ignoreChild: true);
    return renderObject!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFElement.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFElement.nodeName.toString())));
  }
}
