import 'package:flutter/cupertino.dart';

// import 'package:flutter/material.dart'; // No longer needed
import 'package:webf/webf.dart';

class FlutterCupertinoRadio extends WidgetElement {
  FlutterCupertinoRadio(super.context);

  // Internal state - values are stored as strings from attributes
  String? _value;
  String? _groupValue;
  bool _useCheckmarkStyle = false;
  bool _disabled = false;
  Color? _activeColor;
  Color? _focusColor;

  // Color? _fillColorSelected; // Removed

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
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // The value this radio represents
    attributes['val'] = ElementAttributeProperty(
        getter: () => _value ?? '',
        setter: (val) {
          if (val != _value) {
            _value = val;
            state?.requestUpdateState();
          }
        });

    // The currently selected value in the group
    attributes['group-value'] = ElementAttributeProperty(
        getter: () => _groupValue ?? '',
        setter: (val) {
          if (val != _groupValue) {
            _groupValue = val;
            state?.requestUpdateState();
          }
        });

    // Use checkmark style
    attributes['use-checkmark-style'] = ElementAttributeProperty(
        getter: () => _useCheckmarkStyle.toString(),
        setter: (val) {
          bool newValue = (val != 'false');
          if (newValue != _useCheckmarkStyle) {
            _useCheckmarkStyle = newValue;
            state?.requestUpdateState();
          }
        });

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
        getter: () => _disabled.toString(),
        setter: (val) {
          bool newValue = (val != 'false');
          if (newValue != _disabled) {
            _disabled = newValue;
            state?.requestUpdateState();
          }
        });

    // Active color (Color when selected)
    attributes['active-color'] = ElementAttributeProperty(
        getter: () => _activeColor?.value.toRadixString(16),
        setter: (val) {
          Color? newColor = _parseColor(val);
          if (newColor != _activeColor) {
            _activeColor = newColor;
            state?.requestUpdateState();
          }
        });

    // Focus color
    attributes['focus-color'] = ElementAttributeProperty(
        getter: () => _focusColor?.value.toRadixString(16),
        setter: (val) {
          Color? newColor = _parseColor(val);
          if (newColor != _focusColor) {
            _focusColor = newColor;
            state?.requestUpdateState();
          }
        });

    // Removed fill-color-selected attribute
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoRadioState(this);
  }
}

class FlutterCupertinoRadioState extends WebFWidgetElementState {
  FlutterCupertinoRadioState(super.widgetElement);

  @override
  FlutterCupertinoRadio get widgetElement => super.widgetElement as FlutterCupertinoRadio;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: widgetElement._disabled,
        child: Opacity(
          opacity: widgetElement._disabled ? 0.5 : 1.0,
          child: CupertinoRadio<String>(
            value: widgetElement._value ?? '',
            groupValue: widgetElement._groupValue,
            useCheckmarkStyle: widgetElement._useCheckmarkStyle,
            activeColor: widgetElement._activeColor,
            // Directly use the active color
            focusColor: widgetElement._focusColor,
            onChanged: (String? newValue) {
              if (newValue != null) {
                widgetElement.dispatchEvent(CustomEvent('change', detail: newValue));
              }
            },
          ),
        ));
  }
}
