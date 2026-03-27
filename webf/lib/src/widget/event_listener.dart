/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

/// Portal is essential to capture WebF gestures on WebF elements when the
/// renderObject is located outside of WebF's root renderObject tree.
/// Exp: using [showModalBottomSheet] or [showDialog], it will create a
/// standalone Widget Tree along side with the original Widget Tree.
/// Use this widget to make the gesture dispatcher works.
class WebFEventListener extends StatelessWidget {
  final dom.Element ownerElement;
  final bool hasEvent;
  final bool enableTouchEvent;
  final Widget? child;

  const WebFEventListener({
    required this.ownerElement,
    required this.hasEvent,
    this.enableTouchEvent = false,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget wrapped = _WebFRenderEventListener(
      ownerElement: ownerElement,
      hasEvent: hasEvent,
      enableTouchEvent: enableTouchEvent,
      child: child,
    );

    final MouseCursor mouseCursor = ownerElement.renderStyle.cursor.mouseCursor;
    final bool activatesHover = ownerElement.canActivatePseudoClassOnTarget(
      'hover',
    );
    if (!activatesHover && mouseCursor == SystemMouseCursors.basic) {
      return wrapped;
    }

    return MouseRegion(
      cursor: mouseCursor,
      opaque: false,
      onEnter: activatesHover
          ? (PointerEnterEvent event) {
              ownerElement.ownerDocument.queueHoverTargetUpdate(
                event,
                ownerElement,
              );
            }
          : null,
      onHover: activatesHover
          ? (PointerHoverEvent event) {
              ownerElement.ownerDocument.queueHoverTargetUpdate(
                event,
                ownerElement,
              );
            }
          : null,
      onExit: activatesHover
          ? (PointerExitEvent event) {
              ownerElement.ownerDocument.queueHoverTargetClear(
                event,
                ownerElement,
              );
            }
          : null,
      child: wrapped,
    );
  }
}

class _WebFRenderEventListener extends SingleChildRenderObjectWidget {
  final dom.Element ownerElement;
  final bool hasEvent;
  final bool enableTouchEvent;

  const _WebFRenderEventListener({
    required this.ownerElement,
    required this.hasEvent,
    required this.enableTouchEvent,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    if (enableTouchEvent) {
      return RenderTouchEventListener(
        renderStyle: ownerElement.renderStyle,
        controller: ownerElement.ownerDocument.controller,
        hasEvent: hasEvent,
      );
    }
    return RenderEventListener(
      controller: ownerElement.ownerDocument.controller,
      renderStyle: ownerElement.renderStyle,
      hasEvent: hasEvent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderEventListener renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    if (hasEvent) {
      renderObject.enableEventCapture();
    } else {
      renderObject.disabledEventCapture();
    }
  }
}
