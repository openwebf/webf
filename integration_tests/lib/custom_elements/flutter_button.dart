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

  @override
  WebFWidgetElementState createState() {
    return FlutterButtonElementState(this);
  }
}

class FlutterButtonElementState extends WebFWidgetElementState {
  FlutterButtonElementState(super.widgetElement);

  Widget buildButton(BuildContext context, String type, Widget child) {
    switch (type) {
      case 'primary':
        return ElevatedButton(onPressed: () => widgetElement.handlePressed(context), child: child);
      case 'default':
      default:
        return OutlinedButton(onPressed: () => widgetElement.handlePressed(context), child: child);
    }
  }

  @override
  FlutterButtonElement get widgetElement => super.widgetElement as FlutterButtonElement;

  @override
  Widget build(BuildContext context) {
    String type = widgetElement.getAttribute('type') ?? 'default';
    return buildButton(context, type, widgetElement.childNodes.isNotEmpty ? widgetElement.childNodes.first.toWidget() : Container());
  }
}
