/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
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

  testWidgets('focusing input does not scroll HTML to top', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'show-on-screen-focus-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div class="chat" style="display: flex; overflow-x: hidden; width: 100%; flex-direction: column;">
              <div class="head" style="height: 50vh; background: #333; color: #fff; display:flex; align-items:center; justify-content:center;">
                Header
              </div>
              <div class="list" style="height: 50vh; overflow: scroll; background: #f1f1f1;">
                ${List<String>.generate(40, (i) => '<div style="height: 44px; margin: 8px; background: #fff; border: 1px solid #ccc;">Item ${i + 1}</div>').join()}
              </div>
              <div class="footer" style="height: 50vh; background: #333; display:flex; align-items:center; justify-content:center; gap: 8px;">
                <input id="input" placeholder="Enter your message..." style="padding: 10px; font-size: 16px; border: none; background: #f1f1f1; outline: none;" />
                <button style="padding: 10px; font-size: 16px; border: none; background: #4CAF50; color: #fff;">Send</button>
              </div>
            </div>
          </body>
        </html>
      ''',
    );

    final html = prepared.document.documentElement!;
    final double maxScrollTop = math.max(0.0, html.scrollHeight - html.clientHeight);
    expect(maxScrollTop, greaterThan(0.0));

    // Scroll to bottom so the input is visible.
    html.scrollTop = maxScrollTop;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final double beforeFocus = html.scrollTop;
    expect(beforeFocus, greaterThan(100.0));

    await tester.runAsync(() async {
      await prepared.controller.view.evaluateJavaScripts(r'''
        document.getElementById('input').focus();
      ''');
    });

    // Sample scrollTop for a bit. The regression manifested as an animation that
    // briefly drove the HTML scroll position down to ~0.
    double minObserved = beforeFocus;
    for (int i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      minObserved = math.min(minObserved, html.scrollTop);
    }

    expect(minObserved, greaterThan(50.0));
  });
}
