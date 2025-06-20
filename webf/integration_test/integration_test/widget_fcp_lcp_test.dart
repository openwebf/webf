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

// Custom widget element that renders non-contentful widget
class TestLayoutWidgetElement extends WidgetElement {
  TestLayoutWidgetElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'inline-block',
    'width': '200px',
    'height': '100px',
  };

  @override
  WebFWidgetElementState createState() {
    return TestLayoutWidgetState(this);
  }
}

class TestLayoutWidgetState extends WebFWidgetElementState {
  TestLayoutWidgetState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 100,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: SizedBox(),
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register custom elements once
  WebF.defineCustomElement('test-text-widget', (context) => TestTextWidgetElement(context));
  WebF.defineCustomElement('test-layout-widget', (context) => TestLayoutWidgetElement(context));

  testWidgets('Widget FCP and LCP reporting for contentful widgets', (WidgetTester tester) async {
    // Track FCP and LCP callbacks
    double? fcpTime;
    double? lcpTime;
    double? lcpFinalTime;

    await WebFControllerManager.instance.addWithPreload(
      name: 'test_widget_fcp_lcp',
      createController: () => WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        onFCP: (time) {
          fcpTime = time;
        },
        onLCP: (time) {
          lcpTime = time;
        },
        onLCPFinal: (time) {
          lcpFinalTime = time;
        },
      ),
      bundle: WebFBundle.fromContent(
        '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            test-text-widget {
              margin: 10px;
            }
          </style>
        </head>
        <body>
          <test-text-widget id="widget1"></test-text-widget>
        </body>
        </html>
        ''',
        contentType: ContentType.html,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(
          controllerName: 'test_widget_fcp_lcp',
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Wait a bit more for paint to occur
    await tester.pump(Duration(milliseconds: 300));

    // Debug output
    print('FCP time: $fcpTime');
    print('LCP time: $lcpTime');

    // Verify FCP was reported
    expect(fcpTime, isNotNull, reason: 'FCP should be reported for contentful widget');
    expect(fcpTime!, greaterThan(0), reason: 'FCP time should be positive');

    // Verify LCP was reported
    expect(lcpTime, isNotNull, reason: 'LCP should be reported for contentful widget');
    expect(lcpTime!, greaterThan(0), reason: 'LCP time should be positive');
    expect(lcpTime!, greaterThanOrEqualTo(fcpTime!), reason: 'LCP should occur after or at FCP');
  });

  testWidgets('Widget FCP and LCP not reported for non-contentful widgets', (WidgetTester tester) async {
    // Track FCP and LCP callbacks
    double? fcpTime;
    double? lcpTime;

    await WebFControllerManager.instance.addWithPreload(
      name: 'test_widget_no_fcp_lcp',
      createController: () => WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        onFCP: (time) {
          fcpTime = time;
        },
        onLCP: (time) {
          lcpTime = time;
        },
      ),
      bundle: WebFBundle.fromContent(
        '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            test-layout-widget {
              margin: 10px;
            }
          </style>
        </head>
        <body>
          <test-layout-widget id="widget1"></test-layout-widget>
        </body>
        </html>
        ''',
        contentType: ContentType.html,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(
          controllerName: 'test_widget_no_fcp_lcp',
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Wait a bit more for paint to occur
    await tester.pump(Duration(milliseconds: 100));

    // Verify FCP and LCP were not reported
    expect(fcpTime, isNull, reason: 'FCP should not be reported for non-contentful widget');
    expect(lcpTime, isNull, reason: 'LCP should not be reported for non-contentful widget');
  });

  testWidgets('Widget LCP updates for larger contentful widgets', (WidgetTester tester) async {
    // Track LCP updates
    List<double> lcpTimes = [];
    
    // Create controller with initial small widget
    await WebFControllerManager.instance.addWithPreload(
      name: 'test_widget_lcp_update',
      createController: () => WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        onLCP: (time) {
          lcpTimes.add(time);
        },
      ),
      bundle: WebFBundle.fromContent(
        '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            test-text-widget {
              margin: 10px;
            }
          </style>
        </head>
        <body id="body">
          <test-text-widget id="widget1" style="width: 100px; height: 50px;"></test-text-widget>
        </body>
        </html>
        ''',
        contentType: ContentType.html,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(
          controllerName: 'test_widget_lcp_update',
        ),
      ),
    ));

    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 50));

    // Should have initial LCP
    expect(lcpTimes.length, greaterThan(0));
    final initialLCP = lcpTimes.last;

    // Update the bundle to add a larger widget
    await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
      name: 'test_widget_lcp_update',
      bundle: WebFBundle.fromContent(
        '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            test-text-widget {
              margin: 10px;
            }
          </style>
        </head>
        <body id="body">
          <test-text-widget id="widget1" style="width: 100px; height: 50px;"></test-text-widget>
          <test-text-widget id="widget2" style="width: 300px; height: 200px;"></test-text-widget>
        </body>
        </html>
        ''',
        contentType: ContentType.html,
      ),
      mode: WebFLoadingMode.preloading,
      forceReplace: true,
    );

    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 50));

    // Should have updated LCP for the larger widget
    expect(lcpTimes.length, greaterThan(1));
    expect(lcpTimes.last, greaterThan(initialLCP), reason: 'LCP should update for larger widget');
  });
}