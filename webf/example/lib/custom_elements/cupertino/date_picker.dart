import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoDatePicker extends WidgetElement {
  FlutterCupertinoDatePicker(super.context);

  DateTime _parseDateTime(String? dateString) {
    if (dateString == null) return DateTime.now();
    return DateTime.tryParse(dateString) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final mode = getAttribute('mode') ?? 'date';
    final minimumDate = _parseDateTime(getAttribute('minimum-date'));
    final maximumDate = _parseDateTime(getAttribute('maximum-date'));
    final initialDateTime = _parseDateTime(getAttribute('value'));
    
    return SizedBox(
      height: double.tryParse(getAttribute('height') ?? '') ?? 200,
      child: CupertinoDatePicker(
        mode: _getDatePickerMode(mode),
        initialDateTime: initialDateTime,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        onDateTimeChanged: (DateTime dateTime) {
          dispatchEvent(CustomEvent('change', detail: dateTime.toIso8601String()));
        },
        use24hFormat: getAttribute('use-24h') == 'true',
        minuteInterval: int.tryParse(getAttribute('minute-interval') ?? '') ?? 1,
      ),
    );
  }

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
}