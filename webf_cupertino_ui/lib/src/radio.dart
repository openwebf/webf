/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import 'radio_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoRadio].
///
/// Exposed as `<flutter-cupertino-radio>` in the DOM.
class FlutterCupertinoRadio extends FlutterCupertinoRadioBindings {
  FlutterCupertinoRadio(super.context);

  String? _val;
  String? _groupValue;
  bool _disabled = false;
  bool _toggleable = false;
  bool _useCheckmarkStyle = false;
  String? _activeColor;
  String? _inactiveColor;
  String? _fillColor;
  String? _focusColor;
  bool _autofocus = false;

  @override
  String? get val => _val;

  @override
  set val(value) {
    final String? next = value?.toString();
    if (next != _val) {
      _val = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get groupValue => _groupValue;

  @override
  set groupValue(value) {
    final String? next = value?.toString();
    if (next != _groupValue) {
      _groupValue = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool next = value == true;
    if (next != _disabled) {
      _disabled = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get toggleable => _toggleable;

  @override
  set toggleable(value) {
    final bool next = value == true;
    if (next != _toggleable) {
      _toggleable = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get useCheckmarkStyle => _useCheckmarkStyle;

  @override
  set useCheckmarkStyle(value) {
    final bool next = value == true;
    if (next != _useCheckmarkStyle) {
      _useCheckmarkStyle = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get activeColor => _activeColor;

  @override
  set activeColor(value) {
    final String? next = value?.toString();
    if (next != _activeColor) {
      _activeColor = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get inactiveColor => _inactiveColor;

  @override
  set inactiveColor(value) {
    final String? next = value?.toString();
    if (next != _inactiveColor) {
      _inactiveColor = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get fillColor => _fillColor;

  @override
  set fillColor(value) {
    final String? next = value?.toString();
    if (next != _fillColor) {
      _fillColor = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get focusColor => _focusColor;

  @override
  set focusColor(value) {
    final String? next = value?.toString();
    if (next != _focusColor) {
      _focusColor = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get autofocus => _autofocus;

  @override
  set autofocus(value) {
    final bool next = value == true;
    if (next != _autofocus) {
      _autofocus = next;
      state?.requestUpdateState(() {});
    }
  }

  Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    return CSSColor.parseColor(value);
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoRadioState(this);
  }
}

class FlutterCupertinoRadioState extends WebFWidgetElementState {
  FlutterCupertinoRadioState(super.widgetElement);

  @override
  FlutterCupertinoRadio get widgetElement =>
      super.widgetElement as FlutterCupertinoRadio;

  @override
  Widget build(BuildContext context) {
    final Color? active =
        widgetElement._parseColor(widgetElement.activeColor);
    final Color? inactive =
        widgetElement._parseColor(widgetElement.inactiveColor);
    final Color? fill =
        widgetElement._parseColor(widgetElement.fillColor);
    final Color? focus =
        widgetElement._parseColor(widgetElement.focusColor);

    return IgnorePointer(
      ignoring: widgetElement.disabled,
      child: Opacity(
        opacity: widgetElement.disabled ? 0.5 : 1.0,
        child: CupertinoRadio<String>(
          value: widgetElement.val ?? '',
          groupValue: widgetElement.groupValue,
          toggleable: widgetElement.toggleable,
          useCheckmarkStyle: widgetElement.useCheckmarkStyle,
          activeColor: active,
          inactiveColor: inactive,
          fillColor: fill,
          focusColor: focus,
          autofocus: widgetElement.autofocus,
          onChanged: (String? newValue) {
            if (widgetElement.disabled) return;
            final String next = newValue ?? '';
            widgetElement.dispatchEvent(
              CustomEvent('change', detail: next),
            );
          },
        ),
      ),
    );
  }
}
