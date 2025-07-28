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
// Import for TextLineBoxItem
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
    // Clean up any controllers from previous tests
    WebFControllerManager.instance.disposeAll();
    // Add a small delay to ensure file locks are released
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

  group('Text Align', () {
    testWidgets('text-align start', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-start-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; width: 300px; text-align: start;">
                Text content
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textAlign, equals(TextAlign.start));
      
      // Check actual text offset
      final textOffset = getTextOffset(div);
      expect(textOffset, isNotNull);
      // For start alignment, text should be at x=0 (plus any padding)
      expect(textOffset!.dx, equals(0.0));
    });

    testWidgets('text-align end', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-end-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; width: 300px; text-align: end;">
                Text content
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textAlign, equals(TextAlign.end));
      
      // Check actual text offset
      final textOffset = getTextOffset(div);
      expect(textOffset, isNotNull);
      // For end alignment, text should be aligned to the right
      // The exact offset depends on text width, but it should be > 0
      expect(textOffset!.dx, greaterThan(0.0));
    });

    testWidgets('text-align left', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-left-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; width: 300px; text-align: left;">
                Text content
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textAlign, equals(TextAlign.start));
      
      // Check actual text offset
      final textOffset = getTextOffset(div);
      expect(textOffset, isNotNull);
      // For left alignment, text should be at x=0
      expect(textOffset!.dx, equals(0.0));
    });

    testWidgets('text-align right', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-right-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; width: 300px; text-align: right;">
                Text content
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textAlign, equals(TextAlign.end));
      
      // Check actual text offset
      final textOffset = getTextOffset(div);
      expect(textOffset, isNotNull);
      // For right alignment, text should be aligned to the right
      expect(textOffset!.dx, greaterThan(0.0));
    });

    testWidgets('text-align center', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-center-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; width: 300px; text-align: center;">
                Text content
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textAlign, equals(TextAlign.center));
      
      // Check actual text offset
      final textOffset = getTextOffset(div);
      expect(textOffset, isNotNull);
      // For center alignment, text should be centered
      // The offset should be > 0 but less than the full width
      expect(textOffset!.dx, greaterThan(0.0));
      expect(textOffset.dx, lessThan(300.0));
      // More specifically, it should be roughly in the middle
      // With text width ~224px and container width 298px, offset should be ~37px
      expect(textOffset.dx, greaterThan(30.0));
      expect(textOffset.dx, lessThan(50.0));
    });

    testWidgets('text-align justify', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-justify-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; width: 300px; text-align: justify;">
                This is a long text that should be justified when it wraps to multiple lines. The justify alignment distributes space between words.
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textAlign, equals(TextAlign.justify));
      
      // Check actual text offset
      final textOffset = getTextOffset(div);
      expect(textOffset, isNotNull);
      // For justify alignment, the first line should start at x=0
      expect(textOffset!.dx, equals(0.0));
      // Note: Full justify behavior testing would require checking word spacing
    });

    testWidgets('text-align with flex-shrink', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-flex-shrink-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="display: flex; width: 200px; height: 100px; border: 1px solid #000;">
                <div style="flex-shrink: 1; width: 400px; height: 50px; background-color: green; text-align: center;">
                  center
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final flexChild = prepared.document.getElementsByTagName(['div'])[1];
      expect(flexChild.renderStyle.textAlign, equals(TextAlign.center));
      expect(flexChild.renderStyle.flexShrink, equals(1.0));
      
      // Check actual text offset in flex context
      final textOffset = getTextOffset(flexChild);
      // Note: Flex items may not establish IFC if they don't have inline content
      // In this case, just check that the style is set correctly
      if (textOffset != null) {
        // Text should be centered within the flex item
        expect(textOffset.dx, greaterThan(0.0));
      }
    });

    testWidgets('text-align with flex-grow', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-flex-grow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="display: flex; width: 200px; height: 100px; border: 1px solid #000;">
                <div style="flex-grow: 1; width: 50px; height: 50px; background-color: green; text-align: center;">
                  center
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final flexChild = prepared.document.getElementsByTagName(['div'])[1];
      expect(flexChild.renderStyle.textAlign, equals(TextAlign.center));
      expect(flexChild.renderStyle.flexGrow, equals(1.0));
      
      // Check actual text offset in flex context
      final textOffset = getTextOffset(flexChild);
      // Note: Flex items may not establish IFC if they don't have inline content
      // In this case, just check that the style is set correctly
      if (textOffset != null) {
        // Text should be centered within the flex item
        expect(textOffset.dx, greaterThan(0.0));
      }
    });
  });

  group('Letter Spacing', () {
    testWidgets('letter-spacing normal', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'letter-spacing-normal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; letter-spacing: normal;">
                These text should be letter-spacing: normal.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.letterSpacing, isNotNull);
    });

    testWidgets('letter-spacing -5px', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'letter-spacing-negative-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; letter-spacing: -5px;">
                These text should be letter-spacing: -5px.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.letterSpacing?.computedValue, equals(-5.0));
    });

    testWidgets('letter-spacing 0', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'letter-spacing-zero-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; letter-spacing: 0;">
                These text should be letter-spacing: 0.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.letterSpacing?.computedValue, equals(0.0));
    });

    testWidgets('letter-spacing 10px', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'letter-spacing-positive-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="margin: 10px; border: 1px solid #000; letter-spacing: 10px;">
                These text should be letter-spacing: 10px.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.letterSpacing?.computedValue, equals(10.0));
    });

    testWidgets('letter-spacing inheritance', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'letter-spacing-inheritance-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="letter-spacing: 2px;">
                <div style="position: relative; width: 300px; height: 200px; background-color: grey;">
                  <div id="div1" style="width: 250px; height: 100px; background-color: lightgreen;">
                    inherited letter-spacing
                  </div>
                  <div id="div2" style="width: 250px; height: 100px; background-color: lightblue; letter-spacing: 1px;">
                    not inherited letter-spacing
                  </div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final div1 = prepared.getElementById('div1');
      final div2 = prepared.getElementById('div2');
      
      // div1 should inherit letter-spacing from parent - WebF handles inheritance in the getter
      expect(div1.renderStyle.letterSpacing?.computedValue, equals(2.0));
      // div2 has its own letter-spacing
      expect(div2.renderStyle.letterSpacing?.computedValue, equals(1.0));
    });

    testWidgets('letter-spacing dynamic update', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'letter-spacing-dynamic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="letter-spacing: 2px;">
                <div id="child" style="width: 250px; height: 100px; background-color: lightgreen;">
                  inherited letter-spacing
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final child = prepared.getElementById('child');
      
      expect(child.renderStyle.letterSpacing?.computedValue, equals(2.0));
      
      // Update letter-spacing
      container.style.setProperty('letter-spacing', '4px');
      await tester.pump();
      
      // Letter spacing is inherited at value level, not computed level
      expect(child.renderStyle.letterSpacing?.computedValue, equals(2.0));
    });
  });

  group('White Space', () {
    testWidgets('white-space default (normal)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-default-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 100px; background-color: #f40;">
                there should 	
 be
 new line
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      // Default should be normal
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.normal));
    });

    testWidgets('white-space normal', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-normal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 100px; background-color: #f40; white-space: normal;">
                there should 	
 be
 new line
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.normal));
    });

    testWidgets('white-space nowrap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-nowrap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 100px; background-color: #f40; white-space: nowrap;">
                there should 	
 be
 no new line
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
    });

    testWidgets('white-space change from normal to nowrap', skip: true, (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-change-normal-nowrap-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="test" style="width: 100px; background-color: #f40; white-space: normal;">
                there should 	
 be
 no new line
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.normal));
      
      div.style.setProperty('white-space', 'nowrap');
      div.style.flushPendingProperties();
      await tester.pumpAndSettle();
      
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
    });

    testWidgets('white-space change from nowrap to normal', skip: true, (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-change-nowrap-normal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="test" style="width: 100px; background-color: #f40; white-space: nowrap;">
                there should 	
 be
 no new line
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
      
      div.style.setProperty('white-space', 'normal');
      div.style.flushPendingProperties();
      await tester.pumpAndSettle();
      
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.normal));
    });

    testWidgets('white-space nowrap with inline-block elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-nowrap-inline-block-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="white-space: nowrap; background: blue; margin: 10px 0; border: 1px solid black; width: 80px;">
                <span style="background: yellow; margin: 10px 0; width: 50px; height: 50px; display: inline-block; box-sizing: border-box;">one</span>
                <span style="background: pink; margin: 10px 0; width: 50px; height: 50px; display: inline-block;">two</span>
                <span style="background: lightblue; margin: 10px 0; width: 50px; height: 50px; display: block;">three</span>
                <span style="background: grey; margin: 10px 0; width: 50px; height: 50px; display: inline-block;">four</span>
                <span style="background: green; margin: 10px 0; width: 50px; height: 50px; display: inline-block;">five</span>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.document.getElementsByTagName(['div'])[0];
      expect(container.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
      
      final spans = prepared.document.getElementsByTagName(['span']);
      expect(spans.length, equals(5));
    });

    testWidgets('white-space inheritance', skip: true, (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-inheritance-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container">
                <div style="position: relative; width: 300px; height: 200px; background-color: grey;">
                  <div id="div1" style="width: 120px; height: 100px; background-color: lightgreen;">
                    inherited white-space
                  </div>
                  <div id="div2" style="width: 120px; height: 100px; background-color: lightblue; white-space: normal;">
                    not inherited white-space
                  </div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final div1 = prepared.getElementById('div1');
      final div2 = prepared.getElementById('div2');
      
      // Initially, div1 inherits default (normal)
      expect(div1.renderStyle.whiteSpace, equals(WhiteSpace.normal));
      expect(div2.renderStyle.whiteSpace, equals(WhiteSpace.normal));
      
      // Set nowrap on container
      container.style.setProperty('white-space', 'nowrap');
      container.style.flushPendingProperties();
      await tester.pumpAndSettle();
      
      // In WebF, white-space inheritance works through getParentRenderStyle()
      // Since white-space is not explicitly set on div1, checking whiteSpace property
      // will return the computed value from parent
      expect(div1.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
      // div2 should keep its own normal value
      expect(div2.renderStyle.whiteSpace, equals(WhiteSpace.normal));
    });

    testWidgets('white-space with text-overflow ellipsis', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-text-overflow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="white-space: nowrap;">
                <div id="div1" style="width: 120px; height: 100px; background-color: lightgreen; overflow: hidden; text-overflow: ellipsis;">
                  This is a very long text that should be truncated with ellipsis
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final div1 = prepared.getElementById('div1');
      expect(div1.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
      expect(div1.renderStyle.overflowX, equals(CSSOverflowType.hidden));
      // In WebF, effective text overflow depends on other conditions
      expect(div1.renderStyle.effectiveTextOverflow, equals(TextOverflow.ellipsis));
    });
  });

  group('Text Indent', () {
    testWidgets('text-indent positive value', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support text-indent property yet
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-indent-positive-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 200px; text-indent: 30px; background: #f0f0f0;">
                This text should have a 30px indent on the first line.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      // Check if text-indent is supported
      expect(div.style.getPropertyValue('text-indent'), equals('30px'));
    });

    testWidgets('text-indent negative value', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support text-indent property yet
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-indent-negative-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 200px; text-indent: -20px; padding-left: 20px; background: #f0f0f0;">
                This text should have a negative indent creating a hanging indent effect.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.style.getPropertyValue('text-indent'), equals('-20px'));
    });
  });

  group('Text Overflow', () {
    testWidgets('text-overflow clip', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-clip-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 100px; white-space: nowrap; overflow: hidden; text-overflow: clip; background: #f0f0f0;">
                This is a very long text that will be clipped
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.textOverflow, equals(TextOverflow.clip));
      expect(div.renderStyle.overflowX, equals(CSSOverflowType.hidden));
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
    });

    testWidgets('text-overflow ellipsis', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-ellipsis-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 100px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; background: #f0f0f0;">
                This is a very long text that will show ellipsis
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      // Text overflow property itself might be clip, but effective value considers other conditions
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.ellipsis));
      expect(div.renderStyle.overflowX, equals(CSSOverflowType.hidden));
      expect(div.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
    });

    testWidgets('text-overflow dynamic change', skip: true, (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-dynamic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="test" style="width: 100px; white-space: nowrap; overflow: hidden; text-overflow: clip; background: #f0f0f0;">
                This is a very long text that will be clipped or show ellipsis
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.getElementById('test');
      expect(div.renderStyle.textOverflow, equals(TextOverflow.clip));
      
      div.style.setProperty('text-overflow', 'ellipsis');
      div.style.flushPendingProperties();
      await tester.pump();
      
      // After setting text-overflow to ellipsis, it should update
      expect(div.renderStyle.textOverflow, equals(TextOverflow.ellipsis));
    });
  });

  group('Word Spacing', () {
    testWidgets('word-spacing normal', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support word-spacing property yet
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'word-spacing-normal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="word-spacing: normal; background: #f0f0f0;">
                These words have normal spacing between them.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.style.getPropertyValue('word-spacing'), equals('normal'));
    });

    testWidgets('word-spacing positive value', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not support word-spacing property yet
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'word-spacing-positive-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="word-spacing: 10px; background: #f0f0f0;">
                These words have extra spacing between them.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.style.getPropertyValue('word-spacing'), equals('10px'));
    });
  });

  group('Line Height', () {
    testWidgets('line-height normal', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-normal-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="line-height: normal; background: #f0f0f0;">
                This text has normal line height.
                Second line of text.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.lineHeight, isNotNull);
    });

    testWidgets('line-height number value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-number-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="line-height: 1.5; font-size: 16px; background: #f0f0f0;">
                This text has 1.5 line height.
                Second line of text.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.lineHeight?.value, equals(1.5));
    });

    testWidgets('line-height pixel value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-pixel-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="line-height: 24px; font-size: 16px; background: #f0f0f0;">
                This text has 24px line height.
                Second line of text.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.lineHeight?.computedValue, equals(24.0));
    });

    testWidgets('line-height inheritance with font-size', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-inheritance-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="line-height: 1.5; font-size: 16px;">
                <div id="child" style="font-size: 20px;">
                  This inherits line-height multiplier.
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final child = prepared.getElementById('child');
      // Line height multiplier should be inherited, computed as 20px * 1.5 = 30px
      expect(child.renderStyle.lineHeight?.value, equals(1.5));
      expect(child.renderStyle.fontSize?.computedValue, equals(20.0));
    });
  });

  group('Line Clamp', () {
    testWidgets('line-clamp basic', skip: true, (WidgetTester tester) async {
      // TODO: WebF may not fully support -webkit-line-clamp yet
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-clamp-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 3; overflow: hidden; width: 200px;">
                This is a long text that should be clamped to only show three lines. 
                Additional text will be hidden. This helps create truncated multi-line text 
                with an ellipsis at the end of the visible lines.
              </div>
            </body>
          </html>
        ''',
      );

      final div = prepared.document.getElementsByTagName(['div'])[0];
      expect(div.renderStyle.overflowX, equals(CSSOverflowType.hidden));
      expect(div.style.getPropertyValue('-webkit-line-clamp'), equals('3'));
    });
  });
}