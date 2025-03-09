import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

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

class FlutterCupertinoSwitch extends WidgetElement {
  FlutterCupertinoSwitch(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return CupertinoSwitch(
      value: getAttribute('selected') == 'true',
      onChanged: (value) {
        setState(() {
          dispatchEvent(CustomEvent('change', detail: value));
        });
      },
      activeTrackColor: _parseColor(getAttribute('active-color')) ?? CupertinoColors.systemBlue,
      inactiveTrackColor: _parseColor(getAttribute('inactive-color')),
    );
  }
}