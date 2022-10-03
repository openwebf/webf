import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

class FlutterCheckBoxElement extends WidgetElement {
  FlutterCheckBoxElement(BindingContext? context) : super(context);
  bool isChecked = false;

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'value':
        return isChecked;
    }

    return super.getBindingProperty(key);
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'value':
        isChecked = value;
        break;
    }

    super.setBindingProperty(key, value);
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value ?? false;
          dispatchEvent(dom.Event(dom.EVENT_CHANGE));
        });
      },
    );
  }
}
