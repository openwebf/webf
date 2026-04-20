/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

import '../../setup.dart';

void main() {
  group('PerformanceTracker JSON v5', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.startSession();
    });

    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('exportToJson writes version 5 and no jsThreadSpans field', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      child!.end();
      entry!.end();

      final exported = PerformanceTracker.instance.exportToJson();
      final data = jsonDecode(exported) as Map<String, dynamic>;
      expect(data['version'], 5);
      expect(data.containsKey('jsThreadSpans'), false,
          reason: 'v5 has no flat jsThreadSpans array — JS spans live in tree');
      expect(data['rootSpans'], isList);
      final root = (data['rootSpans'] as List).first as Map<String, dynamic>;
      expect(root['subType'], kSubTypeDrawFrame);
      expect(root['children'], isList);
      expect((root['children'] as List).first['subType'], kSubTypePaint);
    });

    test('importFromJson rejects v4 with FormatException', () {
      final v4 = jsonEncode({
        'version': 4,
        'exportedAt': DateTime.now().toIso8601String(),
        'sessionStart': DateTime.now().microsecondsSinceEpoch,
        'totalSpanCount': 0,
        'rootSpans': <dynamic>[],
      });
      expect(
        () => PerformanceTracker.instance.importFromJson(v4),
        throwsA(isA<FormatException>()),
      );
    });

    test('importFromJson rejects missing version with FormatException', () {
      final missing = jsonEncode({'rootSpans': <dynamic>[]});
      expect(
        () => PerformanceTracker.instance.importFromJson(missing),
        throwsA(isA<FormatException>()),
      );
    });

    test('export → import → export is byte-identical', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final paint = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      paint!.end();
      entry!.end();

      final once = PerformanceTracker.instance.exportToJson();
      PerformanceTracker.instance.importFromJson(once);
      final twice = PerformanceTracker.instance.exportToJson();

      // exportedAt timestamp will differ; strip it for comparison.
      final a = jsonDecode(once) as Map<String, dynamic>..remove('exportedAt');
      final b = jsonDecode(twice) as Map<String, dynamic>..remove('exportedAt');
      expect(jsonEncode(a), jsonEncode(b));
    });
  });

  group('PerformanceTracker drain-time grafting', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('JS span with matching entryId becomes child of that root', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');

      // Entry ids are allocated monotonically from 1. The first entry id is 1.
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsBindingSyncCall,
        startUs: PerformanceTracker.instance.nowOffsetUs() - 100,
        endUs: PerformanceTracker.instance.nowOffsetUs() - 50,
        entryId: 1,
        funcName: 'getBoundingClientRect',
      );

      entry!.end();

      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.subType, kSubTypeFlushUICommand);
      expect(root.children.length, 1);
      expect(root.children.first.subType, kSubTypeJsBindingSyncCall);
      expect(root.children.first.name, 'getBoundingClientRect');
    });

    test('JS span with entryId=0 becomes a new root', () {
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsTimer,
        startUs: 1000,
        endUs: 2000,
        entryId: 0,
        funcName: 'setTimeout',
      );

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1);
      expect(roots.first.subType, kSubTypeJsTimer);
      expect(roots.first.parent, isNull);
    });

    test('JS span drained AFTER entry closes still grafts under its root', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      entry!.end();
      // Now drain a JS span tagged with the (now-closed) entry's id.
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsCFunction,
        startUs: 0,
        endUs: 100,
        entryId: 1,
        funcName: 'lateArrival',
      );

      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.children.any((c) => c.name == 'lateArrival'), true,
          reason: '_entryIdToSpan must persist past entry close');
    });

    test(
        'entryId=0 JS span does NOT nest under a time-containing Dart root',
        () {
      // Open a Dart entry and leave it open so its interval is "live".
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');

      // Inject a JS span with entryId=0 whose wall-clock window falls
      // inside the drawFrame. This is the misleading case: autonomous
      // JS event-loop work (timer firing) happening *concurrently* with
      // a Dart drawFrame on the other thread. It must stay its own root
      // in the JS lane, not silently become a child of drawFrame.
      final now = PerformanceTracker.instance.nowOffsetUs();
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsTimer,
        startUs: now - 50,
        endUs: now - 10,
        entryId: 0,
        funcName: 'setTimeout',
      );

      entry!.end();

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 2,
          reason: 'timer must remain an independent root, not a drawFrame child');
      final drawFrameRoot =
          roots.firstWhere((r) => r.subType == kSubTypeDrawFrame);
      final timerRoot =
          roots.firstWhere((r) => r.subType == kSubTypeJsTimer);
      expect(drawFrameRoot.children, isEmpty,
          reason: 'drawFrame must not adopt concurrent JS-thread work');
      expect(timerRoot.parent, isNull);
    });

    test('entryId=0 JS span nests under containing root span', () {
      // First inject a containing root (eg. the C++-side jsMicrotask).
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsMicrotask,
        startUs: 1000,
        endUs: 2000,
        entryId: 0,
        funcName: 'microtaskRoot',
      );
      // Then inject an inner span (eg. jsFunction inside the microtask).
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsFunction,
        startUs: 1100,
        endUs: 1500,
        entryId: 0,
        funcName: 'innerFn',
      );

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1,
          reason: 'inner span must nest, not become a sibling root');
      final outer = roots.single;
      expect(outer.subType, kSubTypeJsMicrotask);
      expect(outer.children.length, 1);
      expect(outer.children.first.name, 'innerFn');
      expect(outer.children.first.subType, kSubTypeJsFunction);
    });

    test('entryId=0 JS span deeply nests under matching descendant', () {
      // Outer → middle → inner; all entryId=0, all should nest.
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsMicrotask,
        startUs: 1000,
        endUs: 2000,
        entryId: 0,
        funcName: 'outer',
      );
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsFunction,
        startUs: 1100,
        endUs: 1900,
        entryId: 0,
        funcName: 'middle',
      );
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsCFunction,
        startUs: 1200,
        endUs: 1300,
        entryId: 0,
        funcName: 'inner',
      );

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1);
      final outer = roots.single;
      expect(outer.children.length, 1);
      final middle = outer.children.single;
      expect(middle.name, 'middle');
      expect(middle.children.length, 1);
      expect(middle.children.single.name, 'inner');
    });

    test('_attachJSSpan respects maxSpans cap so Dart entries do not starve',
        () {
      // Fill the tracker with JS spans up to maxSpans.
      for (int i = 0; i < PerformanceTracker.maxSpans; i++) {
        PerformanceTracker.instance.debugInjectJSSpan(
          subType: kSubTypeJsCFunction,
          startUs: i,
          endUs: i + 1,
          entryId: 0,
          funcName: 'f$i',
        );
      }
      expect(PerformanceTracker.instance.totalSpanCount,
          PerformanceTracker.maxSpans);

      // Subsequent JS span MUST be dropped (does not bump count).
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsCFunction,
        startUs: 9999999,
        endUs: 10000000,
        entryId: 0,
        funcName: 'overflow',
      );
      expect(PerformanceTracker.instance.totalSpanCount,
          PerformanceTracker.maxSpans,
          reason: '_attachJSSpan must drop spans once at capacity');
    });
  });

  group('PerformanceTracker async-spanning entries', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('asyncSpanning entry does not capture concurrent sync entries',
        () async {
      // Open an async-spanning entry (eg. evaluateByteCode).
      final asyncEntry = PerformanceTracker.instance.beginEntry(
          kSubTypeEvaluateByteCode, 'evaluateByteCode',
          asyncSpanning: true);

      // Simulate the await suspension: nothing changes _currentSpan because
      // asyncSpanning entries don't push onto the stack. While "awaiting,"
      // an unrelated post-frame callback fires and opens a drawFrame entry.
      final drawFrame = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      drawFrame!.end();

      // Now the async work completes.
      asyncEntry!.end();

      // drawFrame must be its own root, not nested under evaluateByteCode.
      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 2,
          reason: 'both entries must be roots when one is asyncSpanning');
      final byType = {for (final r in roots) r.subType: r};
      expect(byType[kSubTypeDrawFrame], isNotNull);
      expect(byType[kSubTypeEvaluateByteCode], isNotNull);
      expect(byType[kSubTypeDrawFrame]!.children, isEmpty,
          reason: 'drawFrame must not contain the leaked async entry work');
      expect(byType[kSubTypeEvaluateByteCode]!.children, isEmpty,
          reason: 'evaluateByteCode must not capture drawFrame as a child');
    });

    test('asyncSpanning entry still grafts JS spans by entryId', () {
      final asyncEntry = PerformanceTracker.instance.beginEntry(
          kSubTypeEvaluateByteCode, 'evaluateByteCode',
          asyncSpanning: true);

      // First entry id is 1.
      PerformanceTracker.instance.debugInjectJSSpan(
        subType: kSubTypeJsFunction,
        startUs: PerformanceTracker.instance.nowOffsetUs() - 100,
        endUs: PerformanceTracker.instance.nowOffsetUs() - 50,
        entryId: 1,
        funcName: 'jsHelper',
      );

      asyncEntry!.end();

      final root = PerformanceTracker.instance.rootSpans.single;
      expect(root.subType, kSubTypeEvaluateByteCode);
      expect(root.children.length, 1);
      expect(root.children.first.name, 'jsHelper');
    });

    test('sync beginEntry inside asyncSpanning entry remains independent',
        () {
      final asyncEntry = PerformanceTracker.instance.beginEntry(
          kSubTypeEvaluateByteCode, 'evaluateByteCode',
          asyncSpanning: true);

      // A SYNC entry opened immediately after — should still be a root,
      // not a child, because asyncSpanning didn't push onto the stack.
      final syncEntry = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      syncEntry!.end();

      asyncEntry!.end();

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 2);
      expect(roots.map((r) => r.subType).toSet(),
          {kSubTypeEvaluateByteCode, kSubTypeFlushUICommand});
    });
  });

  group('PerformanceTracker EntryHandle.transitionToAsync', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('sync child beginSpan before transition nests under entry', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeInvokeBindingMethodFromNative, 'setProperty');
      // Sync child opened before transition — must nest as a child.
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleRecalc, 'recalculateStyle');
      child!.end();
      entry!.transitionToAsync();
      entry.end();

      final root = PerformanceTracker.instance.rootSpans.single;
      expect(root.subType, kSubTypeInvokeBindingMethodFromNative);
      expect(root.children.length, 1);
      expect(root.children.first.subType, kSubTypeStyleRecalc);
    });

    test('entry opened after transition does NOT nest under it', () {
      final outer = PerformanceTracker.instance
          .beginEntry(kSubTypeInvokeBindingMethodFromNative, 'setProperty');
      outer!.transitionToAsync();
      // Simulate work scheduled during the await (eg. drawFrame).
      final concurrent = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      concurrent!.end();
      outer.end();

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 2,
          reason: 'transitioned entry must release the stack so concurrent '
              'entries become independent roots');
      final byType = {for (final r in roots) r.subType: r};
      expect(byType[kSubTypeDrawFrame]!.children, isEmpty);
      expect(byType[kSubTypeInvokeBindingMethodFromNative]!.children, isEmpty);
    });

    test('transitionToAsync is idempotent', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeInvokeBindingMethodFromNative, 'setProperty');
      entry!.transitionToAsync();
      entry.transitionToAsync(); // Second call must be a no-op.
      entry.end();

      // No exception, single root, clean stack.
      expect(PerformanceTracker.instance.rootSpans.length, 1);
      // Subsequent sync entry must work normally (stack was not corrupted).
      final next = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      next!.end();
      expect(PerformanceTracker.instance.rootSpans.length, 2);
    });

    test('end() after transition does not double-pop the stack', () {
      // Open a sync outer to detect over-popping.
      final outer = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      final inner = PerformanceTracker.instance
          .beginEntry(kSubTypeInvokeBindingMethodFromNative, 'setProperty');
      inner!.transitionToAsync();
      inner.end();
      // outer must still be on the stack — opening another sync entry
      // here should nest under outer, not become a sibling root.
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleRecalc, 'recalc');
      child!.end();
      outer!.end();

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1);
      expect(roots.first.subType, kSubTypeFlushUICommand);
      expect(roots.first.children.map((c) => c.subType).toList(),
          [kSubTypeInvokeBindingMethodFromNative, kSubTypeStyleRecalc]);
    });
  });

  group('PerformanceTracker beginSpan current_entry_id parent lookup', () {
    setUp(() {
      setupTest();
      PerformanceTracker.instance.clear();
      PerformanceTracker.instance.startSession();
    });
    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test(
        'beginSpan with empty entry stack but active async entry nests under it',
        () {
      // Simulates: a Dart-side async entry (eg. flushUICommand wrapping JS
      // execution) is in flight. The Dart call-stack is empty (we have
      // already returned past the await), but the C++ profiler still
      // has current_entry_id stamped. A subsequent Dart-side beginSpan
      // (eg. styleRecalc invoked through a binding callback handler)
      // must attribute back to the originating entry, not orphan.
      final entry = PerformanceTracker.instance.beginEntry(
          kSubTypeFlushUICommand, 'flushUICommand',
          asyncSpanning: true);
      // After an asyncSpanning beginEntry, _entryStack is empty and
      // _currentSpan is null — exactly the state the binding callback
      // would observe.
      final span = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleRecalc, 'recalculateStyle');
      span!.end();
      entry!.end();

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1, reason: 'styleRecalc must NOT become a root');
      expect(roots.first.subType, kSubTypeFlushUICommand);
      expect(roots.first.children.length, 1);
      expect(roots.first.children.first.subType, kSubTypeStyleRecalc);
      expect(roots.first.children.first.name, 'recalculateStyle');
    });

    test('beginSpan with no active entry still falls through to unattributed',
        () {
      // No entry open — beginSpan must demote to "unattributed" rather
      // than crash or attach to a stale entry id.
      final span = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleRecalc, 'recalculateStyle');
      span!.end();

      final roots = PerformanceTracker.instance.rootSpans;
      expect(roots.length, 1);
      expect(roots.first.subType, 'unattributed');
      expect(roots.first.name, '$kSubTypeStyleRecalc/recalculateStyle');
    });

    test(
        'span grafted via current_entry_id restores _currentSpan to null on end',
        () {
      // Regression: when a span is grafted under an async-spanning entry's
      // root, popping it must not leave _currentSpan pointing at that root
      // — otherwise the next unrelated beginSpan would nest under it too.
      final entry = PerformanceTracker.instance.beginEntry(
          kSubTypeFlushUICommand, 'flushUICommand',
          asyncSpanning: true);

      // First binding callback: opens a span (grafts under entry root).
      final first = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleRecalc, 'first');
      first!.end();

      // Second binding callback (totally unrelated): also grafts under
      // entry root as a sibling — NOT as a child of `first`.
      final second = PerformanceTracker.instance
          .beginSpan(kSubTypeLayout, 'second');
      second!.end();
      entry!.end();

      final root = PerformanceTracker.instance.rootSpans.single;
      expect(root.subType, kSubTypeFlushUICommand);
      expect(root.children.map((c) => c.subType).toList(),
          [kSubTypeStyleRecalc, kSubTypeLayout],
          reason: 'second beginSpan must be a sibling of first, not nested');
      expect(root.children.first.children, isEmpty);
    });

    test('nested beginSpan inside a grafted span still nests correctly', () {
      // The grafted span IS made _currentSpan while it is open, so further
      // nested beginSpan calls should behave as a normal call stack.
      final entry = PerformanceTracker.instance.beginEntry(
          kSubTypeFlushUICommand, 'flushUICommand',
          asyncSpanning: true);

      final outer = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleRecalc, 'outer');
      final inner = PerformanceTracker.instance
          .beginSpan(kSubTypeStyleApply, 'inner');
      inner!.end();
      outer!.end();
      entry!.end();

      final root = PerformanceTracker.instance.rootSpans.single;
      final outerSpan = root.children.single;
      expect(outerSpan.subType, kSubTypeStyleRecalc);
      expect(outerSpan.children.single.subType, kSubTypeStyleApply);
    });
  });
}
