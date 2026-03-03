/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
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
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('logical inset with direction inheritance', () {
    testWidgets('insetInlineStart remaps when direction changes to RTL', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'logical-inset-rtl-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                body { margin: 0; padding: 0; }
                #cb { position: relative; width: 200px; height: 100px; }
                #abs { background: blue; }
              </style>
            </head>
            <body>
              <div id="cb">
                <div id="abs"></div>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element cb = prepared.getElementById('cb');
      final dom.Element abs = prepared.getElementById('abs');

      abs.style.setProperty('position', 'absolute');
      abs.style.setProperty('width', '20px');
      abs.style.setProperty('height', '10px');
      abs.style.setProperty('top', '0px');
      abs.style.setProperty('insetInlineStart', '10%');
      abs.style.flushPendingProperties();

      await tester.pump(const Duration(milliseconds: 50));

      final cbRect = cb.getBoundingClientRect();
      final absRectLtr = abs.getBoundingClientRect();
      final expectedLtr = cbRect.left + cbRect.width * 0.1;
      expect(absRectLtr.left, closeTo(expectedLtr, 0.5));

      cb.style.setProperty('direction', 'rtl');
      cb.style.flushPendingProperties();

      await tester.pump(const Duration(milliseconds: 50));

      final absRectRtl = abs.getBoundingClientRect();
      final expectedLeftRtl = cbRect.left + cbRect.width - cbRect.width * 0.1 - absRectRtl.width;
      expect(absRectRtl.left, closeTo(expectedLeftRtl, 0.5));
    });
  });
}
