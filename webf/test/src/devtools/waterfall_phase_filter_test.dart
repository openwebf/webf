/*
 * Copyright (C) 2026-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/waterfall_chart.dart';

WaterfallEntry _entry(
    {required Duration start, required Duration end, String label = 'e'}) {
  return WaterfallEntry(
    subType: 'lifecycle',
    label: label,
    start: start,
    end: end,
  );
}

WaterfallMilestone _ms(Duration offset, [String label = 'm']) {
  return WaterfallMilestone(
      label: label, offset: offset, color: const Color(0xFF000000));
}

void main() {
  group('WaterfallPhase filter — includeEntry', () {
    test('attachOffset set: initToAttach includes start < attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 100),
                  end: const Duration(milliseconds: 200)),
              WaterfallPhase.initToAttach,
              attach),
          isTrue);
    });

    test('attachOffset set: initToAttach excludes start >= attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 500),
                  end: const Duration(milliseconds: 600)),
              WaterfallPhase.initToAttach,
              attach),
          isFalse);
    });

    test('attachOffset set: attachToPaint includes start >= attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 500),
                  end: const Duration(milliseconds: 700)),
              WaterfallPhase.attachToPaint,
              attach),
          isTrue);
    });

    test('attachOffset set: attachToPaint excludes start < attachOffset', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 100),
                  end: const Duration(milliseconds: 600)),
              WaterfallPhase.attachToPaint,
              attach),
          isFalse);
    });

    test('cross-boundary entry stays in initToAttach (no clipping)', () {
      // Start 100ms (pre-attach), end 800ms (post-attach).
      final attach = const Duration(milliseconds: 500);
      final entry = _entry(
          start: const Duration(milliseconds: 100),
          end: const Duration(milliseconds: 800));
      expect(
          includeEntryForPhase(entry, WaterfallPhase.initToAttach, attach),
          isTrue);
      expect(
          includeEntryForPhase(entry, WaterfallPhase.attachToPaint, attach),
          isFalse);
      // Entry bounds are preserved — no mutation.
      expect(entry.start, const Duration(milliseconds: 100));
      expect(entry.end, const Duration(milliseconds: 800));
    });

    test('attachOffset null: initToAttach includes everything', () {
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 0),
                  end: const Duration(milliseconds: 100)),
              WaterfallPhase.initToAttach,
              null),
          isTrue);
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 999),
                  end: const Duration(milliseconds: 1000)),
              WaterfallPhase.initToAttach,
              null),
          isTrue);
    });

    test('attachOffset null: attachToPaint includes nothing', () {
      expect(
          includeEntryForPhase(
              _entry(
                  start: const Duration(milliseconds: 0),
                  end: const Duration(milliseconds: 100)),
              WaterfallPhase.attachToPaint,
              null),
          isFalse);
    });
  });

  group('WaterfallPhase filter — includeMilestone', () {
    test('attachOffset set: milestone at attachOffset belongs to attachToPaint',
        () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeMilestoneForPhase(
              _ms(attach), WaterfallPhase.attachToPaint, attach),
          isTrue);
      expect(
          includeMilestoneForPhase(
              _ms(attach), WaterfallPhase.initToAttach, attach),
          isFalse);
    });

    test('attachOffset null: only initToAttach includes milestones', () {
      expect(
          includeMilestoneForPhase(
              _ms(const Duration(milliseconds: 100)),
              WaterfallPhase.initToAttach,
              null),
          isTrue);
      expect(
          includeMilestoneForPhase(
              _ms(const Duration(milliseconds: 100)),
              WaterfallPhase.attachToPaint,
              null),
          isFalse);
    });
  });

  group('WaterfallPhase filter — includeFrameBoundary', () {
    test('attachOffset set: boundary at offset belongs to matching phase', () {
      final attach = const Duration(milliseconds: 500);
      expect(
          includeFrameBoundaryForPhase(
              const Duration(milliseconds: 100),
              WaterfallPhase.initToAttach,
              attach),
          isTrue);
      expect(
          includeFrameBoundaryForPhase(
              const Duration(milliseconds: 600),
              WaterfallPhase.attachToPaint,
              attach),
          isTrue);
    });
  });
}
