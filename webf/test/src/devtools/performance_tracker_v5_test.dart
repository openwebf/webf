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
}
