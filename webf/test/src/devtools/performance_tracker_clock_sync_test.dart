/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
// TODO(task-3.5): re-enable waterfall_chart import + waterfall group below
// once the reader is rewritten under the entry-rooted model.
// import 'package:webf/src/devtools/panel/waterfall_chart.dart';
// import 'package:webf/src/launcher/loading_state.dart';

import '../../setup.dart';

void main() {
  group('PerformanceTracker clock sync', () {
    setUp(() {
      setupTest();
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
      // the Dart stopwatch anchor. With no entryId provided, the injected
      // span becomes a new root in the entry-rooted tree.
      tracker.debugInjectJSSpan(
        subType: 'jsScriptEval',
        startUs: 1000000,
        endUs: 1500000,
        funcName: 'clockSyncProbe',
      );

      final injected = tracker.rootSpans.firstWhere(
        (s) => s.subType == 'jsScriptEval' && s.name == 'clockSyncProbe',
      );
      expect(injected.startOffsetUs, 1000000 + offsetUs);
      expect(injected.endOffsetUs, 1500000 + offsetUs);

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

  group('importFromJson version guard', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
    });

    test('throws FormatException for missing version (legacy v3 export)', () {
      final tracker = PerformanceTracker.instance;
      expect(
        () => tracker.importFromJson('{"rootSpans": [], "totalSpanCount": 0}'),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('missing'),
        )),
      );
    });

    test('throws FormatException for version != 5', () {
      final tracker = PerformanceTracker.instance;
      expect(
        () => tracker.importFromJson('{"version": 4, "rootSpans": [], "totalSpanCount": 0}'),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('4'),
        )),
      );
    });

    test('does not clear state when import fails version check', () {
      final tracker = PerformanceTracker.instance;
      // Pre-populate with a span so we can verify it is NOT cleared on failure.
      final anchor = DateTime.now();
      final span = PerformanceSpan(
        subType: 'layout',
        name: 'existing',
        startOffsetUs: 100,
        depth: 0,
        sessionAnchor: anchor,
      );
      span.endOffsetUs = 200;
      tracker.rootSpans.add(span);

      expect(
        () => tracker.importFromJson('{"version": 3, "rootSpans": [], "totalSpanCount": 0}'),
        throwsA(isA<FormatException>()),
      );

      // State must be preserved — import failure must not wipe existing spans.
      expect(tracker.rootSpans, hasLength(1),
          reason: 'rootSpans must not be cleared when version check fails');
    });
  });

  // TODO(task-3.5/3.6): rewrite under entry-rooted model once
  // waterfall_chart.dart is updated. The original tests called
  // buildWaterfallData(LoadingState, PerformanceTracker), which currently does
  // not compile because waterfall_chart.dart still references the removed
  // jsThreadSpans field and JSThreadSpan class.
  //
  // group('waterfall monotonicShift alignment', () { ... });
}
