/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

/// A utility class to help set up WebF widget tests that need layout measurements.
class WebFWidgetTestUtils {
  /// Prepares a WebF widget test with proper layout initialization.
  ///
  /// This function handles all the necessary setup for tests that need to measure
  /// layout properties like offsetWidth, offsetHeight, getBoundingClientRect, etc.
  ///
  /// Example usage:
  /// ```dart
  /// testWidgets('my layout test', (WidgetTester tester) async {
  ///   final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
  ///     tester: tester,
  ///     html: '<div id="test" style="width: 100px;">Test</div>',
  ///   );
  ///
  ///   final element = prepared.controller.view.document.getElementById(['test']);
  ///   expect(element!.offsetWidth, equals(100.0));
  /// });
  /// ```
  static Future<PreparedWidgetTest> prepareWidgetTest({
    required WidgetTester tester,
    required String html,
    String? controllerName,
    double viewportWidth = 360,
    double viewportHeight = 640,
    Map<String, dynamic>? windowProperties,
    Widget Function(Widget child)? wrap,
  }) async {
    final name = controllerName ?? 'test-${DateTime.now().millisecondsSinceEpoch}';
    WebFController? controller;

    tester.view.physicalSize = ui.Size(360, 640);
    tester.view.devicePixelRatio = 1;

    await tester.runAsync(() async {
      controller = await WebFControllerManager.instance.addWithPreload(
        name: name,
        createController: () => WebFController(
          viewportWidth: viewportWidth,
          viewportHeight: viewportHeight,
        ),
        bundle: WebFBundle.fromContent(html, url: 'test://$name/', contentType: htmlContentType),
      );
      await controller!.controlledInitCompleter.future;
    });

    final webf = WebF.fromControllerName(controllerName: name);
    await tester.pumpWidget(wrap != null ? wrap(webf) : webf);

    // Wait for initial rendering
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));

    await tester.runAsync(() async {
      await controller!.controllerPreloadingCompleter.future;
    });

    // Additional frames to ensure layout
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));
    await tester.pumpFrames(webf, Duration(milliseconds: 100));

    await tester.runAsync(() async {
      return Future.wait([
        controller!.controllerOnDOMContentLoadedCompleter.future,
        controller!.viewportLayoutCompleter.future,
      ]);
    });

    await tester.pump(Duration(microseconds: 200));

    return PreparedWidgetTest(
      controller: controller!,
      webf: webf,
      tester: tester,
    );
  }

  /// Prepares a widget test with a custom WebFController configuration.
  ///
  /// Use this when you need more control over the controller setup.
  static Future<PreparedWidgetTest> prepareCustomWidgetTest({
    required WidgetTester tester,
    required WebFController Function() createController,
    required WebFBundle bundle,
    String? controllerName,
    Widget Function(Widget child)? wrap,
  }) async {
    final name = controllerName ?? 'test-${DateTime.now().millisecondsSinceEpoch}';
    WebFController? controller;

    await tester.runAsync(() async {
      controller = await WebFControllerManager.instance.addWithPreload(
        name: name,
        createController: createController,
        bundle: bundle,
      );
      await controller!.controlledInitCompleter.future;
    });

    final webf = WebF.fromControllerName(controllerName: name);
    await tester.pumpWidget(wrap != null ? wrap(webf) : webf);

    // Wait for initial rendering
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));

    await tester.runAsync(() async {
      await controller!.controllerPreloadingCompleter.future;
    });

    // Additional frames to ensure layout
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));
    await tester.pumpFrames(webf, Duration(milliseconds: 100));

    await tester.runAsync(() async {
      return Future.wait([
        controller!.controllerOnDOMContentLoadedCompleter.future,
        controller!.viewportLayoutCompleter.future,
      ]);
    });

    return PreparedWidgetTest(
      controller: controller!,
      webf: webf,
      tester: tester,
    );
  }

  /// Gets an element by ID and ensures it exists.
  static dom.Element getElementByIdOrFail(WebFController controller, String id) {
    final element = controller.view.document.getElementById([id]);
    if (element == null) {
      throw TestFailure('Element with id "$id" not found');
    }
    return element;
  }

  /// Gets multiple elements by IDs and ensures they all exist.
  static List<dom.Element> getElementsByIdsOrFail(WebFController controller, List<String> ids) {
    return ids.map((id) => getElementByIdOrFail(controller, id)).toList();
  }
}

/// Result of preparing a widget test.
class PreparedWidgetTest {
  final WebFController controller;
  final AutoManagedWebF webf;
  final WidgetTester tester;

  PreparedWidgetTest({
    required this.controller,
    required this.webf,
    required this.tester,
  });

  /// Convenience getter for the document.
  dom.Document get document => controller.view.document;

  /// Gets an element by ID, throwing if not found.
  dom.Element getElementById(String id) => WebFWidgetTestUtils.getElementByIdOrFail(controller, id);

  /// Gets multiple elements by IDs, throwing if any are not found.
  List<dom.Element> getElementsByIds(List<String> ids) => WebFWidgetTestUtils.getElementsByIdsOrFail(controller, ids);
}
