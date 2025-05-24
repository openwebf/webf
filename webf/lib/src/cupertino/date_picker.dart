/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'date_picker_bindings_generated.dart';

class FlutterCupertinoDatePicker extends FlutterCupertinoDatePickerBindings {
  FlutterCupertinoDatePicker(super.context);

  String _mode = 'date';
  String? _minimumDate;
  String? _maximumDate;
  String? _minuteInterval;
  String? _value;
  String? _minimumYear;
  String? _maximumYear;
  String? _showDayOfWeek;
  String? _dateOrder;
  String? _height;
  bool _use24H = false;

  @override
  String? get mode => _mode;
  @override
  set mode(value) {
    _mode = value ?? 'date';
  }

  @override
  String? get minimumDate => _minimumDate;
  @override
  set minimumDate(value) {
    _minimumDate = value;
  }

  @override
  String? get maximumDate => _maximumDate;
  @override
  set maximumDate(value) {
    _maximumDate = value;
  }

  @override
  String? get minuteInterval => _minuteInterval;
  @override
  set minuteInterval(value) {
    _minuteInterval = value;
  }

  @override
  String? get value => _value;
  @override
  set value(value) {
    _value = value;
  }

  @override
  String? get minimumYear => _minimumYear;
  @override
  set minimumYear(value) {
    _minimumYear = value;
  }

  @override
  String? get maximumYear => _maximumYear;
  @override
  set maximumYear(value) {
    _maximumYear = value;
  }

  @override
  String? get showDayOfWeek => _showDayOfWeek;
  @override
  set showDayOfWeek(value) {
    _showDayOfWeek = value;
  }

  @override
  String? get dateOrder => _dateOrder;
  @override
  set dateOrder(value) {
    _dateOrder = value;
  }

  @override
  String? get height => _height;
  @override
  set height(value) {
    _height = value;
  }

  @override
  bool? get use24H => _use24H;
  @override
  set use24H(value) {
    _use24H = value != 'false';
  }

  @override
  FlutterCupertinoDatePickerState? get state => super.state as FlutterCupertinoDatePickerState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoDatePickerState(this);
  }
}

class FlutterCupertinoDatePickerState extends WebFWidgetElementState {
  FlutterCupertinoDatePickerState(super.widgetElement);

  @override
  FlutterCupertinoDatePicker get widgetElement => super.widgetElement as FlutterCupertinoDatePicker;

  CupertinoDatePickerMode _getDatePickerMode(String mode) {
    switch (mode) {
      case 'time':
        return CupertinoDatePickerMode.time;
      case 'dateAndTime':
        return CupertinoDatePickerMode.dateAndTime;
      case 'date':
      default:
        return CupertinoDatePickerMode.date;
    }
  }

  DateTime _parseDateTime(String? dateString) {
    if (dateString == null) return DateTime.now();
    return DateTime.tryParse(dateString) ?? DateTime.now();
  }

  DateTime _validateDateTime(DateTime dateTime, DateTime? minDate, DateTime? maxDate, int minuteInterval) {
    // make sure the date time is in the range of min and max date
    if (minDate != null && dateTime.isBefore(minDate)) {
      dateTime = minDate;
    }
    if (maxDate != null && dateTime.isAfter(maxDate)) {
      dateTime = maxDate;
    }

    // make sure the minute is divisible by minuteInterval
    if (minuteInterval > 1) {
      final int minute = dateTime.minute;
      final int adjustedMinute = (minute ~/ minuteInterval) * minuteInterval;
      if (minute != adjustedMinute) {
        dateTime = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          adjustedMinute,
        );
      }
    }

    return dateTime;
  }

  DatePickerDateOrder? _getDateOrder(String? order) {
    switch (order) {
      case 'dmy':
        return DatePickerDateOrder.dmy;
      case 'mdy':
        return DatePickerDateOrder.mdy;
      case 'ymd':
        return DatePickerDateOrder.ymd;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final minimumDate = _parseDateTime(widgetElement.minimumDate);
    final maximumDate = _parseDateTime(widgetElement.maximumDate);
    final minuteInterval = int.tryParse(widgetElement.minuteInterval ?? '') ?? 1;

    // validate and adjust the initial date time
    final initialDateTime = _validateDateTime(
        _parseDateTime(widgetElement.value),
        minimumDate,
        maximumDate,
        minuteInterval
    );

    final minimumYear = int.tryParse(widgetElement.minimumYear ?? '') ?? 1;
    final maximumYear = int.tryParse(widgetElement.maximumYear ?? '');
    final showDayOfWeek = widgetElement.showDayOfWeek == 'true';
    final dateOrder = _getDateOrder(widgetElement.dateOrder);

    return SizedBox(
      height: double.tryParse(widgetElement.height ?? '') ?? 200,
      child: CupertinoDatePicker(
        mode: _getDatePickerMode(widgetElement.mode!),
        initialDateTime: initialDateTime,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        minimumYear: minimumYear,
        maximumYear: maximumYear,
        showDayOfWeek: showDayOfWeek,
        dateOrder: dateOrder,
        onDateTimeChanged: (DateTime dateTime) {
          widgetElement.dispatchEvent(CustomEvent('change', detail: dateTime.toIso8601String()));
        },
        use24hFormat: widgetElement.use24H!,
        minuteInterval: minuteInterval,
      ),
    );
  }
}
