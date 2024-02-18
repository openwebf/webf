/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

class WebFHTMLElementStatefulWidget extends StatefulWidget {
  final dom.Element webFElement;
  WebFHTMLElementStatefulWidget(this.webFElement, {Key? key}): super(key: key) {
    webFElement.flutterWidget = this;
    webFElement.managedByFlutterWidget = true;
  }

  @override
  State<StatefulWidget> createState() {
    return HTMLElementState(webFElement);
  }
}

class HTMLElementState extends State<WebFHTMLElementStatefulWidget> {
  final Set<Widget> customElementWidgets = {};
  final dom.Element _webFElement;

  bool _disposed = false;

  HTMLElementState(this._webFElement);
  dom.Node get webFElement => _webFElement;

  void addWidgetChild(Widget widget) {
    setState(() {
      customElementWidgets.add(widget);
    });
  }
  void removeWidgetChild(Widget widget) {
    if (_disposed) return;
    setState(() {
      customElementWidgets.remove(widget);
    });
  }

  @override
  void initState() {
    super.initState();
    _webFElement.flutterWidgetState = this;
    if (_webFElement.pendingSubWidgets.isNotEmpty) {
      _webFElement.pendingSubWidgets.forEach((widget) {
        customElementWidgets.add(widget);
      });
      _webFElement.pendingSubWidgets.clear();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    customElementWidgets.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WebFHTMLElementToWidgetAdaptor(_webFElement, children: customElementWidgets.toList(), key: ObjectKey(_webFElement.hashCode),);
  }
}

class WebFHTMLElementToWidgetAdaptor extends MultiChildRenderObjectWidget {
  WebFHTMLElementToWidgetAdaptor(this._webFElement, {Key? key, required List<Widget> children})
      : super(key: key, children: children) {
  }

  final dom.Element _webFElement;
  dom.Element get webFElement => _webFElement;

  @override
  WebFHTMLElementToFlutterElementAdaptor createElement() {
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    WebFHTMLElementToFlutterElementAdaptor element = WebFHTMLElementToFlutterElementAdaptor(this);
    // If a WebF element was already connected to a flutter element, should unmount the previous linked renderObjectt
    if (_webFElement.flutterWidgetElement != null && _webFElement.flutterWidgetElement != element) {
      _webFElement.unmountRenderObject(dispose: false, fromFlutterWidget: true);
    }

    _webFElement.flutterWidgetElement = element;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }

    return element;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _webFElement.createRenderer();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFElement.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFElement.nodeName.toString())));
  }
}
