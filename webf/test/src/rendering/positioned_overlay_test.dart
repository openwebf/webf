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
    await Future.delayed(const Duration(milliseconds: 50));
  });

  testWidgets('inline-block container with absolute overlay fills container', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'inline-block-abs-overlay-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin:0;padding:0;">
            <div id="app" style="text-align:center;">
              <div id="container" style="position: relative; display: inline-block; background: #3b82f6;">
                <div id="content" style="display:inline-block; width:180px; height:120px; background:#e5e7eb;"></div>
                <div id="overlay" style="width:100%; height:100%; position:absolute; top:0; left:auto; right:auto; display:flex; align-items:center; justify-content:center;">
                  <span id="span">1Icon</span>
                </div>
              </div>
            </div>
          </body>
        </html>
      ''',
    );

    // Allow layout to settle
    await tester.pump(const Duration(milliseconds: 50));

    final container = prepared.getElementById('container');
    final content = prepared.getElementById('content');
    final overlay = prepared.getElementById('overlay');

    // Sanity: content defines container's shrink-to-fit size
    expect(content.offsetWidth, equals(180));
    expect(content.offsetHeight, equals(120));

    // Container should shrink-wrap to content
    expect(container.offsetWidth, equals(180));
    expect(container.offsetHeight, equals(120));

    // Absolutely positioned overlay with width/height:100% must fill container
    expect(overlay.offsetWidth, equals(180));
    expect(overlay.offsetHeight, equals(120));
  });
}

