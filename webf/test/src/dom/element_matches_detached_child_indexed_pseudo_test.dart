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

  group('Element.matches()', () {
    testWidgets('detached element matches child-indexed pseudo-classes (nth-child etc.)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'matches-detached-child-indexed-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html data-failures="UNSET">
            <head></head>
            <body>
              <div id="out"></div>
            </body>
          </html>
        ''',
      );

      await tester.runAsync(() async {
        await prepared.controller.view.evaluateJavaScripts(r'''
          (function () {
            const el = document.createElement('div');
            const selectors = [
              [':first-child', true],
              [':last-child', true],
              [':only-child', true],
              [':first-of-type', true],
              [':last-of-type', true],
              [':only-of-type', true],
              [':nth-child(1)', true],
              [':nth-child(n)', true],
              [':nth-last-child(1)', true],
              [':nth-last-child(n)', true],
              [':nth-of-type(1)', true],
              [':nth-of-type(n)', true],
              [':nth-last-of-type(1)', true],
              [':nth-last-of-type(n)', true],
              [':nth-child(2)', false],
              [':nth-last-child(2)', false],
              [':nth-of-type(2)', false],
              [':nth-last-of-type(2)', false],
            ];

            const failures = [];
            for (const [selector, expected] of selectors) {
              let got;
              try {
                got = el.matches(selector);
              } catch (e) {
                failures.push(`throw:${selector}`);
                continue;
              }
              if (got !== expected) {
                failures.push(`${selector}:${got}`);
              }
            }
            // Always attach to a stable in-document node so Dart can read it.
            document.documentElement.setAttribute('data-failures', failures.join(';'));
          })();
        ''');
      });

      // Give DOM mutations a chance to flush back to Dart bindings.
      await tester.pump(const Duration(milliseconds: 50));

      final root = prepared.document.documentElement!;
      expect(root.attributes['data-failures'], equals(''));
    });
  });
}
