/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webf/dom.dart';
import 'package:webf/gesture.dart';
import 'package:webf/html.dart';
import 'package:webf/bridge.dart';

class _DragEventInfo extends Drag {
  _DragEventInfo(this.gestureDispatcher);

  final GestureDispatcher gestureDispatcher;

  /// The pointer has moved.
  @override
  void update(DragUpdateDetails details) {
    gestureDispatcher._handleGestureEvent(EVENT_DRAG,
        state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  /// The pointer is no longer in contact with the screen.
  ///
  /// The velocity at which the pointer was moving when it stopped contacting
  /// the screen is available in the `details`.
  @override
  void end(DragEndDetails details) {
    gestureDispatcher._handleGestureEvent(EVENT_DRAG,
        state: EVENT_STATE_END,
        velocityX: details.velocity.pixelsPerSecond.dx,
        velocityY: details.velocity.pixelsPerSecond.dy);
  }

  /// The input from the pointer is no longer directed towards this receiver.
  ///
  /// For example, the user might have been interrupted by a system-modal dialog
  /// in the middle of the drag.
  @override
  void cancel() {
    gestureDispatcher._handleGestureEvent(EVENT_DRAG, state: EVENT_STATE_CANCEL);
  }
}

class DoubleClickDetector {
  TapUpDetails? _lastClickDetails;
  Stopwatch? _stopwatch;

  bool isDoubleClick(TapUpDetails currentDetails) {
    if (_lastClickDetails == null || _stopwatch == null) {
      _startNewClickSequence(currentDetails);
      return false;
    }

    if (_isValidDoubleClick(currentDetails)) {
      _reset();
      return true;
    }

    _startNewClickSequence(currentDetails);
    return false;
  }

  bool _isValidDoubleClick(TapUpDetails currentDetails) {
    return _isWithinTimeThreshold() &&
        _isWithinDistanceThreshold(currentDetails);
  }

  bool _isWithinTimeThreshold() {
    return _stopwatch!.elapsedMilliseconds >= kDoubleTapMinTime.inMilliseconds &&
        _stopwatch!.elapsedMilliseconds <= kDoubleTapTimeout.inMilliseconds;
  }

  bool _isWithinDistanceThreshold(TapUpDetails currentDetails) {
    final Offset offset = _lastClickDetails!.globalPosition - currentDetails.globalPosition;
    return offset.distance < kDoubleTapSlop;
  }

  void _startNewClickSequence(TapUpDetails details) {
    _lastClickDetails = details;
    _stopwatch = Stopwatch()..start();
  }

  void _reset() {
    _lastClickDetails = null;
    _stopwatch?.stop();
    _stopwatch = null;
  }
}


class GestureDispatcher {
  EventTarget target;

  GestureDispatcher(this.target) {
    _gestureRecognizers = [
      TapGestureRecognizer()..onTapUp = _onClick,
      SwipeGestureRecognizer()..onSwipe = _onSwipe,
      PanGestureRecognizer()
        ..onStart = _onPanStart
        ..onUpdate = _onPanUpdate
        ..onEnd = _onPanEnd,
      LongPressGestureRecognizer()..onLongPress = _onLongPress,
      ScaleGestureRecognizer()
        ..onStart = _onScaleStart
        ..onUpdate = _onScaleUpdate
        ..onEnd = _onScaleEnd,
      ImmediateMultiDragGestureRecognizer()..onStart = _onDragStart
    ];
    _dragEventInfo = _DragEventInfo(this);
  }

  late _DragEventInfo _dragEventInfo;

  late List<GestureRecognizer> _gestureRecognizers;

  final Map<int, TouchPoint> _touchPoints = {};

  void _handlePointerDown(PointerDownEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((gesture) {
      // Register the recognizer that needs to be monitored.
      gesture.addPointer(event);
    });
  }

  void _handlePointerPanZoomStart(PointerPanZoomStartEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((gesture) {
      // Register the recognizer that needs to be monitored.
      gesture.addPointerPanZoom(event);
    });
  }

  void handlePointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _handlePointerDown(event);
    }

    if (event is PointerPanZoomStartEvent) {
      _handlePointerPanZoomStart(event);
    }

  }

  Timer? _clearTargetTimer;

  void _stopClearTargetTimer() {
    if (_clearTargetTimer != null) {
      _clearTargetTimer?.cancel();
      _clearTargetTimer = null;
    }
  }

  final DoubleClickDetector _doubleClickDetector = DoubleClickDetector();

  void _onClick(TapUpDetails details) {
    _handleMouseEvent(EVENT_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
    if (_doubleClickDetector.isDoubleClick(details)) {
      _handleMouseEvent(EVENT_DOUBLE_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
    }
  }

  void _onLongPress() {
    _handleMouseEvent(EVENT_LONG_PRESS);
  }

  void _onSwipe(SwipeDetails details) {
    _handleGestureEvent(EVENT_SWIPE,
        velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
  }

  void _onPanStart(DragStartDetails details) {
    _handleGestureEvent(EVENT_PAN,
        state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _handleGestureEvent(EVENT_PAN,
        state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  void _onPanEnd(DragEndDetails details) {
    _handleGestureEvent(EVENT_PAN,
        state: EVENT_STATE_END,
        velocityX: details.velocity.pixelsPerSecond.dx,
        velocityY: details.velocity.pixelsPerSecond.dy);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_START);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_END);
  }

  Drag? _onDragStart(Offset position) {
    _handleGestureEvent(EVENT_DRAG, state: EVENT_STATE_START, deltaX: position.dx, deltaY: position.dy);
    return _dragEventInfo;
  }

  void _handleMouseEvent(String type, {Offset localPosition = Offset.zero, Offset globalPosition = Offset.zero}) {
    RenderBox? root = (target as Node).ownerDocument.attachedRenderer;

    if (root == null) {
      return;
    }

    // When Kraken wraps the Flutter Widget, Kraken need to calculate the global coordinates relative to self.
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

  void _handleGestureEvent(String type,
      {String state = '',
      String direction = '',
      double rotation = 0.0,
      double deltaX = 0.0,
      double deltaY = 0.0,
      double velocityX = 0.0,
      double velocityY = 0.0,
      double scale = 0.0}) {
    Event event = GestureEvent(
      type,
      state: state,
      direction: direction,
      rotation: rotation,
      deltaX: deltaX,
      deltaY: deltaY,
      velocityX: velocityX,
      velocityY: velocityY,
      scale: scale,
    );
    target.dispatchEvent(event);
  }

}
