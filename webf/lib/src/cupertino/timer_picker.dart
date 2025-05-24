/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'timer_picker_bindings_generated.dart';

class FlutterCupertinoTimerPicker extends FlutterCupertinoTimerPickerBindings {
  FlutterCupertinoTimerPicker(super.context);

  String _mode = 'hms';
  int? _initialTimerDuration;
  int? _minuteInterval;
  int? _secondInterval;
  String? _backgroundColor;
  double? _height;

  @override
  String? get mode => _mode;
  @override
  set mode(value) {
    _mode = value ?? 'hms';
  }

  @override
  int? get initialTimerDuration => _initialTimerDuration;
  @override
  set initialTimerDuration(value) {
    _initialTimerDuration = int.tryParse(value.toString());
  }

  @override
  int? get minuteInterval => _minuteInterval;
  @override
  set minuteInterval(value) {
    _minuteInterval = int.tryParse(value.toString());
  }

  @override
  int? get secondInterval => _secondInterval;
  @override
  set secondInterval(value) {
    _secondInterval = int.tryParse(value.toString());
  }

  @override
  String? get backgroundColor => _backgroundColor;
  @override
  set backgroundColor(value) {
    _backgroundColor = value;
  }

  @override
  double? get height => _height;
  @override
  set height(value) {
    _height = double.tryParse(value.toString());
  }

  @override
  FlutterCupertinoTimerPickerState? get state => super.state as FlutterCupertinoTimerPickerState?;

  // Helper to parse duration string (e.g., "HH:MM:SS" or seconds) into Duration
  Duration _parseDuration(String? durationString) {
    if (durationString == null || durationString.isEmpty) {
      return Duration.zero;
    }
    int? seconds = int.tryParse(durationString);
    if (seconds != null) {
      if (seconds < 0) seconds = 0;
      if (seconds >= 24 * 3600) seconds = 24 * 3600 - 1;
      return Duration(seconds: seconds);
    }
    List<String> parts = durationString.split(':');
    if (parts.length == 3) {
      int? h = int.tryParse(parts[0]);
      int? m = int.tryParse(parts[1]);
      int? s = int.tryParse(parts[2]);
      if (h != null && m != null && s != null) {
        h = h.clamp(0, 23);
        m = m.clamp(0, 59);
        s = s.clamp(0, 59);
        Duration result = Duration(hours: h, minutes: m, seconds: s);
        if (result.inSeconds >= 24 * 3600) {
          return Duration(hours: 23, minutes: 59, seconds: 59);
        }
        return result;
      }
    }
    print('Warning: Invalid duration format "$durationString". Defaulting to zero.');
    return Duration.zero;
  }

  // Helper to parse mode string into CupertinoTimerPickerMode
  CupertinoTimerPickerMode _getTimerPickerMode(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'hm':
        return CupertinoTimerPickerMode.hm;
      case 'ms':
        return CupertinoTimerPickerMode.ms;
      case 'hms':
      default:
        return CupertinoTimerPickerMode.hms;
    }
  }

  // Helper to parse color string
  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    if (colorString.startsWith('#')) {
      String hex = colorString.substring(1);
      if (hex.length == 6) hex = 'FF' + hex;
      if (hex.length == 8) {
        try {
          return Color(int.parse(hex, radix: 16));
        } catch (e) {
          print('Error parsing color: $colorString, Error: $e');
          return null;
        }
      }
    }
    print('Unsupported color format: $colorString');
    return null;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTimerPickerState(this);
  }
}

class FlutterCupertinoTimerPickerState extends WebFWidgetElementState {
  FlutterCupertinoTimerPickerState(super.widgetElement);

  @override
  FlutterCupertinoTimerPicker get widgetElement => super.widgetElement as FlutterCupertinoTimerPicker;

  @override
  Widget build(BuildContext context) {
    final mode = widgetElement._getTimerPickerMode(widgetElement.mode);
    final rawInitialDuration = widgetElement._parseDuration(widgetElement.initialTimerDuration?.toString());
    final minuteInterval = widgetElement.minuteInterval ?? 1;
    final secondInterval = widgetElement.secondInterval ?? 1;
    final backgroundColor = widgetElement._parseColor(widgetElement.backgroundColor);
    final height = widgetElement.height ?? 216.0;

    // Ensure intervals are valid factors of 60
    final validMinuteInterval = (minuteInterval > 0 && 60 % minuteInterval == 0) ? minuteInterval : 1;
    final validSecondInterval = (secondInterval > 0 && 60 % secondInterval == 0) ? secondInterval : 1;

    // Adjust the initial duration based on intervals
    int initialSeconds = rawInitialDuration.inSeconds;
    int adjustedSeconds = initialSeconds;
    int adjustedMinutes = initialSeconds ~/ 60;

    // Adjust seconds based on secondInterval (if mode includes seconds)
    if (mode == CupertinoTimerPickerMode.ms || mode == CupertinoTimerPickerMode.hms) {
      int secondsPart = initialSeconds % 60;
      adjustedSeconds = initialSeconds - secondsPart + (secondsPart ~/ validSecondInterval) * validSecondInterval;
    }

    // Adjust minutes based on minuteInterval (if mode includes minutes)
    // Use the potentially second-adjusted time for minute calculation basis
    Duration tempDuration = Duration(seconds: adjustedSeconds);
    int minutesPart = tempDuration.inMinutes % 60;
    int currentHours = tempDuration.inHours;
    adjustedMinutes = (minutesPart ~/ validMinuteInterval) * validMinuteInterval;

    // Reconstruct the final adjusted duration based on the mode
    Duration adjustedInitialDuration;
    if (mode == CupertinoTimerPickerMode.hms) {
      adjustedInitialDuration = Duration(hours: currentHours, minutes: adjustedMinutes, seconds: adjustedSeconds % 60);
    } else if (mode == CupertinoTimerPickerMode.hm) {
      adjustedInitialDuration = Duration(hours: currentHours, minutes: adjustedMinutes);
    } else {
      // mode == CupertinoTimerPickerMode.ms
      // For ms mode, total duration is based on adjusted minutes and seconds part
      adjustedSeconds = adjustedSeconds % 3600; // Consider only minutes and seconds
      adjustedInitialDuration = Duration(minutes: adjustedMinutes, seconds: adjustedSeconds % 60);
    }

    // Ensure final duration is within range (redundant check, but safe)
    if (adjustedInitialDuration.inSeconds >= 24 * 3600) {
      adjustedInitialDuration = Duration(
          hours: 23,
          minutes: (59 ~/ validMinuteInterval) * validMinuteInterval,
          seconds: (59 ~/ validSecondInterval) * validSecondInterval);
    } else if (adjustedInitialDuration.isNegative) {
      adjustedInitialDuration = Duration.zero;
    }

    if (mode == CupertinoTimerPickerMode.hm && validSecondInterval != 1) {
      print('Warning: second-interval is ignored when mode is "hm".');
    }
    if (mode == CupertinoTimerPickerMode.ms && validMinuteInterval != 1) {
      print('Warning: minute-interval is ignored when mode is "ms".');
    }

    return SizedBox(
      height: height,
      child: CupertinoTimerPicker(
        mode: mode,
        // Use the adjusted duration
        initialTimerDuration: adjustedInitialDuration,
        minuteInterval: validMinuteInterval,
        secondInterval: validSecondInterval,
        backgroundColor: backgroundColor,
        onTimerDurationChanged: (Duration newDuration) {
          widgetElement.dispatchEvent(CustomEvent('change', detail: newDuration.inSeconds));
        },
      ),
    );
  }
}
