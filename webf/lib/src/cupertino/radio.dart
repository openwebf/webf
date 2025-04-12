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
         try { return Color(int.parse(hex, radix: 16)); }
         catch (e) { print('Error parsing color: $colorString, Error: $e'); return null; }
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
        if (val != _value) { _value = val; setState(() {}); }
      }
    );

    // The currently selected value in the group
    attributes['group-value'] = ElementAttributeProperty(
      getter: () => _groupValue ?? '',
      setter: (val) {
        if (val != _groupValue) { _groupValue = val; setState(() {}); }
      }
    );


    // Use checkmark style
    attributes['use-checkmark-style'] = ElementAttributeProperty(
      getter: () => _useCheckmarkStyle.toString(),
      setter: (val) {
        bool newValue = (val != 'false');
        if (newValue != _useCheckmarkStyle) { _useCheckmarkStyle = newValue; setState(() {}); }
      }
    );

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (val) {
        bool newValue = (val != 'false');
        if (newValue != _disabled) { _disabled = newValue; setState(() {}); }
      }
    );

    // Active color (Color when selected)
    attributes['active-color'] = ElementAttributeProperty(
      getter: () => _activeColor?.value.toRadixString(16),
      setter: (val) {
        Color? newColor = _parseColor(val);
        if (newColor != _activeColor) { _activeColor = newColor; setState(() {}); }
      }
    );

    // Focus color
    attributes['focus-color'] = ElementAttributeProperty(
      getter: () => _focusColor?.value.toRadixString(16),
      setter: (val) {
        Color? newColor = _parseColor(val);
        if (newColor != _focusColor) { _focusColor = newColor; setState(() {}); }
      }
    );

    // Removed fill-color-selected attribute
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return IgnorePointer(
       ignoring: _disabled,
       child: Opacity(
          opacity: _disabled ? 0.5 : 1.0,
          child: CupertinoRadio<String>(
            value: _value ?? '', 
            groupValue: _groupValue,
            useCheckmarkStyle: _useCheckmarkStyle,
            activeColor: _activeColor, // Directly use the active color
            focusColor: _focusColor,
            onChanged: (String? newValue) {
              if (newValue != null) {
                dispatchEvent(CustomEvent('change', detail: newValue));
              }
            },
          ),
       )
    );
  }
} 