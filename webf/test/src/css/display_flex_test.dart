// ignore_for_file: avoid_print

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

  group('CSS Display Flex', () {
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

    testWidgets('should handle display flex', (WidgetTester tester) async {
      final name ='display-flex-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  flex-direction : row;
                  width: 300px;
                  background-color: #f0f0f0;
                }
                .item {
                  width: 100px;
                  height: 50px;
                  background-color: red;
                }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item">Item 1</div>
                <div id="item2" class="item">Item 2</div>
                <div id="item3" class="item">Item 3</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      var item3 = prepared.getElementById('item3');

      await tester.pump();
      // Verify flex behavior by checking horizontal layout

      // Items should be laid out horizontally
      expect(item1.offsetLeft, 0);
      expect(item2.offsetLeft, 100);
      expect(item3.offsetLeft, 200);
    });

    testWidgets('should handle display inline-flex', (WidgetTester tester) async {

      final name = 'inline-flex-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .inline-container {
                  display: inline-flex;
                  background-color: lightyellow;
                  border: 1px solid black;
                }
                .item {
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                }
              </style>
              <span>Before</span>
              <div id="container" class="inline-container">
                <div class="item">1</div>
                <div class="item">2</div>
              </div>
              <span>After</span>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      await tester.pump();
      // Verify inline-flex behavior by checking container width

      // Inline-flex container should shrink to content
      var containerRect = container.getBoundingClientRect();
      expect(containerRect.width, closeTo(102, 2)); // 100px content + 2px border
      expect(containerRect.height, closeTo(52, 2)); // 50px content + 2px border
    });

    testWidgets('flex container should expand to full width', (WidgetTester tester) async {
      final name = 'flex-expand-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .flex-container {
                  display: flex;
                  background-color: lightgray;
                }
                .item {
                  width: 100px;
                  height: 50px;
                }
              </style>
              <div id="container" class="flex-container">
                <div class="item">Item</div>
              </div>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      await tester.pump();
      expect(container.offsetWidth, 360); // Should expand to viewport width
    });

    testWidgets('inline-flex container should shrink to content', (WidgetTester tester) async {
      final name = 'inline-flex-shrink-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .inline-flex-container {
                  display: inline-flex;
                  background-color: lightgray;
                }
                .item {
                  width: 80px;
                  height: 40px;
                }
              </style>
              <div id="container" class="inline-flex-container">
                <div class="item">1</div>
                <div class="item">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      await tester.pump();
      expect(container.offsetWidth, 160); // Should be sum of children widths
    });

    testWidgets('flex with percentage width children', (WidgetTester tester) async {
      final name = 'flex-percentage-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  width: 400px;
                }
                .item1 { width: 25%; background: red; }
                .item2 { width: 50%; background: green; }
                .item3 { width: 25%; background: blue; }
              </style>
              <div id="container" class="container">
                <div id="item1" class="item1">25%</div>
                <div id="item2" class="item2">50%</div>
                <div id="item3" class="item3">25%</div>
              </div>
            </body>
          </html>
        ''',
      );

      var item1 = prepared.getElementById('item1');
      var item2 = prepared.getElementById('item2');
      var item3 = prepared.getElementById('item3');

      await tester.pump();

      expect(item1.offsetWidth, 100); // 25% of 400px
      expect(item2.offsetWidth, 200); // 50% of 400px
      expect(item3.offsetWidth, 100); // 25% of 400px
    });

    testWidgets('inline-flex with vertical-align', (WidgetTester tester) async {
      final name = 'inline-flex-vertical-align-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .text { font-size: 20px; line-height: 30px; }
                .inline-flex {
                  display: inline-flex;
                  vertical-align: middle;
                  background: lightyellow;
                }
                .box { width: 30px; height: 30px; background: red; }
              </style>
              <div class="text">
                Text <div id="inline-flex" class="inline-flex"><div class="box"></div></div> middle
              </div>
            </body>
          </html>
        ''',
      );

      var inlineFlex = prepared.getElementById('inline-flex');
      await tester.pump();
      // Verify inline-flex exists and can have vertical alignment
      expect(inlineFlex, isNotNull);
    });

    testWidgets('flex wrap behavior', (WidgetTester tester) async {
      final name = 'flex-wrap-test-${DateTime.now().millisecondsSinceEpoch}';
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
                  width: 200px;
                }
                .item {
                  width: 80px;
                  height: 50px;
                  background: blue;
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

      // Third item wraps to second line
      expect(item3.offsetTop, 50);
    });

    testWidgets('flex with margin auto', (WidgetTester tester) async {
      final name = 'flex-margin-auto-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .container {
                  display: flex;
                  width: 300px;
                  background: lightgray;
                }
                .left { width: 80px; height: 50px; background: red; }
                .right {
                  width: 80px;
                  height: 50px;
                  background: green;
                  margin-left: auto;
                }
              </style>
              <div id="container" class="container">
                <div id="left" class="left">Left</div>
                <div id="right" class="right">Right</div>
              </div>
            </body>
          </html>
        ''',
      );

      var left = prepared.getElementById('left');
      var right = prepared.getElementById('right');

      await tester.pump();

      expect(left.offsetLeft, 0);
      expect(right.offsetLeft, 220); // 300 - 80
    });

    testWidgets('flex direction column', (WidgetTester tester) async {
      final name = 'flex-direction-column-test-${DateTime.now().millisecondsSinceEpoch}';
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
                  width: 200px;
                  height: 300px;
                }
                .item {
                  height: 50px;
                  background: red;
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

      // Items should be laid out vertically
      expect(item1.offsetTop, 0);
      expect(item2.offsetTop, 50);
      expect(item3.offsetTop, 100);

      // All items should have full width
      expect(item1.offsetWidth, 200);
      expect(item2.offsetWidth, 200);
      expect(item3.offsetWidth, 200);
    });

    testWidgets('inline-flex with gap', (WidgetTester tester) async {
      final name = 'inline-flex-gap-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .inline-flex {
                  display: inline-flex;
                  gap: 10px;
                  background: lightyellow;
                }
                .box {
                  width: 30px;
                  height: 30px;
                  background: red;
                }
              </style>
              <div id="container" class="inline-flex">
                <div id="box1" class="box"></div>
                <div id="box2" class="box"></div>
                <div id="box3" class="box"></div>
              </div>
            </body>
          </html>
        ''',
      );

      var container = prepared.getElementById('container');
      var box1 = prepared.getElementById('box1');
      var box2 = prepared.getElementById('box2');
      var box3 = prepared.getElementById('box3');

      await tester.pump();

      expect(container.offsetWidth, 110); // 30*3 + 10*2
      expect(box1.offsetLeft, 0);
      expect(box2.offsetLeft, 40); // 30 + 10
      expect(box3.offsetLeft, 80); // 30*2 + 10*2
    });

    testWidgets('flex vs block display comparison', (WidgetTester tester) async {
      final name = 'flex-vs-block-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .block { display: block; background: lightblue; }
                .flex { display: flex; background: lightcoral; }
                .child { width: 100px; height: 30px; background: darkred; }
              </style>
              <div id="block" class="block">
                <div class="child">Block child</div>
              </div>
              <div id="flex" class="flex">
                <div class="child">Flex child</div>
              </div>
            </body>
          </html>
        ''',
      );

      var block = prepared.getElementById('block');
      var flex = prepared.getElementById('flex');

      await tester.pump();

      // Both should expand to full width
      expect(block.offsetWidth, 360);
      expect(flex.offsetWidth, 360);

      // But flex container's height should match content
      expect(flex.offsetHeight, 30);
    });

    testWidgets('nested inline-flex containers', (WidgetTester tester) async {
      final name = 'nested-inline-flex-test-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <style>
                .outer {
                  display: inline-flex;
                  gap: 5px;
                  background: lightgray;
                  padding: 5px;
                }
                .inner {
                  display: inline-flex;
                  gap: 3px;
                  background: lightyellow;
                  padding: 3px;
                }
                .box { width: 20px; height: 20px; background: red; }
              </style>
              <div id="outer" class="outer">
                <div>Item</div>
                <div id="inner" class="inner">
                  <div class="box"></div>
                  <div class="box"></div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      var outer = prepared.getElementById('outer');
      var inner = prepared.getElementById('inner');

      await tester.pump();

      expect(inner.offsetWidth, 49); // 20*2 (children) + 3 (gap) + 6 (padding) = 49
      expect(outer.offsetWidth, greaterThan(inner.offsetWidth));
    });

    testWidgets('flex container with min-height should stretch items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-min-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                min-height: 100px;
                background-color: #f0f0f0;
                border: 1px solid black;
              ">
                <div id="red" style="
                  width: 100px;
                  background-color: red;
                ">Auto height</div>
                <div id="green" style="
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">50px height</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final redDiv = prepared.getElementById('red');
      final greenDiv = prepared.getElementById('green');

      await tester.pump();

      // Container should respect min-height
      expect(container.offsetHeight, equals(100.0));

      // Red div should stretch to container height (98px), not green div height (50px)
      expect(redDiv.offsetHeight, equals(98.0));

      // Green div should keep its explicit height
      expect(greenDiv.offsetHeight, equals(50.0));
    });

    testWidgets('flex container with min-width should stretch items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-min-width-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                min-width: 200px;
                background-color: #f0f0f0;
                border: 1px solid black;
              ">
                <div id="red" style="
                  height: 50px;
                  background-color: red;
                ">Auto width</div>
                <div id="green" style="
                  height: 50px;
                  width: 80px;
                  background-color: green;
                ">80px width</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final redDiv = prepared.getElementById('red');
      final greenDiv = prepared.getElementById('green');

      await tester.pump();

      // Container should be at least min-width (200px), may be larger due to viewport
      expect(container.offsetWidth, greaterThanOrEqualTo(200.0));

      // Red div should stretch to container content width (container width - 2px border), not green div width (80px)
      double expectedRedWidth = container.offsetWidth - 2.0; // Account for border
      expect(redDiv.offsetWidth, equals(expectedRedWidth));
      expect(redDiv.offsetWidth, greaterThan(80.0)); // Should be wider than green div

      // Green div should keep its explicit width
      expect(greenDiv.offsetWidth, equals(80.0));
    });

    testWidgets('inline-flex with gap should include gaps in offsetWidth', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-gap-width-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                gap: 10px;
                background-color: lightyellow;
                border: 1px solid orange;
                padding: 5px;
              ">
                <div style="
                  width: 30px;
                  height: 30px;
                  background-color: red;
                "></div>
                <div style="
                  width: 30px;
                  height: 30px;
                  background-color: green;
                "></div>
                <div style="
                  width: 30px;
                  height: 30px;
                  background-color: blue;
                "></div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');

      await tester.pump();

      // Expected calculation:
      // 3 children × 30px = 90px content
      // 2 gaps × 10px = 20px gaps
      // 2 × 5px padding = 10px padding
      // 2 × 1px border = 2px border
      // Total = 122px

      expect(container.offsetWidth, equals(122.0));
    });

    testWidgets('inline-flex without gap for comparison', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-no-gap-width-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                background-color: lightyellow;
                border: 1px solid orange;
                padding: 5px;
              ">
                <div style="
                  width: 30px;
                  height: 30px;
                  background-color: red;
                "></div>
                <div style="
                  width: 30px;
                  height: 30px;
                  background-color: green;
                "></div>
                <div style="
                  width: 30px;
                  height: 30px;
                  background-color: blue;
                "></div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');

      await tester.pump();

      // Expected calculation without gap:
      // 3 children × 30px = 90px content
      // 2 × 5px padding = 10px padding
      // 2 × 1px border = 2px border
      // Total = 102px

      expect(container.offsetWidth, equals(102.0));
    });

    testWidgets('debug inline-flex gap overflow issue', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'debug-inline-flex-overflow-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-size: 16px;">
              Items with gap:
              <div id="container" style="
                display: inline-flex;
                gap: 10px;
                background-color: lightyellow;
                border: 1px solid orange;
                padding: 5px;
              ">
                <div id="red" style="
                  width: 30px;
                  height: 30px;
                  background-color: red;
                "></div>
                <div id="green" style="
                  width: 30px;
                  height: 30px;
                  background-color: green;
                "></div>
                <div id="blue" style="
                  width: 30px;
                  height: 30px;
                  background-color: blue;
                "></div>
              </div>
               end
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final redDiv = prepared.getElementById('red');
      final greenDiv = prepared.getElementById('green');
      final blueDiv = prepared.getElementById('blue');

      await tester.pump();

      // Get bounding rects to see actual rendered positions
      final containerRect = container.getBoundingClientRect();
      final redRect = redDiv.getBoundingClientRect();
      final greenRect = greenDiv.getBoundingClientRect();
      final blueRect = blueDiv.getBoundingClientRect();

      print('=== DEBUG INLINE-FLEX OVERFLOW ===');
      print('Container offsetWidth: ${container.offsetWidth}');
      print('Container rect: left=${containerRect.left}, right=${containerRect.right}, width=${containerRect.width}');
      print('Red rect: left=${redRect.left}, right=${redRect.right}');
      print('Green rect: left=${greenRect.left}, right=${greenRect.right}');
      print('Blue rect: left=${blueRect.left}, right=${blueRect.right}');
      print('Blue overflows container? ${blueRect.right > containerRect.right}');

      // The key test: blue item should NOT overflow the container
      expect(blueRect.right, lessThanOrEqualTo(containerRect.right),
             reason: 'Blue item should not overflow the lightyellow container');
    });
  });
}
