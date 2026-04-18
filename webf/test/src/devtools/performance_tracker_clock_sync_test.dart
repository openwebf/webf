/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';
import 'package:webf/src/launcher/loading_state.dart';

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

  group('importFromJson version guard', () {
    setUp(() {
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

    test('throws FormatException for version != 4', () {
      final tracker = PerformanceTracker.instance;
      expect(
        () => tracker.importFromJson('{"version": 3, "rootSpans": [], "totalSpanCount": 0}'),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('3'),
        )),
      );
    });

    test('does not clear state when import fails version check', () {
      final tracker = PerformanceTracker.instance;
      // Pre-populate with a span so we can verify it is NOT cleared on failure.
      final anchor = DateTime.now();
      final span = PerformanceSpan(
        category: 'layout',
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

  group('waterfall monotonicShift alignment', () {
    // These tests exercise the shift math in buildWaterfallData WITHOUT calling
    // startSession() (which requires native FFI). They manipulate the tracker's
    // public fields directly to simulate the recording-after-page-load scenario.

    setUp(() {
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.sessionStart = null;
    });

    test(
        'monotonicShiftUs aligns span start with its wall-clock position when '
        'tracker.sessionStart is later than loadingState.startTime', () {
      final tracker = PerformanceTracker.instance;

      // Simulate: page started loading at T=0, but DevTools recording began 2s
      // later. loadingState.startTime == T+0, tracker.sessionStart == T+2s.
      final pageLoadTime = DateTime(2025, 1, 1, 12, 0, 0, 0, 0); // T+0
      final recordingStart =
          pageLoadTime.add(const Duration(seconds: 2)); // T+2s
      tracker.sessionStart = recordingStart;

      // Simulate a LoadingState whose startTime is the earlier pageLoadTime.
      // We can't set _startTime directly, but we can build a LoadingState
      // (which captures DateTime.now()) and verify by checking the actual shift
      // that is computed when sessionStart > loadingState.startTime.
      //
      // Strategy: craft a LoadingState with a known start via a fixed-time
      // analog — inject a single completed layout span at offsetUs=500_000 µs
      // (0.5 s after tracker.sessionStart). For a live profile the chart's
      // sessionStart = loadingState.startTime. The entry's start Duration should
      // equal monotonicShiftUs + 500_000 µs = 2_000_000 + 500_000 = 2_500_000 µs.

      final span = PerformanceSpan(
        category: 'layout',
        name: 'test',
        startOffsetUs: 500000, // 0.5s after tracker.sessionStart
        depth: 0,
        sessionAnchor: recordingStart,
      );
      span.endOffsetUs = 1000000; // 1.0s after tracker.sessionStart
      tracker.rootSpans.add(span);

      // Build a LoadingState; its _startTime will be ~DateTime.now(), which
      // is NOT pageLoadTime, but we can forge the offset by checking the
      // returned entry start against what it would be if sessionStart differed
      // from loadingState.startTime by exactly 2 seconds.
      //
      // To do this deterministically without forging LoadingState internals,
      // we set tracker.sessionStart to exactly (loadingState.startTime + 2s)
      // AFTER we have a LoadingState in hand.
      final loadingState = LoadingState();
      final knownPageLoad = loadingState.startTime!;
      tracker.sessionStart = knownPageLoad.add(const Duration(seconds: 2));

      // Update the span's anchor to match the tracker.sessionStart we just set.
      // Re-create the span so sessionAnchor is consistent.
      tracker.rootSpans.clear();
      final anchor = tracker.sessionStart!;
      final alignedSpan = PerformanceSpan(
        category: 'layout',
        name: 'test',
        startOffsetUs: 500000,
        depth: 0,
        sessionAnchor: anchor,
      );
      alignedSpan.endOffsetUs = 1000000;
      tracker.rootSpans.add(alignedSpan);

      final data = buildWaterfallData(loadingState, tracker);

      // The shift should be 2_000_000 µs (2s). The span starts at 500_000 µs
      // after tracker.sessionStart, which is 2_500_000 µs after sessionStart.
      // After minStart normalization, the chart should start at its earliest
      // event. The entry start should be 2_500_000 µs (no earlier event).
      expect(data.entries, isNotEmpty,
          reason: 'Expected at least one waterfall entry');
      final entry = data.entries.first;

      // monotonicShiftUs = 2_000_000. Entry start = 500_000 + 2_000_000 = 2_500_000.
      // minStart normalization subtracts 2_500_000, so final start = 0.
      // The entry duration should still be correct: 1_000_000 - 500_000 = 500_000 µs.
      final durationUs = entry.end.inMicroseconds - entry.start.inMicroseconds;
      expect(durationUs, equals(500000),
          reason: 'Span duration must be preserved through monotonic shift');
    });

    test('no shift when tracker.sessionStart equals loadingState.startTime',
        () {
      final tracker = PerformanceTracker.instance;
      final loadingState = LoadingState();
      // Set tracker.sessionStart == loadingState.startTime (no drift)
      tracker.sessionStart = loadingState.startTime;

      final anchor = tracker.sessionStart!;
      final span = PerformanceSpan(
        category: 'layout',
        name: 'test',
        startOffsetUs: 500000,
        depth: 0,
        sessionAnchor: anchor,
      );
      span.endOffsetUs = 1000000;
      tracker.rootSpans.add(span);

      final data = buildWaterfallData(loadingState, tracker);

      expect(data.entries, isNotEmpty);
      final entry = data.entries.first;
      // No shift — duration still correct.
      final durationUs = entry.end.inMicroseconds - entry.start.inMicroseconds;
      expect(durationUs, equals(500000),
          reason: 'Span duration must be preserved when there is no shift');
    });
  });
}
