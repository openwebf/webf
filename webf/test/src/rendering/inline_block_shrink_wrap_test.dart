/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart' as dom;
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

  group('Inline-block shrink-wrap with percentage children', () {
    testWidgets('inline-block container should shrink-wrap to content, not percentage child', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-shrink-wrap-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="text-align: center;">
                <div id="container" style="position: relative; background-color: #3b82f6; display: inline-block;">
                  <img id="image" style="display: block; width: 100px; height: 100px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                  <div id="overlay" style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;">
                    <span>Icon</span>
                  </div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final image = prepared.getElementById('image');
      final overlay = prepared.getElementById('overlay');

      print('Container: ${container.offsetWidth}px wide');
      print('Image: ${image.offsetWidth}px wide');
      print('Overlay: ${overlay.offsetWidth}px wide');

      // Container should shrink-wrap to the image width, not expand due to percentage child
      expect(container.offsetWidth, closeTo(100, 5),
        reason: 'Container width (${container.offsetWidth}) should shrink-wrap to image width (~100px)');

      // Image should maintain its specified size
      expect(image.offsetWidth, equals(100.0));
      expect(image.offsetHeight, equals(100.0));

      // Overlay should be 100% of the container's actual content width (100px), not some larger value
      expect(overlay.offsetWidth, closeTo(100, 5),
        reason: 'Overlay width (${overlay.offsetWidth}) should be 100% of container width (${container.offsetWidth})');
    });

    testWidgets('absolutely positioned overlay in inline-block container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-absolute-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="text-align: center;">
                <div id="container" style="position: relative; display: inline-block;">
                  <img id="image" style="display: block; width: 100px; height: 100px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                  <div id="overlay" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: flex;">
                    <span>Icon</span>
                  </div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final image = prepared.getElementById('image');
      final overlay = prepared.getElementById('overlay');

      print('=== Absolutely Positioned Overlay ===');
      print('Container: ${container.offsetWidth}px wide');
      print('Image: ${image.offsetWidth}px wide');
      print('Overlay: ${overlay.offsetWidth}px wide');

      // Container should shrink-wrap to image size
      expect(container.offsetWidth, closeTo(100, 5),
        reason: 'Container width (${container.offsetWidth}) should shrink-wrap to image width (~100px)');

      // Image should maintain its specified size
      expect(image.offsetWidth, equals(100.0));
      expect(image.offsetHeight, equals(100.0));

      // Absolutely positioned overlay should be 100% of container
      expect(overlay.offsetWidth, closeTo(container.offsetWidth, 2),
        reason: 'Absolute overlay width (${overlay.offsetWidth}) should be 100% of container width (${container.offsetWidth})');
    });

    testWidgets('static positioned overlay in inline-block container', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-static-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="text-align: center;">
                <div id="container" style="position: relative; display: inline-block;">
                  <img id="image" style="display: block; width: 100px; height: 100px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" />
                  <div id="overlay" style="width: 100%; height: 100%; display: flex;">
                    <span>Icon</span>
                  </div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final image = prepared.getElementById('image');
      final overlay = prepared.getElementById('overlay');

      print('=== Static Positioned Overlay ===');
      print('Container: ${container.offsetWidth}px wide');
      print('Image: ${image.offsetWidth}px wide');
      print('Overlay: ${overlay.offsetWidth}px wide');

      // Container should shrink-wrap to image size (this is what we're testing)
      expect(container.offsetWidth, closeTo(100, 5),
        reason: 'Container width (${container.offsetWidth}) should shrink-wrap to image width (~100px)');

      // Image should maintain its specified size
      expect(image.offsetWidth, equals(100.0));
      expect(image.offsetHeight, equals(100.0));

      // Static overlay should be 100% of container (this is what we're fixing)
      expect(overlay.offsetWidth, closeTo(container.offsetWidth, 2),
        reason: 'Static overlay width (${overlay.offsetWidth}) should be 100% of container width (${container.offsetWidth})');
    });
  });
}
