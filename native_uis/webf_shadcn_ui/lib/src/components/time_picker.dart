/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'time_picker_bindings_generated.dart';

/// WebF custom element for time picking.
///
/// Exposed as `<flutter-shadcn-time-picker>` in the DOM.
class FlutterShadcnTimePicker extends FlutterShadcnTimePickerBindings {
  FlutterShadcnTimePicker(super.context);

  String? _value;
  String? _placeholder;
  bool _disabled = false;
  bool _use24Hour = true;

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
  bool get use24Hour => _use24Hour;

  @override
  set use24Hour(value) {
    final newValue = value == true;
    if (newValue != _use24Hour) {
      _use24Hour = newValue;
      state?.requestUpdateState(() {});
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnTimePickerState(this);
}

class FlutterShadcnTimePickerState extends WebFWidgetElementState {
  FlutterShadcnTimePickerState(super.widgetElement);

  final _popoverController = ShadPopoverController();

  @override
  FlutterShadcnTimePicker get widgetElement =>
      super.widgetElement as FlutterShadcnTimePicker;

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return widgetElement.placeholder ?? 'Select time';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final time = widgetElement._parseTime(widgetElement.value);

    return ShadPopover(
      controller: _popoverController,
      popover: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TimeSpinner(
                  value: time?.hour ?? 0,
                  maxValue: 23,
                  onChanged: (hour) {
                    final newTime = TimeOfDay(
                      hour: hour,
                      minute: time?.minute ?? 0,
                    );
                    widgetElement._value = _formatTime(newTime);
                    widgetElement.dispatchEvent(Event('change'));
                    widgetElement.state?.requestUpdateState(() {});
                  },
                ),
                Text(' : ', style: theme.textTheme.h4),
                _TimeSpinner(
                  value: time?.minute ?? 0,
                  maxValue: 59,
                  onChanged: (minute) {
                    final newTime = TimeOfDay(
                      hour: time?.hour ?? 0,
                      minute: minute,
                    );
                    widgetElement._value = _formatTime(newTime);
                    widgetElement.dispatchEvent(Event('change'));
                    widgetElement.state?.requestUpdateState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
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
              Icons.access_time,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(time),
              style: TextStyle(
                color:
                    time == null ? theme.colorScheme.mutedForeground : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSpinner extends StatelessWidget {
  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _TimeSpinner({
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            onChanged((value + 1) % (maxValue + 1));
          },
        ),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: theme.textTheme.h4,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            onChanged(value == 0 ? maxValue : value - 1);
          },
        ),
      ],
    );
  }
}
