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

  testWidgets('align-self:flex-end with absolute positioned child (no top/bottom)', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'flex-abspos-end-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin:0; padding:0;">
            <div id="flex" style="display:flex; flex-direction:row; height:50px; background:coral;">
              <div id="abs" style="position:absolute; align-self:flex-end; background:lightblue;">flex-end</div>
            </div>
          </body>
        </html>
      ''',
    );

    await tester.pump(const Duration(milliseconds: 50));

    final flex = prepared.getElementById('flex');
    final abs = prepared.getElementById('abs');

    expect(flex.offsetHeight, equals(50));

    final absRect = abs.getBoundingClientRect();
    final flexRect = flex.getBoundingClientRect();

    // Bottom of abs element should align to container bottom (within tolerance)
    expect((absRect.bottom - (flexRect.top + 50)).abs() < 1.0, isTrue);
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

  testWidgets('align-self:center with absolute positioned child (no top/bottom)', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'flex-abspos-center-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin:0; padding:0;">
            <div id="flex" style="display:flex; flex-direction:row; height:50px; background:coral;">
              <div id="abs" style="position:absolute; align-self:center; background:lightblue;">center</div>
            </div>
          </body>
        </html>
      ''',
    );

    await tester.pump(const Duration(milliseconds: 50));

    final flex = prepared.getElementById('flex');
    final abs = prepared.getElementById('abs');

    // Container is 50px tall
    expect(flex.offsetHeight, equals(50));

    // Abspos element with no top/bottom and align-self:center should be vertically centered.
    final absRect = abs.getBoundingClientRect();
    final flexRect = flex.getBoundingClientRect();

    // Since text height is unknown here, assert the top aligns to roughly center start.
    // The static-position Y for the abspos box should be around the center of the flex container (25px).
    expect((absRect.top - (flexRect.top + 25)).abs() < 1.0, isTrue);
  });
}
