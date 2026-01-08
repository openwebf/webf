/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
  const WebFWidgetElementChild({super.child, super.key});

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
  BoxConstraints? _effectiveChildConstraints;

  /// The last constraints actually used to lay out [child].
  ///
  /// This can differ from [constraints] when [constraints] are unbounded and
  /// we collapse to intrinsic sizing before laying out the WebF subtree.
  BoxConstraints get effectiveChildConstraints => _effectiveChildConstraints ?? constraints;

  @override
  void performLayout() {
    final BoxConstraints incoming = constraints;
    final RenderBox? c = child;
    _effectiveChildConstraints = incoming;

    // When used inside layouts that provide unbounded constraints on one axis
    // (e.g., a horizontal RenderFlex main axis), forwarding those unbounded
    // constraints directly into WebF layout can lead to infinite sizes during
    // IFC/flow sizing. Instead, collapse unbounded width to the child's
    // intrinsic width so the WebF element behaves like a flex item whose size
    // is driven by its content.
    BoxConstraints effective = incoming;
    if (c != null && !incoming.hasBoundedWidth) {
      double intrinsicWidth = c.getMaxIntrinsicWidth(
        incoming.maxHeight.isFinite ? incoming.maxHeight : 0,
      );
      if (!intrinsicWidth.isFinite || intrinsicWidth < 0) {
        intrinsicWidth = 0;
      }
      effective = BoxConstraints(
        minWidth: intrinsicWidth,
        maxWidth: intrinsicWidth,
        minHeight: incoming.minHeight,
        maxHeight: incoming.maxHeight,
      );
    }

    _effectiveChildConstraints = effective;

    if (c is RenderBoxModel) {
      // Ensure CSS sizing queries resolve constraints against the *current*
      // render subtree when the same DOM element is mounted into multiple
      // Flutter widget subtrees (e.g. CupertinoContextMenu preview/modal).
      renderBoxModelInLayoutStack.add(c);
      try {
        c.renderStyle.computeContentBoxLogicalWidth();
        c.renderStyle.computeContentBoxLogicalHeight();
      } finally {
        renderBoxModelInLayoutStack.removeLast();
      }
    }

    if (c != null) {
      c.layout(effective, parentUsesSize: true);
      size = c.size;
    } else {
      size = computeSizeForNoChild(incoming);
    }
  }
}
