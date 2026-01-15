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

  testWidgets('native inline value "!important" is decoded as priority',
      (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareCustomWidgetTest(
      tester: tester,
      controllerName: 'native-important-${DateTime.now().millisecondsSinceEpoch}',
      createController: () => WebFController(
        enableBlink: false,
        viewportWidth: 360,
        viewportHeight: 640,
      ),
      bundle: WebFBundle.fromContent(
        '''
<html>
  <head>
    <style>
      .t { color: rgb(0, 128, 0) !important; }
    </style>
  </head>
  <body>
    <div id="t" class="t">test</div>
  </body>
</html>
''',
        url: 'test://native-inline-important/',
        contentType: htmlContentType,
      ),
    );

    final dom.Element target = prepared.getElementById('t');

    expect(target.renderStyle.color.value.value, equals(0xFF008000));

    target.setInlineStyle('color', 'rgb(255, 0, 0) !important', fromNative: true);
    target.style.flushPendingProperties();

    expect(target.inlineStyle['color']?.important, isTrue);
    expect(target.inlineStyle['color']?.value, equals('rgb(255, 0, 0)'));
    expect(target.renderStyle.color.value.value, equals(0xFFFF0000));
  });
}

