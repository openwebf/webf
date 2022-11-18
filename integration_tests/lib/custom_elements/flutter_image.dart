import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

class ImageWidgetElement extends WidgetElement {
  ImageWidgetElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'inline-block'
  };

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return Image(image: AssetImage(getAttribute('src')!));
  }
}
