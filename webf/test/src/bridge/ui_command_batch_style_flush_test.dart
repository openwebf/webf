/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('UICommand Batch Style Flush', () {
    testWidgets('applies flex layout after DOM append batch', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'ui-command-style-flush-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                #c { display: flex; flex-direction: row; width: 300px; }
                .item { width: 100px; height: 50px; }
              </style>
            </head>
            <body style="margin: 0; padding: 0;">
              <div id="c"></div>
            </body>
          </html>
        ''',
      );

      await tester.runAsync(() async {
        await prepared.controller.view.evaluateJavaScripts('''
          (function () {
            const c = document.getElementById('c');
            for (let i = 0; i < 3; i++) {
              const d = document.createElement('div');
              d.className = 'item';
              d.id = 'i' + i;
              d.textContent = 'Item ' + i;
              c.appendChild(d);
            }
          })();
        ''');
      });

      // Two immediate frames: should not rely on debounce timers.
      await tester.pump();
      await tester.pump();

      final item0 = prepared.getElementById('i0');
      final item1 = prepared.getElementById('i1');
      final item2 = prepared.getElementById('i2');

      expect(item0.offsetLeft, 0);
      expect(item1.offsetLeft, 100);
      expect(item2.offsetLeft, 200);
    });

    testWidgets('applies inline style updates after DOM append batch', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'ui-command-inline-style-flush-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="c"></div>
            </body>
          </html>
        ''',
      );

      await tester.runAsync(() async {
        await prepared.controller.view.evaluateJavaScripts('''
          (function () {
            const c = document.getElementById('c');
            const box = document.createElement('div');
            box.id = 'box';
            box.style.width = '123px';
            box.style.height = '10px';
            c.appendChild(box);
          })();
        ''');
      });

      await tester.pump();
      await tester.pump();

      final box = prepared.getElementById('box');
      expect(box.offsetWidth, equals(123.0));
      expect(box.offsetHeight, equals(10.0));
    });
  });
}
