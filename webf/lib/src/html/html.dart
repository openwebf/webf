/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';

const String HTML = 'HTML';
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
  OVERFLOW: AUTO
};

class HTMLElement extends Element {
  HTMLElement([BindingContext? context]) : super(context) {
    // Add default behavior unfocus focused input or textarea elements.
    addEventListener('click', (event) async {
      flutter.FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  bool get managedByFlutterWidget => true;

  @override
  bool get isRepaintBoundary => true;

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
  Node appendChild(Node child) {
    Node node = super.appendChild(child);
    return node;
  }

  @override
  Node removeChild(Node child) {
    Node node = super.removeChild(child);
    return node;
  }

  @override
  flutter.Widget toWidget({flutter.Key? key}) {
    flutter.Widget child = super.toWidget(key: key);
    return flutter.ScrollConfiguration(
      behavior: flutter.ScrollBehavior().copyWith(scrollbars: false),
      child: child
    );
  }

  // Is child renderObject attached to the render object tree segment, and may be this segment are not attached to flutter.
  @override
  bool get isRendererAttachedToSegmentTree => attachedRenderer != null;

  void _markEntireRenderObjectTreeNeedsLayout() {
    visitor(flutter.RenderObject child) {
      child.markNeedsLayout();
      child.visitChildren(visitor);
    }

    renderStyle.visitChildren(visitor);
  }

  @override
  void setRenderStyle(String property, String present, {String? baseHref}) {
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
      case FONT_SIZE:
        _markEntireRenderObjectTreeNeedsLayout();
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
