/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';

void main() {
  group('JSThreadSpan binding-sync category', () {
    setUp(() {
      PerformanceTracker.instance.clear();
    });

    test('categoryFromIndex(10) returns jsBindingSyncCall', () {
      expect(JSThreadSpan.categoryFromIndex(10), 'jsBindingSyncCall');
    });

    test('categoryNames length matches C++ enum (11 entries 0..10)', () {
      expect(JSThreadSpan.categoryNames.length, 11);
    });

    test('categoryFromIndex out-of-range still returns jsUnknown', () {
      expect(JSThreadSpan.categoryFromIndex(99), 'jsUnknown');
    });
  });
}
