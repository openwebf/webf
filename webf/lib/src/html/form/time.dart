/*
 * Copyright (C) 2022-present The WebF Company. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:webf/src/widget/widget_element.dart';

import 'base_input.dart';

mixin TimeElementState on WebFWidgetElementState {
  bool checked = false;

  @override
  BaseInputElement get widgetElement => super.widgetElement as BaseInputElement;

  Future<String?> _showPicker(BuildContext context) async {
    switch (widgetElement.type) {
      case 'date':
        DateTime? time;
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          case TargetPlatform.iOS:
          case TargetPlatform.fuchsia:
            time = await _showDialog(context);
            break;
          default:
            time = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.parse('19700101'),
              lastDate: DateTime.parse('30000101'),
            );
        }
        return time != null ? DateFormat('yyyy-MM-dd').format(time) : null;
      case 'time':
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          case TargetPlatform.iOS:
          case TargetPlatform.fuchsia:
            var time = await _showDialog(context, mode: CupertinoDatePickerMode.time);
            if (time != null) {
              var minute = time.minute.toString().padLeft(2, '0');
              var hour = time.hour.toString().padLeft(2, '0');
              return '$hour:$minute';
            }
            break;
          default:
            var time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (time != null) {
              var minute = time.minute.toString().padLeft(2, '0');
              var hour = time.hour.toString().padLeft(2, '0');
              return '$hour:$minute';
            }
        }
    }
    return null;
  }

  Future<DateTime?> _showDialog(BuildContext context,
      {CupertinoDatePickerMode mode = CupertinoDatePickerMode.date}) async {
    DateTime? time;
    await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: mode,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    time = newDate;
                  },
                ),
              ),
            ));
    return time;
  }

  Widget createTime(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var time = await _showPicker(context);
        if (time != null)
          setState(() {
            widgetElement.value = time;
          });
      },
      child: AbsorbPointer(child: _createTimeInput(context)),
    );
  }
  
  Widget _createTimeInput(BuildContext context);
}
