import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterButton extends WidgetElement {
  FlutterButton(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return ElevatedButton(onPressed: () {
      dispatchEvent(Event('press'));
    }, child: childNodes.isNotEmpty ? childNodes.first.toWidget() : Text(''));
  }
}