/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:webf/webf.dart';
import 'switch_bindings_generated.dart';

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
    _checked = value == 'true';
  }

  @override
  bool get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  String? get activeColor => _activeColor;
  @override
  set activeColor(value) {
    _activeColor = value;
  }

  @override
  String? get inactiveColor => _inactiveColor;
  @override
  set inactiveColor(value) {
    _inactiveColor = value;
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;

    if (colorString.startsWith('#')) {
      String hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF' + hex;
      }
      return Color(int.parse(hex, radix: 16));
    }
    return null;
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSwitchState(this);
  }
}

class FlutterCupertinoSwitchState extends WebFWidgetElementState {
  FlutterCupertinoSwitchState(super.widgetElement);

  @override
  FlutterCupertinoSwitch get widgetElement => super.widgetElement as FlutterCupertinoSwitch;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widgetElement.disabled ? 0.5 : 1.0,
      child: CupertinoSwitch(
        // Basic properties
        value: widgetElement.checked,
        onChanged: widgetElement.disabled ? null : (bool value) {
          widgetElement.checked = value.toString();
          setState(() {
            widgetElement.dispatchEvent(CustomEvent('change', detail: value));
          });
        },

        // Track color
        activeTrackColor: widgetElement._parseColor(widgetElement.activeColor) ?? CupertinoColors.systemBlue,
        inactiveTrackColor: widgetElement._parseColor(widgetElement.inactiveColor),

        dragStartBehavior: DragStartBehavior.start,
      ),
    );
  }
}
