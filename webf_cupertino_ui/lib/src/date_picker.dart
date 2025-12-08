/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import 'date_picker_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoDatePicker].
///
/// Exposed as `<flutter-cupertino-date-picker>` in the DOM.
class FlutterCupertinoDatePicker extends FlutterCupertinoDatePickerBindings {
  FlutterCupertinoDatePicker(super.context);

  String _mode = 'dateAndTime';
  String? _minimumDate;
  String? _maximumDate;
  int? _minimumYear = 1;
  int? _maximumYear;
  int _minuteInterval = 1;
  bool _use24H = false;
  bool _showDayOfWeek = false;
  String? _value;

  @override
  bool get allowsInfiniteHeight => false;

  @override
  String? get mode => _mode;

  @override
  set mode(value) {
    final String next = (value?.toString() ?? 'dateAndTime');
    if (next != _mode) {
      _mode = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get minimumDate => _minimumDate;

  @override
  set minimumDate(value) {
    final String? next = value?.toString();
    if (next != _minimumDate) {
      _minimumDate = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get maximumDate => _maximumDate;

  @override
  set maximumDate(value) {
    final String? next = value?.toString();
    if (next != _maximumDate) {
      _maximumDate = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  int? get minimumYear => _minimumYear;

  @override
  set minimumYear(value) {
    if (value == null) {
      _minimumYear = null;
    } else if (value is int) {
      _minimumYear = value;
    } else {
      _minimumYear = int.tryParse(value.toString());
    }
    state?.requestUpdateState(() {});
  }

  @override
  int? get maximumYear => _maximumYear;

  @override
  set maximumYear(value) {
    if (value == null) {
      _maximumYear = null;
    } else if (value is int) {
      _maximumYear = value;
    } else {
      _maximumYear = int.tryParse(value.toString());
    }
    state?.requestUpdateState(() {});
  }

  @override
  int? get minuteInterval => _minuteInterval;

  @override
  set minuteInterval(value) {
    if (value == null) {
      _minuteInterval = 1;
    } else if (value is int) {
      _minuteInterval = value;
    } else {
      _minuteInterval = int.tryParse(value.toString()) ?? 1;
    }
    state?.requestUpdateState(() {});
  }

  @override
  bool get use24H => _use24H;

  @override
  set use24H(value) {
    final bool next = value == true;
    if (next != _use24H) {
      _use24H = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get showDayOfWeek => _showDayOfWeek;

  @override
  set showDayOfWeek(value) {
    final bool next = value == true;
    if (next != _showDayOfWeek) {
      _showDayOfWeek = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get value => _value;

  @override
  set value(value) {
    final String? next = value?.toString();
    if (next != _value) {
      _value = next;
      state?.requestUpdateState(() {});
    }
  }

  /// Expose an imperative setter for the current value.
  void _setValueSync(List<dynamic> args) {
    if (args.isEmpty) return;
    final String next = args.first.toString();
    value = next;
  }

  static StaticDefinedSyncBindingObjectMethodMap datePickerMethods =
      <String, StaticDefinedSyncBindingObjectMethod>{
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoDatePicker>(element)._setValueSync(args);
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        datePickerMethods,
      ];

  @override
  FlutterCupertinoDatePickerState? get state =>
      super.state as FlutterCupertinoDatePickerState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoDatePickerState(this);
  }
}

class FlutterCupertinoDatePickerState extends WebFWidgetElementState {
  FlutterCupertinoDatePickerState(super.widgetElement);

  @override
  FlutterCupertinoDatePicker get widgetElement =>
      super.widgetElement as FlutterCupertinoDatePicker;

  DateTime? _currentValue;

  CupertinoDatePickerMode _parseMode(String? mode) {
    switch ((mode ?? 'dateAndTime')) {
      case 'time':
        return CupertinoDatePickerMode.time;
      case 'date':
        return CupertinoDatePickerMode.date;
      case 'monthYear':
        return CupertinoDatePickerMode.monthYear;
      case 'dateAndTime':
      default:
        return CupertinoDatePickerMode.dateAndTime;
    }
  }

  DateTime? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  DateTime _normalizeInitialDateTime({
    required DateTime candidate,
    required CupertinoDatePickerMode mode,
    required int minuteInterval,
    required DateTime? minimumDate,
    required DateTime? maximumDate,
    required int minimumYear,
    required int? maximumYear,
  }) {
    DateTime result = candidate;

    // Clamp to minimum / maximum dates if provided.
    if (minimumDate != null && result.isBefore(minimumDate)) {
      result = minimumDate;
    }
    if (maximumDate != null && result.isAfter(maximumDate)) {
      result = maximumDate;
    }

    // Clamp year range for date / monthYear modes.
    if (mode == CupertinoDatePickerMode.date ||
        mode == CupertinoDatePickerMode.monthYear) {
      if (result.year < minimumYear) {
        result = DateTime(
          minimumYear,
          result.month,
          result.day,
          result.hour,
          result.minute,
          result.second,
          result.millisecond,
          result.microsecond,
        );
      }
      if (maximumYear != null && result.year > maximumYear) {
        result = DateTime(
          maximumYear,
          result.month,
          result.day,
          result.hour,
          result.minute,
          result.second,
          result.millisecond,
          result.microsecond,
        );
      }
    }

    // Ensure the minute matches the required interval to satisfy
    // CupertinoDatePicker's assertion.
    if (minuteInterval > 1) {
      final int clampedMinute =
          result.minute - (result.minute % minuteInterval);
      result = DateTime(
        result.year,
        result.month,
        result.day,
        result.hour,
        clampedMinute,
        result.second,
        result.millisecond,
        result.microsecond,
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    final CupertinoDatePickerMode mode =
        _parseMode(widgetElement.mode);

    final DateTime rawInitial =
        _parseDate(widgetElement.value) ?? DateTime.now();

    final DateTime? minimumDate =
        _parseDate(widgetElement.minimumDate);
    final DateTime? maximumDate =
        _parseDate(widgetElement.maximumDate);

    final int minimumYear =
        widgetElement.minimumYear ?? 1;
    final int? maximumYear =
        widgetElement.maximumYear;

    final int minuteInterval =
        widgetElement.minuteInterval ?? 1;

    final bool use24hFormat = widgetElement.use24H;
    final bool rawShowDayOfWeek = widgetElement.showDayOfWeek;
    // Avoid Flutter internal issues when using showDayOfWeek in pure date mode
    // by disabling the flag in that specific combination.
    final bool effectiveShowDayOfWeek =
        mode == CupertinoDatePickerMode.date ? false : rawShowDayOfWeek;

    final Color? backgroundColor =
        renderStyle.backgroundColor?.value;

    final DateTime initialDateTime = _normalizeInitialDateTime(
      candidate: rawInitial,
      mode: mode,
      minuteInterval: minuteInterval,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      minimumYear: minimumYear,
      maximumYear: maximumYear,
    );

    final double width = renderStyle.width.computedValue;
    final double height = renderStyle.height.computedValue;

    _currentValue ??= initialDateTime;

    final Widget innerPicker = CupertinoDatePicker(
      mode: mode,
      initialDateTime: initialDateTime,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      minimumYear: minimumYear,
      maximumYear: maximumYear,
      minuteInterval: minuteInterval,
      use24hFormat: use24hFormat,
      showDayOfWeek: effectiveShowDayOfWeek,
      backgroundColor: backgroundColor,
      onDateTimeChanged: (DateTime dateTime) {
        _currentValue = dateTime;
        final String iso = _formatDate(dateTime);
        widgetElement._value = iso;
        widgetElement.dispatchEvent(
          CustomEvent('change', detail: iso),
        );
      },
    );

    final Widget picker = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return innerPicker;
      },
    );

    Widget result = picker;

    if (width > 0 || height > 0) {
      result = SizedBox(
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        child: picker,
      );
    }

    return result;
  }
}
