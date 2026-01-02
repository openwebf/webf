/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import 'checkbox_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoCheckbox].
///
/// Exposed as `<flutter-cupertino-checkbox>` in the DOM.
class FlutterCupertinoCheckbox extends FlutterCupertinoCheckboxBindings {
  FlutterCupertinoCheckbox(super.context);

  bool? _value = false;
  bool _disabled = false;
  bool _tristate = false;
  String? _activeColor;
  String? _checkColor;
  String? _focusColor;
  String? _fillColorSelected;
  String? _fillColorDisabled;
  bool _autofocus = false;
  String? _semanticLabel;

  @override
  bool? get checked => _value == true;

  @override
  set checked(value) {
    // Support nullable values when tristate is enabled.
    if (_tristate && value == null) {
      if (_value != null) {
        _value = null;
        state?.requestUpdateState(() {});
      }
      return;
    }

    final bool next = value == true;
    if (_value != next) {
      _value = next;
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
  bool get tristate => _tristate;

  @override
  set tristate(value) {
    final bool next = value == true;
    if (next != _tristate) {
      _tristate = next;
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
  String? get checkColor => _checkColor;

  @override
  set checkColor(value) {
    final String? next = value?.toString();
    if (next != _checkColor) {
      _checkColor = next;
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
  String? get fillColorSelected => _fillColorSelected;

  @override
  set fillColorSelected(value) {
    final String? next = value?.toString();
    if (next != _fillColorSelected) {
      _fillColorSelected = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get fillColorDisabled => _fillColorDisabled;

  @override
  set fillColorDisabled(value) {
    final String? next = value?.toString();
    if (next != _fillColorDisabled) {
      _fillColorDisabled = next;
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

  @override
  String? get semanticLabel => _semanticLabel;

  @override
  set semanticLabel(value) {
    final String? next = value?.toString();
    if (next != _semanticLabel) {
      _semanticLabel = next;
      state?.requestUpdateState(() {});
    }
  }

  Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    return CSSColor.parseColor(value);
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoCheckboxState(this);
  }
}

class FlutterCupertinoCheckboxState extends WebFWidgetElementState {
  FlutterCupertinoCheckboxState(super.widgetElement);

  @override
  FlutterCupertinoCheckbox get widgetElement =>
      super.widgetElement as FlutterCupertinoCheckbox;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widgetElement.disabled,
      child: Opacity(
        opacity: widgetElement.disabled ? 0.5 : 1.0,
        child: CupertinoCheckbox(
          value: widgetElement._value,
          tristate: widgetElement.tristate,
          onChanged: (bool? newValue) {
            if (widgetElement.disabled) return;
            widgetElement._value = newValue;
            final bool checked = newValue == true;
            final String stateLabel;
            if (widgetElement.tristate && newValue == null) {
              stateLabel = 'mixed';
            } else if (checked) {
              stateLabel = 'checked';
            } else {
              stateLabel = 'unchecked';
            }
            widgetElement.dispatchEvent(
              CustomEvent('change', detail: checked),
            );
            widgetElement.dispatchEvent(
              CustomEvent('statechange', detail: stateLabel),
            );
            setState(() {});
          },
          activeColor: widgetElement._parseColor(widgetElement.activeColor),
          checkColor: widgetElement._parseColor(widgetElement.checkColor),
          focusColor: widgetElement._parseColor(widgetElement.focusColor),
          autofocus: widgetElement.autofocus,
          semanticLabel: widgetElement.semanticLabel,
          fillColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return widgetElement._parseColor(
                      widgetElement.fillColorDisabled,
                    ) ??
                    CupertinoColors.quaternarySystemFill;
              }
              if (states.contains(WidgetState.selected)) {
                return widgetElement._parseColor(
                      widgetElement.fillColorSelected,
                    ) ??
                    widgetElement._parseColor(widgetElement.activeColor);
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
