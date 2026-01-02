/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:webf/webf.dart';

import 'switch_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoSwitch].
///
/// Exposed as `<flutter-cupertino-switch>` in the DOM.
class FlutterCupertinoSwitch extends FlutterCupertinoSwitchBindings {
  FlutterCupertinoSwitch(super.context);

  bool _checked = false;
  bool _disabled = false;
  String? _activeColor;
  String? _inactiveColor;

  @override
  bool get checked => _checked;

  @override
  set checked(value) {
    final bool next = value == true;
    if (next != _checked) {
      _checked = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool next = value == true;
    if (next != _disabled) {
      _disabled = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get activeColor => _activeColor;

  @override
  set activeColor(value) {
    final String? next = value?.toString();
    if (next != _activeColor) {
      _activeColor = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get inactiveColor => _inactiveColor;

  @override
  set inactiveColor(value) {
    final String? next = value?.toString();
    if (next != _inactiveColor) {
      _inactiveColor = next;
      state?.requestUpdateState(() {});
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    var v = colorString.trim();
    if (!v.startsWith('#')) return null;
    var hex = v.substring(1);
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final int? parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSwitchState(this);
  }
}

class FlutterCupertinoSwitchState extends WebFWidgetElementState {
  FlutterCupertinoSwitchState(super.widgetElement);

  @override
  FlutterCupertinoSwitch get widgetElement =>
      super.widgetElement as FlutterCupertinoSwitch;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widgetElement.disabled ? 0.5 : 1.0,
      child: CupertinoSwitch(
        value: widgetElement.checked,
        onChanged: widgetElement.disabled
            ? null
            : (bool value) {
                widgetElement.checked = value;
                widgetElement.dispatchEvent(
                  CustomEvent('change', detail: value),
                );
              },
        activeTrackColor:
            widgetElement._parseColor(widgetElement.activeColor) ??
                CupertinoColors.systemBlue,
        inactiveTrackColor:
            widgetElement._parseColor(widgetElement.inactiveColor),
        dragStartBehavior: DragStartBehavior.start,
      ),
    );
  }
}
