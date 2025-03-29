/*
 * Copyright (C) 2024-present The OpenWebF(Cayman). All rights reserved.
 */

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';

enum PointState { Down, Move, Up, Cancel }

// The coordinate point at which a pointer (e.g finger or stylus) intersects the target surface of an interface.
// This may apply to a finger touching a touch-screen, or an digital pen writing on a piece of paper.
// https://www.w3.org/TR/touch-events/#dfn-touch-point
// https://github.com/WebKit/WebKit/blob/main/Source/WebCore/platform/PlatformTouchPoint.h#L31
class TouchPoint {
  final int id;
  final PointState state;
  final Offset pos;
  final Offset screenPos;
  final double radiusX;
  final double radiusY;
  final double rotationAngle;
  final double force;

  const TouchPoint(
      this.id, this.state, this.pos, this.screenPos, this.radiusX, this.radiusY, this.rotationAngle, this.force);

  @override
  String toString() {
    return 'TouchPoint(id: $id, state: $state, pos: $pos, screenPos: $screenPos, radiusX: $radiusX, radiusY: $radiusY, rotationAngle: $rotationAngle, force: $force)';
  }
}

// Get the raw pointer events without the filtering of GestureRecognizer.
// Used for implementing the touchstart, touchmove and touchend DOM events.
class RawPointerListener {
  final List<EventTarget> eventTriggeredEventTargets = [];

  void recordEventTarget(EventTarget eventTarget) {
    eventTriggeredEventTargets.add(eventTarget);
  }

  EventTarget? lastActiveEventTarget;
  final Map<int, EventTarget> _activeEventTarget = {};
  final Map<int, TouchPoint> _activeTouches = {};

  void handleEvent(PointerEvent event) {
    TouchPoint touchPoint = _toTouchPoint(event);

    if (event is PointerDownEvent && eventTriggeredEventTargets.isNotEmpty) {
      EventTarget target = eventTriggeredEventTargets.first;

      lastActiveEventTarget = target;

      _activeTouches[touchPoint.id] = touchPoint;
      _activeEventTarget[touchPoint.id] = target;

      _handleTouchPoint(target, touchPoint);

      eventTriggeredEventTargets.clear();
    }

    if (event is PointerMoveEvent && _activeEventTarget.containsKey(touchPoint.id)) {
      _activeTouches[touchPoint.id] = touchPoint;
      _handleTouchPoint(_activeEventTarget[touchPoint.id]!, touchPoint);
    }

    if (event is PointerUpEvent && _activeEventTarget.containsKey(touchPoint.id)) {
      _handleTouchPoint(_activeEventTarget[touchPoint.id]!, touchPoint);

      scheduleMicrotask(() {
        _activeEventTarget.remove(touchPoint.id);
        _activeTouches.remove(touchPoint.id);
        lastActiveEventTarget = null;
      });
    }
  }

  TouchPoint _toTouchPoint(PointerEvent pointerEvent) {
    PointState pointState = PointState.Cancel;
    if (pointerEvent is PointerDownEvent) {
      pointState = PointState.Down;
    } else if (pointerEvent is PointerMoveEvent) {
      pointState = PointState.Move;
    } else if (pointerEvent is PointerUpEvent) {
      pointState = PointState.Up;
    } else {
      pointState = PointState.Cancel;
    }

    return TouchPoint(pointerEvent.pointer, pointState, pointerEvent.localPosition, pointerEvent.position,
        pointerEvent.radiusMajor, pointerEvent.radiusMinor, pointerEvent.orientation, pointerEvent.pressure);
  }

  void _handleTouchPoint(EventTarget target, TouchPoint currentTouchPoint) {
    String eventType;
    if (currentTouchPoint.state == PointState.Down) {
      eventType = EVENT_TOUCH_START;
    } else if (currentTouchPoint.state == PointState.Move) {
      eventType = EVENT_TOUCH_MOVE;
    } else if (currentTouchPoint.state == PointState.Up) {
      eventType = EVENT_TOUCH_END;
    } else {
      eventType = EVENT_TOUCH_CANCEL;
    }

    TouchEvent e = TouchEvent(eventType);

    _activeTouches.forEach((id, touchPoint) {
      EventTarget target = _activeEventTarget[id]!;
      Touch touch = _toTouch(target, touchPoint);

      // The touch target might be eliminated from the DOM tree and collected by JavaScript GC,
      // resulting in it becoming invisible and inaccessible, yet this change is not synchronized with Dart instantly.
      // Therefore, refrain from triggering events on these unavailable DOM targets.
      if (isBindingObjectDisposed(touch.target.pointer)) {
        return;
      }

      if (currentTouchPoint.id == touchPoint.id) {
        e.changedTouches.append(touch);
      }

      if (_activeEventTarget[touchPoint.id] == _activeEventTarget[currentTouchPoint.id]) {
        // A list of Touch objects for every point of contact that is touching the surface
        // and started on the element that is the target of the current event.
        e.targetTouches.append(touch);
      }
      e.touches.append(touch);
    });

    if (e.touches.length > 0) {
      target.dispatchEvent(e);
    }
  }

  Touch _toTouch(EventTarget target, TouchPoint touchPoint) {
    return Touch(
      identifier: touchPoint.id,
      target: target,
      screenX: touchPoint.screenPos.dx,
      screenY: touchPoint.screenPos.dy,
      clientX: touchPoint.pos.dx,
      clientY: touchPoint.pos.dy,
      pageX: touchPoint.pos.dx,
      pageY: touchPoint.pos.dy,
      radiusX: touchPoint.radiusX,
      radiusY: touchPoint.radiusY,
      rotationAngle: touchPoint.rotationAngle,
      force: touchPoint.force,
    );
  }
}
