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

  group('Flow Layout', () {
    testWidgets('block element should have correct dimensions with padding and border', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-1-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="box1" style="
                width: 200px;
                height: 100px;
                padding: 10px;
                border: 5px solid black;
                background: red;
              ">Box with padding and border</div>
            </body>
          </html>
        ''',
      );

      final box1 = prepared.getElementById('box1');

      // With default border-box sizing:
      // Total width = 200px (includes padding and border)
      // Total height = 100px (includes padding and border)
      expect(box1.offsetWidth, greaterThan(0), reason: 'Width should not be zero');
      expect(box1.offsetHeight, greaterThan(0), reason: 'Height should not be zero');
      expect(box1.offsetWidth, equals(200.0), reason: 'Width should be 200px with border-box');
      expect(box1.offsetHeight, equals(100.0), reason: 'Height should be 100px with border-box');
    });

    testWidgets('block element with explicit content-box sizing behaves as border-box', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-2-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="content-box" style="
                box-sizing: content-box;
                width: 200px;
                height: 100px;
                padding: 10px;
                border: 5px solid black;
                background: blue;
              ">Content box sizing</div>
            </body>
          </html>
        ''',
      );

      final contentBox = prepared.getElementById('content-box');

      // Note: WebF currently treats content-box as border-box
      // So the total width/height is still 200px/100px
      expect(contentBox.offsetWidth, greaterThan(0), reason: 'Width should not be zero');
      expect(contentBox.offsetHeight, greaterThan(0), reason: 'Height should not be zero');
      expect(contentBox.offsetWidth, equals(200.0), reason: 'Width is 200px (WebF treats content-box as border-box)');
      expect(contentBox.offsetHeight, equals(100.0), reason: 'Height is 100px (WebF treats content-box as border-box)');
    });

    testWidgets('auto height computation for block elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-3-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="auto-height" style="
                width: 300px;
                background: green;
                padding: 10px;
              ">
                <div id="child1" style="height: 50px; background: yellow;">Child 1</div>
                <div id="child2" style="height: 75px; background: orange;">Child 2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final autoHeight = prepared.getElementById('auto-height');
      final child1 = prepared.getElementById('child1');
      final child2 = prepared.getElementById('child2');

      // Verify measurements are available
      expect(autoHeight.offsetHeight, greaterThan(0), reason: 'Auto height should not be zero');
      expect(child1.offsetHeight, greaterThan(0), reason: 'Child1 height should not be zero');
      expect(child2.offsetHeight, greaterThan(0), reason: 'Child2 height should not be zero');

      // With border-box and padding:
      // Content height = 50px + 75px = 125px
      // Total height = 125px + 20px padding = 145px
      expect(autoHeight.offsetHeight, equals(145.0), reason: 'Auto height should fit children plus padding');
      expect(child1.offsetHeight, equals(50.0), reason: 'Child 1 should be 50px');
      expect(child2.offsetHeight, equals(75.0), reason: 'Child 2 should be 75px');
    });

    testWidgets('margin collapse between siblings', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-4-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="background: #f0f0f0;">
                <div id="box1" style="
                  height: 50px;
                  margin-bottom: 30px;
                  background: red;
                ">Box 1</div>
                <div id="box2" style="
                  height: 50px;
                  margin-top: 20px;
                  background: blue;
                ">Box 2</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final box1 = prepared.getElementById('box1');
      final box2 = prepared.getElementById('box2');

      // Get positions
      final box1Rect = box1.getBoundingClientRect();
      final box2Rect = box2.getBoundingClientRect();

      // Verify measurements are available
      expect(box1Rect.height, greaterThan(0), reason: 'Box1 height should not be zero');
      expect(box2Rect.height, greaterThan(0), reason: 'Box2 height should not be zero');

      // Check individual box heights
      expect(box1Rect.height, equals(50.0), reason: 'Box 1 should be 50px tall');
      expect(box2Rect.height, equals(50.0), reason: 'Box 2 should be 50px tall');

      // Margin collapse: larger margin (30px) wins
      final gap = box2Rect.top - box1Rect.bottom;
      expect(gap, equals(30.0), reason: 'Margins should collapse to 30px (not 50px)');

      // Container height should be: 50px + 30px + 50px = 130px
      expect(container.offsetHeight, equals(130.0), reason: 'Container height should account for margin collapse');
    });

    testWidgets('percentage width relative to parent', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-5-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="parent" style="width: 400px; background: gray;">
                <div id="child50" style="width: 50%; height: 30px; background: red;">50% width</div>
                <div id="child75" style="width: 75%; height: 30px; background: blue;">75% width</div>
                <div id="childAuto" style="height: 30px; background: green;">Auto width</div>
              </div>
            </body>
          </html>
        ''',
      );

      final parent = prepared.getElementById('parent');
      final child50 = prepared.getElementById('child50');
      final child75 = prepared.getElementById('child75');
      final childAuto = prepared.getElementById('childAuto');

      // Verify measurements are available
      expect(parent.offsetWidth, greaterThan(0), reason: 'Parent width should not be zero');
      expect(child50.offsetWidth, greaterThan(0), reason: 'Child50 width should not be zero');
      expect(child75.offsetWidth, greaterThan(0), reason: 'Child75 width should not be zero');
      expect(childAuto.offsetWidth, greaterThan(0), reason: 'ChildAuto width should not be zero');

      // Check dimensions
      expect(parent.offsetWidth, equals(400.0), reason: 'Parent should be 400px wide');
      expect(child50.offsetWidth, equals(200.0), reason: '50% of 400px = 200px');
      expect(child75.offsetWidth, equals(300.0), reason: '75% of 400px = 300px');
      expect(childAuto.offsetWidth, equals(400.0), reason: 'Auto width should fill parent');
    });

    testWidgets('nested block elements with various dimensions', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-6-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="outer" style="width: 500px; padding: 20px; background: #ccc;">
                <div id="middle" style="width: 80%; padding: 15px; background: #999;">
                  <div id="inner" style="width: 50%; height: 100px; background: #666;">
                    Inner content
                  </div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final outer = prepared.getElementById('outer');
      final middle = prepared.getElementById('middle');
      final inner = prepared.getElementById('inner');

      // Verify measurements are available
      expect(outer.offsetWidth, greaterThan(0), reason: 'Outer width should not be zero');
      expect(middle.offsetWidth, greaterThan(0), reason: 'Middle width should not be zero');
      expect(inner.offsetWidth, greaterThan(0), reason: 'Inner width should not be zero');

      // Outer: 500px (border-box includes padding)
      expect(outer.offsetWidth, equals(500.0), reason: 'Outer should be 500px with border-box');

      // Middle: 80% of outer's content width
      // Outer content width = 500px - 40px padding = 460px
      // Middle width = 80% of 460px = 368px (border-box includes its padding)
      expect(middle.offsetWidth, equals(368.0), reason: 'Middle should be 80% of outer content');

      // Inner: 50% of middle's content width
      // Middle content width = 368px - 30px padding = 338px
      // Inner width = 50% of 338px = 169px
      expect(inner.offsetWidth, equals(169.0), reason: 'Inner should be 50% of middle content');
      expect(inner.offsetHeight, equals(100.0), reason: 'Inner height should be 100px');
    });

    testWidgets('inline-block elements layout', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-7-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-size: 16px;">
              <div id="container" style="width: 400px; background: #f0f0f0; line-height: 1;">
                <span id="inline1" style="
                  display: inline-block;
                  width: 100px;
                  height: 50px;
                  background: red;
                  vertical-align: top;
                ">Inline 1</span>
                <span id="inline2" style="
                  display: inline-block;
                  width: 150px;
                  height: 50px;
                  background: blue;
                  vertical-align: top;
                ">Inline 2</span>
                <span id="inline3" style="
                  display: inline-block;
                  width: 100px;
                  height: 50px;
                  background: green;
                  vertical-align: top;
                ">Inline 3</span>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final inline1 = prepared.getElementById('inline1');
      final inline2 = prepared.getElementById('inline2');
      final inline3 = prepared.getElementById('inline3');

      // Verify measurements are available
      expect(inline1.offsetWidth, greaterThan(0), reason: 'Inline1 width should not be zero');
      expect(inline2.offsetWidth, greaterThan(0), reason: 'Inline2 width should not be zero');
      expect(inline3.offsetWidth, greaterThan(0), reason: 'Inline3 width should not be zero');

      // Check inline-block dimensions
      expect(inline1.offsetWidth, equals(100.0), reason: 'Inline-block 1 should be 100px wide');
      expect(inline2.offsetWidth, equals(150.0), reason: 'Inline-block 2 should be 150px wide');
      expect(inline3.offsetWidth, equals(100.0), reason: 'Inline-block 3 should be 100px wide');

      // All should have same height
      expect(inline1.offsetHeight, equals(50.0), reason: 'All inline-blocks should be 50px tall');
      expect(inline2.offsetHeight, equals(50.0), reason: 'All inline-blocks should be 50px tall');
      expect(inline3.offsetHeight, equals(50.0), reason: 'All inline-blocks should be 50px tall');

      // Container height may include line-height
      // Due to inline formatting context, the container might be taller than 50px
      expect(container.offsetHeight, greaterThan(0), reason: 'Container height should not be zero');
      expect(container.offsetHeight, lessThanOrEqualTo(70.0), reason: 'Container height should be reasonable');
    });

    testWidgets('negative margins affect layout', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-8-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="background: #f0f0f0; padding: 20px;">
                <div id="box1" style="
                  height: 50px;
                  background: red;
                  margin-bottom: -20px;
                ">Box 1 with negative margin</div>
                <div id="box2" style="
                  height: 50px;
                  background: blue;
                ">Box 2 overlapped</div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final box1 = prepared.getElementById('box1');
      final box2 = prepared.getElementById('box2');

      // Get positions
      final box1Rect = box1.getBoundingClientRect();
      final box2Rect = box2.getBoundingClientRect();

      // Verify measurements are available
      expect(box1Rect.height, greaterThan(0), reason: 'Box1 height should not be zero');
      expect(box2Rect.height, greaterThan(0), reason: 'Box2 height should not be zero');

      // Box2 should overlap box1 by 20px due to negative margin
      final overlap = box1Rect.bottom - box2Rect.top;
      expect(overlap, equals(20.0), reason: 'Boxes should overlap by 20px');

      // Container height with padding and negative margin:
      // 20px (top padding) + 50px + (-20px) + 50px + 20px (bottom padding) = 120px
      expect(container.offsetHeight, equals(120.0), reason: 'Container should account for negative margin');
    });

    testWidgets('block element min and max width constraints', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-9-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="parent" style="width: 600px;">
                <div id="min-width" style="
                  min-width: 200px;
                  width: 10%;
                  height: 50px;
                  background: red;
                ">10% width with min-width</div>
                <div id="max-width" style="
                  max-width: 300px;
                  width: 80%;
                  height: 50px;
                  background: blue;
                ">80% width with max-width</div>
              </div>
            </body>
          </html>
        ''',
      );

      final minWidthEl = prepared.getElementById('min-width');
      final maxWidthEl = prepared.getElementById('max-width');

      // Verify measurements are available
      expect(minWidthEl.offsetWidth, greaterThan(0), reason: 'Min width element width should not be zero');
      expect(maxWidthEl.offsetWidth, greaterThan(0), reason: 'Max width element width should not be zero');

      // 10% of 600px = 60px, but min-width: 200px should win
      expect(minWidthEl.offsetWidth, equals(200.0), reason: 'Min-width should override percentage');

      // 80% of 600px = 480px, but max-width: 300px should win
      expect(maxWidthEl.offsetWidth, equals(300.0), reason: 'Max-width should limit percentage');
    });

    testWidgets('height percentage with explicit parent height', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flow-test-10-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="parent" style="height: 400px; background: gray;">
                <div id="child25" style="height: 25%; background: red;">25% height</div>
                <div id="child50" style="height: 50%; background: blue;">50% height</div>
              </div>
            </body>
          </html>
        ''',
      );

      final parent = prepared.getElementById('parent');
      final child25 = prepared.getElementById('child25');
      final child50 = prepared.getElementById('child50');

      // Verify measurements are available
      expect(parent.offsetHeight, greaterThan(0), reason: 'Parent height should not be zero');
      expect(child25.offsetHeight, greaterThan(0), reason: 'Child25 height should not be zero');
      expect(child50.offsetHeight, greaterThan(0), reason: 'Child50 height should not be zero');

      // Check dimensions
      expect(parent.offsetHeight, equals(400.0), reason: 'Parent should be 400px tall');
      expect(child25.offsetHeight, equals(100.0), reason: '25% of 400px = 100px');
      expect(child50.offsetHeight, equals(200.0), reason: '50% of 400px = 200px');
    });
  });
}