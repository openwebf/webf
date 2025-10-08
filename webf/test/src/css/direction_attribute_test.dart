/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui' show TextDirection;

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
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

  group('dir attribute', () {
    testWidgets('applies rtl direction to element',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dir-rtl-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="rtl" dir="rtl">
                النص العربي المتدرج
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element rtl = prepared.getElementById('rtl');
      expect(rtl.renderStyle.direction, TextDirection.rtl);
    });

    testWidgets('cascades rtl direction to descendants',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dir-cascade-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="outer" dir="rtl">
                <span id="inner">النص العربي المتدرج</span>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element outer = prepared.getElementById('outer');
      final dom.Element inner = prepared.getElementById('inner');

      expect(outer.renderStyle.direction, TextDirection.rtl);
      expect(inner.renderStyle.direction, TextDirection.rtl);
    });

    testWidgets('allows descendants to override direction',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'dir-override-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="outer" dir="rtl">
                <span id="inner" dir="ltr">Mixed اللغة</span>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element outer = prepared.getElementById('outer');
      final dom.Element inner = prepared.getElementById('inner');

      expect(outer.renderStyle.direction, TextDirection.rtl);
      expect(inner.renderStyle.direction, TextDirection.ltr);
    });
  });
}
