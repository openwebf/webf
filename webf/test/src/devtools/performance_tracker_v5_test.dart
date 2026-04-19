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
  });
}
