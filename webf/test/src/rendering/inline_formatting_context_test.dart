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

  group('InlineFormattingContext', () {
    testWidgets('should layout simple text', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-simple-text-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 200px;">Hello World</div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      final renderBox = div.attachedRenderer!;
      
      expect(renderBox.hasSize, isTrue);
      expect(renderBox.size.width, equals(200));
      expect(renderBox.size.height, greaterThan(0));
    });

    testWidgets('should handle inline elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-elements-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px;">
            Hello <span style="color: red;">World</span>!
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      final span = controller.view.document.querySelector(['span']) as dom.Element;
      
      expect(div.attachedRenderer!.hasSize, isTrue);
      expect(span.attachedRenderer!.renderStyle.color.value, equals(const Color(0xFFFF0000)));
    });

  testWidgets('should handle inline-block elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px;">
            Text before
            <span style="display: inline-block; width: 100px; height: 50px; background: blue;">
              Inline Block
            </span>
            Text after
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      final span = controller.view.document.querySelector(['span']) as dom.Element;
      
      expect(div.attachedRenderer!.hasSize, isTrue);
      expect(span.attachedRenderer!.size.width, equals(100));
      expect(span.attachedRenderer!.size.height, equals(50));
    });

    testWidgets('should handle text alignment', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-align-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px; text-align: center;">
            Centered Text
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.attachedRenderer!.renderStyle.textAlign, equals(TextAlign.center));
    });

    testWidgets('should handle line breaks and wrapping', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-wrapping-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 100px;">
            This is a very long text that should wrap to multiple lines
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      final renderBox = div.attachedRenderer!;
      
      expect(renderBox.size.width, equals(100));
      // Height should be greater than single line height
      expect(renderBox.size.height, greaterThan(20));
    });

    testWidgets('should handle white-space property', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'white-space-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 200px; white-space: nowrap;">
            This text should not wrap
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.attachedRenderer!.renderStyle.whiteSpace, equals(WhiteSpace.nowrap));
      // With nowrap, height should be single line
      expect(div.attachedRenderer!.size.height, lessThan(30));
    });

    testWidgets('should keep RTL nowrap text within intrinsic width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'rtl-nowrap-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="host" style="display: flex; flex-direction: row; width: 160px; direction: rtl; border: 1px solid black;">
            <div id="btn" style="white-space: nowrap; background: #007bff; color: white; padding: 3px 6px;">
              Btn
            </div>
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final host = controller.view.document.getElementById('host') as dom.Element;
      final btn = controller.view.document.getElementById('btn') as dom.Element;

      expect(host.attachedRenderer!.hasSize, isTrue);
      expect(btn.attachedRenderer!.hasSize, isTrue);
      expect(btn.attachedRenderer!.size.width, greaterThan(0));
      expect(btn.attachedRenderer!.size.width, lessThan(200));
      expect(btn.attachedRenderer!.size.width, lessThan(host.attachedRenderer!.size.width));
    });

    testWidgets('should handle nested inline elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'nested-inline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px;">
            <span>Outer <span style="font-weight: bold;">Inner Bold</span> Text</span>
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final innerSpan = controller.view.document.querySelectorAll(['span'])[1] as dom.Element;
      expect(innerSpan.attachedRenderer!.renderStyle.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should handle borders on inline elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-borders-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px;">
            Text with <span style="border: 2px solid red; padding: 5px;">bordered span</span> element
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final span = controller.view.document.querySelector(['span']) as dom.Element;
      
      expect(span.attachedRenderer!.renderStyle.borderLeftWidth?.value, equals(2));
      expect(span.attachedRenderer!.renderStyle.borderLeftColor.value, equals(const Color(0xFFFF0000)));
      expect(span.attachedRenderer!.renderStyle.paddingLeft.value, equals(5));
    });

    testWidgets('should handle vertical-align property', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'vertical-align-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px;">
            Normal text
            <span style="display: inline-block; vertical-align: top;">Top aligned</span>
            <span style="display: inline-block; vertical-align: middle;">Middle aligned</span>
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final spans = controller.view.document.querySelectorAll(['span']);
      expect((spans[0] as dom.Element).attachedRenderer!.renderStyle.verticalAlign, equals(VerticalAlign.top));
      expect((spans[1] as dom.Element).attachedRenderer!.renderStyle.verticalAlign, equals(VerticalAlign.middle));
    });

    testWidgets('should handle text decoration', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-decoration-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 300px;">
            <span style="text-decoration: underline;">Underlined</span>
            <span style="text-decoration: line-through;">Strike through</span>
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final spans = controller.view.document.querySelectorAll(['span']);
      final span1 = spans[0] as dom.Element;
      final span2 = spans[1] as dom.Element;
      
      expect(span1.attachedRenderer!.renderStyle.textDecorationLine, equals(TextDecoration.underline));
      expect(span2.attachedRenderer!.renderStyle.textDecorationLine, equals(TextDecoration.lineThrough));
    });
  });

  testWidgets('inline-block honors max-width when content is larger', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'inline-block-maxwidth-wrap-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin:0; padding:0;">
            <div id="ib" style="display:inline-block; max-width:200px; border:2px solid #000;">
              This text should be wrapped This text should be wrapped This text should be wrapped
            </div>
          </body>
        </html>
      ''',
    );

    final ib = prepared.getElementById('ib');
    // Border-box width should equal 200 (max-width) when content exceeds it.
    expect(ib.offsetWidth, equals(200.0));
  });
}
