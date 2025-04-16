import 'package:webf/webf.dart';
import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';

class FlutterConstraintContainer extends WidgetElement {
  FlutterConstraintContainer(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'block',
    'width': '100%',
    'height': '200px',
    'border': '2px solid blue',
    'padding': '10px'
  };

  @override
  WebFWidgetElementState createState() {
    return FlutterConstraintContainerState(this);
  }
}

class FlutterConstraintContainerState extends WebFWidgetElementState {
  FlutterConstraintContainerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Create a container with specific constraints
    return Container(
      width: 300,
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 3),
      ),
      // Use WebFWidgetElementChild to pass these constraints to the inner HTML element
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}