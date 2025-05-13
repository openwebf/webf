/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterButton extends WidgetElement {
  FlutterButton(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterButtonState(this);
  }
}

class FlutterButtonState extends WebFWidgetElementState {
  FlutterButtonState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(onPressed: () {
      widgetElement.dispatchEvent(Event('press'));
    }, child: widgetElement.childNodes.isNotEmpty ? widgetElement.childNodes.first.toWidget() : Text(''));

    return (widgetElement.renderStyle.width.isNotAuto || widgetElement.renderStyle.height.isNotAuto) ? Container(
      width: widgetElement.renderStyle.width.isNotAuto ? widgetElement.renderStyle.width.computedValue : null,
      height: widgetElement.renderStyle.height.isNotAuto ? widgetElement.renderStyle.height.computedValue : null,
      child: button,
    ) : button;
  }
}
