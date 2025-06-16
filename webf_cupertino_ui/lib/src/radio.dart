/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'radio_bindings_generated.dart';
import 'logger.dart';

class FlutterCupertinoRadio extends FlutterCupertinoRadioBindings {
  FlutterCupertinoRadio(super.context);

  String? _val;
  String? _groupValue;
  bool _useCheckmarkStyle = false;
  bool _disabled = false;
  String? _activeColor;
  String? _focusColor;

  @override
  String? get val => _val;
  @override
  set val(value) {
    _val = value;
  }

  @override
  String? get groupValue => _groupValue;
  @override
  set groupValue(value) {
    _groupValue = value;
  }

  @override
  bool get useCheckmarkStyle => _useCheckmarkStyle;
  @override
  set useCheckmarkStyle(value) {
    _useCheckmarkStyle = value != 'false';
  }

  @override
  bool get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  String? get activeColor => _activeColor;
  @override
  set activeColor(value) {
    _activeColor = value;
  }

  @override
  String? get focusColor => _focusColor;
  @override
  set focusColor(value) {
    _focusColor = value;
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    if (colorString.startsWith('#')) {
      String hex = colorString.substring(1);
      if (hex.length == 6) hex = 'FF' + hex;
      if (hex.length == 8) {
        try {
          return Color(int.parse(hex, radix: 16));
        } catch (e) {
          logger.e('Error parsing color: $colorString, Error: $e');
          return null;
        }
      }
    }
    logger.w('Unsupported color format: $colorString');
    return null;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoRadioState(this);
  }
}

class FlutterCupertinoRadioState extends WebFWidgetElementState {
  FlutterCupertinoRadioState(super.widgetElement);

  @override
  FlutterCupertinoRadio get widgetElement => super.widgetElement as FlutterCupertinoRadio;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widgetElement.disabled,
      child: Opacity(
        opacity: widgetElement.disabled ? 0.5 : 1.0,
        child: CupertinoRadio<String>(
          value: widgetElement.val ?? '',
          groupValue: widgetElement.groupValue,
          useCheckmarkStyle: widgetElement.useCheckmarkStyle,
          activeColor: widgetElement._parseColor(widgetElement.activeColor),
          focusColor: widgetElement._parseColor(widgetElement.focusColor),
          onChanged: (String? newValue) {
            if (newValue != null) {
              widgetElement.dispatchEvent(CustomEvent('change', detail: newValue));
            }
          },
        ),
      )
    );
  }
}
