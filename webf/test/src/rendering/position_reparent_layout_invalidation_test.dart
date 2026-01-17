/*
 * Copyright (C) 2026
 */

import 'package:flutter_test/flutter_test.dart';
import '../widget/test_utils.dart';
import '../../setup.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  testWidgets('reparent + sizing changes do not trigger Flutter layout assertion', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'reparent-sizing-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <style>
          #container { position: relative; width: 200px; height: 200px; background: #eee; }
          #a { width: 120px; height: 120px; background: #cfc; }
        </style>
        <div id="container">
          <div id="a"></div>
          <div id="b" style="height: 10px"></div>
        </div>
      ''',
    );

    await tester.runAsync(() async {
      await prepared.controller.view.evaluateJavaScripts('''
        const a = document.getElementById('a');
        // Force a structural reparent (static -> absolute attaches under containing block).
        a.style.position = 'absolute';
        a.style.left = '0px';
        a.style.top = '0px';
        // Apply sizing changes in the same batch.
        a.style.maxHeight = '50px';
        a.style.overflow = 'scroll';
      ''');
    });

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
}

