/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webf/dom.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/svg.dart';

class GestureDispatcher {
  dom.Element target;

  GestureDispatcher(this.target) {
    _gestureRecognizers = {
      EVENT_CLICK: TapGestureRecognizer()..onTapUp = _onClick
    };
  }

  late Map<String, GestureRecognizer> _gestureRecognizers;

  void _handlePointerDown(EventTarget currentTarget, PointerDownEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((eventName, gesture) {
      if (currentTarget.getEventHandlers().containsKey(eventName) ||
          currentTarget.getCaptureEventHandlers().containsKey(eventName)) {
        // Register the recognizer that needs to be monitored.
        gesture.addPointer(event);
      }
    });
  }

  void _handlePointerPanZoomStart(EventTarget currentTarget, PointerPanZoomStartEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((eventName, gesture) {
      if (currentTarget.getEventHandlers().containsKey(eventName) ||
          currentTarget.getCaptureEventHandlers().containsKey(eventName)) {
        // Register the recognizer that needs to be monitored.
        gesture.addPointerPanZoom(event);
      }
    });
  }

  void handlePointerEvent(PointerEvent event) {
    EventTarget currentTarget = getCurrentEventTarget();

    if (event is PointerDownEvent) {
      _handlePointerDown(currentTarget, event);
    }

    if (event is PointerPanZoomStartEvent) {
      _handlePointerPanZoomStart(currentTarget, event);
    }
  }

  void _onClick(TapUpDetails details) {
    _handleMouseEvent(EVENT_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  EventTarget getCurrentEventTarget() {
    EventTarget target = this.target.ownerView.viewport?.rawPointerListener.lastActiveEventTarget ?? this.target;

    if (target is SVGElement && target.hostingImageElement != null) {
      target = target.hostingImageElement!;
    }

    return target;
  }

  void _handleMouseEvent(String type, {Offset localPosition = Offset.zero, Offset globalPosition = Offset.zero}) {
    RenderBox? root = (this.target as Node).ownerDocument.attachedRenderer;

    if (root == null) {
      return;
    }

    EventTarget target = getCurrentEventTarget();

    Offset globalOffset = root.globalToLocal(Offset(globalPosition.dx, globalPosition.dy));
    double clientX = globalOffset.dx;
    double clientY = globalOffset.dy;

    Event event = MouseEvent(type,
        clientX: clientX,
        clientY: clientY,
        offsetX: localPosition.dx,
        offsetY: localPosition.dy,
        view: (target as Node).ownerDocument.defaultView);
    target.dispatchEvent(event);
  }
}
