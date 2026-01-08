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

  testWidgets('Removing inline style falls back to stylesheet value', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareCustomWidgetTest(
      tester: tester,
      controllerName: 'inline-style-remove-fallback-${DateTime.now().millisecondsSinceEpoch}',
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
      #t { color: rgb(255, 0, 0); }
    </style>
  </head>
  <body>
    <div id="t">test</div>
  </body>
</html>
''',
        url: 'test://inline-style-remove-fallback/',
        contentType: htmlContentType,
      ),
    );

    final dom.Element target = prepared.getElementById('t');
    expect(target.renderStyle.color.value.value, equals(0xFFFF0000));

    target.setInlineStyle('color', 'rgb(0, 0, 255)', fromNative: true);
    target.style.flushPendingProperties();

    expect(target.inlineStyle['color']?.value, equals('rgb(0, 0, 255)'));
    expect(target.renderStyle.color.value.value, equals(0xFF0000FF));

    target.setInlineStyle('color', '', fromNative: true);
    target.style.flushPendingProperties();

    expect(target.inlineStyle.containsKey('color'), isFalse);
    expect(target.renderStyle.color.value.value, equals(0xFFFF0000));
  });

  testWidgets('Clearing inline styles falls back to stylesheet value', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareCustomWidgetTest(
      tester: tester,
      controllerName: 'inline-style-clear-fallback-${DateTime.now().millisecondsSinceEpoch}',
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
      #t { color: rgb(255, 0, 0); }
    </style>
  </head>
  <body>
    <div id="t">test</div>
  </body>
</html>
''',
        url: 'test://inline-style-clear-fallback/',
        contentType: htmlContentType,
      ),
    );

    final dom.Element target = prepared.getElementById('t');
    expect(target.renderStyle.color.value.value, equals(0xFFFF0000));

    target.setInlineStyle('color', 'rgb(0, 0, 255)', fromNative: true);
    target.style.flushPendingProperties();
    expect(target.renderStyle.color.value.value, equals(0xFF0000FF));

    target.clearInlineStyle();
    target.style.flushPendingProperties();

    expect(target.inlineStyle.isEmpty, isTrue);
    expect(target.renderStyle.color.value.value, equals(0xFFFF0000));
  });
}

