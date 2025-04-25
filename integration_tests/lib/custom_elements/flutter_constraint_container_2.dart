import 'package:webf/webf.dart';
import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';

class FlutterConstraintContainer2 extends WidgetElement {
  FlutterConstraintContainer2(BindingContext? context) : super(context);

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
    return FlutterConstraintContainerState2(this);
  }
}

class FlutterConstraintContainerState2 extends WebFWidgetElementState {
  FlutterConstraintContainerState2(super.widgetElement);

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
                inlineStyle: {
                  'display': 'flex',
                  'border': '1px solid yellow',
                  'flex-direction': 'column'
                },
                controller: widgetElement.controller,
                parentElement: widgetElement,
                children: widgetElement.childNodes.toWidgetList())));
  }
}

class FlutterConstraintContainer2Item extends WidgetElement {
  FlutterConstraintContainer2Item(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterConstraintContainer2ItemState(this);
  }
}

class FlutterConstraintContainer2ItemState extends WebFWidgetElementState {
  FlutterConstraintContainer2ItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.controller,
        inlineStyle: {
          'border': '1px solid green',
        },
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}
