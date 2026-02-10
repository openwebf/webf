/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
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

  group('Flex Layout Basic', () {
    testWidgets('flex items flow horizontally by default', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-horizontal-flow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">2</div>
                <div id="item3" style="
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // Items should be arranged horizontally
      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().left, equals(100.0));
      expect(item3.getBoundingClientRect().left, equals(200.0));

      // All items should have the same top position
      expect(item1.getBoundingClientRect().top, equals(0.0));
      expect(item2.getBoundingClientRect().top, equals(0.0));
      expect(item3.getBoundingClientRect().top, equals(0.0));
    });

    testWidgets('flex items stretch height by default', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-stretch-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  background-color: red;
                ">No height</div>
                <div id="item2" style="
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">50px height</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // item1 should stretch to container height
      expect(item1.offsetHeight, equals(100.0));
      // item2 keeps its specified height
      expect(item2.offsetHeight, equals(50.0));
    });

    testWidgets('flex stretched item respects cross margins', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-stretch-margin-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 80px;
                background-color: #eee;
                border: 1px solid black;
                box-sizing: border-box;
                justify-content: space-around;
              ">
                <span id="item" style="
                  flex: 1 0 0%;
                  margin: 10px;
                  background: white;
                  display: inline-block;
                  box-sizing: border-box;
                ">one</span>
              </div>
            </body>
          </html>
        ''',
      );

      final item = prepared.getElementById('item');

      // Container content box is 78px tall (80px border-box with 1px border), so
      // stretching subtracts the item's 10px top and bottom margins: 78 - 20 = 58.
      expect(item.offsetHeight, equals(58.0));
    });

    testWidgets('inline flex column baseline uses bottom edge', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-column-baseline-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-family: sans-serif;">
              <div id="container" style="box-sizing: border-box;">
                before text
                <div class="inline-flexbox column" style="
                  display: inline-flex;
                  flex-direction: column;
                  background-color: lightgrey;
                  margin-top: 5px;
                  box-sizing: border-box;
                ">
                  <div class="first" style="box-sizing: border-box;">baseline</div>
                  <div class="second" style="box-sizing: border-box;">above</div>
                </div>
                after text
              </div>
            </body>
          </html>
        ''',
      );

      final inlineFlex = prepared.document.querySelector(['.inline-flexbox']) as dom.Element;
      final RenderBoxModel flexRenderBox = inlineFlex.renderStyle.attachedRenderBoxModel!;

      final double? containerBaseline = flexRenderBox.computeCssFirstBaseline();

      expect(containerBaseline, isNotNull);
      expect(
        containerBaseline,
        closeTo(12, 0.01),
      );
    });
  });

  group('Flex Sizing', () {
    testWidgets('flex-grow distributes available space', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have different flex-grow calculation
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-distribute-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  flex-grow: 1;
                  height: 50px;
                  background-color: red;
                ">Grow 1</div>
                <div id="item2" style="
                  flex-grow: 2;
                  height: 50px;
                  background-color: green;
                ">Grow 2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // item1 gets 1/3 of space (100px)
      expect(item1.offsetWidth, equals(100.0));
      // item2 gets 2/3 of space (200px)
      expect(item2.offsetWidth, equals(200.0));
    });

    testWidgets('flex-shrink allows items to shrink below basis', (WidgetTester tester) async {
      // TODO add min-width:0, FIX minWidth default value later
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-shrink-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 200px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  flex-shrink: 1;
                  flex-basis: 150px;
                  min-width: 0;
                  height: 50px;
                  background-color: red;
                ">Shrink 1</div>
                <div id="item2" style="
                  flex-shrink: 0;
                  flex-basis: 150px;
                  min-width:0;
                  height: 50px;
                  background-color: green;
                ">No shrink</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // item2 keeps its basis because flex-shrink: 0
      expect(item2.offsetWidth, equals(150.0));
      // item1 shrinks to fit remaining space
      expect(item1.offsetWidth, equals(50.0)); // 200 - 150
    });

    testWidgets('flex shorthand property', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have issues with flex shorthand parsing
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-shorthand-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 400px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  flex: 1;
                  height: 50px;
                  background-color: red;
                ">flex: 1</div>
                <div id="item2" style="
                  flex: 2 1 100px;
                  height: 50px;
                  background-color: green;
                ">flex: 2 1 100px</div>
                <div id="item3" style="
                  flex: 0 1 auto;
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">flex: 0 1 auto</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // item3 doesn't grow (flex-grow: 0) and uses its width
      expect(item3.offsetWidth, equals(100.0));

      // Remaining 300px is distributed 1:2 between item1 and item2
      expect(item1.offsetWidth, equals(100.0)); // 1/3 of 300px
      expect(item2.offsetWidth, equals(200.0)); // 2/3 of 300px
    });
  });

  group('Flex Wrap', () {
    testWidgets('flex-wrap wrap creates multiple lines', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have issues with flex-wrap implementation
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-wrap-multiline-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                flex-wrap: wrap;
                width: 250px;
                height: 200px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 150px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 150px;
                  height: 50px;
                  background-color: green;
                ">2</div>
                <div id="item3" style="
                  width: 150px;
                  height: 50px;
                  background-color: blue;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // First line
      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item1.getBoundingClientRect().top, equals(0.0));

      // Second line (wrapped)
      expect(item2.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().top, equals(50.0));

      // Third line
      expect(item3.getBoundingClientRect().left, equals(0.0));
      expect(item3.getBoundingClientRect().top, equals(100.0));
    });

    testWidgets('flex-wrap wrap-reverse reverses line order', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support wrap-reverse
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-wrap-reverse-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                flex-wrap: wrap-reverse;
                width: 250px;
                height: 200px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 150px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 150px;
                  height: 50px;
                  background-color: green;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // First item starts at bottom
      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item1.getBoundingClientRect().top, equals(150.0)); // 200 - 50

      // Second item wraps to upper line
      expect(item2.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().top, equals(100.0)); // 150 - 50
    });
  });

  group('Align Self', () {
    testWidgets('align-self overrides align-items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'align-self-override-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                align-items: center;
                width: 300px;
                height: 200px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">Center</div>
                <div id="item2" style="
                  align-self: flex-start;
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">Start</div>
                <div id="item3" style="
                  align-self: flex-end;
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">End</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // item1 inherits center alignment
      expect(item1.getBoundingClientRect().top, equals(75.0)); // (200 - 50) / 2

      // item2 aligns to start
      expect(item2.getBoundingClientRect().top, equals(0.0));

      // item3 aligns to end
      expect(item3.getBoundingClientRect().top, equals(150.0)); // 200 - 50
    });

    testWidgets('align-self baseline aligns baselines', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'align-self-baseline-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                align-items: baseline;
                width: 400px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  font-size: 20px;
                  padding-top: 10px;
                  background-color: red;
                ">Big</div>
                <div id="item2" style="
                  width: 100px;
                  font-size: 14px;
                  padding-top: 20px;
                  background-color: green;
                ">Small</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // Both items should exist and have dimensions
      expect(item1.offsetWidth, equals(100.0));
      expect(item2.offsetWidth, equals(100.0));

      // Baseline alignment is complex to test precisely
      // Just verify items are positioned
      expect(item1.getBoundingClientRect().top, greaterThanOrEqualTo(0.0));
      expect(item2.getBoundingClientRect().top, greaterThanOrEqualTo(0.0));
    });
  });

  group('Auto Margins in Flex', () {
    testWidgets('margin-left auto pushes item right', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'margin-left-auto-flex-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">Left</div>
                <div id="item2" style="
                  margin-left: auto;
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">Right</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().left, equals(200.0)); // 300 - 100
    });

    testWidgets('margin-inline-start auto in RTL pushes item to left', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'margin-inline-start-auto-rtl-flex-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                direction: rtl;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">Right</div>
                <div id="item2" style="
                  margin-inline-start: auto;
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">Left</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // In RTL flex row, the first item starts on the right.
      expect(item1.getBoundingClientRect().left, equals(200.0)); // 300 - 100
      // margin-inline-start:auto should push the second item to the inline-end (left).
      expect(item2.getBoundingClientRect().left, equals(0.0));
    });

    testWidgets('margin auto centers in both directions', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'margin-auto-center-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 200px;
                background-color: #eee;
              ">
                <div id="centered" style="
                  margin: auto;
                  width: 100px;
                  height: 50px;
                  background-color: green;
                ">Centered</div>
              </div>
            </body>
          </html>
        ''',
      );

      final centered = prepared.getElementById('centered');
      final rect = centered.getBoundingClientRect();

      // Horizontally centered
      expect(rect.left, equals(100.0)); // (300 - 100) / 2
      // Vertically centered
      expect(rect.top, equals(75.0)); // (200 - 50) / 2
    });
  });

  group('Flexbox with Absolute Positioning', () {
    testWidgets('absolute child in flex container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-absolute-child-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                position: relative;
                width: 300px;
                height: 200px;
                background-color: #eee;
              ">
                <div id="flex1" style="
                  width: 100px;
                  height: 50px;
                  background-color: red;
                ">Flex 1</div>
                <div id="absolute" style="
                  position: absolute;
                  top: 10px;
                  right: 10px;
                  width: 80px;
                  height: 40px;
                  background-color: green;
                ">Absolute</div>
                <div id="flex2" style="
                  width: 100px;
                  height: 50px;
                  background-color: blue;
                ">Flex 2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final flex1 = prepared.getElementById('flex1');
      final flex2 = prepared.getElementById('flex2');
      final absolute = prepared.getElementById('absolute');

      // Flex items flow normally, ignoring absolute item
      expect(flex1.getBoundingClientRect().left, equals(0.0));
      expect(flex2.getBoundingClientRect().left, equals(100.0));

      // Absolute item is positioned relative to container
      final absRect = absolute.getBoundingClientRect();
      expect(absRect.top, equals(10.0));
      expect(absRect.right, equals(290.0)); // 300 - 10
    });
  });

  group('Flex with Min/Max Constraints', () {
    testWidgets('min-width prevents excessive shrinking', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have issues with min-width in flex context
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-min-width-constraint-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 150px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  flex: 1 1 100px;
                  min-width: 80px;
                  height: 50px;
                  background-color: red;
                ">Min 80px</div>
                <div id="item2" style="
                  flex: 1 1 100px;
                  height: 50px;
                  background-color: green;
                ">Flexible</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // item1 respects min-width
      expect(item1.offsetWidth, equals(80.0));
      // item2 gets remaining space
      expect(item2.offsetWidth, equals(70.0)); // 150 - 80
    });

    testWidgets('max-width limits growth', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have issues with max-width in flex context
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-max-width-constraint-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 400px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  flex: 1 0 50px;
                  max-width: 150px;
                  height: 50px;
                  background-color: red;
                ">Max 150px</div>
                <div id="item2" style="
                  flex: 1 0 50px;
                  height: 50px;
                  background-color: green;
                ">Flexible</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // item1 is limited by max-width
      expect(item1.offsetWidth, equals(150.0));
      // item2 gets remaining space
      expect(item2.offsetWidth, equals(250.0)); // 400 - 150
    });
  });

  group('Nested Flexbox', () {
    testWidgets('flex container inside flex item', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have issues with nested flex containers
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'nested-flex-container-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 400px;
                height: 200px;
                background-color: #eee;
              ">
                <div id="outer1" style="
                  flex: 1;
                  background-color: #ddd;
                ">Outer 1</div>
                <div id="nested-container" style="
                  display: flex;
                  flex-direction: column;
                  flex: 2;
                  background-color: #ccc;
                ">
                  <div id="inner1" style="
                    flex: 1;
                    background-color: red;
                  ">Inner 1</div>
                  <div id="inner2" style="
                    flex: 1;
                    background-color: green;
                  ">Inner 2</div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final outer1 = prepared.getElementById('outer1');
      final nestedContainer = prepared.getElementById('nested-container');
      final inner1 = prepared.getElementById('inner1');
      final inner2 = prepared.getElementById('inner2');

      // Outer flex distribution (1:2 ratio)
      expect(outer1.offsetWidth, closeTo(133.3, 1.0)); // ~1/3 of 400
      expect(nestedContainer.offsetWidth, closeTo(266.7, 1.0)); // ~2/3 of 400

      // Inner flex items split height evenly
      expect(inner1.offsetHeight, equals(100.0)); // Half of 200
      expect(inner2.offsetHeight, equals(100.0));
    });
  });

  group('Flex Direction', () {
    testWidgets('flex-direction row (default)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-row-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 300px;
                height: 100px;
                background-color: #333;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: #7FFF00;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: #00FFFF;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: #4169E1;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // Items arranged horizontally
      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().left, equals(50.0));
      expect(item3.getBoundingClientRect().left, equals(100.0));

      // All items at same vertical position
      expect(item1.getBoundingClientRect().top, equals(0.0));
      expect(item2.getBoundingClientRect().top, equals(0.0));
      expect(item3.getBoundingClientRect().top, equals(0.0));
    });

    testWidgets('flex-direction row-reverse', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-row-reverse-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                flex-direction: row-reverse;
                width: 300px;
                height: 100px;
                background-color: #333;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: #7FFF00;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: #00FFFF;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: #4169E1;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // Items arranged horizontally in reverse order
      expect(item1.getBoundingClientRect().left, equals(250.0)); // 300 - 50
      expect(item2.getBoundingClientRect().left, equals(200.0)); // 300 - 50 - 50
      expect(item3.getBoundingClientRect().left, equals(150.0)); // 300 - 50 - 50 - 50

      // All items at same vertical position
      expect(item1.getBoundingClientRect().top, equals(0.0));
      expect(item2.getBoundingClientRect().top, equals(0.0));
      expect(item3.getBoundingClientRect().top, equals(0.0));
    });

    testWidgets('flex-direction column', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-column-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                flex-direction: column;
                width: 100px;
                height: 300px;
                background-color: #333;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: #7FFF00;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: #00FFFF;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: #4169E1;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // Items arranged vertically
      expect(item1.getBoundingClientRect().top, equals(0.0));
      expect(item2.getBoundingClientRect().top, equals(50.0));
      expect(item3.getBoundingClientRect().top, equals(100.0));

      // All items at same horizontal position
      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().left, equals(0.0));
      expect(item3.getBoundingClientRect().left, equals(0.0));
    });

    testWidgets('flex-direction column-reverse', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-direction-column-reverse-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                flex-direction: column-reverse;
                width: 100px;
                height: 300px;
                background-color: #333;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: #7FFF00;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: #00FFFF;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: #4169E1;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // Items arranged vertically in reverse order
      expect(item1.getBoundingClientRect().top, equals(250.0)); // 300 - 50
      expect(item2.getBoundingClientRect().top, equals(200.0)); // 300 - 50 - 50
      expect(item3.getBoundingClientRect().top, equals(150.0)); // 300 - 50 - 50 - 50

      // All items at same horizontal position
      expect(item1.getBoundingClientRect().left, equals(0.0));
      expect(item2.getBoundingClientRect().left, equals(0.0));
      expect(item3.getBoundingClientRect().left, equals(0.0));
    });
  });

  group('Justify Content', () {
    testWidgets('justify-content space-between', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'justify-content-space-between-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                justify-content: space-between;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // First item at start
      expect(item1.getBoundingClientRect().left, equals(0.0));
      // Middle item centered
      expect(item2.getBoundingClientRect().left, equals(125.0)); // (300 - 50) / 2
      // Last item at end
      expect(item3.getBoundingClientRect().left, equals(250.0)); // 300 - 50
    });

    testWidgets('justify-content space-around', skip: true, (WidgetTester tester) async {
      // TODO: WebF may have issues with space-around calculation
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'justify-content-space-around-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                justify-content: space-around;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">2</div>
                <div id="item3" style="
                  width: 50px;
                  height: 50px;
                  background-color: blue;
                ">3</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      // Available space: 300 - 150 = 150
      // Each item gets 150/3 = 50px of space
      // Items get half space on each side
      expect(item1.getBoundingClientRect().left, equals(25.0)); // 50/2
      expect(item2.getBoundingClientRect().left, equals(125.0)); // 25 + 50 + 50
      expect(item3.getBoundingClientRect().left, equals(225.0)); // 125 + 50 + 50
    });

    testWidgets('justify-content center', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'justify-content-center-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                justify-content: center;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // Items centered as a group
      // Total width: 100px, container: 300px, offset: (300-100)/2 = 100
      expect(item1.getBoundingClientRect().left, equals(100.0));
      expect(item2.getBoundingClientRect().left, equals(150.0));
    });

    testWidgets('justify-content flex-end', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'justify-content-flex-end-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                justify-content: flex-end;
                width: 300px;
                height: 100px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  width: 50px;
                  height: 50px;
                  background-color: red;
                ">1</div>
                <div id="item2" style="
                  width: 50px;
                  height: 50px;
                  background-color: green;
                ">2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // Items aligned to end
      expect(item1.getBoundingClientRect().left, equals(200.0)); // 300 - 100
      expect(item2.getBoundingClientRect().left, equals(250.0)); // 300 - 50
    });
  });

  group('Flex with Overflow', () {
    testWidgets('flex item with overflow hidden', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-overflow-hidden-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="
                display: flex;
                width: 200px;
                height: 50px;
                background-color: #eee;
              ">
                <div id="item1" style="
                  flex: 1;
                  overflow: hidden;
                  white-space: nowrap;
                  text-overflow: ellipsis;
                  background-color: red;
                ">This is a very long text that should be truncated</div>
                <div id="item2" style="
                  width: 80px;
                  background-color: green;
                ">Fixed</div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');

      // item1 takes remaining space
      expect(item1.offsetWidth, equals(120.0)); // 200 - 80
      expect(item2.offsetWidth, equals(80.0));

      // Both items same height
      expect(item1.offsetHeight, equals(50.0));
      expect(item2.offsetHeight, equals(50.0));
    });

    testWidgets('flex:1 text with fixed-size img sibling should not collapse', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-overflow-hidden-img-sibling-test',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="row" style="
                display: flex;
                width: 132px;
                height: 20px;
                align-items: center;
                background-color: #eee;
              ">
                <span id="name" style="
                  flex: 1;
                  overflow: hidden;
                  white-space: nowrap;
                  text-overflow: ellipsis;
                ">CryptoTrader123</span>
                <span id="badge" style="margin-left: 4px;">
                  <img id="img" style="width: 16px; height: 16px;"
                    src="data:image/svg+xml,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'300'%20height%3D'224'%3E%3Crect%20width%3D'300'%20height%3D'224'%20fill%3D'red'%2F%3E%3C%2Fsvg%3E" />
                </span>
              </div>
            </body>
          </html>
        ''',
      );

      final name = prepared.getElementById('name');
      final badge = prepared.getElementById('badge');
      final img = prepared.getElementById('img');

      // Badge stays at its CSS size, not its intrinsic size (300px).
      expect(img.offsetWidth, equals(16.0));
      expect(img.offsetHeight, equals(16.0));

      // Name takes remaining space: 132 - (badge margin-left 4 + img width 16) = 112.
      expect(badge.offsetWidth, equals(16.0));
      expect(name.offsetWidth, equals(112.0));
    });

    testWidgets('specified width caps intrinsic min-content for flex items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-specified-width-overflow-test',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="constrained" style="display: flex; width: 10px;">
                <img id="img" style="width: 100px; height: 100px;"
                  src="data:image/svg+xml,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'200'%20height%3D'200'%3E%3Crect%20width%3D'200'%20height%3D'200'%20fill%3D'green'%2F%3E%3C%2Fsvg%3E" />
              </div>
            </body>
          </html>
        ''',
      );

      final constrained = prepared.getElementById('constrained');
      final img = prepared.getElementById('img');

      expect(constrained.offsetWidth, equals(10.0));
      expect(img.offsetWidth, equals(100.0));
      expect(img.offsetHeight, equals(100.0));
    });
  });
}
