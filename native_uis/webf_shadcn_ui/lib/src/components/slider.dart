/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'slider_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadSlider].
///
/// Exposed as `<flutter-shadcn-slider>` in the DOM.
class FlutterShadcnSlider extends FlutterShadcnSliderBindings {
  FlutterShadcnSlider(super.context);

  double _value = 0;
  double _min = 0;
  double _max = 100;
  double _step = 1;
  bool _disabled = false;
  String _orientation = 'horizontal';

  @override
  String get value => _value.toString();

  @override
  set value(v) {
    final newValue = double.tryParse(v?.toString() ?? '') ?? 0;
    if (newValue != _value) {
      _value = newValue.clamp(_min, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get min => _min.toString();

  @override
  set min(v) {
    final newValue = double.tryParse(v?.toString() ?? '') ?? 0;
    if (newValue != _min) {
      _min = newValue;
      _value = _value.clamp(_min, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get max => _max.toString();

  @override
  set max(v) {
    final newValue = double.tryParse(v?.toString() ?? '') ?? 100;
    if (newValue != _max) {
      _max = newValue;
      _value = _value.clamp(_min, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get step => _step.toString();

  @override
  set step(v) {
    final newValue = double.tryParse(v?.toString() ?? '') ?? 1;
    if (newValue != _step && newValue > 0) {
      _step = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(v) {
    final newValue = v == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get orientation => _orientation;

  @override
  set orientation(v) {
    final newValue = v?.toString() ?? 'horizontal';
    if (newValue != _orientation) {
      _orientation = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSliderState(this);
}

class FlutterShadcnSliderState extends WebFWidgetElementState {
  FlutterShadcnSliderState(super.widgetElement);

  @override
  FlutterShadcnSlider get widgetElement =>
      super.widgetElement as FlutterShadcnSlider;

  @override
  Widget build(BuildContext context) {
    // Calculate divisions based on step
    final range = widgetElement._max - widgetElement._min;
    final divisions =
        widgetElement._step > 0 ? (range / widgetElement._step).round() : null;

    return ShadSlider(
      initialValue: widgetElement._value,
      min: widgetElement._min,
      max: widgetElement._max,
      divisions: divisions,
      enabled: !widgetElement.disabled,
      onChanged: widgetElement.disabled
          ? null
          : (value) {
              widgetElement._value = value;
              widgetElement.dispatchEvent(Event('input'));
            },
      onChangeEnd: widgetElement.disabled
          ? null
          : (value) {
              widgetElement._value = value;
              widgetElement.dispatchEvent(Event('change'));
            },
    );
  }
}
