/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoDatePicker extends WidgetElement {
  FlutterCupertinoDatePicker(super.context);

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
    final mode = widgetElement.getAttribute('mode') ?? 'date';
    final minimumDate = _parseDateTime(widgetElement.getAttribute('minimum-date'));
    final maximumDate = _parseDateTime(widgetElement.getAttribute('maximum-date'));
    final minuteInterval = int.tryParse(widgetElement.getAttribute('minute-interval') ?? '') ?? 1;

    // validate and adjust the initial date time
    final initialDateTime = _validateDateTime(
        _parseDateTime(widgetElement.getAttribute('value')),
        minimumDate,
        maximumDate,
        minuteInterval
    );

    final minimumYear = int.tryParse(widgetElement.getAttribute('minimum-year') ?? '') ?? 1;
    final maximumYear = int.tryParse(widgetElement.getAttribute('maximum-year') ?? '');
    final showDayOfWeek = widgetElement.getAttribute('show-day-of-week') == 'true';
    final dateOrder = _getDateOrder(widgetElement.getAttribute('date-order'));

    return SizedBox(
      height: double.tryParse(widgetElement.getAttribute('height') ?? '') ?? 200,
      child: CupertinoDatePicker(
        mode: _getDatePickerMode(mode),
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
        use24hFormat: widgetElement.getAttribute('use-24h') == 'true',
        minuteInterval: minuteInterval,
      ),
    );
  }
}
