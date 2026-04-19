/*
 * Copyright (C) 2026-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';

import '../../setup.dart';

void main() {
  group('PerformanceTracker entry stack', () {
    setUp(() {
      // Each test gets a fresh session. We can't construct PerformanceTracker
      // because it's a singleton, but startSession resets all state including
      // _entryStack, _entryIdToSpan, _nextEntryId.
      setupTest();
      PerformanceTracker.instance.startSession();
    });

    tearDown(() {
      PerformanceTracker.instance.endSession();
    });

    test('nested beginEntry produces nested span tree (not sibling roots)', () {
      final outer = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      expect(outer, isNotNull);
      expect(PerformanceTracker.instance.rootSpans.length, 1);

      final inner = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      expect(inner, isNotNull);

      // Inner must be a CHILD of outer, not a sibling root.
      expect(PerformanceTracker.instance.rootSpans.length, 1,
          reason: 'inner entry must not appear as a sibling root');
      final outerRoot = PerformanceTracker.instance.rootSpans.first;
      expect(outerRoot.children.length, 1);
      expect(outerRoot.children.first.category, kSubTypeFlushUICommand);

      inner!.end();
      outer!.end();
    });

    test('beginSpan inside an entry attributes to that entry', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      expect(child, isNotNull);

      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.children.length, 1);
      expect(root.children.first.category, kSubTypePaint);

      child!.end();
      entry!.end();
    });

    test('beginSpan outside any entry asserts in dev when opted in', () {
      PerformanceTracker.instance.assertOnUnattributedSpan = true;
      try {
        expect(
          () => PerformanceTracker.instance.beginSpan(kSubTypePaint, 'paint'),
          throwsA(isA<AssertionError>()),
        );
      } finally {
        PerformanceTracker.instance.assertOnUnattributedSpan = false;
      }
    });

    test('endSession closes any unclosed entries', () {
      final entry = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      expect(entry, isNotNull);
      // Note: endSession is called in tearDown, so we check state after it.
      PerformanceTracker.instance.endSession();
      final root = PerformanceTracker.instance.rootSpans.first;
      expect(root.endOffsetUs, isNotNull,
          reason: 'open entry must be closed when session ends');
      // Restart so tearDown's endSession doesn't double-fail
      PerformanceTracker.instance.startSession();
    });

    test('popping inner entry restores _currentSpan to outer entry', () {
      final outer = PerformanceTracker.instance
          .beginEntry(kSubTypeDrawFrame, 'drawFrame');
      final inner = PerformanceTracker.instance
          .beginEntry(kSubTypeFlushUICommand, 'flushUICommand');
      inner!.end();

      // Now beginSpan should attribute to OUTER, not become a sibling root.
      final child = PerformanceTracker.instance
          .beginSpan(kSubTypePaint, 'paint');
      expect(child, isNotNull);

      final root = PerformanceTracker.instance.rootSpans.first;
      // root.children = [flushUICommand (closed), paint]
      expect(root.children.length, 2);
      expect(root.children[1].category, kSubTypePaint);

      child!.end();
      outer!.end();
    });
  });
}
