import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterSwitch extends WidgetElement {
  FlutterSwitch(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Switch(value: getAttribute('selected') == 'true', onChanged: (value) {
      setState(() {
        dispatchEvent(CustomEvent('change', detail: value));
      });
    });
  }
}