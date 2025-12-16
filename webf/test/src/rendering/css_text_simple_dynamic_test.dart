/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
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
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('Simple Dynamic CSS Updates', () {
    testWidgets('should accept font-size changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'simple-font-size-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="text" style="font-size: 16px;">
                Text content
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      expect(textElement.renderStyle.fontSize.computedValue, equals(16.0));

      // Change font size
      textElement.setInlineStyle('fontSize', '24px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      // Verify the style was updated
      expect(textElement.renderStyle.fontSize.computedValue, equals(24.0));
    });

    testWidgets('should accept line-height changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'simple-line-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="text" style="font-size: 16px; line-height: 1;">
                Line height test
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      expect(textElement.renderStyle.lineHeight.computedValue, equals(16.0)); // 1 * 16px

      // Change line height
      textElement.setInlineStyle('lineHeight', '2');
      textElement.style.flushPendingProperties();
      await tester.pump();

      expect(textElement.renderStyle.lineHeight.computedValue, equals(32.0)); // 2 * 16px
    });

    testWidgets('should accept letter-spacing changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'simple-letter-spacing-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="text" style="letter-spacing: normal;">
                Letter spacing test
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      // letterSpacing with 'normal' might be null or 0
      expect(textElement.renderStyle.letterSpacing?.value ?? 0, equals(0));

      // Add letter spacing
      textElement.setInlineStyle('letterSpacing', '2px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      expect(textElement.renderStyle.letterSpacing?.value, equals(2.0));

      // Negative spacing
      textElement.setInlineStyle('letterSpacing', '-1px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      expect(textElement.renderStyle.letterSpacing?.value, equals(-1.0));
    });

    testWidgets('should accept font-weight changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'simple-font-weight-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="text" style="font-weight: normal;">
                Font weight test
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      expect(textElement.renderStyle.fontWeight, equals(FontWeight.w400));

      // Change to bold
      textElement.setInlineStyle('fontWeight', 'bold');
      textElement.style.flushPendingProperties();
      await tester.pump();

      expect(textElement.renderStyle.fontWeight, equals(FontWeight.w700));

      // Numeric weight
      textElement.setInlineStyle('fontWeight', '300');
      textElement.style.flushPendingProperties();
      await tester.pump();

      expect(textElement.renderStyle.fontWeight, equals(FontWeight.w300));
    });

    testWidgets('should accept multiple property changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'simple-multiple-changes-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="text" style="font-size: 16px; line-height: 1; letter-spacing: 0;">
                Multiple properties
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');

      // Change multiple properties
      textElement.setInlineStyle('fontSize', '20px');
      textElement.setInlineStyle('lineHeight', '1.5');
      textElement.setInlineStyle('letterSpacing', '1px');
      textElement.setInlineStyle('fontWeight', 'bold');
      textElement.style.flushPendingProperties();
      await tester.pump();

      // Verify all changes
      expect(textElement.renderStyle.fontSize.computedValue, equals(20.0));
      expect(textElement.renderStyle.lineHeight.computedValue, equals(30.0)); // 1.5 * 20px
      expect(textElement.renderStyle.letterSpacing?.value, equals(1.0));
      expect(textElement.renderStyle.fontWeight, equals(FontWeight.w700));
    });
  });
}
