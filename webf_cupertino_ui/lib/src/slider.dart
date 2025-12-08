/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

import 'slider_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoSlider].
///
/// Exposed as `<flutter-cupertino-slider>` in the DOM.
class FlutterCupertinoSlider extends FlutterCupertinoSliderBindings {
  FlutterCupertinoSlider(super.context);

  double _value = 0.0;
  double _min = 0.0;
  double _max = 100.0;
  int? _step;
  bool _disabled = false;

  double _parseDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  int? _parseInt(dynamic value, int? fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  @override
  double? get val => _value;

  @override
  set val(value) {
    final next = _parseDouble(value, _value).clamp(_min, _max);
    if (next != _value) {
      _value = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  double? get min => _min;

  @override
  set min(value) {
    final next = _parseDouble(value, _min);
    if (next != _min) {
      _min = next;
      _value = _value.clamp(_min, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  double? get max => _max;

  @override
  set max(value) {
    final next = _parseDouble(value, _max);
    if (next != _max) {
      _max = next;
      _value = _value.clamp(_min, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  int? get step => _step;

  @override
  set step(value) {
    final next = _parseInt(value, _step);
    if (next != _step) {
      _step = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final next = value == true;
    if (next != _disabled) {
      _disabled = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  double getValue(List<dynamic> args) {
    return _value;
  }

  @override
  void setValue(List<dynamic> args) {
    if (args.isEmpty) return;
    final next = _parseDouble(args[0], _value).clamp(_min, _max);
    if (next != _value) {
      _value = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSliderState(this);
  }
}

class FlutterCupertinoSliderState extends WebFWidgetElementState {
  FlutterCupertinoSliderState(super.widgetElement);

  @override
  FlutterCupertinoSlider get widgetElement =>
      super.widgetElement as FlutterCupertinoSlider;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoSlider(
      value: widgetElement._value,
      min: widgetElement._min,
      max: widgetElement._max,
      divisions: widgetElement._step,
      activeColor: isDark
          ? CupertinoColors.activeBlue.darkColor
          : CupertinoColors.activeBlue,
      thumbColor: CupertinoColors.white,
      onChanged: widgetElement._disabled
          ? null
          : (double value) {
              widgetElement._value = value;
              setState(() {});
              widgetElement.dispatchEvent(
                CustomEvent('change', detail: value),
              );
            },
      onChangeStart: (double value) {
        widgetElement.dispatchEvent(
          CustomEvent('changestart', detail: value),
        );
      },
      onChangeEnd: (double value) {
        widgetElement.dispatchEvent(
          CustomEvent('changeend', detail: value),
        );
      },
    );
  }
}
