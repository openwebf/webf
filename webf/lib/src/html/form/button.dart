/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF Company. All rights reserved.
 */


import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/src/accessibility/semantics.dart';

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
        fontSize: (() {
          final double fs = _buttonElement.renderStyle.fontSize.computedValue;
          return fs.isFinite && fs >= 0 ? fs : 0.0;
        })(),
        fontWeight: _buttonElement.renderStyle.fontWeight,
        fontFamily: _buttonElement.renderStyle.fontFamily?.join(' '),
      );

  Widget createButton(BuildContext context) {
    Widget child = TextButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.resolveWith<Color?>((states) => _buttonElement.renderStyle.backgroundColor?.value),
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
      child: Text(_buttonElement.value, style: _buttonStyle),
    );

    // Apply accessibility semantics if label present (aria-label/aria-labelledby)
    final String? semanticsLabel = WebFAccessibility.computeAccessibleName(_buttonElement);
    final String? role = _buttonElement.getAttribute('role')?.toLowerCase();
    final String? ariaSel = _buttonElement.getAttribute('aria-selected')?.toLowerCase();
    final bool selected = role == 'tab' && ariaSel == 'true';
    final bool disabled = _buttonElement.getAttribute('aria-disabled')?.toLowerCase() == 'true';

    // Always provide semantics for buttons to expose selected/mutual exclusivity for tabs.
    child = Semantics(
      label: (semanticsLabel != null && semanticsLabel.isNotEmpty) ? semanticsLabel : null,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: role == 'tab',
      enabled: !disabled,
      textDirection: _buttonElement.renderStyle.direction,
      child: child,
    );

    return Directionality(textDirection: TextDirection.ltr, child: child);
  }
}
