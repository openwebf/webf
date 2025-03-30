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
        setState(() {});
      }
    );

    // Whether the switch is disabled
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
        setState(() {});
      }
    );

    // The color of the active state
    attributes['active-color'] = ElementAttributeProperty(
      getter: () => _activeColor?.toString(),
      setter: (value) {
        _activeColor = _parseColor(value);
        setState(() {});
      }
    );

    // The color of the inactive state
    attributes['inactive-color'] = ElementAttributeProperty(
      getter: () => _inactiveColor?.toString(),
      setter: (value) {
        _inactiveColor = _parseColor(value);
        setState(() {});
      }
    );
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Opacity(
      opacity: _disabled ? 0.5 : 1.0,
      child: CupertinoSwitch(
        // Basic properties
        value: _checked,
        onChanged: _disabled ? null : (bool value) {
          _checked = value;
          setState(() {
            dispatchEvent(CustomEvent('change', detail: value));
          });
        },
        
        // Track color
        activeTrackColor: _activeColor ?? CupertinoColors.systemBlue,
        inactiveTrackColor: _inactiveColor,
        
        dragStartBehavior: DragStartBehavior.start,
      ),
    );
  }
}
