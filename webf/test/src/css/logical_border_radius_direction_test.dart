/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

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
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('logical border radius with direction inheritance', () {
    testWidgets('border-start radii remap when direction changes to RTL', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'logical-border-radius-rtl-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                body { margin: 0; padding: 0; }
              </style>
            </head>
            <body>
              <div id="wrapper">
                <div id="box"></div>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element wrapper = prepared.getElementById('wrapper');
      final dom.Element box = prepared.getElementById('box');

      box.style.setProperty('borderStartStartRadius', '12px');
      box.style.setProperty('borderEndStartRadius', '12px');
      box.style.flushPendingProperties();

      await tester.pump(const Duration(milliseconds: 50));

      final brLtr = box.renderStyle.decoration!.borderRadius!;
      expect(brLtr.topLeft, const Radius.circular(12));
      expect(brLtr.bottomLeft, const Radius.circular(12));
      expect(brLtr.topRight, Radius.zero);
      expect(brLtr.bottomRight, Radius.zero);

      wrapper.style.setProperty('direction', 'rtl');
      wrapper.style.flushPendingProperties();

      await tester.pump(const Duration(milliseconds: 50));

      final brRtl = box.renderStyle.decoration!.borderRadius!;
      expect(brRtl.topRight, const Radius.circular(12));
      expect(brRtl.bottomRight, const Radius.circular(12));
      expect(brRtl.topLeft, Radius.zero);
      expect(brRtl.bottomLeft, Radius.zero);
    });
  });
}

