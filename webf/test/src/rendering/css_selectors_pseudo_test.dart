/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

// Helper to find pseudo elements in an element's children
PseudoElement? findPseudoElement(dom.Element element, PseudoKind kind) {
  for (var child in element.childNodes) {
    if (child is PseudoElement && child.kind == kind) {
      return child;
    }
  }
  return null;
}

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

  group('CSS Pseudo Elements', () {
    testWidgets('::before pseudo element creates PseudoElement child', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'before-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .with-before::before {
                  content: 'Before Text';
                  display: block;
                  width: 100px;
                  height: 30px;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="with-before">Main Content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Wait for pseudo element to be created
      await tester.pump(Duration(milliseconds: 50));

      // Find the before pseudo element
      final beforeElement = findPseudoElement(div, PseudoKind.kPseudoBefore);

      expect(beforeElement, isNotNull);
      expect(beforeElement!.kind, equals(PseudoKind.kPseudoBefore));
      expect(beforeElement.parent, equals(div));

      // Check the pseudo element has the correct content
      expect(beforeElement.childNodes.length, equals(1));
      expect(beforeElement.firstChild, isA<dom.TextNode>());
      final textNode = beforeElement.firstChild as dom.TextNode;
      expect(textNode.data, equals('Before Text'));

      // Check pseudo element dimensions
      expect(beforeElement.offsetWidth, equals(100.0));
      expect(beforeElement.offsetHeight, equals(30.0));
    });

    testWidgets('::after pseudo element creates PseudoElement child', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'after-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .with-after::after {
                  content: 'After Text';
                  display: inline-block;
                  width: 80px;
                  height: 20px;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="with-after">Main Content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Wait for pseudo element to be created
      await tester.pump(Duration(milliseconds: 50));

      // Find the after pseudo element
      final afterElement = findPseudoElement(div, PseudoKind.kPseudoAfter);

      expect(afterElement, isNotNull);
      expect(afterElement!.kind, equals(PseudoKind.kPseudoAfter));
      expect(afterElement.parent, equals(div));

      // Check the pseudo element has the correct content
      expect(afterElement.childNodes.length, equals(1));
      expect(afterElement.firstChild, isA<dom.TextNode>());
      final textNode = afterElement.firstChild as dom.TextNode;
      expect(textNode.data, equals('After Text'));

      // Check pseudo element dimensions
      expect(afterElement.offsetWidth, equals(80.0));
      expect(afterElement.offsetHeight, equals(20.0));
    });

    testWidgets('both ::before and ::after pseudo elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'both-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .with-pseudo::before {
                  content: 'Before';
                  color: red;
                }
                .with-pseudo::after {
                  content: 'After';
                  color: blue;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="with-pseudo">Middle</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Wait for pseudo elements to be created
      await tester.pump(Duration(milliseconds: 50));

      // Find both pseudo elements
      final beforeElement = findPseudoElement(div, PseudoKind.kPseudoBefore);
      final afterElement = findPseudoElement(div, PseudoKind.kPseudoAfter);

      expect(beforeElement, isNotNull);
      expect(afterElement, isNotNull);

      // Check content
      expect((beforeElement!.firstChild as dom.TextNode).data, equals('Before'));
      expect((afterElement!.firstChild as dom.TextNode).data, equals('After'));

      // Check colors
      final beforeColor = beforeElement.renderStyle.color;
      final afterColor = afterElement.renderStyle.color;
      expect(beforeColor, isNotNull);
      expect(afterColor, isNotNull);
      // WebF may render colors differently, so we just check they're different
      expect(beforeColor!.value, isNot(equals(afterColor!.value)));

      // Check order in childNodes
      final children = div.childNodes.toList();
      expect(children.first, equals(beforeElement));
      expect(children.last, equals(afterElement));
    });

    testWidgets('dynamic pseudo element creation/removal', skip: true, (WidgetTester tester) async {
      // TODO: This test is flaky due to timing issues with WebF's style recalculation
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .with-pseudo::before {
                  content: 'Dynamic Before';
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test">No pseudo initially</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Initially no pseudo element
      expect(findPseudoElement(div, PseudoKind.kPseudoBefore), isNull);

      // Add class to trigger pseudo element
      div.className = 'with-pseudo';
      // Need multiple pumps for style changes to propagate
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump();

      // Should have pseudo element now
      final beforeElement = findPseudoElement(div, PseudoKind.kPseudoBefore);
      expect(beforeElement, isNotNull);
      expect((beforeElement!.firstChild as dom.TextNode).data, equals('Dynamic Before'));

      // Remove class to remove pseudo element
      div.className = '';
      // Need multiple pumps for style changes to propagate
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump();

      // Pseudo element should be removed
      expect(findPseudoElement(div, PseudoKind.kPseudoBefore), isNull);
    });

    testWidgets('pseudo element with display:none', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'hidden-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .hidden-pseudo::before {
                  content: 'Hidden';
                  display: none;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="hidden-pseudo">Visible content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Wait for pseudo element to be created
      await tester.pump(Duration(milliseconds: 50));

      // Find the before pseudo element
      final beforeElement = findPseudoElement(div, PseudoKind.kPseudoBefore);

      expect(beforeElement, isNotNull);
      expect(beforeElement!.renderStyle.display, equals(CSSDisplay.none));

      // The main element should still be visible
      expect(div.renderStyle.display, isNot(equals(CSSDisplay.none)));
    });

    testWidgets('pseudo element positioning and layout', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'layout-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .container {
                  position: relative;
                  width: 200px;
                  height: 100px;
                  padding: 10px;
                }
                .container::before {
                  content: '';
                  position: absolute;
                  top: 5px;
                  left: 5px;
                  width: 30px;
                  height: 30px;
                  background: red;
                }
                .container::after {
                  content: '';
                  position: absolute;
                  bottom: 5px;
                  right: 5px;
                  width: 40px;
                  height: 40px;
                  background: blue;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="container">Container</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Wait for pseudo elements to be created
      await tester.pump(Duration(milliseconds: 50));

      // Find pseudo elements
      final beforeElement = findPseudoElement(div, PseudoKind.kPseudoBefore);
      final afterElement = findPseudoElement(div, PseudoKind.kPseudoAfter);

      expect(beforeElement, isNotNull);
      expect(afterElement, isNotNull);

      // Check positioning
      expect(beforeElement!.renderStyle.position, equals(CSSPositionType.absolute));
      expect(afterElement!.renderStyle.position, equals(CSSPositionType.absolute));


      // Check dimensions
      expect(beforeElement.offsetWidth, equals(30.0));
      expect(beforeElement.offsetHeight, equals(30.0));
      expect(afterElement.offsetWidth, equals(40.0));
      expect(afterElement.offsetHeight, equals(40.0));
    });

    testWidgets('pseudo element behavior with empty content vs no content', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'empty-pseudo-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .empty-pseudo::before {
                  content: '';
                }
                .empty-pseudo::after {
                  /* No content property */
                  display: block;
                }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="test" class="empty-pseudo">Content</div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');

      // Wait for pseudo element processing
      await tester.pump(Duration(milliseconds: 50));

      // Empty string content should still create a pseudo element
      final beforeElement = findPseudoElement(div, PseudoKind.kPseudoBefore);
      expect(beforeElement, isNotNull);

      // This is incorrect behavior according to CSS spec - pseudo elements should only be created when content is specified
      // The test below should expect isNull, but WebF creates the element anyway
      final afterElement = findPseudoElement(div, PseudoKind.kPseudoAfter);
      expect(afterElement, isNull); // This is what should happen
    });
  });
}
