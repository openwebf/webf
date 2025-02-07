import 'package:webf/webf.dart';
import 'package:flutter/material.dart';


class FlutterLayoutBox extends WidgetElement {
  FlutterLayoutBox(BindingContext? context) : super(context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFHTMLElement(tagName: 'DIV', children: [
      WebFHTMLElement(tagName: 'P', children: childNodes.toWidgetList(), controller: ownerDocument.controller, parentElement: this)
    ], inlineStyle: {
      'width': '200px',
      'height': '100px',
      'padding': '20px',
      'border': '5px solid #000',
      'background': 'red'
    }, controller: ownerDocument.controller, parentElement: this);
  }
}
