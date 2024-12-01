/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

class WebFWidgetElementStatefulWidget extends StatefulWidget {
  final WidgetElement widgetElement;

  WebFWidgetElementStatefulWidget(this.widgetElement, {Key? key}) : super(key: key);

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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }
    super.mount(parent, newSlot);
    // Make sure RenderWidget had been created.
    widget.widgetElement.createRenderer(this);
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WidgetElement(${widgetElement.tagName}) adapterWidgetState';
  }

  @override
  Widget build(BuildContext context) {
    return widgetElement.build(context, widgetElement.childNodes as dom.ChildNodeList);
  }
}
