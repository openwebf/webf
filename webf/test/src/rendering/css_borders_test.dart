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

  group('Border Basic', () {
    testWidgets('border with width and style should render', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border: 25px;
                border-style: solid;
                border-color: #000;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Box</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      // With border-box sizing, total size is 100x100
      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('border shorthand with color, style, width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-shorthand-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border: 5px solid blue;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Box</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('border with zero width should not appear', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-zero-width-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border-width: 0;
                border-style: solid;
                border-color: #000;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">No Border</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      // With zero border, element should still have its specified size
      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('border-width can be changed dynamically', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-width-change-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                width: 200px;
                height: 200px;
                background-color: red;
                position: relative;
                border: 2px solid black;
              ">
                <div style="
                  height: 100px;
                  width: 100px;
                  background-color: yellow;
                ">Inner</div>
              </div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      // Initial state - 2px border (WebF uses border-box by default)
      expect(target.offsetWidth, equals(200.0)); // border-box: width includes border
      expect(target.offsetHeight, equals(200.0));

      // Change border width
      await tester.runAsync(() async {
        target.style.setProperty('border-width', '10px');
      });
      await tester.pump();

      // After change - 10px border
      expect(target.offsetWidth, equals(200.0)); // border-box: width still 200
      expect(target.offsetHeight, equals(200.0));
    });
  });

  group('Border Style', () {
    testWidgets('dashed border style should work', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-dashed-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border: 5px dashed blue;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Dashed</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('dashed border with border-radius', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-dashed-radius-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border: 8px dashed green;
                border-radius: 20px;
                background-color: yellow;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Rounded Dashed</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('different border styles on each side', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-mixed-styles-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border-width: 5px;
                border-top-style: solid;
                border-right-style: dashed;
                border-bottom-style: solid;
                border-left-style: dashed;
                border-color: black;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Mixed</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('different border colors on each side', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-colors-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border-style: solid;
                border-width: 10px;
                border-top-color: red;
                border-right-color: green;
                border-bottom-color: blue;
                border-left-color: purple;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Colorful</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('different border widths on each side', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-widths-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border-style: solid;
                border-top-width: 2px;
                border-right-width: 5px;
                border-bottom-width: 10px;
                border-left-width: 15px;
                border-color: blue;
                height: 100px;
                width: 100px;
                background-color: yellow;
              ">Variable Width</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      // With border-box sizing (WebF default)
      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });
  });

  group('Border Bottom', () {
    testWidgets('border-bottom with only width set', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-bottom-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border-bottom: 100px;
                border-bottom-style: solid;
                height: 100px;
                width: 100px;
                box-sizing: border-box;
              ">Bottom Border</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      // With border-box and 100px bottom border
      expect(target.offsetWidth, equals(100.0));
      expect(target.offsetHeight, equals(100.0));
    });

    testWidgets('individual border sides', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-sides-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="top" style="
                border-top: 5px solid red;
                height: 50px;
                width: 100px;
                margin-bottom: 10px;
              ">Top</div>
              <div id="right" style="
                border-right: 5px solid green;
                height: 50px;
                width: 100px;
                margin-bottom: 10px;
              ">Right</div>
              <div id="bottom" style="
                border-bottom: 5px solid blue;
                height: 50px;
                width: 100px;
                margin-bottom: 10px;
              ">Bottom</div>
              <div id="left" style="
                border-left: 5px solid purple;
                height: 50px;
                width: 100px;
              ">Left</div>
            </body>
          </html>
        ''',
      );

      final top = prepared.getElementById('top');
      final right = prepared.getElementById('right');
      final bottom = prepared.getElementById('bottom');
      final left = prepared.getElementById('left');

      // With border-box sizing (WebF default)
      expect(top.offsetWidth, equals(100.0));
      expect(top.offsetHeight, equals(50.0));

      expect(right.offsetWidth, equals(100.0));
      expect(right.offsetHeight, equals(50.0));

      expect(bottom.offsetWidth, equals(100.0));
      expect(bottom.offsetHeight, equals(50.0));

      expect(left.offsetWidth, equals(100.0));
      expect(left.offsetHeight, equals(50.0));
    });
  });

  group('Border Special Cases', () {
    testWidgets('border on element with zero dimensions', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-zero-dimensions-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="position: relative;">
                <div id="reference" style="
                  position: absolute;
                  background: red;
                  height: 200px;
                  left: 0;
                  top: 0;
                  width: 200px;
                ">Reference</div>
                <div id="target" style="
                  position: relative;
                  border: 100px solid blue;
                  height: 0;
                  width: 0;
                  box-sizing: border-box;
                "></div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final target = prepared.getElementById('target');

      // With border-box and zero content, only border is visible
      expect(target.offsetWidth, equals(200));
      expect(target.offsetHeight, equals(200));
    });

    testWidgets('border with transform', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-transform-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target" style="
                border: 8px dashed green;
                border-radius: 15px;
                background-color: lightyellow;
                height: 80px;
                width: 80px;
                transform: rotate(45deg);
                margin: 40px;
              ">Rotated</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');

      // Transform doesn't affect offsetWidth/Height (WebF uses border-box)
      expect(target.offsetWidth, equals(80.0));
      expect(target.offsetHeight, equals(80.0));
    });

    testWidgets('border with inline display', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-inline-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-size: 16px;">
              <span id="inline1" style="
                border: 2px solid red;
                padding: 5px;
              ">Inline with border</span>
              <span id="inline2" style="
                border: 2px solid blue;
                padding: 5px;
              ">Another inline</span>
            </body>
          </html>
        ''',
      );

      final inline1 = prepared.getElementById('inline1');
      final inline2 = prepared.getElementById('inline2');

      // Inline elements respect borders
      expect(inline1.offsetHeight, greaterThan(0));
      expect(inline2.offsetHeight, greaterThan(0));
    });

    testWidgets('border shorthand with missing values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'border-shorthand-partial-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="target1" style="
                border: solid;
                border-width: 3px;
                border-color: red;
                height: 50px;
                width: 100px;
                margin-bottom: 10px;
              ">Solid only</div>
              <div id="target2" style="
                border: 5px;
                border-style: solid;
                border-color: blue;
                height: 50px;
                width: 100px;
              ">Width only</div>
            </body>
          </html>
        ''',
      );

      final target1 = prepared.getElementById('target1');
      final target2 = prepared.getElementById('target2');

      // First div with solid border (border-box)
      expect(target1.offsetWidth, equals(100.0));
      expect(target1.offsetHeight, equals(50.0));

      // Second div with 5px border (border-box)
      expect(target2.offsetWidth, equals(100.0));
      expect(target2.offsetHeight, equals(50.0));
    });
  });
}
