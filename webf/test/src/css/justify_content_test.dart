/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('CSS Justify Content', () {
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
      WebFControllerManager.instance.disposeAll();
      await Future.delayed(Duration(milliseconds: 100));
    });

    testWidgets('should apply justify-content flex-start correctly', (WidgetTester tester) async {
      final name = 'justify-content-start-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: flex-start;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: blue;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      
      await tester.pump();
      
      // Items should start from left
      expect(item1.offsetLeft, 0);
      expect(item2.offsetLeft, 50);
    });

    testWidgets('should apply justify-content flex-end correctly', (WidgetTester tester) async {
      final name = 'justify-content-end-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: flex-end;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: red;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      
      await tester.pump();
      
      // Items should end at right edge
      var item2Rect = item2.getBoundingClientRect();
      expect(item2Rect.right, closeTo(container.offsetWidth, 1.0));
      expect(item1.offsetLeft, 200); // 300 - 50 - 50
    });

    testWidgets('should apply justify-content center correctly', (WidgetTester tester) async {
      final name = 'justify-content-center-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: center;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: green;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      
      await tester.pump();
      
      // Items should be centered
      expect(item1.offsetLeft, closeTo(100, 5)); // (300 - 100) / 2
    });

    testWidgets('should apply justify-content space-between correctly', (WidgetTester tester) async {
      final name = 'justify-content-space-between-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: space-between;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: purple;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      
      await tester.pump();
      
      // First item at start, last item at end
      expect(item1.offsetLeft, 0);
      var item2Rect = item2.getBoundingClientRect();
      expect(item2Rect.right, closeTo(container.offsetWidth, 1.0));
    });

    testWidgets('should apply justify-content space-around correctly', (WidgetTester tester) async {
      final name = 'justify-content-space-around-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: space-around;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: orange;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      
      await tester.pump();
      
      // Items should have space around them
      expect(item1.offsetLeft, greaterThan(0));
      expect(item2.offsetLeft, lessThan(250)); // Should have space after
    });

    testWidgets('should work with column direction', (WidgetTester tester) async {
      final name = 'justify-content-column-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  flex-direction: column;
                  justify-content: center;
                  width: 200px;
                  height: 300px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: teal;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      
      await tester.pump();
      
      // Items should be vertically centered
      expect(item1.offsetTop, closeTo(100, 10)); // (300 - 100) / 2
    });

    testWidgets('should work with flex-grow', (WidgetTester tester) async {
      final name = 'justify-content-grow-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: flex-start;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  height: 50px;
                  background: navy;
                  flex-grow: 1;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      
      await tester.pump();
      
      // Items should grow to fill space
      expect(item1.offsetWidth, 150);
      expect(item2.offsetWidth, 150);
    });

    testWidgets('should work with gap property', (WidgetTester tester) async {
      final name = 'justify-content-gap-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: flex-start;
                  gap: 10px;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: maroon;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
                <div id="item3" class="item">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      var item3 = prepared.getElementById('item3');
      
      await tester.pump();
      
      // Items should have gap between them
      expect(item1.offsetLeft, 0);
      expect(item2.offsetLeft, 60); // 50 + 10
      expect(item3.offsetLeft, 120); // 50 + 10 + 50 + 10
    });

    testWidgets('should handle percentage max-width with space-between', (WidgetTester tester) async {
      final name = 'justify-content-percentage-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: space-between;
                  gap: 5px;
                  width: 360px;
                  height: 100px;
                  background: #f0f0f0;
                  padding: 10px;
                  box-sizing: border-box;
                }
                .item {
                  max-width: 30%;
                  height: 50px;
                  background: olive;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">First</div>
                <div id="item2" class="item">Second</div>
                <div id="item3" class="item">Third</div>
              </div>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      var item3 = prepared.getElementById('item3');
      
      await tester.pump();
      
      // Third item should be close to right edge with proper gap handling
      var containerRect = container.getBoundingClientRect();
      var item3Rect = item3.getBoundingClientRect();
      expect(item3Rect.right, lessThanOrEqualTo(containerRect.right - 10 + 20)); // Allow tolerance for gap + padding
    });


    testWidgets('should work with wrapped items', (WidgetTester tester) async {
      final name = 'justify-content-wrap-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  flex-wrap: wrap;
                  justify-content: space-between;
                  width: 200px;
                  height: 200px;
                  background: #f0f0f0;
                }
                .item {
                  width: 80px;
                  height: 50px;
                  background: crimson;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">1</div>
                <div id="item2" class="item">2</div>
                <div id="item3" class="item">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      var item3 = prepared.getElementById('item3');
      
      await tester.pump();
      
      // First two items on first line
      expect(item1.offsetTop, 0);
      expect(item2.offsetTop, 0);
      // Third item wrapped
      expect(item3.offsetTop, greaterThan(item1.offsetTop)); // Should be on a new line
    });

    testWidgets('should work with single item', (WidgetTester tester) async {
      final name = 'justify-content-single-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  justify-content: space-between;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background: indigo;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">Only</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      
      await tester.pump();
      
      // Single item should be at start with space-between
      expect(item1.offsetLeft, 0);
    });
  });
}