/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2024-present The OpenWebF(Cayman) Company. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
class BRElement extends Element {
  BRElement([super.context]);


  @override
  void setRenderStyle(String property, String present, { String? baseHref }) {
    // Noop
  }

  @override
  RenderBox createRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    // Use a dedicated render object so <br> contributes one line of height
    // when it is not part of an inline formatting context.
    final renderBr = RenderBr(renderStyle: renderStyle);

    assert(flutterWidgetElement != null);
    // Pair render object with Flutter element for widget-managed elements
    renderStyle.addOrUpdateWidgetRenderObjects(flutterWidgetElement!, renderBr);
    // Ensure event responder is bound for event dispatch consistency
    renderStyle.ensureEventResponderBound();

    return renderBr;
  }

}
