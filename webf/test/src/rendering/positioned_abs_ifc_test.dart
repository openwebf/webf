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

  testWidgets('abspos in IFC no-inflow anchor -> bottom-right', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'abspos-ifc-br-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin:0; padding:0;">
            <div id="cb" style="border:2px solid black; padding:100px; position:relative; width:0; box-sizing:border-box;">
              <span id="outer" style="direction:ltr; box-sizing:border-box;">
                <span id="abs" style="position:absolute; width:100px; height:100px; background:blue;"></span>
              </span>
            </div>
          </body>
        </html>
      ''',
    );

    await tester.pump(const Duration(milliseconds: 50));

    final cb = prepared.getElementById('cb');
    final abs = prepared.getElementById('abs');

    // Containing block border-box size should be 204x204 (2*border + 2*padding + 0 content)
    expect(cb.offsetWidth, equals(204));
    expect(cb.offsetHeight, equals(204));

    final rectCb = cb.getBoundingClientRect();
    final rectAbs = abs.getBoundingClientRect();
    // The abs box (100x100) should sit at bottom-right inside padding box, i.e.,
    // top-left at (border + padding) for both axes: 2 + 100 = 102 from respective edges.
    expect((rectAbs.left - (rectCb.left + 102)).abs() < 1.0, isTrue);
    expect((rectAbs.top - (rectCb.top + 102)).abs() < 1.0, isTrue);
  });
}

