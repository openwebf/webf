import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterSwitch extends WidgetElement {
  FlutterSwitch(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterSwitchState(this);
  }
}

class FlutterSwitchState extends WebFWidgetElementState {
  FlutterSwitchState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Switch(value: widgetElement.getAttribute('selected') == 'true', onChanged: (value) {
      setState(() {
        widgetElement.dispatchEvent(CustomEvent('change', detail: value));
      });
    });
  }

}
