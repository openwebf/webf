/*
 * Copyright (C) 2024-present The OpenWebF(Cayman) Company. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
class BRElement extends Element {
  BRElement([BindingContext? context]) : super(context);

  @override
  bool get isReplacedElement => true;

  @override
  void setRenderStyle(String property, String present, { String? baseHref }) {
    // Noop
  }

  @override
  flutter.Widget toWidget({flutter.Key? key}) {
    return WebFReplacedElementWidget(webFElement: this, key: key ?? this.key);
  }

  @override
  RenderBox createRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    RenderLineBreak lineBreak = RenderLineBreak(renderStyle);

    if (managedByFlutterWidget) {
      assert(flutterWidgetElement != null);
      renderStyle.addOrUpdateWidgetRenderObjects(flutterWidgetElement!, lineBreak);
    } else {
      renderStyle.setDomRenderObject(lineBreak);
    }

    return lineBreak;
  }
}
