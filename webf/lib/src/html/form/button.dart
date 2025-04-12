/*
 * Copyright (C) 2022-present The WebF Company. All rights reserved.
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';

/// create a button widget when input type is button or submit
mixin BaseButtonElement on WidgetElement {
  bool checked = false;
  String _value = '';

  bool get disabled => getAttribute('disabled') != null;

  @override
  void propertyDidUpdate(String key, value) {
    _setValue(key, value == null ? '' : value.toString());
    super.propertyDidUpdate(key, value);
  }

  @override
  void attributeDidUpdate(String key, String value) {
    _setValue(key, value);
    super.attributeDidUpdate(key, value);
  }

  void _setValue(String key, String value) {
    switch (key) {
      case 'value':
        if (_value != value) {
          _value = value;
        }
        break;
    }
  }
}

mixin ButtonElementState on WebFWidgetElementState {
  @override
  FlutterInputElement get widgetElement => super.widgetElement as FlutterInputElement;

  TextStyle get _buttonStyle => TextStyle(
        color: widgetElement.renderStyle.color.value,
        fontSize: widgetElement.renderStyle.fontSize.computedValue,
        fontWeight: widgetElement.renderStyle.fontWeight,
        fontFamily: widgetElement.renderStyle.fontFamily?.join(' '),
      );

  Widget createButton(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith<Color?>((states) => widgetElement.renderStyle.backgroundColor?.value),
        ),
        onPressed: () {
          var box = context.findRenderObject() as RenderBox;
          Offset globalOffset = box.globalToLocal(Offset(Offset.zero.dx, Offset.zero.dy));
          double clientX = globalOffset.dx;
          double clientY = globalOffset.dy;
          Event event = MouseEvent(EVENT_CLICK,
              clientX: clientX, clientY: clientY, view: widgetElement.ownerDocument.defaultView);
          widgetElement.dispatchEvent(event);
        },
        child: Text(widgetElement.value, style: _buttonStyle));
  }
}
