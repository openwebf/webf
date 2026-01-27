import 'package:flutter/material.dart';
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
    await Future.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('textarea defaultValue/value priority matches integration spec', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'textarea-value-priority-test-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <textarea id="ta">hello world</textarea>
          </body>
        </html>
      ''',
    );

    final dom.Element element = prepared.getElementById('ta');
    final dynamic textarea = element;
    final dom.TextNode text = element.firstChild as dom.TextNode;

    text.data = 'text content value';
    await tester.pump();
    expect(textarea.defaultValue, equals('text content value'));
    expect(textarea.value, equals('text content value'));

    textarea.defaultValue = 'default value';
    await tester.pump();
    expect(textarea.defaultValue, equals('default value'));
    expect(textarea.value, equals('default value'));

    textarea.value = 'property value';
    await tester.pump();
    expect(textarea.defaultValue, equals('default value'));
    expect(textarea.value, equals('property value'));

    text.data = 'text content value 2';
    await tester.pump(const Duration(milliseconds: 50));
    expect(textarea.defaultValue, equals('default value'));
    expect(textarea.value, equals('property value'));
  });
}

