import 'package:webf/webf.dart';
import 'package:flutter/material.dart';


class FlutterLayoutBox extends WidgetElement {
  FlutterLayoutBox(BindingContext? context) : super(context);

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return WebFHTMLElement(tagName: 'DIV', children: [
      WebFHTMLElement(tagName: 'P', children: children)
    ], inlineStyle: {
      'width': '100px',
      'height': '100px',
      'padding': '20px',
      'border': '5px solid #000',
      'background': 'red'
    });
  }
}
