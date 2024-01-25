/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/widgets.dart' show FocusManager;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';

const String HTML = 'HTML';
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class HTMLElement extends Element {
  HTMLElement([BindingContext? context]) : super(context) {
    // Add default behavior unfocus focused input or textarea elements.
    addEventListener('click', (event) async {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  @override
  Future<void> dispatchEvent(Event event) async {
    // Scroll event proxy to document.
    if (event.type == EVENT_SCROLL) {
      // https://www.w3.org/TR/2014/WD-DOM-Level-3-Events-20140925/#event-type-scroll
      // When dispatched on the Document element, this event type must bubble to the Window object.
      event.bubbles = true;
      ownerDocument.dispatchEvent(event);
      return;
    }
    super.dispatchEvent(event);
  }

  @override
  void ensureChildAttached() {
    final box = renderBoxModel as RenderLayoutBox?;
    if (box == null) return;
    for (Node child in childNodes) {
      RenderBox? after;
      RenderLayoutBox? scrollingContentBox = box.renderScrollingContent;
      if (scrollingContentBox != null) {
        after = scrollingContentBox.lastChild;
      } else {
        after = box.lastChild;
      }
      if (!child.isRendererAttachedToSegmentTree) {
        child.attachTo(this, after: after);
        child.ensureChildAttached();
      }
    }
  }

  // Is child renderObject attached to the render object tree segment, and may be this segment are not attached to flutter.
  @override
  bool get isRendererAttachedToSegmentTree => renderer != null;

  @override
  void setRenderStyle(String property, String present, { String? baseHref }) {
    switch (property) {
      // Visible should be interpreted as auto and clip should be interpreted as hidden when overflow apply to html.
      // https://drafts.csswg.org/css-overflow-3/#overflow-propagation
      case OVERFLOW:
      case OVERFLOW_X:
      case OVERFLOW_Y:
        if (present == VISIBLE || present == '') {
          present = AUTO;
        } else if (present == CLIP) {
          present = HIDDEN;
        }
        break;
    }
    super.setRenderStyle(property, present);
  }

  void flushPendingStylePropertiesForWholeTree() {
    runner(Element root) {
      root.style.flushPendingProperties();
      root.children.forEach((element) {
        runner(element);
      });
    }
    runner(this);
  }
}
