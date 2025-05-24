/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'slider_bindings_generated.dart';

class FlutterCupertinoSlider extends FlutterCupertinoSliderBindings {
  FlutterCupertinoSlider(super.context);

  double _value = 0.0;
  double _min = 0.0;
  double _max = 100.0;
  int? _step;
  bool _disabled = false;

  @override
  double? get val => _value;
  @override
  set val(value) {
    final newValue = double.tryParse(value) ?? _value;
    if (newValue != _value) {
      _value = newValue.clamp(_min, _max);
    }
  }

  @override
  double? get min => _min;
  @override
  set min(value) {
    final newMin = double.tryParse(value) ?? _min;
    if (newMin != _min) {
      _min = newMin;
      _value = _value.clamp(_min, _max);
    }
  }

  @override
  double? get max => _max;
  @override
  set max(value) {
    final newMax = double.tryParse(value) ?? _max;
    if (newMax != _max) {
      _max = newMax;
      _value = _value.clamp(_min, _max);
    }
  }

  @override
  int? get step => _step;
  @override
  set step(value) {
    final steps = int.tryParse(value);
    if (steps != _step) {
      _step = steps;
    }
  }

  @override
  bool? get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  double getValue(List<dynamic> args) {
    return _value;
  }

  @override
  void setValue(List<dynamic> args) {
    if (args.isNotEmpty) {
      final newValue = double.tryParse(args[0].toString()) ?? _value;
      _value = newValue.clamp(_min, _max);
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
  FlutterCupertinoSlider get widgetElement => super.widgetElement as FlutterCupertinoSlider;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoSlider(
      value: widgetElement._value,
      min: widgetElement._min,
      max: widgetElement._max,
      divisions: widgetElement._step,
      activeColor: isDark ? CupertinoColors.activeBlue.darkColor : CupertinoColors.activeBlue,
      thumbColor: CupertinoColors.white,
      onChanged: widgetElement._disabled ? null : (double value) {
        setState(() {
          widgetElement._value = value;
        });
        widgetElement.dispatchEvent(CustomEvent('change', detail: value));
      },
      onChangeStart: (double value) {
        widgetElement.dispatchEvent(CustomEvent('changestart', detail: value));
      },
      onChangeEnd: (double value) {
        widgetElement.dispatchEvent(CustomEvent('changeend', detail: value));
      },
    );
  }
}
