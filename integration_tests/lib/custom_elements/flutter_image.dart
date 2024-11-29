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
  Widget build(BuildContext context, dom.ChildNodeList childNodes) {
    return Image(image: AssetImage(getAttribute('src')!));
  }
}
