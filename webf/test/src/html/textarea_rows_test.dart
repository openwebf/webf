/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  testWidgets('textarea defaults to rows=2 when rows attribute is omitted', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'textarea-default-rows-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <textarea id="default" cols="10" style="font-size: 16px;">Hello World
Hello World Hello World Hello World</textarea>
            <textarea id="rows2" cols="10" rows="2" style="font-size: 16px;">Hello World
Hello World Hello World Hello World</textarea>
            <textarea id="rows3" cols="10" rows="3" style="font-size: 16px;">Hello World
Hello World Hello World Hello World</textarea>
          </body>
        </html>
      ''',
      wrap: (child) => MaterialApp(
        home: Material(
          child: child,
        ),
      ),
    );

    await tester.pump();

    final defaultTextarea = prepared.getElementById('default');
    final rows2Textarea = prepared.getElementById('rows2');
    final rows3Textarea = prepared.getElementById('rows3');

    expect(defaultTextarea.offsetHeight, equals(rows2Textarea.offsetHeight));
    expect(defaultTextarea.clientHeight, equals(rows2Textarea.clientHeight));
    expect(defaultTextarea.offsetHeight, lessThan(rows3Textarea.offsetHeight));
  });
}
