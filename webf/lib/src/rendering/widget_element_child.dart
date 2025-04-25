/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';

/// A widget that passes outer constraints to inner WebF HTMLElement children.
///
/// This widget serves as a bridge between Flutter widget constraints and WebF HTML elements.
/// It exposes the Flutter layout constraints to the inner HTML elements, ensuring proper
/// sizing and layout when custom Flutter widgets interact with WebF HTML content.
///
/// Typically used in custom WebFWidgetElementState implementations to ensure HTML elements
/// properly receive and respect the parent widget's constraints.
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return Padding(
///     padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
///     child: WebFWidgetElementChild(
///       child: WebFHTMLElement(
///         tagName: 'DIV',
///         controller: widgetElement.controller,
///         parentElement: widgetElement,
///         children: widgetElement.childNodes.toWidgetList()
///       )
///     )
///   );
/// }
/// ```
class WebFWidgetElementChild extends SingleChildRenderObjectWidget {
  /// Creates a WebFWidgetElementChild widget.
  ///
  /// The [child] parameter is the WebF HTML element that will receive
  /// the constraints from the parent Flutter widget.
  WebFWidgetElementChild({Widget? child, Key? key}): super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWidgetElementChild();
  }
}

/// The render object for [WebFWidgetElementChild].
///
/// This render object extends [RenderProxyBox] to maintain the original
/// constraints from the parent render object, making them accessible to
/// WebF HTML elements through the [findWidgetElementChild] method.
class RenderWidgetElementChild extends RenderProxyBox {
  @override
  void performLayout() {
    if (child is RenderBoxModel) {
      (child as RenderBoxModel).renderStyle.computeContentBoxLogicalWidth();
      (child as RenderBoxModel).renderStyle.computeContentBoxLogicalHeight();
    }
    super.performLayout();
  }
}
