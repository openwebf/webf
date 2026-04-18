/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';

void main() {
  group('PerformanceTracker clock sync', () {
    setUp(() {
      PerformanceTracker.instance.clear();
    });

    test('startSession starts a monotonic stopwatch', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();

      final first = tracker.nowOffsetUs();
      // Busy-wait ~1ms using a local Stopwatch (not tracker state).
      final wait = Stopwatch()..start();
      while (wait.elapsedMicroseconds < 1000) {}
      final second = tracker.nowOffsetUs();

      expect(second, greaterThan(first),
          reason: 'Stopwatch must advance monotonically');
      expect(second - first, greaterThan(500),
          reason: 'Expected >500µs after ~1ms busy wait');

      tracker.endSession();
    });

    test('startSession records a non-zero C++→Dart offset after FFI sync',
        () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();
      // The offset is the delta between C++ session_start_ and the Dart
      // stopwatch anchor. It is a constant for the session and must be
      // populated (not null) after startSession() completes.
      expect(tracker.cppToDartOffsetUsForTest, isNotNull);
      tracker.endSession();
    });
  });
}
