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
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('logical vs physical padding precedence', () {
    testWidgets('padding-left overrides UA padding-inline-start on UL (LTR)', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'logical-padding-precedence-ul-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                body { margin: 0; padding: 0; }
                #wrapper { width: 160px; }
                ul { margin: 0; }
              </style>
            </head>
            <body>
              <div id="wrapper">
                <ul id="list" style="padding-left: 25px;">
                  <li>Item</li>
                </ul>
              </div>
            </body>
          </html>
        ''',
      );

      final dom.Element list = prepared.getElementById('list');
      expect(list.renderStyle.paddingLeft.computedValue, 25.0);
      expect(list.renderStyle.contentBoxLogicalWidth, 135.0);
    });
  });
}

