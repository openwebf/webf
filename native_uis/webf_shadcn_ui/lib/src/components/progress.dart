/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'progress_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadProgress].
///
/// Exposed as `<flutter-shadcn-progress>` in the DOM.
class FlutterShadcnProgress extends FlutterShadcnProgressBindings {
  FlutterShadcnProgress(super.context);

  double _value = 0;
  double _max = 100;
  String _variant = 'default';

  @override
  String? get value => _value.toString();

  @override
  set value(value) {
    final strValue = value?.toString() ?? '';
    final newValue = double.tryParse(strValue) ?? 0;
    if (newValue != _value) {
      _value = newValue.clamp(0, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get max => _max.toString();

  @override
  set max(value) {
    final strValue = value?.toString() ?? '';
    final newValue = double.tryParse(strValue) ?? 100;
    if (newValue != _max) {
      _max = newValue;
      _value = _value.clamp(0, _max);
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get variant => _variant;

  @override
  set variant(value) {
    final newValue = value?.toString() ?? 'default';
    if (newValue != _variant) {
      _variant = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnProgressState(this);
}

class FlutterShadcnProgressState extends WebFWidgetElementState {
  FlutterShadcnProgressState(super.widgetElement);

  @override
  FlutterShadcnProgress get widgetElement =>
      super.widgetElement as FlutterShadcnProgress;

  @override
  Widget build(BuildContext context) {
    final progress = widgetElement._max > 0
        ? widgetElement._value / widgetElement._max
        : 0.0;

    return ShadProgress(value: progress);
  }
}
