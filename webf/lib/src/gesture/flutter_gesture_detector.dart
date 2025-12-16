/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;

// ignore: constant_identifier_names
const String FLUTTER_GESTURE_DETECTOR = 'FLUTTER-GESTURE-DETECTOR';

// Custom gesture detector element
class FlutterGestureDetector extends WidgetElement {
  FlutterGestureDetector(super.context);

  @override
  Map<String, dynamic> get defaultStyle => {
    DISPLAY: BLOCK
  };

  @override
  bool get allowsInfiniteHeight => true;

  @override
  bool get allowsInfiniteWidth => true;

  @override
  FlutterGestureDetectorState createState() => FlutterGestureDetectorState(this);
}

class FlutterGestureDetectorState extends WebFWidgetElementState {
  FlutterGestureDetectorState(super.widgetElement);

  @override
  FlutterGestureDetector get widgetElement => super.widgetElement as FlutterGestureDetector;

  void _dispatchGestureEvent(String eventType, Map<String, dynamic> data) {
    final event = dom.CustomEvent(eventType, detail: data);
    widgetElement.dispatchEvent(event);
  }

  // Track last focal points to compute deltas for pan-style events.
  Offset? _lastLocalFocalPoint;
  double _panTotalDeltaX = 0.0;
  double _panTotalDeltaY = 0.0;

  int _now() => DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap gestures
      onTap: () {
        _dispatchGestureEvent('tap', {'timestamp': _now()});
      },
      onDoubleTap: () {
        _dispatchGestureEvent('doubletap', {'timestamp': _now()});
      },
      onLongPressStart: (details) {
        _dispatchGestureEvent('longpress', {
          'timestamp': _now(),
          'globalX': details.globalPosition.dx,
          'globalY': details.globalPosition.dy,
          'localX': details.localPosition.dx,
          'localY': details.localPosition.dy,
        });
      },
      onLongPressEnd: (details) {
        _dispatchGestureEvent('longpressend', {
          'timestamp': _now(),
          'globalX': details.globalPosition.dx,
          'globalY': details.globalPosition.dy,
          'localX': details.localPosition.dx,
          'localY': details.localPosition.dy,
          'velocityX': details.velocity.pixelsPerSecond.dx,
          'velocityY': details.velocity.pixelsPerSecond.dy,
        });
      },

      // Scale gestures (includes pan functionality)
      onScaleStart: (details) {
        // Dispatch both scale and pan start events
        _dispatchGestureEvent('scalestart', {
          'focalPointX': details.focalPoint.dx,
          'focalPointY': details.focalPoint.dy,
          'localFocalPointX': details.localFocalPoint.dx,
          'localFocalPointY': details.localFocalPoint.dy,
          'pointerCount': details.pointerCount,
          // Duration? expose as micros for JS number safety
          'sourceTimeStampMicros': details.sourceTimeStamp?.inMicroseconds,
          'timestamp': _now(),
        });
        _dispatchGestureEvent('panstart', {
          'x': details.focalPoint.dx,
          'y': details.focalPoint.dy,
          'localX': details.localFocalPoint.dx,
          'localY': details.localFocalPoint.dy,
          'pointerCount': details.pointerCount,
          'timestamp': _now(),
        });

        // Initialize tracking for pan deltas
        _lastLocalFocalPoint = details.localFocalPoint;
        _panTotalDeltaX = 0;
        _panTotalDeltaY = 0;
      },
      onScaleUpdate: (details) {
        // Dispatch scale update event
        _dispatchGestureEvent('scaleupdate', {
          'scale': details.scale,
          'horizontalScale': details.horizontalScale,
          'verticalScale': details.verticalScale,
          'rotation': details.rotation,
          'focalPointX': details.focalPoint.dx,
          'focalPointY': details.focalPoint.dy,
          'localFocalPointX': details.localFocalPoint.dx,
          'localFocalPointY': details.localFocalPoint.dy,
          'focalPointDeltaX': details.focalPointDelta.dx,
          'focalPointDeltaY': details.focalPointDelta.dy,
          'pointerCount': details.pointerCount,
          'sourceTimeStampMicros': details.sourceTimeStamp?.inMicroseconds,
          'timestamp': _now(),
        });

        // Dispatch pan update event
        final double dx = details.focalPointDelta.dx;
        final double dy = details.focalPointDelta.dy;
        _panTotalDeltaX += dx;
        _panTotalDeltaY += dy;
        final double localDx = (_lastLocalFocalPoint != null)
            ? (details.localFocalPoint.dx - _lastLocalFocalPoint!.dx)
            : 0.0;
        final double localDy = (_lastLocalFocalPoint != null)
            ? (details.localFocalPoint.dy - _lastLocalFocalPoint!.dy)
            : 0.0;
        _dispatchGestureEvent('panupdate', {
          'x': details.focalPoint.dx,
          'y': details.focalPoint.dy,
          'localX': details.localFocalPoint.dx,
          'localY': details.localFocalPoint.dy,
          'deltaX': dx,
          'deltaY': dy,
          'localDeltaX': localDx,
          'localDeltaY': localDy,
          'pointerCount': details.pointerCount,
          'timestamp': _now(),
        });

        _lastLocalFocalPoint = details.localFocalPoint;
      },
      onScaleEnd: (details) {
        // Dispatch scale end event
        _dispatchGestureEvent('scaleend', {
          'velocityX': details.velocity.pixelsPerSecond.dx,
          'velocityY': details.velocity.pixelsPerSecond.dy,
          'scaleVelocity': details.scaleVelocity,
          'pointerCount': details.pointerCount,
          'timestamp': _now(),
        });

        // Dispatch pan end event
        _dispatchGestureEvent('panend', {
          'velocityX': details.velocity.pixelsPerSecond.dx,
          'velocityY': details.velocity.pixelsPerSecond.dy,
          'totalDeltaX': _panTotalDeltaX,
          'totalDeltaY': _panTotalDeltaY,
          'pointerCount': details.pointerCount,
          'timestamp': _now(),
        });
      },

      child: WebFWidgetElementChild(
          child: widgetElement.firstChild != null ? widgetElement.firstChild!.toWidget() : SizedBox.shrink()),
    );
  }
}
