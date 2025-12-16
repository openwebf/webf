/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';
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

  group('CSS Flex Direction', () {
    test('should resolve flex-direction values correctly', () {
      expect(CSSFlexboxMixin.resolveFlexDirection('row'), FlexDirection.row);
      expect(CSSFlexboxMixin.resolveFlexDirection('row-reverse'), FlexDirection.rowReverse);
      expect(CSSFlexboxMixin.resolveFlexDirection('column'), FlexDirection.column);
      expect(CSSFlexboxMixin.resolveFlexDirection('column-reverse'), FlexDirection.columnReverse);
      
      // Default value
      expect(CSSFlexboxMixin.resolveFlexDirection(''), FlexDirection.row);
      expect(CSSFlexboxMixin.resolveFlexDirection('invalid'), FlexDirection.row);
    });

    testWidgets('should apply flex-direction row correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-row-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: row; width: 300px;">
                <div id="child1" style="width: 100px; height: 50px; background-color: red;">1</div>
                <div id="child2" style="width: 100px; height: 50px; background-color: green;">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final child1 = prepared.getElementById('child1');
      final child2 = prepared.getElementById('child2');
      
      expect(container.offsetWidth, equals(300.0));
      
      // Children should be arranged horizontally
      final child1Rect = child1.getBoundingClientRect();
      final child2Rect = child2.getBoundingClientRect();
      
      expect(child1Rect.left, equals(0.0));
      expect(child2Rect.left, equals(100.0)); // After first child
      expect(child1Rect.top, equals(child2Rect.top)); // Same vertical position
    });

    testWidgets('should apply flex-direction row-reverse correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-row-reverse-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: row-reverse; width: 300px;">
                <div id="child1" style="width: 100px; height: 50px; background-color: red;">1</div>
                <div id="child2" style="width: 100px; height: 50px; background-color: green;">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final child1 = prepared.getElementById('child1');
      final child2 = prepared.getElementById('child2');
      
      expect(container.offsetWidth, equals(300.0));
      
      // Children should be arranged horizontally in reverse order
      final child1Rect = child1.getBoundingClientRect();
      final child2Rect = child2.getBoundingClientRect();
      
      // Child1 should be to the right of child2 (reverse order)
      expect(child1Rect.left, greaterThan(child2Rect.left));
      expect(child1Rect.top, equals(child2Rect.top)); // Same vertical position
    });

    testWidgets('should apply flex-direction column correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-column-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: column; height: 300px;">
                <div id="child1" style="width: 100px; height: 100px; background-color: red;">1</div>
                <div id="child2" style="width: 100px; height: 100px; background-color: green;">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final child1 = prepared.getElementById('child1');
      final child2 = prepared.getElementById('child2');
      
      expect(container.offsetHeight, equals(300.0));
      
      // Children should be arranged vertically
      final child1Rect = child1.getBoundingClientRect();
      final child2Rect = child2.getBoundingClientRect();
      
      expect(child1Rect.top, equals(0.0));
      expect(child2Rect.top, equals(100.0)); // After first child
      expect(child1Rect.left, equals(child2Rect.left)); // Same horizontal position
    });

    testWidgets('should apply flex-direction column-reverse correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-column-reverse-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: column-reverse; height: 300px;">
                <div id="child1" style="width: 100px; height: 100px; background-color: red;">1</div>
                <div id="child2" style="width: 100px; height: 100px; background-color: green;">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final child1 = prepared.getElementById('child1');
      final child2 = prepared.getElementById('child2');
      
      expect(container.offsetHeight, equals(300.0));
      
      // Children should be arranged vertically in reverse order
      final child1Rect = child1.getBoundingClientRect();
      final child2Rect = child2.getBoundingClientRect();
      
      // Child1 should be below child2 (reverse order)
      expect(child1Rect.top, greaterThan(child2Rect.top));
      expect(child1Rect.left, equals(child2Rect.left)); // Same horizontal position
    });

    testWidgets('should work with flex-wrap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-wrap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: row; flex-wrap: wrap; width: 200px;">
                <div style="width: 100px; height: 50px; background-color: red;">1</div>
                <div style="width: 100px; height: 50px; background-color: green;">2</div>
                <div style="width: 100px; height: 50px; background-color: blue;">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      expect(container.offsetWidth, equals(200.0));
      // Test passes if no error occurs with wrapping
    });

    testWidgets('should work with flex-grow', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-grow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; flex-direction: row; width: 400px;">
                <div id="grow1" style="flex-grow: 1; height: 80px; background-color: red;">Grow</div>
                <div style="width: 100px; height: 80px; background-color: green;">Fixed</div>
                <div id="grow2" style="flex-grow: 2; height: 80px; background-color: blue;">Grow x2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final grow1 = prepared.getElementById('grow1');
      final grow2 = prepared.getElementById('grow2');
      
      expect(container.offsetWidth, equals(400.0));
      
      // grow2 should be wider than grow1 (2x growth factor)
      expect(grow2.offsetWidth, greaterThan(grow1.offsetWidth));
    });

    testWidgets('should work with nested flex containers', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-nested-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="outer" style="display: flex; flex-direction: row; width: 400px; height: 200px;">
                <div id="inner1" style="display: flex; flex-direction: column; width: 150px; background-color: lightblue;">
                  <div style="width: 50px; height: 50px; background-color: red;">1A</div>
                  <div style="width: 50px; height: 50px; background-color: darkred;">1B</div>
                </div>
                <div id="inner2" style="display: flex; flex-direction: column-reverse; width: 150px; background-color: lightgreen;">
                  <div style="width: 50px; height: 50px; background-color: green;">2A</div>
                  <div style="width: 50px; height: 50px; background-color: darkgreen;">2B</div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final outer = prepared.getElementById('outer');
      final inner1 = prepared.getElementById('inner1');
      final inner2 = prepared.getElementById('inner2');
      
      expect(outer.offsetWidth, equals(400.0));
      expect(inner1.offsetWidth, equals(150.0));
      expect(inner2.offsetWidth, equals(150.0));
    });

    test('should work with isHorizontalFlexDirection helper', () {
      expect(CSSFlex.isHorizontalFlexDirection(FlexDirection.row), true);
      expect(CSSFlex.isHorizontalFlexDirection(FlexDirection.rowReverse), true);
      expect(CSSFlex.isHorizontalFlexDirection(FlexDirection.column), false);
      expect(CSSFlex.isHorizontalFlexDirection(FlexDirection.columnReverse), false);
    });

    test('should work with isVerticalFlexDirection helper', () {
      expect(CSSFlex.isVerticalFlexDirection(FlexDirection.row), false);
      expect(CSSFlex.isVerticalFlexDirection(FlexDirection.rowReverse), false);
      expect(CSSFlex.isVerticalFlexDirection(FlexDirection.column), true);
      expect(CSSFlex.isVerticalFlexDirection(FlexDirection.columnReverse), true);
    });
  });
}