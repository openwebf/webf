/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

// Regression test for https://github.com/openwebf/webf/issues/855
//
// HybridRouterChangeEvent dispatched by the RouteAware callbacks (didPush,
// didPop, didPushNext, didPopNext) reads state directly from
// ModalRoute.settings.arguments, bypassing HybridHistoryDelegate.state().
//
// When a delegate is set, the event state should come from delegate.state(),
// not from ModalRoute.settings.arguments.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import '../../setup.dart';

/// A minimal [HybridHistoryDelegate] whose [state] always returns [customState].
class _TestHybridHistoryDelegate extends HybridHistoryDelegate {
  final dynamic customState;

  _TestHybridHistoryDelegate({required this.customState});

  @override
  dynamic state(BuildContext? context, Map<String, dynamic>? initialState) {
    return customState;
  }

  @override
  String path(BuildContext? context, String? initialRoute) {
    String? currentPath =
        context != null ? ModalRoute.of(context)?.settings.name : null;
    return currentPath ?? initialRoute ?? '/';
  }

  // Delegate all navigation to Flutter's Navigator.
  @override
  void pop(BuildContext context) => Navigator.pop(context);

  @override
  void pushNamed(BuildContext context, String routeName,
          {Object? arguments}) =>
      Navigator.pushNamed(context, routeName, arguments: arguments);

  @override
  String restorablePopAndPushNamed<T extends Object?, TO extends Object?>(
          BuildContext context, String routeName,
          {TO? result, Object? arguments}) =>
      Navigator.restorablePopAndPushNamed(context, routeName,
          result: result, arguments: arguments);

  @override
  void replaceState(BuildContext context, Object? state, String name) =>
      Navigator.pushReplacementNamed(context, name, arguments: state);

  @override
  void popUntil(BuildContext context, RoutePredicate predicate) =>
      Navigator.popUntil(context, predicate);

  @override
  bool canPop(BuildContext context) => Navigator.canPop(context);

  @override
  Future<bool> maybePop<T extends Object?>(BuildContext context,
          [T? result]) =>
      Navigator.maybePop(context, result);

  @override
  void popAndPushNamed(BuildContext context, String routeName,
          {Object? arguments}) =>
      Navigator.popAndPushNamed(context, routeName, arguments: arguments);

  @override
  void pushNamedAndRemoveUntil(
          BuildContext context, String newRouteName, RoutePredicate predicate,
          {Object? arguments}) =>
      Navigator.pushNamedAndRemoveUntil(context, newRouteName, predicate,
          arguments: arguments);
}

