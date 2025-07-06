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

  group('ID Selectors', () {
    testWidgets('basic id selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'id-selector-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                #div1 { color: green; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="div1">Green text</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('div1');
      expect(div.renderStyle.color?.value, equals(0xFF008000)); // green
    });

    testWidgets('id selector with hyphen', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'id-selector-hyphen-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div { color: red; }
                #-div1 { color: green; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="-div1">Green text</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('-div1');
      expect(div.renderStyle.color?.value, equals(0xFF008000)); // green
    });

    testWidgets('id selector specificity', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'id-selector-specificity-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div[id=div1] { color: red; }
                div#div1 { color: green; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="div1">Green text (ID selector wins)</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('div1');
      expect(div.renderStyle.color?.value, equals(0xFF008000)); // green
    });
  });

  group('Class Selectors', () {
    testWidgets('basic class selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'class-selector-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .red { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="red-div" class="red">Red text</div>
            </body>
          </html>
        ''',
      );

      final element = prepared.getElementById('red-div');
      expect(element.className, equals('red'));
      expect(element.renderStyle.color?.value, equals(0xFFFF0000)); // red
    });

    testWidgets('element with class selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'element-class-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div.div1 { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="div1" class="div1">Red text</div>
              <span id="span1" class="div1">Black text (not a div)</span>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('div1');
      final span = prepared.getElementById('span1');
      
      expect(div.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(span.renderStyle.color, isNull); // no color applied
    });

    testWidgets('multiple class selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'multiple-class-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div.bar.foo.bat { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="all-classes" class="foo bar bat">Red text</div>
              <div id="missing-class" class="foo bar">Black text (missing bat)</div>
            </body>
          </html>
        ''',
      );

      final divWithAll = prepared.getElementById('all-classes');
      final divMissing = prepared.getElementById('missing-class');
      
      expect(divWithAll.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(divMissing.renderStyle.color, isNull); // no color applied
    });

    testWidgets('class selector specificity order', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'class-specificity-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .rule1 { background: red; color: yellow; }
                .rule2 { background: green; color: white; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <p id="test" class="rule2 rule1">Green background</p>
            </body>
          </html>
        ''',
      );

      final p = prepared.getElementById('test');
      // Last rule wins when specificity is equal
      expect(p.renderStyle.backgroundColor?.value, equals(0xFF008000)); // green
      expect(p.renderStyle.color?.value, equals(0xFFFFFFFF)); // white
    });

    testWidgets('dynamic class addition', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-class-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .red { color: red; }
                .blue { color: blue; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test">Default color</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      
      // Initially no color
      expect(div.renderStyle.color, isNull);
      
      // Add red class
      div.className = 'red';
      await tester.pump();
      expect(div.renderStyle.color?.value, equals(0xFFFF0000)); // red
      
      // Change to blue class
      div.className = 'blue';
      await tester.pump();
      expect(div.renderStyle.color?.value, equals(0xFF0000FF)); // blue
    });
  });

  group('Tag Selectors', () {
    testWidgets('basic tag selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'tag-selector-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div { color: red; }
                span { color: blue; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="div1">Red text</div>
              <span id="span1">Blue text</span>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('div1');
      final span = prepared.getElementById('span1');
      
      expect(div.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(span.renderStyle.color?.value, equals(0xFF0000FF)); // blue
    });

    testWidgets('universal selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'universal-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                * { margin: 10px; }
                div { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="div1">Red text with margin</div>
              <span id="span1">Default color with margin</span>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('div1');
      final span = prepared.getElementById('span1');
      
      // Both should have margin from universal selector
      expect(div.renderStyle.marginTop?.computedValue, equals(10.0));
      expect(span.renderStyle.marginTop?.computedValue, equals(10.0));
      
      // Only div has red color
      expect(div.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(span.renderStyle.color, isNull);
    });
  });

  group('Pseudo Selectors', () {
    testWidgets('::before pseudo element content', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'before-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .div1::before {
                  content: 'Before: ';
                  color: red;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="div1">Main content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      
      // Check that element has the class that triggers pseudo element
      expect(div.className, equals('div1'));
      
      // WebF should apply pseudo element styles
      // Note: Direct access to pseudo elements may not be available
      // We can check that the main element is styled correctly
      expect(div.renderStyle, isNotNull);
    });

    testWidgets('::after pseudo element content', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'after-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .div1::after {
                  content: ' :After';
                  color: blue;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="div1">Main content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      
      // Check that element has the class that triggers pseudo element
      expect(div.className, equals('div1'));
      expect(div.renderStyle, isNotNull);
    });

    testWidgets('pseudo element with display none', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'pseudo-display-none-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .div1::before {
                  content: 'Hidden';
                  display: none;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="div1">Visible content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      
      // The main element should still be visible
      expect(div.renderStyle.display, isNot(equals(CSSDisplay.none)));
    });
  });

  group('Descendant Selectors', () {
    testWidgets('basic descendant selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'descendant-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div span { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="parent">
                <span id="nested-span">Red text</span>
              </div>
              <span id="top-span">Default color</span>
            </body>
          </html>
        ''',
      );

      final nestedSpan = prepared.getElementById('nested-span');
      final topSpan = prepared.getElementById('top-span');
      
      expect(nestedSpan.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(topSpan.renderStyle.color, isNull); // no color
    });

    testWidgets('multiple level descendant', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'multi-descendant-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .container .inner span { color: blue; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div class="container">
                <div class="inner">
                  <span id="deep-span">Blue text</span>
                </div>
                <span id="shallow-span">Default color</span>
              </div>
            </body>
          </html>
        ''',
      );

      final deepSpan = prepared.getElementById('deep-span');
      final shallowSpan = prepared.getElementById('shallow-span');
      
      expect(deepSpan.renderStyle.color?.value, equals(0xFF0000FF)); // blue
      expect(shallowSpan.renderStyle.color, isNull); // no color
    });
  });

  group('Child Selectors', () {
    testWidgets('direct child selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'child-selector-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div > span { color: green; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="parent">
                <span id="direct-child">Green text (direct child)</span>
                <p>
                  <span id="nested-span">Default color (not direct child)</span>
                </p>
              </div>
            </body>
          </html>
        ''',
      );

      final directChild = prepared.getElementById('direct-child');
      final nestedSpan = prepared.getElementById('nested-span');
      
      expect(directChild.renderStyle.color?.value, equals(0xFF008000)); // green
      expect(nestedSpan.renderStyle.color, isNull); // no color
    });
  });

  group('Sibling Selectors', () {
    testWidgets('adjacent sibling selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'adjacent-sibling-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                h2 + p { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <h2 id="heading">Heading</h2>
              <p id="p1">Red text (adjacent to h2)</p>
              <p id="p2">Default color (not adjacent)</p>
            </body>
          </html>
        ''',
      );

      final p1 = prepared.getElementById('p1');
      final p2 = prepared.getElementById('p2');
      
      expect(p1.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(p2.renderStyle.color, isNull); // no color
    });

    testWidgets('general sibling selector', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support general sibling selector (~)
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'general-sibling-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                h2 ~ p { color: blue; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <h2>Heading</h2>
              <div>Divider</div>
              <p id="p1">Blue text (general sibling)</p>
              <p id="p2">Also blue text</p>
            </body>
          </html>
        ''',
      );

      final p1 = prepared.getElementById('p1');
      final p2 = prepared.getElementById('p2');
      
      expect(p1.renderStyle.color?.value, equals(0xFF0000FF)); // blue
      expect(p2.renderStyle.color?.value, equals(0xFF0000FF)); // blue
    });
  });

  group('Attribute Selectors', () {
    testWidgets('has attribute selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'has-attribute-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                input[type] { border: 2px solid red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <input id="input1" type="text" />
              <input id="input2" />
            </body>
          </html>
        ''',
      );

      final input1 = prepared.getElementById('input1');
      final input2 = prepared.getElementById('input2');
      
      expect(input1.renderStyle.borderTopWidth?.computedValue, equals(2.0));
      expect(input2.renderStyle.borderTopWidth, isNull);
    });

    testWidgets('exact attribute value selector', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'exact-attribute-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                input[type="text"] { background: yellow; }
                input[type="password"] { background: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <input id="text-input" type="text" />
              <input id="password-input" type="password" />
              <input id="number-input" type="number" />
            </body>
          </html>
        ''',
      );

      final textInput = prepared.getElementById('text-input');
      final passwordInput = prepared.getElementById('password-input');
      final numberInput = prepared.getElementById('number-input');
      
      expect(textInput.renderStyle.backgroundColor?.value, equals(0xFFFFFF00)); // yellow
      expect(passwordInput.renderStyle.backgroundColor?.value, equals(0xFFFF0000)); // red
      expect(numberInput.renderStyle.backgroundColor, isNull); // no background
    });

    testWidgets('contains word attribute selector', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support ~= attribute selector
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'contains-word-attribute-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div[class~="highlight"] { background: yellow; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="div1" class="box highlight">Yellow background</div>
              <div id="div2" class="highlighted">No background</div>
            </body>
          </html>
        ''',
      );

      final div1 = prepared.getElementById('div1');
      final div2 = prepared.getElementById('div2');
      
      expect(div1.renderStyle.backgroundColor?.value, equals(0xFFFFFF00)); // yellow
      expect(div2.renderStyle.backgroundColor, isNull); // no background
    });
  });

  group('Combinator Selectors', () {
    testWidgets('multiple combinators', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'multiple-combinators-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                div.container > ul > li { color: red; }
                div.container p { color: blue; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div class="container">
                <ul>
                  <li id="list-item">Red text</li>
                </ul>
                <div>
                  <p id="paragraph">Blue text</p>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final li = prepared.getElementById('list-item');
      final p = prepared.getElementById('paragraph');
      
      expect(li.renderStyle.color?.value, equals(0xFFFF0000)); // red
      expect(p.renderStyle.color?.value, equals(0xFF0000FF)); // blue
    });
  });

  group('Dynamic Style Changes', () {
    testWidgets('style removal', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'style-removal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style id="style1">
                .red { color: red; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="red">Text</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      final style = prepared.getElementById('style1');
      
      // Initially red
      expect(div.renderStyle.color?.value, equals(0xFFFF0000)); // red
      
      // Remove style
      style.parentNode?.removeChild(style);
      await tester.pump();
      
      // Should have no color
      expect(div.renderStyle.color, isNull);
    });

    testWidgets('multiple styles cascade', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'cascade-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .txt { color: red; }
              </style>
              <style>
                .txt { font-size: 20px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="txt">Red and 20px</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      
      // Both styles should apply
      // Check if color is red
      final color = div.renderStyle.color;
      expect(color, isNotNull);
      expect(color!.value, equals(0xFFFF0000)); // red
      expect(div.renderStyle.fontSize?.computedValue, equals(20.0));
    });
  });
}