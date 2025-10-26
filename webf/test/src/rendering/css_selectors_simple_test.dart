/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart' as dom;
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

  group('CSS Selectors Basic', () {
    testWidgets('id selector applies style', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'id-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                #test { width: 100px; height: 50px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test">Test</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      expect(div.offsetWidth, equals(100.0));
      expect(div.offsetHeight, equals(50.0));
    });

    testWidgets('class selector applies style', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'class-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .box { width: 200px; height: 100px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="box">Test</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      expect(div.className, equals('box'));
      expect(div.offsetWidth, equals(200.0));
      expect(div.offsetHeight, equals(100.0));
    });

    testWidgets('tag selector applies style', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'tag-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div { padding: 10px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" style="width: 100px; height: 100px;">Test</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      // Check that padding is applied
      expect(div.renderStyle.paddingTop?.computedValue, equals(10.0));
      expect(div.renderStyle.paddingRight?.computedValue, equals(10.0));
      expect(div.renderStyle.paddingBottom?.computedValue, equals(10.0));
      expect(div.renderStyle.paddingLeft?.computedValue, equals(10.0));
    });

    testWidgets('multiple class selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'multi-class-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .box { width: 100px; }
                .large { width: 200px; }
                .tall { height: 150px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test1" class="box">Small box</div>
              <div id="test2" class="box large tall">Large tall box</div>
            </body>
          </html>
        ''',
      );

      final div1 = prepared.getElementById('test1');
      final div2 = prepared.getElementById('test2');

      expect(div1.offsetWidth, equals(100.0));
      // Last class rule wins for width
      expect(div2.offsetWidth, equals(200.0));
      expect(div2.offsetHeight, equals(150.0));
    });

    testWidgets('descendant selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'descendant-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .container span { padding: 5px; display: inline-block; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div class="container">
                <span id="nested" style="width: 50px; height: 50px;">Nested</span>
              </div>
              <span id="outside" style="width: 50px; height: 50px;">Outside</span>
            </body>
          </html>
        ''',
      );

      final nested = prepared.getElementById('nested');
      final outside = prepared.getElementById('outside');

      // Nested span should have padding
      expect(nested.renderStyle.paddingTop?.computedValue, equals(5.0));
      expect(nested.renderStyle.paddingLeft?.computedValue, equals(5.0));

      // Outside span should not have padding
      expect(outside.renderStyle.paddingTop?.computedValue ?? 0, equals(0.0));
      expect(outside.renderStyle.paddingLeft?.computedValue ?? 0, equals(0.0));
    });

    testWidgets('child selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'child-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .parent > span { margin: 10px; display: inline-block; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div class="parent">
                <span id="direct" style="width: 30px; height: 30px;">Direct</span>
                <div>
                  <span id="nested" style="width: 30px; height: 30px;">Nested</span>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final direct = prepared.getElementById('direct');
      final nested = prepared.getElementById('nested');

      // Direct child should have margin
      expect(direct.renderStyle.marginTop?.computedValue, equals(10.0));

      // Nested span should not have margin from the selector
      expect(nested.renderStyle.marginTop?.computedValue ?? 0, equals(0.0));
    });

    testWidgets('attribute selector with exact value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'attribute-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div[data-type="box"] { padding: 15px; }
                div[data-type="panel"] { padding: 20px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="box" data-type="box">Box</div>
              <div id="panel" data-type="panel">Panel</div>
              <div id="plain">Plain</div>
            </body>
          </html>
        ''',
      );

      final box = prepared.getElementById('box');
      final panel = prepared.getElementById('panel');
      final plain = prepared.getElementById('plain');

      expect(box.renderStyle.paddingTop?.computedValue, equals(15.0));
      expect(panel.renderStyle.paddingTop?.computedValue, equals(20.0));
      expect(plain.renderStyle.paddingTop?.computedValue ?? 0, equals(0.0));
    });

    testWidgets('pseudo selector ::before and ::after', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .with-pseudo { width: 100px; height: 50px; }
                .with-pseudo::before { content: 'Before '; }
                .with-pseudo::after { content: ' After'; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="with-pseudo">Content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // The element should have the base dimensions
      expect(div.offsetWidth, equals(100.0));
      expect(div.offsetHeight, equals(50.0));

      // Note: WebF may render pseudo elements but we can't directly access them
      // We just verify the main element is styled correctly
    });

    testWidgets('specificity order', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'specificity-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div { width: 100px; }
                .box { width: 200px; }
                #specific { width: 300px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="specific" class="box">Test</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('specific');

      // ID selector should win (highest specificity)
      expect(div.offsetWidth, equals(300.0));
    });

    testWidgets('dynamic class changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-class-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .small { width: 100px; height: 100px; }
                .large { width: 200px; height: 200px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="small">Test</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Initially small
      expect(div.offsetWidth, equals(100.0));
      expect(div.offsetHeight, equals(100.0));

      // Change to large
      div.className = 'large';
      await tester.pump();

      expect(div.offsetWidth, equals(200.0));
      expect(div.offsetHeight, equals(200.0));
    });
  });
}
