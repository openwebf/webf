/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'calendar_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadCalendar].
///
/// Exposed as `<flutter-shadcn-calendar>` in the DOM.
class FlutterShadcnCalendar extends FlutterShadcnCalendarBindings {
  FlutterShadcnCalendar(super.context);

  String _mode = 'single';
  String? _value;
  bool _disabled = false;
  String? _min;
  String? _max;

  @override
  String get mode => _mode;

  @override
  set mode(value) {
    final newValue = value?.toString() ?? 'single';
    if (newValue != _mode) {
      _mode = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get value => _value;

  @override
  set value(value) {
    final newValue = value?.toString();
    if (newValue != _value) {
      _value = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final newValue = value == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get min => _min;

  @override
  set min(value) {
    final newValue = value?.toString();
    if (newValue != _min) {
      _min = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get max => _max;

  @override
  set max(value) {
    final newValue = value?.toString();
    if (newValue != _max) {
      _max = newValue;
      state?.requestUpdateState(() {});
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnCalendarState(this);
}

class FlutterShadcnCalendarState extends WebFWidgetElementState {
  FlutterShadcnCalendarState(super.widgetElement);

  @override
  FlutterShadcnCalendar get widgetElement =>
      super.widgetElement as FlutterShadcnCalendar;

  @override
  Widget build(BuildContext context) {
    final selected = widgetElement._parseDate(widgetElement.value);
    final minDate = widgetElement._parseDate(widgetElement.min);
    final maxDate = widgetElement._parseDate(widgetElement.max);

    return ShadCalendar(
      selected: selected,
      fromMonth: minDate,
      toMonth: maxDate,
      onChanged: widgetElement.disabled
          ? null
          : (date) {
              if (date != null) {
                widgetElement._value =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                widgetElement.dispatchEvent(Event('change'));
                widgetElement.state?.requestUpdateState(() {});
              }
            },
    );
  }
}
