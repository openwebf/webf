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
  Color? _backgroundColor;
  Color? _color;
  double? _minHeight;
  double? _borderRadius;

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
  String? get backgroundColor => _backgroundColor != null
      ? '#${_backgroundColor!.value.toRadixString(16).padLeft(8, '0')}'
      : null;

  @override
  set backgroundColor(value) {
    final newValue = value != null ? _parseColor(value.toString()) : null;
    if (newValue != _backgroundColor) {
      _backgroundColor = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get color => _color != null
      ? '#${_color!.value.toRadixString(16).padLeft(8, '0')}'
      : null;

  @override
  set color(value) {
    final newValue = value != null ? _parseColor(value.toString()) : null;
    if (newValue != _color) {
      _color = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get minHeight => _minHeight?.toString();

  @override
  set minHeight(value) {
    final newValue = value != null ? double.tryParse(value.toString()) : null;
    if (newValue != _minHeight) {
      _minHeight = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get borderRadius => _borderRadius?.toString();

  @override
  set borderRadius(value) {
    final newValue = value != null ? double.tryParse(value.toString()) : null;
    if (newValue != _borderRadius) {
      _borderRadius = newValue;
      state?.requestUpdateState(() {});
    }
  }

  static Color? _parseColor(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.startsWith('#')) {
      final hex = trimmed.substring(1);
      if (hex.length == 6) {
        final intValue = int.tryParse(hex, radix: 16);
        if (intValue != null) return Color(0xFF000000 | intValue);
      } else if (hex.length == 8) {
        final intValue = int.tryParse(hex, radix: 16);
        if (intValue != null) return Color(intValue);
      }
    }
    return null;
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
    final isIndeterminate = widgetElement._variant == 'indeterminate';

    final double? progressValue;
    if (isIndeterminate) {
      progressValue = null;
    } else {
      progressValue = widgetElement._max > 0
          ? widgetElement._value / widgetElement._max
          : 0.0;
    }

    return ShadProgress(
      value: progressValue,
      backgroundColor: widgetElement._backgroundColor,
      color: widgetElement._color,
      minHeight: widgetElement._minHeight,
      borderRadius: widgetElement._borderRadius != null
          ? BorderRadius.circular(widgetElement._borderRadius!)
          : null,
    );
  }
}
