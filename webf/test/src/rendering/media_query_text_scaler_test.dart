/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('respects MediaQuery textScaler for layout', (WidgetTester tester) async {
    final scaler = ValueNotifier<TextScaler>(const TextScaler.linear(1.0));
    addTearDown(scaler.dispose);
    expect(
      MediaQueryData.fromView(tester.view).copyWith(textScaler: const TextScaler.linear(0.5)).textScaler.scale(20),
      closeTo(10, 0.01),
    );

    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'media-query-text-scaler-test-${DateTime.now().millisecondsSinceEpoch}',
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div id="text" style="font-size: 20px; line-height: 20px;">Hello</div>
          </body>
        </html>
      ''',
      wrap: (child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<TextScaler>(
            valueListenable: scaler,
            builder: (context, textScaler, _) {
              final data = MediaQueryData.fromView(tester.view).copyWith(textScaler: textScaler, boldText: false);
              return MediaQuery(data: data, child: child);
            },
          ),
        );
      },
    );

    final element = prepared.getElementById('text');
    final double height1x = element.offsetHeight;
    expect(height1x, greaterThan(0));
    expect(prepared.controller.textScaler.scale(20), closeTo(20, 0.01));
    final ctx1x = tester.element(find.byWidget(prepared.webf));
    expect(MediaQuery.of(ctx1x).textScaler.scale(20), closeTo(20, 0.01));

    scaler.value = const TextScaler.linear(0.5);
    await tester.pump(const Duration(milliseconds: 100));
    final ctx0_5x = tester.element(find.byWidget(prepared.webf));
    expect(MediaQuery.of(ctx0_5x).textScaler.scale(20), closeTo(10, 0.01));
    expect(prepared.controller.textScaler.scale(20), closeTo(10, 0.01));

    final double height0_5x = element.offsetHeight;
    expect(height0_5x, closeTo(height1x * 0.5, 1.0));
  });

  testWidgets('updates controller textScaler when using WebFRouterView.fromControllerName builder', (WidgetTester tester) async {
    final name = 'media-query-router-builder-test-${DateTime.now().millisecondsSinceEpoch}';
    late WebFController controller;

    await tester.runAsync(() async {
      controller = (await WebFControllerManager.instance.addWithPreload(
        name: name,
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
        ),
        bundle: WebFBundle.fromContent(
          '<html><body></body></html>',
          url: 'test://$name/',
          contentType: htmlContentType,
        ),
      ))!;
      await controller.controlledInitCompleter.future;
    });

    final scaler = ValueNotifier<TextScaler>(const TextScaler.linear(1.0));
    addTearDown(scaler.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<TextScaler>(
          valueListenable: scaler,
          builder: (context, textScaler, _) {
            final data = MediaQueryData.fromView(tester.view).copyWith(textScaler: textScaler, boldText: false);
            return MediaQuery(
              data: data,
              child: WebFRouterView.fromControllerName(
                controllerName: name,
                path: '/ignored',
                builder: (context, controller) => const SizedBox.shrink(),
                loadingWidget: const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.textScaler.scale(20), closeTo(20, 0.01));

    scaler.value = const TextScaler.linear(0.5);
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.textScaler.scale(20), closeTo(10, 0.01));
  });
}
