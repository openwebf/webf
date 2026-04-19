/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';
import 'package:webf/src/launcher/loading_state.dart';

import '../../setup.dart';

void main() {
  group('WaterfallData layout', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('one row per entry subType in fixed order', () {
      // Drive entries in REVERSE display order to confirm sorting.
      final timer = PerformanceTracker.instance
          .beginEntry(kSubTypeJsTimer, 'setTimeout');
      timer!.end();
      final flush = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      flush!.end();
      final draw = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      draw!.end();

      final loadingState = LoadingState();
      final data = buildWaterfallData(loadingState, PerformanceTracker.instance);

      // Filter entries by the subTypes we created (skip lifecycle/network rows).
      final entrySubTypes = data.entries
          .map((e) => e.subType)
          .where((s) => [
                kSubTypeDrawFrame,
                kSubTypeFlushUICommand,
                kSubTypeJsTimer,
              ].contains(s))
          .toList();
      expect(entrySubTypes,
          [kSubTypeDrawFrame, kSubTypeFlushUICommand, kSubTypeJsTimer],
          reason: 'rows must follow kWaterfallRowOrder');
    });

    test('drilldown is available for entry rows', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      entry!.end();

      final loadingState = LoadingState();
      final data = buildWaterfallData(loadingState, PerformanceTracker.instance);
      final drawRow = data.entries.firstWhere((e) => e.subType == kSubTypeDrawFrame);
      expect(drawRow.hasDrillDown, true);
    });

    test('color is stable across runs for the same subType', () {
      expect(colorForSubType(kSubTypeDrawFrame),
          colorForSubType(kSubTypeDrawFrame));
      expect(colorForSubType(kSubTypeDrawFrame),
          isNot(colorForSubType(kSubTypeJsTimer)));
    });
  });
}
