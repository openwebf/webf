library webf;

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'node_to_flutter_element_adapter.dart';

class WebFNodeWidget extends StatefulWidget {
  final dom.Node _webFNode;
  WebFNodeWidget(this._webFNode, {Key? key}): super(key: key) {
    _webFNode.flutterWidget = this;
    _webFNode.managedByFlutterWidget = true;
  }

  @override
  State<StatefulWidget> createState() {
    return WebFNodeState(_webFNode);
  }
}

class WebFNodeState extends State<WebFNodeWidget> {
  final Set<Widget> customElementWidgets = {};
  final dom.Node _webFNode;

  WebFNodeState(this._webFNode);
  dom.Node get webFNode => _webFNode;

  void addWidgetChild(Widget widget) {
    Future.microtask(() {
      setState(() {
        customElementWidgets.add(widget);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _webFNode.flutterWidgetState = this;
  }

  @override
  Widget build(BuildContext context) {
    return WebFElementToWidgetAdaptor(webFNode, children: customElementWidgets.toList());
  }
}

class WebFElementToWidgetAdaptor extends MultiChildRenderObjectWidget {
  WebFElementToWidgetAdaptor(this._webFNode, {Key? key, required List<Widget> children})
      : super(key: key, children: children) {
  }

  final dom.Node _webFNode;
  dom.Node get webFNode => _webFNode;

  @override
  WebFNodeToFlutterElementAdaptor createElement() {
    _webFNode.flutterElement = WebFNodeToFlutterElementAdaptor(this);
    return _webFNode.flutterElement!;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _webFNode.renderer!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFNode.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFNode.nodeName.toString())));
  }
}
