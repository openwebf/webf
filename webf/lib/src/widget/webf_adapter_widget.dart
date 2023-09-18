/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';


class WebFWidgetElementStatefulWidget extends StatefulWidget {
  final WidgetElement widgetElement;

  WebFWidgetElementStatefulWidget(this.widgetElement, {Key? key}): super(key: key);

  @override
  StatefulElement createElement() {
    return WebFWidgetElementElement(this);
  }

  @override
  State<StatefulWidget> createState() {
    WebFWidgetElementState state = WebFWidgetElementState(widgetElement);
    widgetElement.state = state;
    return state;
  }
}

class WebFWidgetElementElement extends StatefulElement {
  WebFWidgetElementElement(super.widget);

  @override
  WebFWidgetElementStatefulWidget get widget => super.widget as WebFWidgetElementStatefulWidget;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    // Make sure RenderWidget had been created.
    if (widget.widgetElement.renderer == null) {
      widget.widgetElement.createRenderer();
    }
  }
}

class WebFWidgetElementState extends State<WebFWidgetElementStatefulWidget> {
  final WidgetElement widgetElement;

  WebFWidgetElementState(this.widgetElement);

  @override
  void initState() {
    super.initState();
    widgetElement.initState();
  }

  void requestUpdateState([VoidCallback? callback]) {
    if (mounted) {
      setState(callback ?? () {});
    }
  }

  List<Widget>? _cachedChildren;
  /// Return the previous built widget lists. When the DOM nodes change, the children property will be updated.
  List<Widget>? get children => _cachedChildren;

  void markChildrenNeedsUpdate() {
    _cachedChildren = null;
    if (mounted) {
      requestUpdateState();
    }
  }

  Widget buildNodeWidget(dom.Node node, {Key? key}) {
    if (node is dom.CharacterData) {
      return WebFCharacterDataToWidgetAdaptor(node, key: key);
    }
    return WebFHTMLElementStatefulWidget(node as dom.Element, key: key);
  }

  List<Widget> convertNodeListToWidgetList(List<dom.Node> childNodes) {
    if (_cachedChildren != null) return _cachedChildren!;

    List<Widget> children = [];

    for(dom.Node node in childNodes) {
      if (node is WidgetElement) {
        children.add((node.widget));
      } else if (node is dom.TextNode && node.data.isNotEmpty || node is dom.Element) {
        children.add(node.flutterWidget ?? buildNodeWidget(node, key: Key(node.hashCode.toString())));
      }
    }

    _cachedChildren = children;

    return children;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WidgetElement(${widgetElement.tagName}) adapterWidgetState';
  }

  @override
  Widget build(BuildContext context) {
    return widgetElement.build(context, convertNodeListToWidgetList(widgetElement.childNodes.where((node) => !node.createdByFlutterWidget).toList()));
  }
}
