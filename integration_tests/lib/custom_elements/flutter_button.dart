import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

class FlutterButtonElement extends WidgetElement {
  FlutterButtonElement(BindingContext? context) : super(context);

  handlePressed(BuildContext context) {
    dispatchEvent(Event(EVENT_CLICK));
  }

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'inline-block'
  };

  Widget buildButton(BuildContext context, String type, Widget child) {
    switch (type) {
      case 'primary':
        return ElevatedButton(onPressed: () => handlePressed(context), child: child);
      case 'default':
      default:
        return OutlinedButton(onPressed: () => handlePressed(context), child: child);
    }
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    String type = getAttribute('type') ?? 'default';
    return buildButton(context, type, children.isNotEmpty ? children[0] : Container());
  }
}
