/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'date_picker_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadDatePicker].
///
/// Exposed as `<flutter-shadcn-date-picker>` in the DOM.
class FlutterShadcnDatePicker extends FlutterShadcnDatePickerBindings {
  FlutterShadcnDatePicker(super.context);

  String? _value;
  String? _placeholder;
  bool _disabled = false;
  String _format = 'yyyy-MM-dd';

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
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final newValue = value?.toString();
    if (newValue != _placeholder) {
      _placeholder = newValue;
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
  String? get format => _format;

  @override
  set format(value) {
    final newValue = value?.toString() ?? 'yyyy-MM-dd';
    if (newValue != _format) {
      _format = newValue;
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
  WebFWidgetElementState createState() => FlutterShadcnDatePickerState(this);
}

class FlutterShadcnDatePickerState extends WebFWidgetElementState {
  FlutterShadcnDatePickerState(super.widgetElement);

  final _popoverController = ShadPopoverController();

  @override
  FlutterShadcnDatePicker get widgetElement =>
      super.widgetElement as FlutterShadcnDatePicker;

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return widgetElement.placeholder ?? 'Pick a date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final selected = widgetElement._parseDate(widgetElement.value);

    return ShadPopover(
      controller: _popoverController,
      popover: (context) => ShadCalendar(
        selected: selected,
        onChanged: (date) {
          if (date != null) {
            widgetElement._value = _formatDate(date);
            widgetElement.dispatchEvent(CustomEvent('change', detail: {'value': widgetElement._value}));
            _popoverController.hide();
            widgetElement.state?.requestUpdateState(() {});
          }
        },
      ),
      child: ShadButton.outline(
        enabled: !widgetElement.disabled,
        onPressed: widgetElement.disabled
            ? null
            : () {
                _popoverController.toggle();
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(selected),
              style: TextStyle(
                color: selected == null
                    ? theme.colorScheme.mutedForeground
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
