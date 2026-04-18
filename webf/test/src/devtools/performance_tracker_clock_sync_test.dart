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

    test('drainJSThreadSpans applies cppToDartOffsetUs to native spans', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();
      final offsetUs = tracker.cppToDartOffsetUsForTest!;

      // Simulate a C++ span at offset 1_000_000 µs (1s after C++ session_start_).
      // After correction it should sit at 1_000_000 + offsetUs relative to
      // the Dart stopwatch anchor.
      tracker.debugInjectJSSpan(
        category: 'jsScriptEval',
        startUs: 1000000,
        endUs: 1500000,
      );

      expect(tracker.jsThreadSpans, hasLength(1));
      final s = tracker.jsThreadSpans.first;
      expect(s.startOffset.inMicroseconds, 1000000 + offsetUs);
      expect(s.endOffset.inMicroseconds, 1500000 + offsetUs);

      tracker.endSession();
    });

    test('beginSpan records offsetUs from monotonic clock', () {
      final tracker = PerformanceTracker.instance;
      tracker.startSession();

      final before = tracker.nowOffsetUs();
      final handle = tracker.beginSpan('layout', 'flexLayout');
      expect(handle, isNotNull);
      handle!.end();
      final after = tracker.nowOffsetUs();

      expect(tracker.rootSpans, hasLength(1));
      final span = tracker.rootSpans.first;
      expect(span.startOffsetUs, greaterThanOrEqualTo(before));
      expect(span.endOffsetUs, isNotNull);
      expect(span.endOffsetUs!, greaterThanOrEqualTo(span.startOffsetUs));
      expect(span.endOffsetUs!, lessThanOrEqualTo(after));

      tracker.endSession();
    });
  });
}
