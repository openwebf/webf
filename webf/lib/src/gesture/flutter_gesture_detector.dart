/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

const String FLUTTER_GESTURE_DETECTOR = 'FLUTTER-GESTURE-DETECTOR';

// Custom gesture detector element
class FlutterGestureDetector extends WidgetElement {
  FlutterGestureDetector(super.context);

  @override
  FlutterGestureDetectorState createState() => FlutterGestureDetectorState(this);
}

class FlutterGestureDetectorState extends WebFWidgetElementState {
  FlutterGestureDetectorState(super.widgetElement);

  @override
  FlutterGestureDetector get widgetElement => super.widgetElement as FlutterGestureDetector;

  // Gesture state
  bool _isLongPressing = false;
  bool _isPanning = false;
  bool _isScaling = false;
  Offset _panStart = Offset.zero;
  Offset _panCurrent = Offset.zero;
  double _currentScale = 1.0;
  double _rotation = 0.0;

  void _dispatchGestureEvent(String eventType, Map<String, dynamic> data) {
    final event = dom.CustomEvent(eventType, detail: data);
    widgetElement.dispatchEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap gestures
      onTap: () {
        _dispatchGestureEvent('tap', {'timestamp': DateTime.now().millisecondsSinceEpoch});
      },
      onDoubleTap: () {
        _dispatchGestureEvent('doubletap', {'timestamp': DateTime.now().millisecondsSinceEpoch});
      },
      onLongPress: () {
        _isLongPressing = true;
        _dispatchGestureEvent('longpress', {'timestamp': DateTime.now().millisecondsSinceEpoch});
      },
      onLongPressEnd: (details) {
        _isLongPressing = false;
        _dispatchGestureEvent('longpressend', {'timestamp': DateTime.now().millisecondsSinceEpoch});
      },

      // Scale gestures (includes pan functionality)
      onScaleStart: (details) {
        _isScaling = true;
        _isPanning = true;
        _panStart = details.focalPoint;
        _panCurrent = details.focalPoint;
        
        // Dispatch both scale and pan start events
        _dispatchGestureEvent('scalestart', {
          'scale': 1.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _dispatchGestureEvent('panstart', {
          'x': details.focalPoint.dx,
          'y': details.focalPoint.dy,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      },
      onScaleUpdate: (details) {
        if (_isScaling) {
          _currentScale = details.scale;
          _rotation = details.rotation;
          _panCurrent = details.focalPoint;
          final delta = _panCurrent - _panStart;
          
          // Dispatch scale update event
          _dispatchGestureEvent('scaleupdate', {
            'scale': details.scale,
            'rotation': details.rotation,
            'focalPointX': details.focalPoint.dx,
            'focalPointY': details.focalPoint.dy,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          
          // Dispatch pan update event
          _dispatchGestureEvent('panupdate', {
            'x': details.focalPoint.dx,
            'y': details.focalPoint.dy,
            'deltaX': delta.dx,
            'deltaY': delta.dy,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      },
      onScaleEnd: (details) {
        if (_isScaling) {
          _isScaling = false;
          _isPanning = false;
          final delta = _panCurrent - _panStart;
          
          // Dispatch scale end event
          _dispatchGestureEvent('scaleend', {
            'scale': _currentScale,
            'rotation': _rotation,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          
          // Dispatch pan end event
          _dispatchGestureEvent('panend', {
            'deltaX': delta.dx,
            'deltaY': delta.dy,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      },

      child: Container(
        width: double.maxFinite,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Gesture target
            Center(
              child: Transform.scale(
                scale: _currentScale,
                child: Transform.rotate(
                  angle: _rotation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isLongPressing 
                          ? [Colors.green, Colors.green.shade700]
                          : [Colors.blue, Colors.blue.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            // Pan indicator
            if (_isPanning)
              Positioned(
                left: _panCurrent.dx - 10,
                top: _panCurrent.dy - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            // Instruction text
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Text(
                'Tap, Double Tap, Long Press, Pan, Pinch, Rotate',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}