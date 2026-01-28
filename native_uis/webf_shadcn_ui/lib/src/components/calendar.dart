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

  FlutterShadcnCalendarMode? _mode = FlutterShadcnCalendarMode.single;
  String? _value;
  bool _disabled = false;
  String? _min;
  String? _max;
  FlutterShadcnCalendarCaptionLayout? _captionLayout = FlutterShadcnCalendarCaptionLayout.label;
  bool _hideNavigation = false;
  bool _showWeekNumbers = false;
  bool _showOutsideDays = true;
  bool _fixedWeeks = false;
  bool _hideWeekdayNames = false;
  double? _numberOfMonths = 1;
  bool _allowDeselection = false;

  @override
  FlutterShadcnCalendarMode? get mode => _mode;

  @override
  set mode(value) {
    FlutterShadcnCalendarMode? newValue;
    if (value is FlutterShadcnCalendarMode) {
      newValue = value;
    } else if (value is String) {
      newValue = FlutterShadcnCalendarMode.parse(value);
    } else {
      newValue = FlutterShadcnCalendarMode.single;
    }
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

  @override
  FlutterShadcnCalendarCaptionLayout? get captionLayout => _captionLayout;

  @override
  set captionLayout(value) {
    FlutterShadcnCalendarCaptionLayout? newValue;
    if (value is FlutterShadcnCalendarCaptionLayout) {
      newValue = value;
    } else if (value is String) {
      newValue = FlutterShadcnCalendarCaptionLayout.parse(value);
    } else {
      newValue = FlutterShadcnCalendarCaptionLayout.label;
    }
    if (newValue != _captionLayout) {
      _captionLayout = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get hideNavigation => _hideNavigation;

  @override
  set hideNavigation(value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _hideNavigation) {
      _hideNavigation = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get showWeekNumbers => _showWeekNumbers;

  @override
  set showWeekNumbers(value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _showWeekNumbers) {
      _showWeekNumbers = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get showOutsideDays => _showOutsideDays;

  @override
  set showOutsideDays(value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _showOutsideDays) {
      _showOutsideDays = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get fixedWeeks => _fixedWeeks;

  @override
  set fixedWeeks(value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _fixedWeeks) {
      _fixedWeeks = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get hideWeekdayNames => _hideWeekdayNames;

  @override
  set hideWeekdayNames(value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _hideWeekdayNames) {
      _hideWeekdayNames = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  double? get numberOfMonths => _numberOfMonths;

  @override
  set numberOfMonths(value) {
    double? newValue;
    if (value is double) {
      newValue = value;
    } else if (value is int) {
      newValue = value.toDouble();
    } else if (value is String) {
      newValue = double.tryParse(value) ?? 1;
    } else {
      newValue = 1;
    }
    if (newValue != _numberOfMonths) {
      _numberOfMonths = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get allowDeselection => _allowDeselection;

  @override
  set allowDeselection(value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _allowDeselection) {
      _allowDeselection = newValue;
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

  List<DateTime> _parseDates(String? datesStr) {
    if (datesStr == null || datesStr.isEmpty) return [];
    return datesStr
        .split(',')
        .map((s) => _parseDate(s.trim()))
        .whereType<DateTime>()
        .toList();
  }

  ShadDateTimeRange? _parseDateRange(String? rangeStr) {
    if (rangeStr == null || rangeStr.isEmpty) return null;
    final parts = rangeStr.split(',');
    if (parts.length != 2) return null;
    final start = _parseDate(parts[0].trim());
    final end = _parseDate(parts[1].trim());
    return ShadDateTimeRange(start: start, end: end);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDates(List<DateTime> dates) {
    return dates.map(_formatDate).join(',');
  }

  String _formatDateRange(ShadDateTimeRange range) {
    final parts = <String>[];
    if (range.start != null) parts.add(_formatDate(range.start!));
    if (range.end != null) parts.add(_formatDate(range.end!));
    return parts.join(',');
  }

  ShadCalendarCaptionLayout get captionLayoutEnum {
    switch (_captionLayout) {
      case FlutterShadcnCalendarCaptionLayout.dropdown:
        return ShadCalendarCaptionLayout.dropdown;
      case FlutterShadcnCalendarCaptionLayout.dropdownMonths:
        return ShadCalendarCaptionLayout.dropdownMonths;
      case FlutterShadcnCalendarCaptionLayout.dropdownYears:
        return ShadCalendarCaptionLayout.dropdownYears;
      default:
        return ShadCalendarCaptionLayout.label;
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
    final minDate = widgetElement._parseDate(widgetElement.min);
    final maxDate = widgetElement._parseDate(widgetElement.max);
    final modeValue = widgetElement.mode?.value ?? 'single';
    final numMonths = widgetElement.numberOfMonths?.toInt() ?? 1;

    // Multiple selection mode
    if (modeValue == 'multiple') {
      final selectedDates = widgetElement._parseDates(widgetElement.value);

      return ShadCalendar.multiple(
        selected: selectedDates,
        numberOfMonths: numMonths,
        fromMonth: minDate,
        toMonth: maxDate,
        captionLayout: widgetElement.captionLayoutEnum,
        hideNavigation: widgetElement.hideNavigation,
        showWeekNumbers: widgetElement.showWeekNumbers,
        showOutsideDays: widgetElement.showOutsideDays,
        fixedWeeks: widgetElement.fixedWeeks,
        hideWeekdayNames: widgetElement.hideWeekdayNames,
        onChanged: widgetElement.disabled
            ? null
            : (dates) {
                widgetElement._value = widgetElement._formatDates(dates);
                widgetElement.dispatchEvent(CustomEvent('change', detail: {'value': widgetElement._value}));
                widgetElement.state?.requestUpdateState(() {});
              },
      );
    }

    // Range selection mode
    if (modeValue == 'range') {
      final selectedRange = widgetElement._parseDateRange(widgetElement.value);

      return ShadCalendar.range(
        selected: selectedRange,
        numberOfMonths: numMonths,
        fromMonth: minDate,
        toMonth: maxDate,
        captionLayout: widgetElement.captionLayoutEnum,
        hideNavigation: widgetElement.hideNavigation,
        showWeekNumbers: widgetElement.showWeekNumbers,
        showOutsideDays: widgetElement.showOutsideDays,
        fixedWeeks: widgetElement.fixedWeeks,
        hideWeekdayNames: widgetElement.hideWeekdayNames,
        onChanged: widgetElement.disabled
            ? null
            : (range) {
                if (range != null) {
                  widgetElement._value = widgetElement._formatDateRange(range);
                  widgetElement.dispatchEvent(CustomEvent('change', detail: {'value': widgetElement._value}));
                  widgetElement.state?.requestUpdateState(() {});
                }
              },
      );
    }

    // Single selection mode (default)
    final selected = widgetElement._parseDate(widgetElement.value);

    return ShadCalendar(
      selected: selected,
      numberOfMonths: numMonths,
      fromMonth: minDate,
      toMonth: maxDate,
      captionLayout: widgetElement.captionLayoutEnum,
      hideNavigation: widgetElement.hideNavigation,
      showWeekNumbers: widgetElement.showWeekNumbers,
      showOutsideDays: widgetElement.showOutsideDays,
      fixedWeeks: widgetElement.fixedWeeks,
      hideWeekdayNames: widgetElement.hideWeekdayNames,
      allowDeselection: widgetElement.allowDeselection,
      onChanged: widgetElement.disabled
          ? null
          : (date) {
              if (date != null) {
                widgetElement._value = widgetElement._formatDate(date);
              } else {
                widgetElement._value = null;
              }
              widgetElement.dispatchEvent(CustomEvent('change', detail: {'value': widgetElement._value}));
              widgetElement.state?.requestUpdateState(() {});
            },
    );
  }
}
