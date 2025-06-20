/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';

// Custom widget element that renders Flutter Text widget
class TestTextWidgetElement extends WidgetElement {
  TestTextWidgetElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'inline-block',
    'width': '200px',
    'height': '100px',
  };

  @override
  WebFWidgetElementState createState() {
    return TestTextWidgetState(this);
  }
}

class TestTextWidgetState extends WebFWidgetElementState {
  TestTextWidgetState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100,
      color: Colors.blue,
      child: Center(
        child: Text(
          'Flutter Text Widget',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register custom elements once
  WebF.defineCustomElement('test-text-widget', (context) => TestTextWidgetElement(context));

  testWidgets('Simple widget FCP test', (WidgetTester tester) async {
    bool fcpCalled = false;
    double? fcpTime;

    await WebFControllerManager.instance.addWithPreload(
      name: 'test_simple_widget_fcp',
      createController: () => WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        onFCP: (time) {
          fcpCalled = true;
          fcpTime = time;
          print('FCP reported: $time ms');
        },
      ),
      bundle: WebFBundle.fromContent(
        '''
        <!DOCTYPE html>
        <html>
        <body>
          <test-text-widget></test-text-widget>
        </body>
        </html>
        ''',
        contentType: ContentType.html,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(
          controllerName: 'test_simple_widget_fcp',
        ),
      ),
    ));

    await tester.pumpAndSettle();
    await Future.delayed(Duration(milliseconds: 500));

    print('FCP called: $fcpCalled');
    print('FCP time: $fcpTime');
    
    expect(fcpCalled, isTrue, reason: 'FCP should be called');
    expect(fcpTime, isNotNull, reason: 'FCP time should not be null');
  });
}