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
    
    // Force layout
    container.flushLayout();
    
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
    
    // Force layout
    container.flushLayout();
    
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
    final name = 'max-width-constraint-${DateTime.now().millisecondsSinceEpoch}';
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
    
    // Wait for image to load and layout
    await tester.pump(Duration(milliseconds: 500));
    
    // Get elements
    final container = prepared.getElementById('container');
    final image = prepared.getElementById('image');
    final overlay = prepared.getElementById('overlay');
    
    // Force layout
    container.flushLayout();
    
    // Log actual values
    print('Max-width constraint case:');
    print('Container width: ${container.offsetWidth}');
    print('Image width: ${image.offsetWidth}');
    print('Overlay width: ${overlay.offsetWidth}');
    
    // With a 1x1 pixel image and width:auto, the image should be very small
    // Container should shrink-wrap to the actual image size, not expand to max-width
    expect(container.offsetWidth, lessThan(100),
      reason: 'Container should shrink-wrap to small image, not expand to max-width');
    
    // Overlay should match container width
    expect(overlay.offsetWidth, closeTo(container.offsetWidth, 5),
      reason: 'Overlay width should match container width');
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