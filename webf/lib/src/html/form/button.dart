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
  
  String get value => _value;

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
  BaseButtonElement get _buttonElement => widgetElement as BaseButtonElement;

  TextStyle get _buttonStyle => TextStyle(
        color: _buttonElement.renderStyle.color.value,
        fontSize: _buttonElement.renderStyle.fontSize.computedValue,
        fontWeight: _buttonElement.renderStyle.fontWeight,
        fontFamily: _buttonElement.renderStyle.fontFamily?.join(' '),
      );

  Widget createButton(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith<Color?>((states) => _buttonElement.renderStyle.backgroundColor?.value),
        ),
        onPressed: () {
          var box = context.findRenderObject() as RenderBox;
          Offset globalOffset = box.globalToLocal(Offset(Offset.zero.dx, Offset.zero.dy));
          double clientX = globalOffset.dx;
          double clientY = globalOffset.dy;
          Event event = MouseEvent(EVENT_CLICK,
              clientX: clientX, clientY: clientY, view: _buttonElement.ownerDocument.defaultView);
          _buttonElement.dispatchEvent(event);
        },
        child: Text(_buttonElement.value, style: _buttonStyle));
  }
}
