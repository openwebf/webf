import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

class FlutterContainerElement extends WidgetElement {
  FlutterContainerElement(BindingContext? context) : super(context);

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(width: 5, color: Colors.red),
            bottom: BorderSide(width: 5, color: Colors.red),
            left: BorderSide(width: 5, color: Colors.red),
            right: BorderSide(width: 5, color: Colors.red)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
