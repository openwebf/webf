import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';

class SliderElement extends WidgetElement {
  SliderElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => {'height': '110px', 'width': '100%'};

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Slider(
      value: double.parse(getAttribute('val') ?? '0'),
      max: 100,
      divisions: 5,
      onChanged: (double value) {
        setState(() {
          dispatchEvent(CustomEvent('change', detail: value));
        });
      },
    );
  }
}