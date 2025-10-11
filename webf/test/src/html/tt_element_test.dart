/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';
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

  testWidgets('<tt> maps to monospace font', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'tt-element-test-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body>
            <tt id="mono">Hello</tt>
          </body>
        </html>
      ''',
    );

    final el = prepared.getElementById('mono');
    final families = el.renderStyle.fontFamily;
    final expected = CSSText.resolveFontFamilyFallback('monospace');

    expect(families, isNotNull);
    expect(families, equals(expected));
  });
}

