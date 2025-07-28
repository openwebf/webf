/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/rendering/line_box.dart';
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

  // Helper function to get text offset in inline formatting context
  Offset? getTextOffset(dom.Element element) {
    if (element.attachedRenderer == null) return null;

    final renderer = element.attachedRenderer!;
    if (renderer is! RenderFlowLayout) return null;

    // Get the inline formatting context
    final ifc = renderer.inlineFormattingContext;
    if (ifc == null || ifc.lineBoxes.isEmpty) return null;

    // Get the first line box item that contains text
    final firstLineBox = ifc.lineBoxes.first;
    for (final item in firstLineBox.items) {
      if (item is TextLineBoxItem) {
        return item.offset;
      }
    }

    return null;
  }

  // Helper function to get text elements from inline formatting context
  List<TextLineBoxItem> getTextItems(dom.Element element) {
    if (element.attachedRenderer == null) return [];

    final renderer = element.attachedRenderer!;
    if (renderer is! RenderFlowLayout) return [];

    final ifc = renderer.inlineFormattingContext;
    if (ifc == null || ifc.lineBoxes.isEmpty) return [];

    final textItems = <TextLineBoxItem>[];
    for (final lineBox in ifc.lineBoxes) {
      for (final item in lineBox.items) {
        if (item is TextLineBoxItem) {
          textItems.add(item);
        }
      }
    }

    return textItems;
  }

  group('Dynamic Font Size Updates', () {
    testWidgets('should update layout when font-size changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-font-size-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 300px;">
                <span id="text" style="display: inline-block; font-size: 16px;">Dynamic font size test</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      final initialHeight = textElement.offsetHeight;

      // Change font size
      textElement.setInlineStyle('fontSize', '32px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      final newHeight = textElement.offsetHeight;
      expect(newHeight, greaterThan(initialHeight));
    });

    testWidgets('should reflow inline content when font-size changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-inline-font-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 200px;">
                <span id="text1" style="font-size: 16px;">Text 1</span>
                <span id="text2" style="font-size: 16px;">Text 2</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final text2 = prepared.getElementById('text2');
      final initialOffset = getTextOffset(text2.parentElement!);

      // Increase font size of text2
      text2.setInlineStyle('fontSize', '24px');
      text2.style.flushPendingProperties();
      await tester.pump();

      final newOffset = getTextOffset(text2.parentElement!);
      // Font size change should affect layout
      expect(newOffset, isNot(equals(initialOffset)));
    });
  });

  group('Dynamic Text Align Updates', () {
    testWidgets('should update text position when text-align changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-text-align-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 300px; text-align: left;">
                Test Text
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final initialOffset = getTextOffset(container);
      expect(initialOffset?.dx, equals(0.0)); // Left aligned

      // Change to center alignment
      container.setInlineStyle('textAlign', 'center');
      container.style.flushPendingProperties();
      await tester.pump();

      final centerOffset = getTextOffset(container);
      expect(centerOffset?.dx, greaterThan(0.0)); // Centered

      // Change to right alignment
      container.setInlineStyle('textAlign', 'right');
      container.style.flushPendingProperties();
      await tester.pump();

      final rightOffset = getTextOffset(container);
      expect(rightOffset?.dx, greaterThan(centerOffset!.dx)); // Right aligned
    });

    testWidgets('should update nested text alignment', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-nested-align-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="parent" style="width: 300px; text-align: center;">
                <div id="child" style="width: 200px;">
                  Nested Text
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final child = prepared.getElementById('child');
      final initialOffset = getTextOffset(child);

      // Change parent alignment
      final parent = prepared.getElementById('parent');
      parent.setInlineStyle('textAlign', 'left');
      parent.style.flushPendingProperties();
      await tester.pump();

      final newOffset = getTextOffset(child);
      // Text within child should now be left-aligned
      expect(newOffset?.dx, equals(0.0));
    });
  });

  group('Dynamic Line Height Updates', () {
    testWidgets('should update layout when line-height changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-line-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 200px; font-size: 16px; line-height: 1;">
                This is a long text that will wrap to multiple lines in the container
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final initialHeight = container.offsetHeight;

      // Increase line height
      container.setInlineStyle('lineHeight', '2');
      container.style.flushPendingProperties();
      await tester.pump();

      final newHeight = container.offsetHeight;
      expect(newHeight, greaterThan(initialHeight));
    });

    testWidgets('should affect nested inline elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-nested-line-height-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 300px; line-height: 1;">
                <span id="inline1" style="display: inline-block;">Line 1</span>
                <br>
                <span id="inline2" style="display: inline-block;">Line 2</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final initialHeight = container.offsetHeight;

      // Change line height on inline element
      final inline1 = prepared.getElementById('inline1');
      inline1.setInlineStyle('lineHeight', '3');
      inline1.style.flushPendingProperties();
      await tester.pump();

      // Container height should increase due to line height change
      final newHeight = container.offsetHeight;
      expect(newHeight, greaterThan(initialHeight));
    });
  });

  group('Dynamic Letter Spacing Updates', () {
    testWidgets('should update text width when letter-spacing changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-letter-spacing-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 400px;">
                <span id="text" style="display: inline-block; letter-spacing: normal;">Letter spacing test</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      final initialWidth = textElement.offsetWidth;

      // Increase letter spacing
      textElement.setInlineStyle('letterSpacing', '5px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      final newWidth = textElement.offsetWidth;
      expect(newWidth, greaterThan(initialWidth));
    });

    testWidgets('should handle negative letter-spacing', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-negative-spacing-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container">
                <span id="text" style="display: inline-block; letter-spacing: 0;">Condensed text</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');
      final initialWidth = textElement.offsetWidth;

      // Apply negative letter spacing
      textElement.setInlineStyle('letterSpacing', '-2px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      final newWidth = textElement.offsetWidth;
      expect(newWidth, lessThan(initialWidth));
    });
  });

  group('Dynamic Font Weight Updates', () {
    testWidgets('should update text rendering when font-weight changes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-font-weight-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container">
                <span id="text" style="display: inline-block; font-weight: normal;">Font weight test</span>
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
    });

    testWidgets('should handle numeric font-weight values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-numeric-weight-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div>
                <span id="text" style="display: inline-block; font-weight: 400;">Weight test</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');

      // Test light weight
      textElement.setInlineStyle('fontWeight', '100');
      textElement.style.flushPendingProperties();
      await tester.pump();
      expect(textElement.renderStyle.fontWeight, equals(FontWeight.w100));

      // Test heavy weight
      textElement.setInlineStyle('fontWeight', '900');
      textElement.style.flushPendingProperties();
      await tester.pump();
      expect(textElement.renderStyle.fontWeight, equals(FontWeight.w900));
    });
  });
  //
  // group('Dynamic Text Transform Updates', () {
  //   testWidgets('should update text when text-transform changes', (WidgetTester tester) async {
  //     final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
  //       tester: tester,
  //       controllerName: 'dynamic-text-transform-test-${DateTime.now().millisecondsSinceEpoch}',
  //       html: '''
  //         <html>
  //           <body style="margin: 0; padding: 0;">
  //             <div>
  //               <span id="text" style="display: inline-block; text-transform: none;">Hello World</span>
  //             </div>
  //           </body>
  //         </html>
  //       ''',
  //     );
  //
  //     await tester.pump();
  //
  //     final textElement = prepared.getElementById('text');
  //
  //     // Change to uppercase
  //     textElement.setInlineStyle('textTransform', 'uppercase');
  //     textElement.style.flushPendingProperties();
  //     await tester.pump();
  //     expect(textElement.renderStyle.textTransform, equals(TextTransform.uppercase));
  //
  //     // Change to lowercase
  //     textElement.setInlineStyle('textTransform', 'lowercase');
  //     textElement.style.flushPendingProperties();
  //     await tester.pump();
  //     expect(textElement.renderStyle.textTransform, equals(TextTransform.lowercase));
  //
  //     // Change to capitalize
  //     textElement.setInlineStyle('textTransform', 'capitalize');
  //     textElement.style.flushPendingProperties();
  //     await tester.pump();
  //     expect(textElement.renderStyle.textTransform, equals(TextTransform.capitalize));
  //   });
  // });

  group('Dynamic Multiple Property Updates', () {
    testWidgets('should handle multiple simultaneous updates', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-multiple-updates-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 400px;">
                <span id="text" style="display: inline-block; font-size: 16px;">Multiple updates</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final textElement = prepared.getElementById('text');
      final initialHeight = container.offsetHeight;
      final initialWidth = textElement.offsetWidth;

      // Apply multiple style changes at once
      container.setInlineStyle('textAlign', 'center');
      textElement.setInlineStyle('fontSize', '24px');
      textElement.setInlineStyle('lineHeight', '1.5');
      textElement.setInlineStyle('letterSpacing', '2px');

      // Flush all pending properties
      container.style.flushPendingProperties();
      textElement.style.flushPendingProperties();
      await tester.pump();

      // Verify all changes were applied
      expect(container.renderStyle.textAlign, equals(TextAlign.center));
      expect(textElement.renderStyle.fontSize.value, equals(24));
      expect(textElement.renderStyle.lineHeight.value, equals(1.5));
      expect(textElement.renderStyle.letterSpacing?.value, equals(2));

      // Layout should have changed
      expect(container.offsetHeight, greaterThan(initialHeight));
      expect(textElement.offsetWidth, greaterThan(initialWidth));
    });

    testWidgets('should maintain layout consistency with rapid updates', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-rapid-updates-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="width: 300px;">
                <span id="text" style="display: inline-block; font-size: 16px;">Rapid updates test</span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final textElement = prepared.getElementById('text');

      // Perform rapid updates
      textElement.setInlineStyle('fontSize', '20px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      textElement.setInlineStyle('fontSize', '14px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      textElement.setInlineStyle('fontSize', '18px');
      textElement.style.flushPendingProperties();
      await tester.pump();

      // Final state should be consistent
      expect(textElement.renderStyle.fontSize.value, equals(18));
      expect(textElement.offsetHeight, greaterThan(0));
    });
  });

  group('Dynamic Inline Block Updates', () {
    testWidgets('should update inline-block dimensions dynamically', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dynamic-inline-block-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 400px;">
                <span id="inline-block" style="display: inline-block; font-size: 16px; padding: 10px; background: lightblue;">
                  Inline block content
                </span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final inlineBlock = prepared.getElementById('inline-block');
      final initialHeight = inlineBlock.offsetHeight;

      // Change font size
      inlineBlock.setInlineStyle('fontSize', '24px');
      inlineBlock.style.flushPendingProperties();
      await tester.pump();

      final newHeight = inlineBlock.offsetHeight;
      expect(newHeight, greaterThan(initialHeight));
    });
  });
}
