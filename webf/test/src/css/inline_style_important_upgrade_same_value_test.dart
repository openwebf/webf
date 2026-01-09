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

  testWidgets('inline importance upgrade applies even when value unchanged', (WidgetTester tester) async {
    final String inlineBaseHref = 'test://inline-important-upgrade-${DateTime.now().millisecondsSinceEpoch}/';

    final prepared = await WebFWidgetTestUtils.prepareCustomWidgetTest(
      tester: tester,
      controllerName: 'inline-important-upgrade-${DateTime.now().millisecondsSinceEpoch}',
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
      #t { color: rgb(255, 0, 0) !important; }
    </style>
  </head>
  <body>
    <div id="t">test</div>
  </body>
</html>
''',
        url: 'test://inline-important-upgrade/',
        contentType: htmlContentType,
      ),
    );

    final dom.Element target = prepared.getElementById('t');

    expect(target.renderStyle.color.value.value, equals(0xFFFF0000));
    expect(target.style.getPropertyBaseHref('color'), isNull);

    target.setInlineStyle('color', 'rgb(255, 0, 0)');
    target.style.flushPendingProperties();

    expect(target.inlineStyle['color']?.important, isFalse);
    expect(target.style.getPropertyBaseHref('color'), isNull);

    target.setInlineStyle(
      'color',
      'rgb(255, 0, 0)',
      important: true,
      baseHref: inlineBaseHref,
    );
    target.style.flushPendingProperties();

    expect(target.inlineStyle['color']?.important, isTrue);
    expect(target.style.getPropertyBaseHref('color'), equals(inlineBaseHref));
  });
}

