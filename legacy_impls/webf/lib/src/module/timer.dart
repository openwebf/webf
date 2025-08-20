/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [Timer] that can be paused, resumed.
class PausablePeriodicTimer implements Timer {
  Timer? _timer;
  final void Function(Timer) _callback;
  final Duration _duration;
  int _tick = 0;

  void _startTimer() {
    var boundCallback = _callback;
    if (Zone.current != Zone.root) {
      boundCallback = Zone.current.bindUnaryCallbackGuarded(_callback);
    }
    _timer = Zone.current.createPeriodicTimer(_duration, (Timer timer) {
      _tick++;
      boundCallback(timer);
    });
  }

  /// Creates a new timer.
  PausablePeriodicTimer(Duration duration, void Function(Timer) callback)
      : assert(duration >= Duration.zero),
        _duration = duration,
        _callback = callback {
    _startTimer();
  }

  @override
  bool get isActive => _timer != null;

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resume the timer.
  void resume() {
    if (isActive) return;
    _startTimer();
  }

  /// Pauses an active timer.
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  int get tick => _tick;
}

mixin TimerMixin {
  final Map<int, Timer> _timerMap = {};

  bool _isPaused = false;
  final List<VoidCallback> _pendingUnFinishedCallbacks = [];

  void setTimeout(int newTimerId, int timeout, void Function() callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    _timerMap[newTimerId] = Timer(timeoutDurationMS, () {
      if (_isPaused) {
        _pendingUnFinishedCallbacks.add(callback);
        return;
      }
      callback();
      _timerMap.remove(newTimerId);
    });
  }

  void clearTimeout(int timerId) {
    // If timer already executed, which will be removed.
    if (_timerMap[timerId] != null) {
      _timerMap[timerId]!.cancel();
      _timerMap.remove(timerId);
    }
  }

  void setInterval(int newTimerId, int timeout, void Function() callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    _timerMap[newTimerId] = PausablePeriodicTimer(timeoutDurationMS, (_) {
      if (_isPaused) return;
      callback();
    });
  }

  void pauseTimer() {
    // Pause all intervals
    _timerMap.forEach((key, timer) {
      if (timer is PausablePeriodicTimer) {
        timer.pause();
      }
    });

    _isPaused = true;
  }

  void resumeTimer() {
    // Resume all intervals
    _timerMap.forEach((key, timer) {
      if (timer is PausablePeriodicTimer) {
        timer.resume();
      }
    });

    _pendingUnFinishedCallbacks.forEach((callback) {
      callback();
    });
    _pendingUnFinishedCallbacks.clear();
    _isPaused = false;

  }

  void disposeTimer() {
    _timerMap.forEach((key, timer) {
      timer.cancel();
    });
    _timerMap.clear();
    _pendingUnFinishedCallbacks.clear();
  }
}
