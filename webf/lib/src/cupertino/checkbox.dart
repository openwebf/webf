import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoCheckbox extends WidgetElement {
  FlutterCupertinoCheckbox(super.context);

  // Internal state
  bool _value = false;
  bool _disabled = false;
  Color? _activeColor;
  Color? _checkColor;
  Color? _focusColor;
  Color? _fillColorSelected;
  Color? _fillColorDisabled;

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

    // Checked value (true or false) - Using 'val' as requested
    attributes['val'] = ElementAttributeProperty(
        getter: () => _value.toString(),
        setter: (value) {
          // Parameter name change for clarity inside setter
          print('set val: $value');
          bool newValue = (value == 'true');
          if (newValue != _value) {
            _value = newValue;
            state?.requestUpdateState();
          }
        });

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
        getter: () => _disabled.toString(),
        setter: (val) {
          bool previousDisabled = _disabled;
          _disabled = (val != 'false'); // Simplified to check for 'true'
          if (_disabled != previousDisabled) state?.requestUpdateState();
        });

    // Active color (still relevant for fallback and border potentially)
    attributes['active-color'] = ElementAttributeProperty(
        getter: () => _activeColor?.value.toRadixString(16),
        setter: (val) {
          Color? newColor = _parseColor(val);
          if (newColor != _activeColor) {
            _activeColor = newColor;
            state?.requestUpdateState();
          }
        });

    // Check color
    attributes['check-color'] = ElementAttributeProperty(
        getter: () => _checkColor?.value.toRadixString(16),
        setter: (val) {
          Color? newColor = _parseColor(val);
          if (newColor != _checkColor) {
            _checkColor = newColor;
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

    // Fill color for selected state
    attributes['fill-color-selected'] = ElementAttributeProperty(
        getter: () => _fillColorSelected?.value.toRadixString(16),
        setter: (val) {
          Color? newColor = _parseColor(val);
          if (newColor != _fillColorSelected) {
            _fillColorSelected = newColor;
            state?.requestUpdateState();
          }
        });

    // Fill color for disabled state
    attributes['fill-color-disabled'] = ElementAttributeProperty(
        getter: () => _fillColorDisabled?.value.toRadixString(16),
        setter: (val) {
          Color? newColor = _parseColor(val);
          if (newColor != _fillColorDisabled) {
            _fillColorDisabled = newColor;
            state?.requestUpdateState();
          }
        });
  }

  @override
  FlutterCupertinoCheckboxState? get state => super.state as FlutterCupertinoCheckboxState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoCheckboxState(this);
  }
}

class FlutterCupertinoCheckboxState extends WebFWidgetElementState {
  FlutterCupertinoCheckboxState(super.widgetElement);

  @override
  FlutterCupertinoCheckbox get widgetElement => super.widgetElement as FlutterCupertinoCheckbox;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: widgetElement._disabled,
        child: Opacity(
          opacity: widgetElement._disabled ? 0.5 : 1.0,
          child: CupertinoCheckbox(
            value: widgetElement._value,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                widgetElement._value = newValue;
                widgetElement.dispatchEvent(CustomEvent('change', detail: widgetElement._value));
                setState(() {});
              }
            },
            activeColor: widgetElement._activeColor,
            checkColor: widgetElement._checkColor,
            focusColor: widgetElement._focusColor,
            fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return widgetElement._fillColorDisabled ?? CupertinoColors.quaternarySystemFill;
              }
              if (states.contains(WidgetState.selected)) {
                return widgetElement._fillColorSelected ?? widgetElement._activeColor;
              }
              return null;
            }),
          ),
        ));
  }
}
