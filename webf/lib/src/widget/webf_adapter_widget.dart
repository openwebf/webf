/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'widget_element.dart';
import 'node_to_widget_adaptor.dart';


class WebFWidgetElementWidget extends StatefulWidget {
  final WidgetElement widgetElement;

  WebFWidgetElementWidget(this.widgetElement, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    WebFWidgetElementState state = WebFWidgetElementState(widgetElement);
    widgetElement.state = state;
    return state;
  }
}

class WebFWidgetElementState extends State<WebFWidgetElementWidget> {
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

  List<Widget> convertNodeListToWidgetList(List<dom.Node> childNodes) {
    List<Widget> children = List.generate(childNodes.length, (index) {
      if (childNodes[index] is WidgetElement) {
        return (childNodes[index] as WidgetElement).widget;
      } else {
        return childNodes[index].flutterWidget ??
            WebFNodeWidget(childNodes[index], key: Key(childNodes[index].hashCode.toString()));
      }
    });

    return children;
  }

  void onChildrenChanged() {
    if (mounted) {
      requestUpdateState();
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WidgetElement(${widgetElement.tagName}) adapterWidgetState';
  }

  @override
  Widget build(BuildContext context) {
    return widgetElement.build(context, convertNodeListToWidgetList(widgetElement.childNodes));
  }
}
