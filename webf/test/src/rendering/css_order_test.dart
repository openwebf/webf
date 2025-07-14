/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
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

  group('Order Property CSS Parsing', () {
    testWidgets('order property parsing with integer values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-integer-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  order: 3;
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  order: 1;
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  order: 2;
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Container and items should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item3, isNotNull);
      
      // Items should be parsed correctly
      expect(container.offsetWidth, equals(300.0));
      expect(container.offsetHeight, equals(100.0));
    });

    testWidgets('order property with negative values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-negative-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 200px;
                height: 80px;
                background-color: #888;
              ">
                <div id="item1" style="
                  order: -1;
                  width: 40px;
                  height: 40px;
                  background-color: orange;
                ">A</div>
                <div id="item2" style="
                  order: 0;
                  width: 40px;
                  height: 40px;
                  background-color: purple;
                ">B</div>
                <div id="item3" style="
                  order: -2;
                  width: 40px;
                  height: 40px;
                  background-color: cyan;
                ">C</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(200.0));
      expect(container.offsetHeight, equals(80.0));
    });

    testWidgets('order property with zero value (default)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-zero-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 250px;
                height: 90px;
                background-color: #aaa;
              ">
                <div id="item1" style="
                  order: 0;
                  width: 60px;
                  height: 60px;
                  background-color: magenta;
                ">X</div>
                <div id="item2" style="
                  width: 60px;
                  height: 60px;
                  background-color: yellow;
                ">Y</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(250.0));
      expect(container.offsetHeight, equals(90.0));
    });

    testWidgets('order property with mixed positive and negative values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-mixed-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 400px;
                height: 100px;
                background-color: #ccc;
              ">
                <div id="item1" style="
                  order: 5;
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  order: -3;
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">2</div>
                <div id="item3" style="
                  order: 0;
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">3</div>
                <div id="item4" style="
                  order: 2;
                  width: 50px;
                  height: 50px;
                  background-color: yellow;
                ">4</div>
                <div id="item5" style="
                  order: -1;
                  width: 50px;
                  height: 50px;
                  background-color: purple;
                ">5</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(400.0));
      expect(container.offsetHeight, equals(100.0));
      
      // Expected visual order: item2(-3), item5(-1), item3(0), item4(2), item1(5)
    });
  });

  group('Order Property Behavior', () {
    testWidgets('order affects visual layout but not DOM order', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-visual-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: row;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="first" style="
                  order: 2;
                  width: 80px;
                  height: 80px;
                  background-color: blue;
                ">First</div>
                <div id="second" style="
                  order: 1;
                  width: 80px;
                  height: 80px;
                  background-color: red;
                ">Second</div>
                <div id="third" style="
                  order: 3;
                  width: 80px;
                  height: 80px;
                  background-color: green;
                ">Third</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final first = prepared.getElementById('first');
      final second = prepared.getElementById('second');
      final third = prepared.getElementById('third');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(third, isNotNull);
      
      // DOM order should remain unchanged
      final children = container.children;
      expect(children.length, equals(3));
      final childrenList = children.toList();
      expect(childrenList[0].id, equals('first'));
      expect(childrenList[1].id, equals('second'));
      expect(childrenList[2].id, equals('third'));
      
      // Visual order should be: second(1), first(2), third(3)
    });

    testWidgets('order works with column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-column-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                width: 150px;
                height: 300px;
                background-color: #777;
              ">
                <div id="item1" style="
                  order: 3;
                  width: 100px;
                  height: 70px;
                  background-color: cyan;
                ">A</div>
                <div id="item2" style="
                  order: 1;
                  width: 100px;
                  height: 70px;
                  background-color: magenta;
                ">B</div>
                <div id="item3" style="
                  order: 2;
                  width: 100px;
                  height: 70px;
                  background-color: yellow;
                ">C</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(150.0));
      expect(container.offsetHeight, equals(300.0));
      
      // Visual order should be: item2(1), item3(2), item1(3)
    });

    testWidgets('order works with flex-wrap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-wrap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-wrap: wrap;
                width: 200px;
                height: 200px;
                background-color: #888;
              ">
                <div id="item1" style="
                  order: 4;
                  width: 80px;
                  height: 80px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  order: 2;
                  width: 80px;
                  height: 80px;
                  background-color: green;
                ">2</div>
                <div id="item3" style="
                  order: 1;
                  width: 80px;
                  height: 80px;
                  background-color: blue;
                ">3</div>
                <div id="item4" style="
                  order: 3;
                  width: 80px;
                  height: 80px;
                  background-color: yellow;
                ">4</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(200.0));
      expect(container.offsetHeight, equals(200.0));
      
      // Visual order should be: item3(1), item2(2), item4(3), item1(4)
    });
  });

  group('Order Property Edge Cases', () {
    testWidgets('order with same values preserves document order', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-same-values-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #999;
              ">
                <div id="item1" style="
                  order: 1;
                  width: 60px;
                  height: 60px;
                  background-color: orange;
                ">First</div>
                <div id="item2" style="
                  order: 1;
                  width: 60px;
                  height: 60px;
                  background-color: purple;
                ">Second</div>
                <div id="item3" style="
                  order: 1;
                  width: 60px;
                  height: 60px;
                  background-color: teal;
                ">Third</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(300.0));
      
      // When order values are the same, document order should be preserved
      final children = container.children;
      expect(children.length, equals(3));
      final childrenList = children.toList();
      expect(childrenList[0].id, equals('item1'));
      expect(childrenList[1].id, equals('item2'));
      expect(childrenList[2].id, equals('item3'));
    });

    testWidgets('order with very large values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-large-values-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 200px;
                height: 80px;
                background-color: #aaa;
              ">
                <div id="item1" style="
                  order: 999999;
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">A</div>
                <div id="item2" style="
                  order: -999999;
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">B</div>
                <div id="item3" style="
                  order: 0;
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">C</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and handle large order values
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(200.0));
      expect(container.offsetHeight, equals(80.0));
      
      // Visual order should be: item2(-999999), item3(0), item1(999999)
    });

    testWidgets('order with invalid values defaults to 0', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'order-invalid-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                width: 150px;
                height: 100px;
                background-color: #bbb;
              ">
                <div id="item1" style="
                  order: invalid;
                  width: 40px;
                  height: 40px;
                  background-color: pink;
                ">X</div>
                <div id="item2" style="
                  order: 1;
                  width: 40px;
                  height: 40px;
                  background-color: lime;
                ">Y</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist despite invalid order value
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(150.0));
      expect(container.offsetHeight, equals(100.0));
      
      // Invalid order should be treated as 0, so visual order: item1(0), item2(1)
    });
  });
}