void main() {
  setUp(() {
    setupTest();
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    try {
      WebFControllerManager.instance.disposeAll();
    } catch (_) {
      // Ignore disposal errors in tearDown; the WebFRouterView teardown path
      // may hit a type cast issue that is unrelated to this test.
    }
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('Issue #855: HybridRouterChangeEvent should respect delegate.state()',
      () {
    testWidgets(
      'WebFRouterViewState.didPopNext should use delegate.state()',
      (WidgetTester tester) async {
        final routeObserver = RouteObserver<ModalRoute<void>>();
        final controllerName =
            'delegate-popnext-test-${DateTime.now().millisecondsSinceEpoch}';

        late WebFController controller;

        await tester.runAsync(() async {
          controller =
              (await WebFControllerManager.instance.addWithPreload(
            name: controllerName,
            createController: () => WebFController(
              viewportWidth: 360,
              viewportHeight: 640,
              routeObserver: routeObserver,
            ),
            bundle: WebFBundle.fromContent(
              '<div id="root"></div>',
              url: 'test://$controllerName/',
              contentType: htmlContentType,
            ),
          ))!;
          await controller.controlledInitCompleter.future;
        });

        // Install a delegate whose state() returns known custom data.
        final delegateState = {'from_delegate': true, 'custom': 'data'};
        controller.hybridHistory.delegate =
            _TestHybridHistoryDelegate(customState: delegateState);

        // Collect HybridRouterChangeEvents dispatched on the document.
        final capturedEvents = <dom.HybridRouterChangeEvent>[];
        controller.view.document.addEventListener(
          'hybridrouterchange',
          (dom.Event event) async {
            if (event is dom.HybridRouterChangeEvent) {
              capturedEvents.add(event);
            }
          },
        );

        // Build the app: the home route hosts a WebFRouterView;
        // a second route is a plain Flutter page.
        await tester.pumpWidget(MaterialApp(
          navigatorObservers: [routeObserver],
          home: WebFRouterView(
            controller: controller,
            path: '/test',
          ),
          routes: {
            '/second': (_) => const Scaffold(
                  body: Center(child: Text('Second Page')),
                ),
          },
        ));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Push a second route on top of the WebFRouterView home route.
        final navigatorState =
            tester.state<NavigatorState>(find.byType(Navigator));
        navigatorState.pushNamed('/second',
            arguments: {'from_modal_route': true});
        await tester.pumpAndSettle();

        // Pop the second route. This triggers didPopNext on WebFRouterViewState.
        navigatorState.pop();
        await tester.pumpAndSettle();

        // Let async event dispatch complete.
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 200));
        });
        await tester.pump();

        // Find the didPopNext event.
        final popNextEvents =
            capturedEvents.where((e) => e.kind == 'didPopNext').toList();
        expect(popNextEvents, isNotEmpty,
            reason:
                'Expected at least one didPopNext HybridRouterChangeEvent');

        final event = popNextEvents.first;

        // The delegate's state() returns delegateState. The ModalRoute for the
        // home route has null arguments. The current (buggy) code reads
        // route.settings.arguments (null), so the event state is null,
        // NOT delegateState.
        //
        // After the fix, the event state should equal delegateState.
        expect(
          event.state,
          equals(delegateState),
          reason:
              'HybridRouterChangeEvent.state should come from '
              'HybridHistoryDelegate.state() when a delegate is set, '
              'not from ModalRoute.settings.arguments (issue #855)',
        );
      },
    );

    testWidgets(
      'WebFRouterViewState.didPop should use delegate.state()',
      (WidgetTester tester) async {
        final routeObserver = RouteObserver<ModalRoute<void>>();
        final controllerName =
            'delegate-pop-test-${DateTime.now().millisecondsSinceEpoch}';

        late WebFController controller;

        await tester.runAsync(() async {
          controller =
              (await WebFControllerManager.instance.addWithPreload(
            name: controllerName,
            createController: () => WebFController(
              viewportWidth: 360,
              viewportHeight: 640,
              routeObserver: routeObserver,
            ),
            bundle: WebFBundle.fromContent(
              '<div id="root"></div>',
              url: 'test://$controllerName/',
              contentType: htmlContentType,
            ),
          ))!;
          await controller.controlledInitCompleter.future;
        });

        // Install a delegate whose state() returns known custom data.
        final delegateState = {'from_delegate': true};
        controller.hybridHistory.delegate =
            _TestHybridHistoryDelegate(customState: delegateState);

        // Collect events.
        final capturedEvents = <dom.HybridRouterChangeEvent>[];
        controller.view.document.addEventListener(
          'hybridrouterchange',
          (dom.Event event) async {
            if (event is dom.HybridRouterChangeEvent) {
              capturedEvents.add(event);
            }
          },
        );

        // The home route is a plain page. A second route hosts the
        // WebFRouterView and is pushed with ModalRoute arguments that differ
        // from delegateState.
        final modalRouteArguments = {
          'from_modal_route': true,
          'url': '/webf',
        };

        await tester.pumpWidget(MaterialApp(
          navigatorObservers: [routeObserver],
          home: Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(
                        name: '/webf',
                        arguments: modalRouteArguments,
                      ),
                      builder: (_) => WebFRouterView(
                        controller: controller,
                        path: '/webf',
                      ),
                    ),
                  );
                },
                child: const Text('Go to WebF'),
              ),
            );
          }),
        ));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Push the WebFRouterView route with distinct ModalRoute arguments.
        await tester.tap(find.text('Go to WebF'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));

        // Clear any events from the push phase.
        capturedEvents.clear();

        // Pop the WebFRouterView route. This triggers didPop on
        // WebFRouterViewState.
        final navigatorState =
            tester.state<NavigatorState>(find.byType(Navigator));
        navigatorState.pop();
        await tester.pumpAndSettle();

        // Let async event dispatch complete.
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 200));
        });
        await tester.pump();

        // Find the didPop event.
        final popEvents =
            capturedEvents.where((e) => e.kind == 'didPop').toList();
        expect(popEvents, isNotEmpty,
            reason: 'Expected at least one didPop HybridRouterChangeEvent');

        final event = popEvents.first;

        // BUG: The current code sets event.state = route.settings.arguments
        // which is modalRouteArguments, not delegateState.
        //
        // After the fix, event.state should equal delegateState.
        expect(
          event.state,
          equals(delegateState),
          reason:
              'HybridRouterChangeEvent.state should come from '
              'HybridHistoryDelegate.state() when a delegate is set, '
              'not from ModalRoute.settings.arguments (issue #855). '
              'Got ${event.state} instead of $delegateState',
        );
      },
    );

    testWidgets(
      'HybridHistoryModule.getState() correctly uses delegate (control test)',
      (WidgetTester tester) async {
        final controllerName =
            'delegate-getstate-test-${DateTime.now().millisecondsSinceEpoch}';

        late WebFController controller;

        await tester.runAsync(() async {
          controller =
              (await WebFControllerManager.instance.addWithPreload(
            name: controllerName,
            createController: () => WebFController(
              viewportWidth: 360,
              viewportHeight: 640,
            ),
            bundle: WebFBundle.fromContent(
              '<div></div>',
              url: 'test://$controllerName/',
              contentType: htmlContentType,
            ),
          ))!;
          await controller.controlledInitCompleter.future;
        });

        // Install a delegate.
        final delegateState = {'from_delegate': true};
        controller.hybridHistory.delegate =
            _TestHybridHistoryDelegate(customState: delegateState);

        // Build the app so the controller has a BuildContext.
        await tester.pumpWidget(MaterialApp(
          home: WebF.fromControllerName(controllerName: controllerName),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify that the synchronous getState() path correctly uses the
        // delegate. This path already works; the bug is in the event-driven
        // path.
        final stateResult = controller.hybridHistory.getState();
        expect(
          stateResult,
          equals(delegateState),
          reason:
              'HybridHistoryModule.getState() should use delegate.state() '
              'when a delegate is set',
        );
      },
    );
  });
}
