/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/bridge.dart';

typedef DoubleCallback = void Function(double);
typedef VoidCallback = void Function();

int _frameDelayCount = 0;

void scheduleDelayForFrameCallback() {
  _frameDelayCount++;
}

mixin ScheduleFrameMixin {
  final Map<int, bool> _animationFrameCallbackMap = {};
  bool _paused = false;
  final List<VoidCallback> _pendingFrameCallbacks = [];

  void requestAnimationFrame(int newFrameId, DoubleCallback callback) {
    _animationFrameCallbackMap[newFrameId] = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (_frameDelayCount > 0) {
        _frameDelayCount--;
        requestAnimationFrame(newFrameId, callback);
        return;
      }

      if (_paused) {
        _pendingFrameCallbacks.add(() {
          callback(0);
        });
        return;
      }

      if (_animationFrameCallbackMap.containsKey(newFrameId)) {
        _animationFrameCallbackMap.remove(newFrameId);
        double highResTimeStamp = timeStamp.inMicroseconds / 1000;
        callback(highResTimeStamp);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void cancelAnimationFrame(int id) {
    if (_animationFrameCallbackMap.containsKey(id)) {
      _animationFrameCallbackMap.remove(id);
    }
  }

  final Map<int, DoubleCallback> _idleCalllbackMap = {};

  void requestIdleCallback(double contextId, int idleId, int uiCommandSize, DoubleCallback callback) {
    _idleCalllbackMap[idleId] = callback;
    if (uiCommandSize > 0) {
      SchedulerBinding.instance.addPostFrameCallback((timestamp) {
        uiCommandSize = getUICommandSize(contextId);
        if (_idleCalllbackMap.containsKey(idleId)) {
          requestIdleCallback(contextId, idleId, uiCommandSize, callback);
        }
      });
      SchedulerBinding.instance.scheduleFrame();
      return;
    }

    DateTime lastFrameTimeStamp = DateTime.now();
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (_idleCalllbackMap.containsKey(idleId)) {
        Display display = WidgetsBinding.instance.platformDispatcher.views.first.display;
        double maxFPS = 1000 / display.refreshRate;
        double remainingTime = maxFPS - (DateTime.now().difference(lastFrameTimeStamp)).inMilliseconds;
        callback(remainingTime > 0 ? remainingTime : 0);
      }
    });
    SchedulerBinding.instance.scheduleFrameCallback((timestamp) {
      lastFrameTimeStamp = DateTime.now();
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void cancelIdleCallback(int idleId) {
    _idleCalllbackMap.remove(idleId);
  }

  void pauseAnimationFrame() {
    _paused = true;
    _pendingFrameCallbacks.clear();
  }

  void resumeAnimationFrame() {
    _paused = false;
    _pendingFrameCallbacks.forEach((callback) {
      callback();
    });
    _pendingFrameCallbacks.clear();
  }

  void requestBatchUpdate() {
    SchedulerBinding.instance.scheduleFrame();
  }

  void disposeScheduleFrame() {
    _animationFrameCallbackMap.clear();
  }
}
