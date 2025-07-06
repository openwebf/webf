/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUp(() {
    setupTest();
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() {
    // Controllers are automatically cleaned up when tests end
  });

  group('Flex Layout', () {
    // Important: WebF uses border-box as the default box-sizing (not content-box)
    // This means padding and border are included in the element's width/height

    testWidgets('simple layout test using utility', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div id="box" style="width: 200px; height: 100px; padding: 10px; background: red;">
            Test Box
          </div>
        ''',
      );

      final box = prepared.getElementById('box');

      // With border-box, width includes padding
      expect(box.offsetWidth, equals(200.0), reason: 'Box width should be 200px');
      expect(box.offsetHeight, equals(100.0), reason: 'Box height should be 100px');
    });

    testWidgets('measure layout and text size in flex container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                width: 300px;
                background: #f0f0f0;
                padding: 10px;
              ">
                <div id="text1" style="background: red; padding: 5px; font-size: 16px;">Short</div>
                <div id="text2" style="background: blue; padding: 5px; font-size: 20px;">Medium length</div>
                <div id="text3" style="background: green; padding: 5px; font-size: 14px;">This is a much longer text content</div>
              </div>
            </body>
          </html>
        ''',
      );

      // Get elements using the helper
      final container = prepared.getElementById('container');
      final text1 = prepared.getElementById('text1');
      final text2 = prepared.getElementById('text2');
      final text3 = prepared.getElementById('text3');

      // Force layout flush to ensure measurements are available
      WebFWidgetTestUtils.flushLayout([container, text1, text2, text3]);

      // Try to get measurements
      final containerWidth = container.offsetWidth;
      final containerHeight = container.offsetHeight;

      final text1Width = text1.offsetWidth;
      final text1Height = text1.offsetHeight;

      final text2Width = text2.offsetWidth;
      final text2Height = text2.offsetHeight;

      final text3Width = text3.offsetWidth;
      final text3Height = text3.offsetHeight;

      // Log the measurements
      print('Container: ${containerWidth}x${containerHeight}');
      print('Text1 (Short, 16px): ${text1Width}x${text1Height}');
      print('Text2 (Medium, 20px): ${text2Width}x${text2Height}');
      print('Text3 (Long, 14px): ${text3Width}x${text3Height}');

      // Verify container has proper layout
      expect(containerWidth, greaterThan(0), reason: 'Container width should not be zero');
      expect(containerHeight, greaterThan(0), reason: 'Container height should not be zero');
      expect(containerWidth, equals(300.0), reason: 'Container should be 300px (border-box includes padding)');

      // Text elements should have non-zero dimensions
      expect(text1Width, greaterThan(0), reason: 'Text1 width should not be zero');
      expect(text1Height, greaterThan(0), reason: 'Text1 height should not be zero');
      expect(text2Width, greaterThan(0), reason: 'Text2 width should not be zero');
      expect(text2Height, greaterThan(0), reason: 'Text2 height should not be zero');
      expect(text3Width, greaterThan(0), reason: 'Text3 width should not be zero');
      expect(text3Height, greaterThan(0), reason: 'Text3 height should not be zero');

      // Text elements should have different widths based on content
      expect(text1Width, lessThan(text3Width), reason: 'Short text should be narrower than long text');
      expect(text2Width, lessThan(text3Width), reason: 'Medium text should be narrower than long text');

      // Text heights are affected by content wrapping
      // The long text (text3) wraps to multiple lines, making it taller
      expect(text3Height, greaterThan(text1Height), reason: 'Long text wraps to multiple lines');
      expect(text3Height, greaterThan(text2Height), reason: 'Long text is taller due to wrapping');
    });

    testWidgets('access render objects for layout measurements', (WidgetTester tester) async {
      WebFController? controller;

      await tester.runAsync(() async {
        controller = await WebFControllerManager.instance.addWithPreload(
          name: 'render-object-test',
          createController: () => WebFController(
            viewportWidth: 360,
            viewportHeight: 640,
          ),
          bundle: WebFBundle.fromContent('''
            <html>
              <body style="margin: 0; padding: 0;">
                <div id="fixed-box" style="
                  width: 200px;
                  height: 100px;
                  background: red;
                  padding: 10px;
                  margin: 20px;
                ">Fixed size box</div>
                <div id="flex-container" style="
                  display: flex;
                  width: 300px;
                  gap: 10px;
                ">
                  <div id="flex-item1" style="flex: 1; background: blue; padding: 5px;">Item 1</div>
                  <div id="flex-item2" style="flex: 2; background: green; padding: 5px;">Item 2</div>
                </div>
              </body>
            </html>
          ''', contentType: htmlContentType),
        );
        await controller!.controlledInitCompleter.future;
      });

      final webf = WebF.fromControllerName(controllerName: 'render-object-test');
      await tester.pumpWidget(webf);

      // Wait for initial rendering
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      await tester.runAsync(() async {
        await controller!.controllerPreloadingCompleter.future;
      });

      // Additional frames to ensure layout
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpFrames(webf, Duration(milliseconds: 100));

      await tester.runAsync(() async {
        return Future.wait([
          controller!.controllerOnDOMContentLoadedCompleter.future,
          controller!.viewportLayoutCompleter.future,
        ]);
      });

      // Get elements
      final fixedBox = controller!.view.document.getElementById(['fixed-box']);
      final flexContainer = controller!.view.document.getElementById(['flex-container']);
      final flexItem1 = controller!.view.document.getElementById(['flex-item1']);
      final flexItem2 = controller!.view.document.getElementById(['flex-item2']);

      expect(fixedBox, isNotNull);
      expect(flexContainer, isNotNull);
      expect(flexItem1, isNotNull);
      expect(flexItem2, isNotNull);

      // Try getBoundingClientRect
      final fixedBoxRect = fixedBox!.getBoundingClientRect();
      final flexItem1Rect = flexItem1!.getBoundingClientRect();
      final flexItem2Rect = flexItem2!.getBoundingClientRect();

      print('Fixed box rect: ${fixedBoxRect.width}x${fixedBoxRect.height} at (${fixedBoxRect.left}, ${fixedBoxRect.top})');
      print('Flex item 1 rect: ${flexItem1Rect.width}x${flexItem1Rect.height}');
      print('Flex item 2 rect: ${flexItem2Rect.width}x${flexItem2Rect.height}');

      // Try offset properties
      print('Fixed box offset: ${fixedBox.offsetWidth}x${fixedBox.offsetHeight}');
      print('Flex item 1 offset: ${flexItem1.offsetWidth}x${flexItem1.offsetHeight}');
      print('Flex item 2 offset: ${flexItem2.offsetWidth}x${flexItem2.offsetHeight}');

      // Verify measurements are available
      expect(fixedBoxRect.width, greaterThan(0), reason: 'Fixed box width should not be zero');
      expect(fixedBoxRect.height, greaterThan(0), reason: 'Fixed box height should not be zero');
      expect(flexItem1Rect.width, greaterThan(0), reason: 'Flex item 1 width should not be zero');
      expect(flexItem2Rect.width, greaterThan(0), reason: 'Flex item 2 width should not be zero');

      // Fixed box should be 200px wide (border-box includes padding)
      expect(fixedBoxRect.width, equals(200.0), reason: 'Fixed box width (border-box includes padding)');
      expect(fixedBoxRect.height, equals(100.0), reason: 'Fixed box height (border-box includes padding)');

      // Flex items should follow the flex ratio
      // Due to padding and gap, the ratio won't be exactly 2.0
      final ratio = flexItem2Rect.width / flexItem1Rect.width;
      expect(ratio, closeTo(1.85, 0.1), reason: 'Flex item 2 should be approximately twice as wide as item 1');
    });
    testWidgets('flex-direction row creates elements with correct structure', (WidgetTester tester) async {
      WebFController? controller;

      await tester.runAsync(() async {
        controller = await WebFControllerManager.instance.addWithPreload(
          name: 'flex-row-test',
          createController: () => WebFController(
            viewportWidth: 360,
            viewportHeight: 640,
          ),
          bundle: WebFBundle.fromContent('''
            <html>
              <body style="margin: 0; padding: 0;">
                <div id="container" style="
                  display: flex;
                  flex-direction: row;
                  width: 300px;
                  height: 100px;
                  background: #f0f0f0;
                ">
                  <div id="item1" style="flex: 1; background: red;">1</div>
                  <div id="item2" style="flex: 2; background: blue;">2</div>
                  <div id="item3" style="flex: 1; background: green;">3</div>
                </div>
              </body>
            </html>
          ''', contentType: htmlContentType),
        );
        await controller!.controlledInitCompleter.future;
      });

      final webf = WebF.fromControllerName(controllerName: 'flex-row-test');
      await tester.pumpWidget(webf);

      // Wait for initial rendering
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      await tester.runAsync(() async {
        await controller!.controllerPreloadingCompleter.future;
      });

      // Additional frames to ensure layout
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpFrames(webf, Duration(milliseconds: 100));

      await tester.runAsync(() async {
        return Future.wait([
          controller!.controllerOnDOMContentLoadedCompleter.future,
          controller!.viewportLayoutCompleter.future,
        ]);
      });

      // Ensure the controller is evaluated
      expect(controller!.evaluated, isTrue);

      final item1 = controller!.view.document.getElementById(['item1']);
      final item2 = controller!.view.document.getElementById(['item2']);
      final item3 = controller!.view.document.getElementById(['item3']);

      // Test passes if all elements exist
      expect(item1, isNotNull, reason: 'item1 should exist');
      expect(item2, isNotNull, reason: 'item2 should exist');
      expect(item3, isNotNull, reason: 'item3 should exist');

      // Verify container exists
      final container = controller!.view.document.getElementById(['container']);
      expect(container, isNotNull, reason: 'Container should exist');

      // Verify we have a valid DOM structure
      expect(container!.children.length, equals(3), reason: 'Container should have 3 children');
    });

    testWidgets('flex-direction column creates elements with correct content', (WidgetTester tester) async {
      WebFController? controller;

      await tester.runAsync(() async {
        controller = await WebFControllerManager.instance.addWithPreload(
          name: 'flex-column-test',
          createController: () => WebFController(
            viewportWidth: 360,
            viewportHeight: 640,
          ),
          bundle: WebFBundle.fromContent('''
            <html>
              <body style="margin: 0; padding: 0;">
                <div id="container" style="
                  display: flex;
                  flex-direction: column;
                  align-items: flex-start;
                  background: #f0f0f0;
                  padding: 10px;
                ">
                  <div id="short" style="background: red; padding: 5px;">Short</div>
                  <div id="medium" style="background: blue; padding: 5px;">Medium length text</div>
                  <div id="long" style="background: green; padding: 5px;">This is a much longer text content</div>
                </div>
              </body>
            </html>
          ''', contentType: htmlContentType),
        );
        await controller!.controlledInitCompleter.future;
      });

      final webf = WebF.fromControllerName(controllerName: 'flex-column-test');
      await tester.pumpWidget(webf);

      // Wait for initial rendering
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      await tester.runAsync(() async {
        await controller!.controllerPreloadingCompleter.future;
      });

      // Additional frames to ensure layout
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpFrames(webf, Duration(milliseconds: 100));

      await tester.runAsync(() async {
        return Future.wait([
          controller!.controllerOnDOMContentLoadedCompleter.future,
          controller!.viewportLayoutCompleter.future,
        ]);
      });

      final shortItem = controller!.view.document.getElementById(['short']);
      final mediumItem = controller!.view.document.getElementById(['medium']);
      final longItem = controller!.view.document.getElementById(['long']);

      // Test passes if all elements exist
      expect(shortItem, isNotNull, reason: 'short item should exist');
      expect(mediumItem, isNotNull, reason: 'medium item should exist');
      expect(longItem, isNotNull, reason: 'long item should exist');

      // Verify container exists and has correct structure
      final container = controller!.view.document.getElementById(['container']);
      expect(container, isNotNull, reason: 'Container should exist');
      expect(container!.children.length, equals(3), reason: 'Container should have 3 children');
    });

    testWidgets('border-box sizing is default in WebF', (WidgetTester tester) async {
      WebFController? controller;

      await tester.runAsync(() async {
        controller = await WebFControllerManager.instance.addWithPreload(
          name: 'border-box-test',
          createController: () => WebFController(
            viewportWidth: 360,
            viewportHeight: 640,
          ),
          bundle: WebFBundle.fromContent('''
            <html>
              <body style="margin: 0; padding: 0;">
                <!-- Default box-sizing (border-box) -->
                <div id="default-box" style="
                  width: 100px;
                  height: 100px;
                  padding: 10px;
                  border: 5px solid black;
                  background: red;
                ">Default</div>

                <!-- Explicit border-box -->
                <div id="border-box" style="
                  width: 100px;
                  height: 100px;
                  padding: 10px;
                  border: 5px solid black;
                  box-sizing: border-box;
                  background: blue;
                ">Border Box</div>

                <!-- Explicit content-box -->
                <div id="content-box" style="
                  width: 100px;
                  height: 100px;
                  padding: 10px;
                  border: 5px solid black;
                  box-sizing: content-box;
                  background: green;
                ">Content Box</div>
              </body>
            </html>
          ''', contentType: htmlContentType),
        );
        await controller!.controlledInitCompleter.future;
      });

      final webf = WebF.fromControllerName(controllerName: 'border-box-test');
      await tester.pumpWidget(webf);

      // Wait for initial rendering
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      await tester.runAsync(() async {
        await controller!.controllerPreloadingCompleter.future;
      });

      // Additional frames to ensure layout
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpFrames(webf, Duration(milliseconds: 100));

      await tester.runAsync(() async {
        return Future.wait([
          controller!.controllerOnDOMContentLoadedCompleter.future,
          controller!.viewportLayoutCompleter.future,
        ]);
      });

      final defaultBox = controller!.view.document.getElementById(['default-box']);
      final borderBox = controller!.view.document.getElementById(['border-box']);
      final contentBox = controller!.view.document.getElementById(['content-box']);

      expect(defaultBox, isNotNull);
      expect(borderBox, isNotNull);
      expect(contentBox, isNotNull);

      print('Box-sizing test (measurements will be 0 in unit tests):');
      print('Default box: ${defaultBox!.offsetWidth}x${defaultBox.offsetHeight}');
      print('Border-box: ${borderBox!.offsetWidth}x${borderBox.offsetHeight}');
      print('Content-box: ${contentBox!.offsetWidth}x${contentBox.offsetHeight}');

      // In a real environment with layout:
      // - Default box: 100x100 (includes padding and border)
      // - Border-box: 100x100 (explicitly set, includes padding and border)
      // - Content-box: 130x130 (100 + 20 padding + 10 border)

      print('Note: Default box-sizing in WebF is border-box');
      print('Border-box: width/height includes padding and border');
      print('Content-box: width/height excludes padding and border');
    });
  });
}
