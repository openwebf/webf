/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/scheduler.dart';

typedef DoubleCallback = void Function(double);
typedef VoidCallback = void Function();

mixin ScheduleFrameMixin {
  final Map<int, bool> _animationFrameCallbackMap = {};
  bool _paused = false;
  final List<VoidCallback> _pendingFrameCallbacks = [];

  void requestAnimationFrame(int newFrameId, DoubleCallback callback) {
    _animationFrameCallbackMap[newFrameId] = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
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
