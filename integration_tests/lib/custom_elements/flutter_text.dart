import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

class TextWidgetElement extends WidgetElement {
  TextWidgetElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'inline-block'
  };

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return Text(getAttribute('value') ?? '',
        textDirection: TextDirection.ltr,
        style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)));
  }
}