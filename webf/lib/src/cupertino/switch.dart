/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoSwitch extends WidgetElement {
  FlutterCupertinoSwitch(super.context);

  bool _checked = false;
  bool _disabled = false;
  Color? _activeColor;
  Color? _inactiveColor;

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
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Switch value
    attributes['checked'] = ElementAttributeProperty(
      getter: () => _checked.toString(),
      setter: (value) {
        _checked = value == 'true';
      }
    );

    // Whether the switch is disabled
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
      }
    );

    // The color of the active state
    attributes['active-color'] = ElementAttributeProperty(
      getter: () => _activeColor?.toString(),
      setter: (value) {
        _activeColor = _parseColor(value);
      }
    );

    // The color of the inactive state
    attributes['inactive-color'] = ElementAttributeProperty(
      getter: () => _inactiveColor?.toString(),
      setter: (value) {
        _inactiveColor = _parseColor(value);
      }
    );
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
      opacity: widgetElement._disabled ? 0.5 : 1.0,
      child: CupertinoSwitch(
        // Basic properties
        value: widgetElement._checked,
        onChanged: widgetElement._disabled ? null : (bool value) {
          widgetElement._checked = value;
          setState(() {
            widgetElement.dispatchEvent(CustomEvent('change', detail: value));
          });
        },

        // Track color
        activeTrackColor: widgetElement._activeColor ?? CupertinoColors.systemBlue,
        inactiveTrackColor: widgetElement._inactiveColor,

        dragStartBehavior: DragStartBehavior.start,
      ),
    );
  }
}
