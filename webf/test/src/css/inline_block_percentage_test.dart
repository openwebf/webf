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
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('Inline-block with percentage width children', () {
    testWidgets('should resolve percentage width correctly against inline-block parent', (WidgetTester tester) async {
      final name = 'inline-block-percentage-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="text-align: center;">
                <div id="container" style="position: relative; display: inline-block; background-color: blue;">
                  <img id="image" style="display: block; width: 100px; height: 100px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                  <div id="overlay" style="width: 100%; height: 100%; background-color: rgba(255, 0, 0, 0.5);"></div>
                </div>
              </div>
            </body>
          </html>
          ''',
      );

      // Wait for image to load
      await tester.pump(Duration(milliseconds: 500));

      // Get elements
      final container = prepared.getElementById('container');
      final image = prepared.getElementById('image');
      final overlay = prepared.getElementById('overlay');

      // Wait for layout to complete
      await tester.pump();

      // Container should shrink-wrap to image width (100px)
      expect(container.offsetWidth, closeTo(100, 5),
        reason: 'Container should shrink-wrap to image width');

      // Image should be 100px wide
      expect(image.offsetWidth, equals(100.0));

      // Overlay should be 100% of container width (100px), not some larger value
      expect(overlay.offsetWidth, closeTo(100, 5),
        reason: 'Overlay width should be 100% of container width');
    });

    testWidgets('should handle static positioned overlay with percentage width', (WidgetTester tester) async {
      // Test without position:absolute to ensure normal flow also works
      final name = 'inline-block-static-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="text-align: center;">
                <div id="container" style="position: relative; display: inline-block; background-color: #3b82f6;">
                  <img id="image" style="display: block; width: 102px; height: 102px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                  <div id="overlay" style="width: 100%; height: 2px; background-color: red;"></div>
                </div>
              </div>
            </body>
          </html>
          ''',
      );

      // Wait for image to load
      await tester.pump(Duration(milliseconds: 500));

      // Get elements
      final container = prepared.getElementById('container');
      final image = prepared.getElementById('image');
      final overlay = prepared.getElementById('overlay');

      // Wait for layout to complete
      await tester.pump();

      // Container should shrink-wrap to image width (102px)
      expect(container.offsetWidth, closeTo(102, 5));

      // Image should be 102px wide
      expect(image.offsetWidth, equals(102.0));

      // Overlay should be 100% of container width (102px)
      expect(overlay.offsetWidth, closeTo(102, 5),
        reason: 'Static overlay should also be 100% of container width');

      // Overlay height should be 2px as specified
      expect(overlay.offsetHeight, equals(2.0));
    });

    testWidgets('should match browser behavior for complex case', (WidgetTester tester) async {
      // This test documents the expected browser behavior
      final name = 'inline-block-complex-${DateTime.now().millisecondsSinceEpoch}';
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: name,
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="text-align: center;">
                <div id="container" style="position: relative; background-color: #3b82f6; display: inline-block;">
                  <img id="image" style="border: 1px solid #e5e7eb; max-width: 299px; max-height: 160px; width: auto; height: auto; object-fit: contain; border-radius: 0.5rem; display: block;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                  <div id="overlay" style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; border: 1px solid #ff0000; background-color: rgba(255, 255, 0, 0.3);">
                    <span id="span" style="border: 1px solid #22c55e;">Icon</span>
                  </div>
                </div>
              </div>
            </body>
          </html>
          ''',
      );

      // Wait for image to load
      await tester.pump(Duration(milliseconds: 500));

      // Get elements
      final container = prepared.getElementById('container');
      final image = prepared.getElementById('image');
      final overlay = prepared.getElementById('overlay');
      final span = prepared.getElementById('span');

      // Wait for layout to complete
      await tester.pump();

      // Log the actual values for debugging
      print('Container: width=${container.offsetWidth}, height=${container.offsetHeight}');
      print('Image: width=${image.offsetWidth}, height=${image.offsetHeight}');
      print('Overlay: width=${overlay.offsetWidth}, height=${overlay.offsetHeight}');
      print('Span: width=${span.offsetWidth}, height=${span.offsetHeight}');

      // The key assertion: overlay width should match container width
      // In browsers, the overlay would be 100% of the container's shrink-wrapped width
      expect(overlay.offsetWidth, closeTo(container.offsetWidth, 5),
        reason: 'Overlay width should match container width');
    });
  });
}
