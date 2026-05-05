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

    test('invokeModule has its own color distinct from related subtypes', () {
      expect(colorForSubType(kSubTypeInvokeModule),
          isNot(colorForSubType(kSubTypeInvokeModuleEvent)));
      expect(colorForSubType(kSubTypeInvokeModule),
          isNot(colorForSubType(kSubTypeInvokeBindingMethodFromNative)));
    });

    test(
        'sync invokeModule (graftable) is suppressed; '
        'async invokeModule (overflow) stays visible', () {
      // Sync invoke pattern: the Dart `invokeModule` entry is fully
      // time-contained inside a JS `__webf_invoke_module__` bridge span
      // — the flame drilldown grafts it under the bridge so the overview
      // can suppress it.
      final dispatchEntry = PerformanceTracker.instance
          .beginEntry(kSubTypeDispatchEvent, 'click');
      final syncInvoke = PerformanceTracker.instance
          .beginEntry(kSubTypeInvokeModule, 'LocalStorage.getItem');
      syncInvoke!.end();
      // Look up the just-closed sync invoke span via the dispatch root's
      // children, then inject a narrow JS bridge window that brackets it.
      // Bracket = [syncSpan.start - 1 .. syncSpan.end + 1] so the sync
      // invoke is fully contained; dispatchEntry closes strictly after,
      // so the bridge window also fits inside the dispatch.
      final dispatchRoot = PerformanceTracker.instance.rootSpans
          .firstWhere((r) => r.subType == kSubTypeDispatchEvent);
      final syncSpan = dispatchRoot.children
          .firstWhere((c) => c.name == 'LocalStorage.getItem');
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsCFunction,
        funcName: '__webf_invoke_module__',
        startUs: syncSpan.startOffsetUs - 1,
        endUs: syncSpan.endOffsetUs! + 1,
        entryId: dispatchEntry!.entryId,
      );
      dispatchEntry.end();

      // Async invoke pattern: standalone Dart entry that opens AFTER the
      // dispatch (and its JS bridge) has fully closed — there is no
      // `__webf_invoke_module__` span enclosing this window, so the graft
      // can't attach it. It must stay in the overview.
      final asyncInvoke = PerformanceTracker.instance.beginEntry(
          kSubTypeInvokeModule, 'Fetch.https://example.com/api',
          asyncSpanning: true);
      asyncInvoke!.end();

      final loadingState = LoadingState();
      final data =
          buildWaterfallData(loadingState, PerformanceTracker.instance);
      final overviewLabels = data.entries
          .where((e) => e.subType == kSubTypeInvokeModule)
          .map((e) => e.label)
          .toList();
      expect(overviewLabels, contains('Fetch.https://example.com/api'),
          reason: 'async invokeModule whose Dart entry overflows the JS '
              'bridge window cannot be grafted, so it must remain in the '
              'overview to preserve end-to-end latency visibility');
      expect(overviewLabels, isNot(contains('LocalStorage.getItem')),
          reason: 'sync invokeModule that fits inside a __webf_invoke_module__ '
              'JS bridge span must be suppressed from the overview — the '
              'flame drilldown grafts it under the bridge');
    });

    test('invokeModule entry tracks sync and async semantics', () {
      // Sync: closes synchronously after end().
      final sync = PerformanceTracker.instance
          .beginEntry(kSubTypeInvokeModule, 'Navigator.userAgent');
      sync!.end();
      expect(sync.entryId, greaterThan(0));

      // Async-spanning: stays open across the begin/end (no _currentSpan
      // leaked to subsequent unrelated entries).
      final async_ = PerformanceTracker.instance.beginEntry(
          kSubTypeInvokeModule, 'Fetch.fetch',
          asyncSpanning: true);
      // While async entry is in flight, a sibling sync entry must not nest
      // under it (asyncSpanning entries are not pushed onto _currentSpan).
      final sibling = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      sibling!.end();
      async_!.end();

      // Verify both async invokeModule and sibling drawFrame are roots,
      // not nested.
      final roots = PerformanceTracker.instance.rootSpans;
      final asyncRoot = roots.firstWhere(
          (r) => r.subType == kSubTypeInvokeModule && r.name == 'Fetch.fetch');
      final siblingRoot = roots.firstWhere(
          (r) => r.subType == kSubTypeDrawFrame && r.name == 'drawFrame');
      expect(siblingRoot.parent, isNull,
          reason: 'sibling drawFrame must remain a root, not nest under '
              'the async-spanning invokeModule entry');
      expect(asyncRoot.parent, isNull);
    });

    // Regression: when LoadingState starts before the tracker (real-world
    // order — LoadingState ctor → view init → startSession → recordPhase),
    // the minStart shift must also apply to attachOffset. Otherwise drawFrame
    // entries get their `start` shifted down by minStart while attachOffset
    // stays at its unshifted value, making drawFrame.start < attachOffset
    // and causing the attach→paint phase filter to drop the row.
    test('drawFrame after attach is kept by attach→paint phase filter',
        () async {
      PerformanceTracker.instance.endSession();

      final loadingState = LoadingState();
      await Future.delayed(const Duration(milliseconds: 5));
      PerformanceTracker.instance.startSession();

      loadingState.recordPhase(LoadingState.phaseInit);
      await Future.delayed(const Duration(milliseconds: 5));
      loadingState.recordPhase(LoadingState.phaseAttachToFlutter);
      await Future.delayed(const Duration(milliseconds: 1));

      final draw = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      draw!.end();

      final data = buildWaterfallData(loadingState, PerformanceTracker.instance);
      final drawEntry = data.entries
          .firstWhere((e) => e.subType == kSubTypeDrawFrame);
      expect(data.attachOffset, isNotNull);
      expect(
        includeEntryForPhase(
            drawEntry, WaterfallPhase.attachToPaint, data.attachOffset),
        isTrue,
        reason: 'drawFrame recorded after attachToFlutter must survive the '
            'attach→paint filter. drawEntry.start=${drawEntry.start}, '
            'attachOffset=${data.attachOffset}',
      );
    });
  });
}
