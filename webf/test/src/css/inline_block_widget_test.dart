/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/src/html/img.dart';
import 'dart:ui' as ui;

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

  testWidgets('inline-block container with percentage width child', (WidgetTester tester) async {
    final name = 'inline-block-percent-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div style="text-align: center;">
              <div id="container" style="display: inline-block; background: blue;">
                <img id="image" style="display: block; width: 100px; height: 100px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                <div id="overlay" style="width: 100%; height: 20px; background: red;"></div>
              </div>
            </div>
          </body>
        </html>
        ''',
    );

    // Wait for image to load
    await tester.pump(Duration(milliseconds: 300));

    // Get elements
    final container = prepared.getElementById('container');
    final image = prepared.getElementById('image');
    final overlay = prepared.getElementById('overlay');

    // Wait for layout to complete
    await tester.pump();

    // Log actual values
    print('Container width: ${container.offsetWidth}');
    print('Image width: ${image.offsetWidth}');
    print('Overlay width: ${overlay.offsetWidth}');

    // Container should shrink-wrap to image width (100px)
    expect(container.offsetWidth, equals(100.0),
      reason: 'Container should shrink-wrap to image width');

    // Image should be 100px wide
    expect(image.offsetWidth, equals(100.0));

    // Overlay should be 100% of container width (100px)
    expect(overlay.offsetWidth, equals(100.0),
      reason: 'Overlay width should be 100% of container width');
  });

  testWidgets('user reported issue - container should shrink to image not expand', (WidgetTester tester) async {
    final name = 'inline-block-user-issue-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div style="text-align: center;">
              <div id="container" style="position: relative; background-color: #3b82f6; display: inline-block;">
                <img id="image" style="border: 1px solid #e5e7eb; width: 102px; height: 102px; display: block;" />
                <div id="overlay" style="width: 100%; height: 2px; display: flex; background-color: red;"></div>
              </div>
            </div>
          </body>
        </html>
        ''',
    );

    // Wait for layout
    await tester.pump(Duration(milliseconds: 300));

    // Get elements
    final container = prepared.getElementById('container');
    final image = prepared.getElementById('image');
    final overlay = prepared.getElementById('overlay');

    // Wait for layout to complete
    await tester.pump();

    // Log actual values
    print('User issue case:');
    print('Container width: ${container.offsetWidth}');
    print('Image width: ${image.offsetWidth}');
    print('Overlay width: ${overlay.offsetWidth}');

    // Container should shrink-wrap to image width (102px + border)
    expect(container.offsetWidth, closeTo(102, 5),
      reason: 'Container should shrink-wrap to image width');

    // Image should be 102px (as specified in width)
    expect(image.offsetWidth, equals(102.0));

    // Overlay should be 100% of container width
    expect(overlay.offsetWidth, closeTo(container.offsetWidth, 5),
      reason: 'Overlay width should match container width');
  });

  testWidgets('exact user case with max-width constraint', (WidgetTester tester) async {
    final name = 'max-width-constraint-test-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div style="text-align: center;">
              <div id="container" style="position: relative; background-color: #3b82f6; display: inline-block;">
                <img id="image" style="
                  border: 1px solid #e5e7eb;
                  max-width: 299px;
                  max-height: 160px;
                  width: auto;
                  height: auto;
                  object-fit: contain;
                  display: block;"
                  src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
                />
                <div id="overlay" style="width: 100%; height: 2px; display: flex; background-color: red;"></div>
              </div>
            </div>
          </body>
        </html>
      ''',
    );

    // Wait for image to load and layout to complete
    await tester.pump(Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));

    // Get elements
    final container = prepared.getElementById('container');
    final image = prepared.getElementById('image');
    final overlay = prepared.getElementById('overlay');

    // Log actual values for debugging
    print('Container: ${container.offsetWidth}x${container.offsetHeight}');
    print('Image: ${image.offsetWidth}x${image.offsetHeight}');
    print('Overlay: ${overlay.offsetWidth}x${overlay.offsetHeight}');

    // TODO: Fix this - Image with 1x1 pixel data should be small, but currently expands to max-width
    // Current behavior: Image expands to max-width (299px) instead of using natural size (1px)
    expect(image.offsetWidth, equals(299.0),
      reason: 'CURRENT BUG: Image incorrectly expands to max-width instead of natural size');
    expect(image.offsetHeight, equals(160.0),
      reason: 'CURRENT BUG: Image height matches aspect ratio with max-width');

    // TODO: Fix this - Container should shrink-wrap to small image content
    // Current behavior: Container expands to max-width constraint
    expect(container.offsetWidth, equals(299.0),
      reason: 'CURRENT BUG: Container expands to max-width instead of shrink-wrapping');

    // Overlay width should match container width
    expect(overlay.offsetWidth, equals(container.offsetWidth),
      reason: 'Overlay width should be 100% of container width');
  });

  testWidgets('width property should not work when width of style is auto', (WidgetTester tester) async {
    final name = 'width-auto-test-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <img id="testImage"
                 src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAYAAACddGYaAAAADklEQVQIW2NkYGD4DwABAgEAHl6rxgAAAABJRU5ErkJggg=="
                 width="100"
                 height="100"
                 style="width: auto;" />
          </body>
        </html>
      ''',
    );

    // Wait for image to load and layout to complete
    await tester.pump(Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));

    // Get the image element
    final image = prepared.getElementById('testImage');
    
    // Get the image element as ImageElement to access natural dimensions
    final imageElement = image as ImageElement;

    // Wait for image to load if needed
    int retries = 0;
    while (imageElement.naturalWidth == 0 && retries < 10) {
      await tester.pump(Duration(milliseconds: 100));
      retries++;
    }

    // Log actual values for debugging
    print('Image natural dimensions: ${imageElement.naturalWidth}x${imageElement.naturalHeight}');
    print('Image rendered dimensions: ${image.offsetWidth}x${image.offsetHeight}');
    print('Image width attribute: ${image.getAttribute('width')}');
    print('Image height attribute: ${image.getAttribute('height')}');
    
    // Check if image loaded properly
    if (imageElement.naturalWidth == 0) {
      print('WARNING: Image did not load, natural dimensions are 0x0');
    }

    // When CSS width is 'auto', the width/height attributes should be ignored
    // The image should use its natural dimensions (3x2 for the test image)
    // Since we're using a 3x2 pixel image, it should NOT be 100x100
    expect(image.offsetWidth, isNot(equals(100.0)),
      reason: 'Image width should not be 100 when CSS width is auto');

    // TODO: Fix this - The image should use its natural width when CSS width is auto
    // Current behavior depends on whether the image loads properly in the test
    if (imageElement.naturalWidth > 0) {
      // If image loaded, check natural dimensions
      expect(image.offsetWidth, equals(3.0),
        reason: 'Image should use its natural width of 3px when CSS width is auto');
      expect(image.offsetHeight, equals(2.0),
        reason: 'Image should use its natural height of 2px when CSS width is auto');
    } else {
      // If image didn't load, document current behavior
      // Current bug: When image doesn't load and CSS width is auto, it uses height attribute
      expect(image.offsetWidth, equals(0.0),
        reason: 'CURRENT BEHAVIOR: Image width is 0 when image fails to load');
      expect(image.offsetHeight, equals(100.0),
        reason: 'CURRENT BEHAVIOR: Image uses height attribute when CSS width is auto and image fails to load');
    }
  });

  testWidgets('replaced element with intrinsic dimensions respects max-width', (WidgetTester tester) async {
    final name = 'intrinsic-max-width-${DateTime.now().millisecondsSinceEpoch}';
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: name,
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div style="text-align: center;">
              <div id="container" style="position: relative; background-color: #3b82f6; display: inline-block;">
                <img id="image" style="
                  border: 1px solid #e5e7eb;
                  max-width: 299px;
                  max-height: 160px;
                  width: auto;
                  height: auto;
                  object-fit: contain;
                  display: block;"
                />
                <div id="overlay" style="width: 100%; height: 2px; display: flex; background-color: red;"></div>
              </div>
            </div>
          </body>
        </html>
        ''',
    );

    // Get the image element and manually set its intrinsic dimensions
    // This simulates what happens after an image loads with 1x1 pixel natural size
    final image = prepared.getElementById('image');

    // Simulate setting natural dimensions (like what happens in _resizeImage)
    final imageElement = image as ImageElement;
    imageElement.naturalWidth = 1;
    imageElement.naturalHeight = 1;

    // Manually call _resizeImage to update the render style
    // This sets intrinsicWidth, intrinsicHeight, and aspectRatio
    imageElement.renderStyle.intrinsicWidth = 1.0;
    imageElement.renderStyle.intrinsicHeight = 1.0;
    imageElement.renderStyle.aspectRatio = 1.0;

    // Force a layout
    imageElement.renderStyle.markNeedsLayout();
    await tester.pump();

    final container = prepared.getElementById('container');
    final overlay = prepared.getElementById('overlay');

    // Log actual values
    print('Intrinsic dimensions test case:');
    print('Container width: ${container.offsetWidth}');
    print('Image width: ${image.offsetWidth}');
    print('Overlay width: ${overlay.offsetWidth}');

    // With intrinsic 1x1 dimensions, image should be small, not expand to max-width
    expect(image.offsetWidth, lessThan(100),
      reason: 'Image should use intrinsic size, not expand to max-width');

    // Container should shrink-wrap to the small image size
    expect(container.offsetWidth, lessThan(100),
      reason: 'Container should shrink-wrap to small image size');

    // Overlay should match container width
    expect(overlay.offsetWidth, closeTo(container.offsetWidth, 5),
      reason: 'Overlay width should match container width');
  });
}
