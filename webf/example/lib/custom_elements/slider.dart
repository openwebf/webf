/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';

class SliderElement extends WidgetElement {
  SliderElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => {'height': '110px', 'width': '100%'};

  @override
  WebFWidgetElementState createState() {
    return SliderElementState(this);
  }
}

class SliderElementState extends WebFWidgetElementState {
  SliderElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: double.parse(widgetElement.getAttribute('val') ?? '0'),
      max: 100,
      divisions: 5,
      onChanged: (double value) {
        setState(() {
          widgetElement.dispatchEvent(CustomEvent('change', detail: value));
        });
      },
    );
  }
}
