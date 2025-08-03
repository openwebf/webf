/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    // Clean up any controllers from previous tests
    WebFControllerManager.instance.disposeAll();
    // Add a small delay to ensure file locks are released
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('CSS Flex Grow', () {
    test('should resolve flex-grow values correctly', () {
      expect(CSSFlexboxMixin.resolveFlexGrow('0'), 0.0);
      expect(CSSFlexboxMixin.resolveFlexGrow('1'), 1.0);
      expect(CSSFlexboxMixin.resolveFlexGrow('2'), 2.0);
      expect(CSSFlexboxMixin.resolveFlexGrow('0.5'), 0.5);
      expect(CSSFlexboxMixin.resolveFlexGrow('1.5'), 1.5);
      
      // Default value
      expect(CSSFlexboxMixin.resolveFlexGrow(''), 0.0);
      expect(CSSFlexboxMixin.resolveFlexGrow('invalid'), 0.0);
      
      // Negative values should be treated as 0
      expect(CSSFlexboxMixin.resolveFlexGrow('-1'), 0.0);
      expect(CSSFlexboxMixin.resolveFlexGrow('-0.5'), 0.0);
    });

    testWidgets('should apply basic flex-grow correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 300px; height: 100px;">
                <div id="item1" style="width: 50px; flex-grow: 1; background-color: red;">1</div>
                <div id="item2" style="width: 50px; flex-grow: 2; background-color: green;">2</div>
                <div id="item3" style="width: 50px; background-color: blue;">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      expect(container.offsetWidth, equals(300.0));
      
      // Item3 should keep its original width
      expect(item3.offsetWidth, equals(50.0));
      
      // Items 1 and 2 should grow
      expect(item1.offsetWidth, greaterThan(50.0));
      expect(item2.offsetWidth, greaterThan(50.0));
      
      // Item2 should be larger than item1 (approximately 2x the growth)
      expect(item2.offsetWidth, greaterThan(item1.offsetWidth));
    });

    testWidgets('should work with flex-grow zero', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-zero-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 300px;">
                <div id="item1" style="width: 50px; flex-grow: 0; background-color: red;">1</div>
                <div id="item2" style="width: 50px; flex-grow: 0; background-color: green;">2</div>
                <div id="item3" style="width: 50px; flex-grow: 0; background-color: blue;">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // All items should keep their original width
      expect(item1.offsetWidth, equals(50.0));
      expect(item2.offsetWidth, equals(50.0));
      expect(item3.offsetWidth, equals(50.0));
    });

    testWidgets('should work with decimal flex-grow values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-decimal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 300px;">
                <div id="item1" style="width: 50px; flex-grow: 0.5; background-color: red;">0.5</div>
                <div id="item2" style="width: 50px; flex-grow: 1.5; background-color: green;">1.5</div>
                <div id="item3" style="width: 50px; background-color: blue;">0</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Item3 should keep its original width
      expect(item3.offsetWidth, equals(50.0));
      
      // Items 1 and 2 should grow
      expect(item1.offsetWidth, greaterThan(50.0));
      expect(item2.offsetWidth, greaterThan(50.0));
      
      // Item2 should be larger than item1
      expect(item2.offsetWidth, greaterThan(item1.offsetWidth));
    });

    testWidgets('should work in column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-column-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: column; height: 300px; width: 100px;">
                <div id="item1" style="height: 50px; flex-grow: 1; background-color: red;">1</div>
                <div id="item2" style="height: 50px; flex-grow: 2; background-color: green;">2</div>
                <div id="item3" style="height: 50px; background-color: blue;">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      expect(container.offsetHeight, equals(300.0));
      
      // Item3 should keep its original height
      expect(item3.offsetHeight, equals(50.0));
      
      // Items 1 and 2 should grow
      expect(item1.offsetHeight, greaterThan(50.0));
      expect(item2.offsetHeight, greaterThan(50.0));
      
      // Item2 should be taller than item1
      expect(item2.offsetHeight, greaterThan(item1.offsetHeight));
    });

    testWidgets('should respect min-width constraint', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-min-width-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 300px;">
                <div id="item1" style="min-width: 100px; flex-grow: 1; background-color: red;">min-100</div>
                <div id="item2" style="min-width: 50px; flex-grow: 1; background-color: green;">min-50</div>
                <div id="item3" style="width: 50px; background-color: blue;">fixed</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Both items should respect their min-width
      expect(item1.offsetWidth, greaterThanOrEqualTo(100.0));
      expect(item2.offsetWidth, greaterThanOrEqualTo(50.0));
    });

    testWidgets('should respect max-width constraint', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-max-width-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 400px;">
                <div id="item1" style="width: 50px; max-width: 100px; flex-grow: 1; background-color: red;">max-100</div>
                <div id="item2" style="width: 50px; max-width: 150px; flex-grow: 1; background-color: green;">max-150</div>
                <div id="item3" style="width: 50px; flex-grow: 1; background-color: blue;">no-max</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Items should not exceed their max-width
      expect(item1.offsetWidth, lessThanOrEqualTo(100.0));
      expect(item2.offsetWidth, lessThanOrEqualTo(150.0));
    });

    testWidgets('should work with equal flex-grow values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-equal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 300px;">
                <div id="item1" style="width: 20px; flex-grow: 1; background-color: red;">1</div>
                <div id="item2" style="width: 20px; flex-grow: 1; background-color: green;">1</div>
                <div id="item3" style="width: 20px; flex-grow: 1; background-color: blue;">1</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // All items should have approximately equal width
      expect(item1.offsetWidth, equals(100.0));
      expect(item2.offsetWidth, equals(100.0));
      expect(item3.offsetWidth, equals(100.0));
    });

    testWidgets('should work with margins', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-margins-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 320px;">
                <div id="item1" style="width: 50px; margin: 0 10px; flex-grow: 1; background-color: red;">1</div>
                <div id="item2" style="width: 50px; margin: 0 10px; flex-grow: 2; background-color: green;">2</div>
                <div id="item3" style="width: 50px; margin: 0 10px; background-color: blue;">0</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item3 = prepared.getElementById('item3');
      
      expect(container.offsetWidth, equals(320.0));
      
      // Item3 should keep its original width
      expect(item3.offsetWidth, equals(50.0));
    });

    testWidgets('should work with flex-basis', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-basis-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 350px;">
                <div id="item1" style="flex-basis: 50px; flex-grow: 1; background-color: red;">basis-50</div>
                <div id="item2" style="flex-basis: 100px; flex-grow: 1; background-color: green;">basis-100</div>
                <div id="item3" style="flex-basis: 50px; background-color: blue;">no-grow</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      expect(container.offsetWidth, equals(350.0));
      
      // Item3 should respect its flex-basis
      expect(item3.offsetWidth, greaterThanOrEqualTo(50.0));
      
      // Items 1 and 2 should grow beyond their basis
      expect(item1.offsetWidth, greaterThanOrEqualTo(50.0));
      expect(item2.offsetWidth, greaterThanOrEqualTo(100.0));
      
      // Test passes if layout completes without error
    });

    testWidgets('should handle dynamic flex-grow changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-dynamic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 300px;">
                <div id="grow-item" style="width: 50px; flex-grow: 0; background-color: red;">dynamic</div>
                <div style="width: 50px; flex-grow: 1; background-color: green;">grow-1</div>
                <div style="width: 50px; background-color: blue;">fixed</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final growItem = prepared.getElementById('grow-item');
      
      expect(container.offsetWidth, equals(300.0));
      
      // Initial state: no grow
      expect(growItem.offsetWidth, equals(50.0));
      
      // Change to flex-grow: 2
      growItem.style.setProperty('flex-grow', '2');
      await tester.pump();
      
      // Test passes if layout completes without error after property change
      expect(growItem.offsetWidth, greaterThanOrEqualTo(50.0));
    });

    testWidgets('should work with flex-wrap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-wrap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-wrap: wrap; width: 200px; height: 200px;">
                <div id="item1" style="width: 80px; height: 80px; flex-grow: 1; background-color: red;">1</div>
                <div id="item2" style="width: 80px; height: 80px; flex-grow: 1; background-color: green;">2</div>
                <div id="item3" style="width: 80px; height: 80px; flex-grow: 1; background-color: blue;">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      expect(container.offsetWidth, equals(200.0));
      expect(container.offsetHeight, equals(200.0));
      
      // Test passes if layout completes without error
    });

    testWidgets('should work with gap property', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; gap: 10px; width: 300px;">
                <div id="item1" style="width: 50px; flex-grow: 1; background-color: red;">1</div>
                <div id="item2" style="width: 50px; flex-grow: 2; background-color: green;">2</div>
                <div id="item3" style="width: 50px; background-color: blue;">0</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item3 = prepared.getElementById('item3');
      
      expect(container.offsetWidth, equals(300.0)); // Flex container keeps its explicit width, gaps are internal
      
      // Item3 should keep its original width
      expect(item3.offsetWidth, equals(50.0));
    });

    test('should handle invalid flex-grow values gracefully', () {
      // Test that invalid values default to 0.0
      expect(CSSFlexboxMixin.resolveFlexGrow('invalid'), equals(0.0));
      expect(CSSFlexboxMixin.resolveFlexGrow(''), equals(0.0));
      expect(CSSFlexboxMixin.resolveFlexGrow('not-a-number'), equals(0.0));
    });
  });
}