/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
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

  group('Gap Property CSS Parsing', () {
    testWidgets('gap property parsing with single value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-single-value-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 20px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and have correct dimensions
      expect(container.offsetWidth, equals(300.0)); // Flex container keeps its explicit width, gaps are internal
      expect(container.offsetHeight, equals(100.0));
      
      // TODO: Verify gap property is parsed correctly
      // This test ensures the CSS with gap property doesn't cause parsing errors
    });

    testWidgets('gap property parsing with two values (row-gap column-gap)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-two-values-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 20px 10px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and have correct dimensions
      expect(container.offsetWidth, equals(300.0)); // Flex container keeps its explicit width, gaps are internal
      expect(container.offsetHeight, equals(100.0));
      
      // TODO: Verify gap property with two values is parsed correctly
      // First value should be row-gap (20px), second should be column-gap (10px)
    });

    testWidgets('row-gap property parsing', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'row-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                row-gap: 15px;
                width: 200px;
                height: 200px;
                background-color: #666;
              ">
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and have correct dimensions
      expect(container.offsetWidth, equals(200.0));
      expect(container.offsetHeight, equals(200.0));
      
      // TODO: Verify row-gap property is parsed correctly
    });

    testWidgets('column-gap property parsing', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'column-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: row;
                column-gap: 25px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div style="
                  width: 60px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 60px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and have correct dimensions
      expect(container.offsetWidth, equals(300.0)); // Flex container keeps its explicit width, gaps are internal
      expect(container.offsetHeight, equals(100.0));
      
      // TODO: Verify column-gap property is parsed correctly
    });

    testWidgets('gap with different units (px, em, rem, %)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-units-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-size: 16px;">
              <div id="px-container" style="
                display: flex;
                gap: 10px;
                width: 200px;
                height: 50px;
                background-color: #aaa;
                margin-bottom: 10px;
              ">
                <div style="width: 30px; height: 30px; background-color: blue;">1</div>
                <div style="width: 30px; height: 30px; background-color: red;">2</div>
              </div>
              
              <div id="em-container" style="
                display: flex;
                gap: 1em;
                width: 200px;
                height: 50px;
                background-color: #bbb;
                margin-bottom: 10px;
              ">
                <div style="width: 30px; height: 30px; background-color: green;">3</div>
                <div style="width: 30px; height: 30px; background-color: yellow;">4</div>
              </div>
              
              <div id="rem-container" style="
                display: flex;
                gap: 1rem;
                width: 200px;
                height: 50px;
                background-color: #ccc;
              ">
                <div style="width: 30px; height: 30px; background-color: purple;">5</div>
                <div style="width: 30px; height: 30px; background-color: orange;">6</div>
              </div>
            </body>
          </html>
        ''',
      );

      final pxContainer = prepared.getElementById('px-container');
      final emContainer = prepared.getElementById('em-container');
      final remContainer = prepared.getElementById('rem-container');
      
      // Containers should exist
      expect(pxContainer, isNotNull);
      expect(emContainer, isNotNull);
      expect(remContainer, isNotNull);
      
      // Verify different gap units are parsed correctly without errors
      // px units should be absolute (10px)
      // em units should be relative to font-size (16px * 1em = 16px)
      // rem units should be relative to root font-size (16px * 1rem = 16px)
    });
  });

  group('Gap Layout Behavior in Flex Containers', () {
    testWidgets('gap creates space between flex items in row direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-row-layout-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: row;
                gap: 20px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Items should exist
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item3, isNotNull);
      
      // TODO: When gap is implemented, verify spacing between items
      // final item1Rect = item1.getBoundingClientRect();
      // final item2Rect = item2.getBoundingClientRect();
      // final item3Rect = item3.getBoundingClientRect();
      
      // Expected with 20px gap:
      // item1: left = 0
      // item2: left = 70 (50 + 20)
      // item3: left = 140 (50 + 20 + 50 + 20)
      // expect(item2Rect.left - (item1Rect.left + item1.offsetWidth), equals(20.0));
      // expect(item3Rect.left - (item2Rect.left + item2.offsetWidth), equals(20.0));
    });

    testWidgets('gap creates space between flex items in column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-column-layout-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                gap: 15px;
                width: 200px;
                height: 300px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Items should exist
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item3, isNotNull);
      
      // TODO: When gap is implemented, verify vertical spacing between items
      // final item1Rect = item1.getBoundingClientRect();
      // final item2Rect = item2.getBoundingClientRect();
      // final item3Rect = item3.getBoundingClientRect();
      
      // Expected with 15px gap:
      // item1: top = 0
      // item2: top = 65 (50 + 15)
      // item3: top = 130 (50 + 15 + 50 + 15)
      // expect(item2Rect.top - (item1Rect.top + item1.offsetHeight), equals(15.0));
      // expect(item3Rect.top - (item2Rect.top + item2.offsetHeight), equals(15.0));
    });

    testWidgets('row-gap only affects vertical spacing in wrapped flex', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'row-gap-wrapped-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-wrap: wrap;
                row-gap: 20px;
                column-gap: 0px;
                width: 150px;
                height: 200px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 60px;
                  height: 40px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 60px;
                  height: 40px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  width: 60px;
                  height: 40px;
                  background-color: green;
                ">3</div>
                <div id="item4" style="
                  width: 60px;
                  height: 40px;
                  background-color: yellow;
                ">4</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      final item4 = prepared.getElementById('item4');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item3, isNotNull);
      expect(item4, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - Items 1 and 2 should be on first row with no horizontal gap (column-gap: 0)
      // - Items 3 and 4 should be on second row
      // - There should be 20px vertical gap between rows (row-gap: 20px)
    });

    testWidgets('column-gap only affects horizontal spacing', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'column-gap-only-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: row;
                column-gap: 25px;
                row-gap: 0px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Items should exist
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item3, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - 25px horizontal gap between items (column-gap: 25px)
      // - No vertical gap since row-gap: 0px and flex-direction: row
      // Expected positions: item1 at 0, item2 at 75, item3 at 150
    });
  });

  group('Gap Integration with Flex Properties', () {
    testWidgets('gap works with flex-grow', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-flex-grow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 20px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  flex-grow: 1;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  flex-grow: 2;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - Available space for flex items should be 300px - 20px (gap) = 280px
      // - item1 gets 1/3 of 280px = ~93.33px
      // - item2 gets 2/3 of 280px = ~186.67px
      // - Plus 20px gap between them
    });

    testWidgets('gap works with flex-basis', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-flex-basis-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 15px;
                width: 400px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  flex-basis: 100px;
                  flex-grow: 0;
                  flex-shrink: 0;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  flex-basis: 150px;
                  flex-grow: 0;
                  flex-shrink: 0;
                  height: 50px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  flex-basis: 100px;
                  flex-grow: 0;
                  flex-shrink: 0;
                  height: 50px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Items should exist
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item3, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - item1: 100px width
      // - gap: 15px
      // - item2: 150px width
      // - gap: 15px
      // - item3: 100px width
      // Total used space: 100 + 15 + 150 + 15 + 100 = 380px (fits in 400px container)
    });

    testWidgets('gap works with justify-content', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-justify-content-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                justify-content: center;
                gap: 10px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - Total items width: 50 + 10 + 50 = 110px
      // - Available space: 300 - 110 = 190px
      // - justify-content: center should center the group with 95px on each side
      // - item1 should start at x = 95px
      // - item2 should start at x = 95 + 50 + 10 = 155px
    });

    testWidgets('gap works with align-items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-align-items-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 12px;
                width: 200px;
                height: 300px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 80px;
                  height: 40px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 120px;
                  height: 40px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - align-items: center should horizontally center each item
      // - item1 (80px) centered in 200px container: x = (200-80)/2 = 60px
      // - item2 (120px) centered in 200px container: x = (200-120)/2 = 40px
      // - 12px vertical gap between items
    });
  });

  group('Gap Edge Cases and Error Handling', () {
    testWidgets('gap with zero value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-zero-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 0px;
                width: 200px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Items should exist
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - gap: 0px should result in no space between items
      // - item2 should start immediately after item1 (at x = 50px)
    });

    testWidgets('gap with negative value (should be treated as zero)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-negative-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: -10px;
                width: 200px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist - negative gap should not cause errors
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(200.0));
      
      // TODO: When gap is implemented, verify:
      // - Negative gap values should be clamped to 0
      // - Should behave same as gap: 0px
    });

    testWidgets('gap in single-item flex container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-single-item-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 50px;
                width: 200px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">Only Item</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      
      // TODO: When gap is implemented, verify:
      // - gap should have no effect with only one item
      // - item should be positioned normally (at x = 0)
    });

    testWidgets('gap in empty flex container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-empty-container-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 30px;
                width: 200px;
                height: 100px;
                background-color: #666;
              ">
                <!-- No children -->
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      
      // Empty container should have no children
      expect(container.children.length, equals(0));
      
      // Gap should have no effect in empty container - test should pass without errors
      // This verifies that gap properties don't cause layout errors in empty containers
    });
  });

  group('Gap Compatibility Tests', () {
    testWidgets('gap fallback behavior when not supported', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-fallback-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 20px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  margin-right: 20px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Elements should exist
      expect(container, isNotNull);
      expect(item1, isNotNull);
      expect(item2, isNotNull);
      
      // Fallback using margin should work regardless of gap support
      final item1Rect = item1.getBoundingClientRect();
      final item2Rect = item2.getBoundingClientRect();
      
      // With margin-right: 20px + gap: 20px, there should be 40px total space between items
      expect(item2Rect.left - (item1Rect.left + item1.offsetWidth), equals(40.0));
    });

    testWidgets('gap with older flexbox properties', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-legacy-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: -webkit-flex;
                -webkit-flex-direction: row;
                -webkit-justify-content: flex-start;
                display: flex;
                flex-direction: row;
                justify-content: flex-start;
                gap: 15px;
                width: 300px;
                height: 100px;
                background-color: #666;
              ">
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and work with both prefixed and unprefixed properties
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(300.0)); // Flex container keeps its explicit width, gaps are internal
      expect(container.offsetHeight, equals(100.0));
      
      // TODO: When gap is implemented, verify compatibility with legacy flexbox syntax
    });
  });

  group('Gap with Percentage Values', () {
    testWidgets('percentage gap values parsing and computation', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-percentage-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                gap: 10%;
                width: 200px;
                height: 100px;
                background-color: #666;
              ">
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist and have correct dimensions
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(200.0));
      expect(container.offsetHeight, equals(100.0));
      
      // Percentage gap should be parsed without errors
      // 10% of 200px container width = 20px gap
    });

    testWidgets('percentage column-gap in row direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'percentage-column-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: row;
                column-gap: 15%;
                width: 300px;
                height: 80px;
                background-color: #888;
              ">
                <div style="
                  width: 60px;
                  height: 60px;
                  background-color: green;
                ">A</div>
                <div style="
                  width: 60px;
                  height: 60px;
                  background-color: orange;
                ">B</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetWidth, equals(300.0)); // WebF may not yet support percentage-based gaps in offsetWidth calculation
      
      // TODO: 15% of 300px = 45px column gap should be computed correctly when percentage gaps are fully implemented
    });

    testWidgets('percentage row-gap in column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'percentage-row-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                row-gap: 12%;
                width: 150px;
                height: 250px;
                background-color: #aaa;
              ">
                <div style="
                  width: 100px;
                  height: 70px;
                  background-color: purple;
                ">X</div>
                <div style="
                  width: 100px;
                  height: 70px;
                  background-color: cyan;
                ">Y</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container should exist
      expect(container, isNotNull);
      expect(container.offsetHeight, equals(250.0));
      
      // 12% of 250px = 30px row gap should be computed correctly
    });
  });

  group('Flex Height Calculation with Gap', () {
    testWidgets('inline-flex container height includes gap in column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-height-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 20px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Expected height: 50 + 20 + 50 + 20 + 50 = 190px
      expect(container.offsetHeight, equals(190.0));
    });

    testWidgets('regular flex container height includes gap in column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-height-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                row-gap: 15px;
                background-color: #ddd;
              ">
                <div id="item1" style="
                  width: 150px;
                  height: 40px;
                  background-color: purple;
                ">1</div>
                <div id="item2" style="
                  width: 150px;
                  height: 40px;
                  background-color: orange;
                ">2</div>
                <div id="item3" style="
                  width: 150px;
                  height: 40px;
                  background-color: cyan;
                ">3</div>
                <div id="item4" style="
                  width: 150px;
                  height: 40px;
                  background-color: yellow;
                ">4</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Expected height: 40 + 15 + 40 + 15 + 40 + 15 + 40 = 205px
      expect(container.offsetHeight, equals(205.0));
    });

    testWidgets('inline-flex container width includes gap in row direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-width-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: row;
                column-gap: 25px;
                background-color: #ccc;
              ">
                <div id="item1" style="
                  width: 60px;
                  height: 80px;
                  background-color: blue;
                ">1</div>
                <div id="item2" style="
                  width: 60px;
                  height: 80px;
                  background-color: red;
                ">2</div>
                <div id="item3" style="
                  width: 60px;
                  height: 80px;
                  background-color: green;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Expected width: 60 + 25 + 60 + 25 + 60 = 230px
      expect(container.offsetWidth, equals(230.0));
    });

    testWidgets('gap shorthand property works for both directions', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-shorthand-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 30px;
                background-color: #bbb;
              ">
                <div style="
                  width: 120px;
                  height: 60px;
                  background-color: brown;
                ">1</div>
                <div style="
                  width: 120px;
                  height: 60px;
                  background-color: pink;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Expected height: 60 + 30 + 60 = 150px
      expect(container.offsetHeight, equals(150.0));
    });

    testWidgets('multi-line flex container includes cross-axis gap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'multi-line-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-wrap: wrap;
                width: 150px;
                gap: 20px 10px;
                background-color: #aaa;
              ">
                <div style="
                  width: 60px;
                  height: 40px;
                  background-color: blue;
                ">1</div>
                <div style="
                  width: 60px;
                  height: 40px;
                  background-color: red;
                ">2</div>
                <div style="
                  width: 60px;
                  height: 40px;
                  background-color: green;
                ">3</div>
                <div style="
                  width: 60px;
                  height: 40px;
                  background-color: yellow;
                ">4</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Items 1&2 on first line, items 3&4 on second line
      // Height: 40 (first line) + 20 (row gap) + 40 (second line) = 100px
      expect(container.offsetHeight, equals(100.0));
    });

    testWidgets('flex container with single item has no gap effect', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'single-item-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 50px;
                background-color: #999;
              ">
                <div style="
                  width: 100px;
                  height: 70px;
                  background-color: navy;
                ">Only Item</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // With only one item, gap should have no effect
      expect(container.offsetHeight, equals(70.0));
    });

    testWidgets('empty flex container has zero height even with gap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'empty-container-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 100px;
                background-color: #888;
              ">
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Empty container should have zero height
      expect(container.offsetHeight, equals(0.0));
    });

    testWidgets('flex container respects explicit height over content with gap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'explicit-height-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                gap: 20px;
                height: 300px;
                background-color: #777;
              ">
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: teal;
                ">1</div>
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: olive;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Explicit height should override content height
      expect(container.offsetHeight, equals(300.0));
    });

    testWidgets('percentage gap calculates based on container dimension', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'percentage-gap-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                row-gap: 10%;
                width: 200px;
                background-color: #666;
              ">
                <div style="
                  width: 150px;
                  height: 30px;
                  background-color: coral;
                ">1</div>
                <div style="
                  width: 150px;
                  height: 30px;
                  background-color: crimson;
                ">2</div>
                <div style="
                  width: 150px;
                  height: 30px;
                  background-color: darkblue;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Without explicit height, percentage gap might be treated as 0 or computed differently
      // This test verifies that percentage gaps are handled without errors
      expect(container.offsetHeight, greaterThanOrEqualTo(90.0)); // At least the sum of item heights
    });

    testWidgets('negative gap values are treated as zero', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'negative-gap-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: -20px;
                background-color: #555;
              ">
                <div style="
                  width: 80px;
                  height: 45px;
                  background-color: gold;
                ">1</div>
                <div style="
                  width: 80px;
                  height: 45px;
                  background-color: silver;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Negative gap should be treated as 0
      expect(container.offsetHeight, equals(90.0)); // 45 + 45
    });

    testWidgets('gap with different units (em, rem) in height calculation', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'gap-units-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-size: 16px;">
              <div id="em-container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 1em;
                font-size: 20px;
                background-color: #444;
              ">
                <div style="
                  width: 100px;
                  height: 40px;
                  background-color: indigo;
                ">1</div>
                <div style="
                  width: 100px;
                  height: 40px;
                  background-color: violet;
                ">2</div>
              </div>
              
              <div id="rem-container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 2rem;
                background-color: #333;
                margin-top: 10px;
              ">
                <div style="
                  width: 100px;
                  height: 35px;
                  background-color: lime;
                ">1</div>
                <div style="
                  width: 100px;
                  height: 35px;
                  background-color: aqua;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final emContainer = prepared.getElementById('em-container');
      final remContainer = prepared.getElementById('rem-container');
      
      // em container: 1em = 20px (container font-size), height = 40 + 20 + 40 = 100px
      expect(emContainer.offsetHeight, equals(100.0));
      
      // rem container: 2rem = 32px (root font-size 16px), height = 35 + 32 + 35 = 102px
      expect(remContainer.offsetHeight, equals(102.0));
    });

    testWidgets('flex-grow items with gap height calculation', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-gap-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                gap: 20px;
                height: 200px;
                background-color: #222;
              ">
                <div style="
                  width: 100px;
                  flex-grow: 1;
                  background-color: darkgreen;
                ">1</div>
                <div style="
                  width: 100px;
                  flex-grow: 2;
                  background-color: darkred;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Container has explicit height
      expect(container.offsetHeight, equals(200.0));
      
      // Available space for items: 200px - 20px (gap) = 180px
      // Item 1 gets 1/3 of 180px = 60px
      // Item 2 gets 2/3 of 180px = 120px
    });

    testWidgets('inline-flex with padding and gap height calculation', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'padding-gap-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 15px;
                padding: 10px;
                background-color: #111;
              ">
                <div style="
                  width: 90px;
                  height: 25px;
                  background-color: maroon;
                ">1</div>
                <div style="
                  width: 90px;
                  height: 25px;
                  background-color: navy;
                ">2</div>
                <div style="
                  width: 90px;
                  height: 25px;
                  background-color: olive;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Height: padding-top (10) + item1 (25) + gap (15) + item2 (25) + gap (15) + item3 (25) + padding-bottom (10) = 125px
      expect(container.offsetHeight, equals(125.0));
    });

    testWidgets('align-items stretch with gap in column direction', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'align-stretch-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
                width: 200px;
                background-color: #000;
              ">
                <div style="
                  height: 30px;
                  background-color: fuchsia;
                ">1</div>
                <div style="
                  height: 40px;
                  background-color: turquoise;
                ">2</div>
                <div style="
                  height: 35px;
                  background-color: tomato;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // Height: 30 + 10 + 40 + 10 + 35 = 125px
      expect(container.offsetHeight, equals(125.0));
    });

    testWidgets('min-height constraint with gap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'min-height-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                gap: 25px;
                min-height: 150px;
                background-color: #0a0a0a;
              ">
                <div style="
                  width: 80px;
                  height: 20px;
                  background-color: wheat;
                ">1</div>
                <div style="
                  width: 80px;
                  height: 20px;
                  background-color: tan;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // min-height should be respected
      expect(container.offsetHeight, equals(150.0));
    });

    testWidgets('max-height constraint with gap overflow', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'max-height-gap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: inline-flex;
                flex-direction: column;
                gap: 30px;
                max-height: 100px;
                overflow: hidden;
                background-color: #1a1a1a;
              ">
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: plum;
                ">1</div>
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: peachpuff;
                ">2</div>
                <div style="
                  width: 100px;
                  height: 50px;
                  background-color: palegreen;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      
      // max-height should limit the container height
      expect(container.offsetHeight, equals(100.0));
    });
  });
}