/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'checkbox_bindings_generated.dart';

class FlutterCupertinoCheckbox extends FlutterCupertinoCheckboxBindings {
  FlutterCupertinoCheckbox(super.context);

  // Internal state
  bool _value = false;
  bool _disabled = false;
  String? _activeColor;
  String? _checkColor;
  String? _focusColor;
  String? _fillColorSelected;
  String? _fillColorDisabled;

  @override
  String get val => _value.toString();
  @override
  set val(value) {
    bool newValue = (value == 'true');
    if (newValue != _value) {
      _value = newValue;
      state?.requestUpdateState();
    }
  }

  @override
  bool get disabled => _disabled;
  @override
  set disabled(value) {
    bool newDisabled = (value != 'false');
    if (newDisabled != _disabled) {
      _disabled = newDisabled;
      state?.requestUpdateState();
    }
  }

  @override
  String? get activeColor => _activeColor;
  @override
  set activeColor(value) {
    if (value != _activeColor) {
      _activeColor = value;
      state?.requestUpdateState();
    }
  }

  @override
  String? get checkColor => _checkColor;
  @override
  set checkColor(value) {
    if (value != _checkColor) {
      _checkColor = value;
      state?.requestUpdateState();
    }
  }

  @override
  String? get focusColor => _focusColor;
  @override
  set focusColor(value) {
    if (value != _focusColor) {
      _focusColor = value;
      state?.requestUpdateState();
    }
  }

  @override
  String? get fillColorSelected => _fillColorSelected;
  @override
  set fillColorSelected(value) {
    if (value != _fillColorSelected) {
      _fillColorSelected = value;
      state?.requestUpdateState();
    }
  }

  @override
  String? get fillColorDisabled => _fillColorDisabled;
  @override
  set fillColorDisabled(value) {
    if (value != _fillColorDisabled) {
      _fillColorDisabled = value;
      state?.requestUpdateState();
    }
  }

  // Helper to parse color string
  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    if (colorString.startsWith('#')) {
      String hex = colorString.substring(1);
      if (hex.length == 6) hex = 'FF' + hex;
      if (hex.length == 8) {
        try {
          return Color(int.parse(hex, radix: 16));
        } catch (e) {
          print('Error parsing color: $colorString, Error: $e');
          return null;
        }
      }
    }
    print('Unsupported color format: $colorString');
    return null;
  }

  @override
  FlutterCupertinoCheckboxState? get state => super.state as FlutterCupertinoCheckboxState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoCheckboxState(this);
  }
}

class FlutterCupertinoCheckboxState extends WebFWidgetElementState {
  FlutterCupertinoCheckboxState(super.widgetElement);

  @override
  FlutterCupertinoCheckbox get widgetElement => super.widgetElement as FlutterCupertinoCheckbox;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: widgetElement.disabled,
        child: Opacity(
          opacity: widgetElement.disabled ? 0.5 : 1.0,
          child: CupertinoCheckbox(
            value: widgetElement._value,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                widgetElement.val = newValue.toString();
                widgetElement.dispatchEvent(CustomEvent('change', detail: widgetElement._value));
                setState(() {});
              }
            },
            activeColor: widgetElement._parseColor(widgetElement.activeColor),
            checkColor: widgetElement._parseColor(widgetElement.checkColor),
            focusColor: widgetElement._parseColor(widgetElement.focusColor),
            fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return widgetElement._parseColor(widgetElement.fillColorDisabled) ?? CupertinoColors.quaternarySystemFill;
              }
              if (states.contains(WidgetState.selected)) {
                return widgetElement._parseColor(widgetElement.fillColorSelected) ?? widgetElement._parseColor(widgetElement.activeColor);
              }
              return null;
            }),
          ),
        ));
  }
}
