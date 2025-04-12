import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/bridge.dart';
import 'package:webf/widget.dart';

class ImageWidgetElement extends WidgetElement {
  ImageWidgetElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'inline-block'
  };

  @override
  WebFWidgetElementState createState() {
    return ImageWidgetElementState(this);
  }
}

class ImageWidgetElementState extends WebFWidgetElementState {
  ImageWidgetElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage(widgetElement.getAttribute('src')!));
  }
}
