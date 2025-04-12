import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

class FlutterLayoutBox extends WidgetElement {
  FlutterLayoutBox(BindingContext? context) : super(context);

  @override
  WebFWidgetElementState createState() {
    return FlutterLayoutBoxState(this);
  }
}

class FlutterLayoutBoxState extends WebFWidgetElementState {
  FlutterLayoutBoxState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFHTMLElement(
        tagName: 'DIV',
        children: [
          WebFHTMLElement(
              tagName: 'P',
              children: widgetElement.childNodes.toWidgetList(),
              controller: widgetElement.ownerDocument.controller,
              parentElement: widgetElement)
        ],
        inlineStyle: {
          'width': '200px',
          'height': '100px',
          'padding': '20px',
          'border': '5px solid #000',
          'background': 'red'
        },
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement);
  }
}
