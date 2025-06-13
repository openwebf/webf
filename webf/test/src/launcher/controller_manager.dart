/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/launcher.dart';

import '../../webf_test.dart';
import '../foundation/mock_bundle.dart';

// We'll need to patch the controller to avoid the actual attachToFlutter call
class TestWebFController extends WebFController {
  bool _isFlutterAttached = false;

  @override
  bool get isFlutterAttached => _isFlutterAttached;

  @override
  void attachToFlutter(BuildContext context) {
    // Skip the actual attachment which requires a real BuildContext
    _isFlutterAttached = true;
  }

  @override
  void detachFromFlutter(BuildContext? context) {
    // Skip the actual detachment
    _isFlutterAttached = false;
  }
}

// Simple mock context
class MockBuildContext extends Fake implements BuildContext {}

void main() {
  setUp(() {
    setupTest();
  });

  group('WebFControllerManager', () {
    late WebFControllerManager manager;

    setUp(() {
      // Reset the singleton instance
      manager = WebFControllerManager.instance;
      // Clean up any controllers from previous tests
      manager.disposeAll();
      // Initialize with test configuration
      manager.initialize(
        const WebFControllerManagerConfig(
          maxAliveInstances: 5,
          maxAttachedInstances: 3,
          autoDisposeWhenLimitReached: true,
        ),
      );
    });

    tearDown(() async {
      // Clean up after each test
      await manager.disposeAll();
    });

    test('should initialize with default configuration', () {
      expect(manager.config.maxAliveInstances, 5);
      expect(manager.config.maxAttachedInstances, 3);
      expect(manager.config.autoDisposeWhenLimitReached, true);
    });

    test('should add controller with preload', () async {
      final MockTimedBundle bundle = MockTimedBundle.fast(content: 'console.log("Hello World")');
      final controller = await manager.addWithPreload(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: bundle,
      );

      expect(controller, isNotNull);
      expect(manager.hasController('test'), isTrue);
      expect(manager.controllerCount, 1);
      expect(manager.isControllerAlive('test'), true);
    });

    test('should get controller by name', () async {
      final MockTimedBundle bundle = MockTimedBundle.fast(content: 'console.log("Hello World")');
      final addedController = await manager.addWithPreload(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: bundle,
      );

      final retrievedController = await manager.getController('test');
      expect(retrievedController, equals(addedController));
    });

    test('should remove controller', () async {
      final MockTimedBundle bundle = MockTimedBundle.fast(content: 'console.log("Hello World")');
      await manager.addWithPreload(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: bundle,
      );

      final removedController = manager.removeController('test');
      expect(removedController, isNotNull);
      expect(manager.hasController('test'), isFalse);
      expect(manager.controllerCount, 0);
    });

    test('should attach and detach controller', () async {
      final MockTimedBundle bundle = MockTimedBundle.fast(content: 'console.log("Hello World")');
      await manager.addWithPreload(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: bundle,
      );

      // Simulate attaching to Flutter
      final context = MockBuildContext();
      manager.attachController('test', context);

      expect(manager.getControllerState('test'), equals(ControllerState.attached));
      expect(manager.attachedControllersCount, 1);

      // Simulate detaching from Flutter
      manager.detachController('test', null);

      expect(manager.getControllerState('test'), equals(ControllerState.detached));
      expect(manager.attachedControllersCount, 0);
    });

    test('should update controller with preload', () async {
      final MockTimedBundle initialBundle = MockTimedBundle.fast(content: 'console.log("Initial")');
      final initialController = await manager.addWithPreload(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: initialBundle,
      );

      final MockTimedBundle updatedBundle = MockTimedBundle.fast(content: 'console.log("Updated")');
      final updatedController = await manager.addOrUpdateControllerWithLoading(
        name: 'test',
        bundle: updatedBundle,
        mode: WebFLoadingMode.preloading,
      );

      expect(updatedController, isNot(equals(initialController)));
      expect(manager.hasController('test'), isTrue);
      expect(manager.controllerCount, 1);
    });

    test('should enforce maximum limits for alive instances', () async {
      // Add more controllers than the maximum allowed
      for (int i = 0; i < 6; i++) {
        final MockTimedBundle bundle = MockTimedBundle.fast(content: 'console.log("Test $i")');
        await manager.addWithPreload(
          name: 'test$i',
          createController: () => TestWebFController(),
          bundle: bundle,
        );
      }

      // Should have enforced the limit
      expect(manager.controllerCount, equals(5));

      // The first controller should have been disposed (LRU policy)
      expect(manager.hasController('test0'), isFalse);
      expect(manager.hasController('test5'), isTrue);
    });

    test('should enforce maximum limits for attached instances', () async {
      final context = MockBuildContext();

      // Add and attach more controllers than the maximum allowed
      for (int i = 0; i < 4; i++) {
        final MockTimedBundle bundle = MockTimedBundle.fast(content: 'console.log("Test $i")');
        await manager.addWithPreload(
          name: 'test$i',
          createController: () => TestWebFController(),
          bundle: bundle,
        );

        manager.attachController('test$i', context);
      }

      // Should have enforced the limit - only the 3 most recent should be attached
      expect(manager.attachedControllersCount, equals(3));

      // The first controller should be detached
      expect(manager.getControllerState('test0'), equals(ControllerState.detached));

      // The other controllers should be attached
      expect(manager.getControllerState('test1'), equals(ControllerState.attached));
      expect(manager.getControllerState('test2'), equals(ControllerState.attached));
      expect(manager.getControllerState('test3'), equals(ControllerState.attached));
    });

    test('should handle race condition with two success requests', () async {
      // Start two update operations - a slow one and a fast one
      final slowCompleter = Completer<void>();
      final MockTimedBundle slowBundle = MockTimedBundle.controlled(
        completer: slowCompleter,
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: slowBundle,
      );

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: fastBundle,
      );

      await Future.delayed(const Duration(milliseconds: 20));

      // Now allow the slow update to complete
      slowCompleter.complete();

      // Get both results
      final slowController = await slowUpdateFuture;
      final fastController = await fastUpdateFuture;

      expect(slowController, equals(null));

      // The fast controller should be the one that's active
      final currentController = await manager.getController('test');

      expect(currentController, equals(fastController));
      expect(currentController!.entrypoint, equals(fastBundle));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition with two success requests, but faster one in the first', () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start two update operations - a slow one and a fast one
      final MockTimedBundle slowBundle = MockTimedBundle.slow(
        content: 'console.log("Slow Prerender")',
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: slowBundle,
      );

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 200));

      // Get both results
      final slowController = await slowUpdateFuture;
      final fastController = await fastUpdateFuture;

      expect(fastController, equals(null));

      // The fast controller should be the one that's active
      final currentController = await manager.getController('test');

      expect(currentController, equals(slowController));
      expect(slowController!.entrypoint, equals(slowBundle));
      expect(fastController, equals(null));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition with three success requests, fast slow medium', () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast")');
      final MockTimedBundle slowBundle = MockTimedBundle.fast(content: 'console.log("Slow")');
      final MockTimedBundle mediumBundle = MockTimedBundle.fast(content: 'console.log("Medium")');

      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: slowBundle,
      );

      // Start the slow update (but don't await it)
      final mediumUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: mediumBundle,
      );

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      // Get both results
      final slowController = await slowUpdateFuture;
      final fastController = await fastUpdateFuture;
      final mediumController = await mediumUpdateFuture;

      expect(slowController, equals(null));
      expect(fastController, equals(null));

      // The fast controller should be the one that's active
      final currentController = await manager.getController('test');

      expect(currentController, equals(mediumController));
      expect(mediumController!.entrypoint, equals(mediumBundle));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test(
        'should handle race condition with three success requests, and the earlier getController will returns the winner one',
        () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast")');
      final MockTimedBundle slowBundle = MockTimedBundle.fast(content: 'console.log("Slow")');
      final MockTimedBundle mediumBundle = MockTimedBundle.fast(content: 'console.log("Medium")');

      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: slowBundle,
      );

      // Start the slow update (but don't await it)
      final mediumUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: mediumBundle,
      );

      // The fast controller should be the one that's active
      WebFController? currentController = await manager.getController('test');

      final fastController = await fastUpdateFuture;

      expect(fastController?.entrypoint, equals(null));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      // Get both results
      final slowController = await slowUpdateFuture;
      final mediumController = await mediumUpdateFuture;

      expect(slowController, equals(null));
      expect(fastController, equals(null));

      // The fast controller should be the one that's active
      currentController = await manager.getController('test');

      expect(currentController, equals(mediumController));
      expect(mediumController!.entrypoint, equals(mediumBundle));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test(
        'should handle race condition with three success requests, and the getController will invoke at at middle await',
        () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast")');
      final MockTimedBundle slowBundle = MockTimedBundle.fast(content: 'console.log("Slow")');
      final MockTimedBundle mediumBundle = MockTimedBundle.fast(content: 'console.log("Medium")');

      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: slowBundle,
      );

      // Start the slow update (but don't await it)
      final mediumUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: mediumBundle,
      );

      final fastController = await fastUpdateFuture;

      // The fast controller should be the one that's active
      WebFController? currentController = await manager.getController('test');

      expect(fastController?.entrypoint, equals(null));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      // Get both results
      final slowController = await slowUpdateFuture;
      final mediumController = await mediumUpdateFuture;

      expect(slowController, equals(null));
      expect(fastController, equals(null));

      // The fast controller should be the one that's active
      currentController = await manager.getController('test');

      expect(currentController, equals(mediumController));
      expect(mediumController!.entrypoint, equals(mediumBundle));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition with three success requests, and the getController will invoke at at last await',
        () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast")');
      final MockTimedBundle slowBundle = MockTimedBundle.fast(content: 'console.log("Slow")');
      final MockTimedBundle mediumBundle = MockTimedBundle.fast(content: 'console.log("Medium")');

      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: slowBundle,
      );

      // Start the slow update (but don't await it)
      final mediumUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        bundle: mediumBundle,
      );

      final fastController = await fastUpdateFuture;

      // Get both results
      final slowController = await slowUpdateFuture;

      // The fast controller should be the one that's active
      WebFController? currentController = await manager.getController('test');

      expect(currentController?.entrypoint, equals(mediumBundle));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);

      final mediumController = await mediumUpdateFuture;

      expect(slowController, equals(null));
      expect(fastController, equals(null));

      // The fast controller should be the one that's active
      currentController = await manager.getController('test');

      expect(currentController, equals(mediumController));
      expect(mediumController!.entrypoint, equals(mediumBundle));

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test(
        'should handle race condition with two separate group of requests, and the getController will receive different value',
        () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast")');

      await manager.addOrUpdateControllerWithLoading(
          name: 'test',
          bundle: fastBundle,
          mode: WebFLoadingMode.preloading,
          createController: () => TestWebFController());

      WebFController? controller = await manager.getController('test');

      expect(controller?.entrypoint!, equals(fastBundle));

      final MockTimedBundle slowBundle = MockTimedBundle.slow(content: 'console.log("Slow")');

      Future<WebFController?> slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
          name: 'test',
          bundle: slowBundle,
          mode: WebFLoadingMode.preloading,
          forceReplace: true,
          createController: () => TestWebFController());

      controller = await manager.getController('test');

      expect(controller?.entrypoint!, equals(fastBundle));

      await slowUpdateFuture;

      controller = await manager.getController('test');

      expect(controller?.entrypoint!, equals(slowBundle));

      await manager.removeAndDisposeController('test');

      expect(manager.controllerCount, 0);

      final MockTimedBundle mediumBundle = MockTimedBundle.fast(content: 'console.log("Medium")');

      // // Start and await the fast update
      await manager.addOrUpdateControllerWithLoading(
          name: 'test',
          mode: WebFLoadingMode.preloading,
          createController: () => TestWebFController(),
          bundle: mediumBundle);

      controller = await manager.getController('test');

      expect(controller?.entrypoint!, equals(mediumBundle));

      expect(manager.controllerCount, 1);
    });

    test('should handle race condition with both preload and prerendering success requests', () async {
      // Start two update operations - a slow one and a fast one
      final slowCompleter = Completer<void>();
      final MockTimedBundle slowBundle = MockTimedBundle.controlled(
        completer: slowCompleter,
      );

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: slowBundle,
      );

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preRendering,
        bundle: fastBundle,
      );

      await Future.delayed(const Duration(milliseconds: 20));

      // Now allow the slow update to complete
      slowCompleter.complete();

      // Get both results
      final slowController = await slowUpdateFuture;
      final fastController = await fastUpdateFuture;

      expect(slowController, equals(null));

      // The fast controller should be the one that's active
      final currentController = await manager.getController('test');

      expect(currentController, equals(fastController));
      expect(currentController!.entrypoint, equals(fastBundle));
      expect(fastController!.evaluated, true);

      // // There should still only be one controller
      expect(manager.controllerCount, 1);
    });
    test('should handle race condition with last request where failed', () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      await manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preRendering,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start two update operations - a slow one and a fast one
      final failedCompleter = Completer<void>();
      final MockTimedBundle failedBundle = MockTimedBundle.controlled(
        completer: failedCompleter,
      );

      // Start the slow update (but don't await it)
      manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: failedBundle,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      failedCompleter.completeError(FlutterError('ERROR'));

      WebFController? currentController = await WebFControllerManager.instance.getController('test');

      expect(currentController?.entrypoint, equals(fastBundle));
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition with last request where failed and earlier than first', () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      await manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preRendering,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start two update operations - a slow one and a fast one
      final failedCompleter = Completer<void>();
      final MockTimedBundle failedBundle = MockTimedBundle.controlled(
        completer: failedCompleter,
      );

      // Start the slow update (but don't await it)
      manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: failedBundle,
      );

      Timer(Duration(seconds: 1), () {
        failedCompleter.completeError(FlutterError('ERROR'));
      });

      WebFController? currentController = await WebFControllerManager.instance.getController('test');

      expect(currentController?.entrypoint, equals(fastBundle));
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition with middle request were failed', () async {
      // Start two update operations - a slow one and a fast one
      final slowCompleter = Completer<void>();
      final MockTimedBundle slowBundle = MockTimedBundle.controlled(
        completer: slowCompleter,
      );

      // Start the slow update (but don't await it)
      manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: slowBundle,
      );

      Timer(Duration(seconds: 2), () {
        slowCompleter.complete();
      });

      // Start two update operations - a slow one and a fast one
      final failedCompleter = Completer<void>();
      final MockTimedBundle failedBundle = MockTimedBundle.controlled(
        completer: failedCompleter,
      );

      // Start the slow update (but don't await it)
      manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: failedBundle,
      );

      Timer(Duration(seconds: 1), () {
        failedCompleter.completeError(FlutterError('ERROR'));
      });

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      await manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preRendering,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      WebFController? currentController = await WebFControllerManager.instance.getController('test');

      expect(currentController?.entrypoint, equals(fastBundle));
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition all requests were failed', () async {
      // Start two update operations - a slow one and a fast one
      final failedCompleter = Completer<void>();
      final MockTimedBundle failedBundle = MockTimedBundle.controlled(
        completer: failedCompleter,
      );

      // Start the slow update (but don't await it)
      Future<WebFController?> failedUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: failedBundle,
      );
      failedUpdateFuture.catchError((e, _) {
        return TestWebFController();
      });

      Timer(Duration(seconds: 1), () {
        failedCompleter.completeError(FlutterError('ERROR'));
      });
      //
      // // Start two update operations - a slow one and a fast one
      final failedCompleter2 = Completer<void>();
      final MockTimedBundle failedBundle2 = MockTimedBundle.controlled(
        completer: failedCompleter2,
      );

      // Start the slow update (but don't await it)
      final failedUpdateFuture2 = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: failedBundle2,
      );
      failedUpdateFuture2.catchError((e, _) {
        return TestWebFController();
      });

      Timer(Duration(milliseconds: 500), () {
        failedCompleter2.completeError(FlutterError('ERROR2'));
      });

      bool isErrorCalled = true;
      try {
        await WebFControllerManager.instance.getController('test');
        isErrorCalled = false;
        throw FlutterError('should failed');
      } catch (e) {
        expect(e.toString(), 'ERROR');
        expect(isErrorCalled, true);
      }
    });

    test('should handle race condition when last request first finished and failed', () async {
      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      await manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preRendering,
        createController: () => TestWebFController(),
        bundle: fastBundle,
      );

      // Start two update operations - a slow one and a fast one
      final slowCompleter = Completer<void>();
      final MockTimedBundle slowBundle = MockTimedBundle.controlled(
        completer: slowCompleter,
      );

      // Start the slow update (but don't await it)
      manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: slowBundle,
      );

      // Start two update operations - a slow one and a fast one
      final failedCompleter = Completer<void>();
      final MockTimedBundle failedBundle = MockTimedBundle.controlled(
        completer: failedCompleter,
      );
      failedCompleter.future.catchError((e, _) {
        return null;
      });

      // Start the slow update (but don't await it)
      Future<WebFController?> failedUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: failedBundle,
      );
      failedUpdateFuture.catchError((e, _) {
        return null;
      });

      // Make the error first happened
      Timer(Duration(microseconds: 1), () {
        failedCompleter.completeError(FlutterError('ERROR'));
      });

      Timer(Duration(seconds: 2), () {
        slowCompleter.complete();
      });

      WebFController? currentController = await WebFControllerManager.instance.getController('test');
      expect(currentController?.entrypoint, equals(slowBundle));
    });

    test('should handle race condition when first request timeout', () async {
      Completer<void> timeoutCompleter = Completer();
      final MockTimedBundle timeoutBundle = MockTimedBundle.controlled(completer: timeoutCompleter);
      // Start and await the fast update
      final timeoutFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preloading,
        createController: () => TestWebFController(),
        bundle: timeoutBundle,
        timeout: Duration(seconds: 2)
      );

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
        name: 'test',
        mode: WebFLoadingMode.preRendering,
        createController: () => TestWebFController(),
        bundle: fastBundle,
        timeout: Duration(seconds: 2)
      );

      final timeout = await timeoutFuture;
      final fast = await fastUpdateFuture;

      WebFController? currentController = await WebFControllerManager.instance.getController('test');
      expect(currentController?.entrypoint, equals(fastBundle));
      expect(currentController, equals(fast));
      expect(timeout, equals(null));
    });

    test('pending preload request with timeout should failed', () async {
      Completer<void> timeoutCompleter = Completer();
      final MockTimedBundle timeoutBundle = MockTimedBundle.controlled(completer: timeoutCompleter);
      // Start and await the fast update
      manager.addOrUpdateControllerWithLoading(
          name: 'test',
          mode: WebFLoadingMode.preloading,
          createController: () => TestWebFController(),
          bundle: timeoutBundle,
          timeout: Duration(seconds: 2)
      ).catchError((e, _) { return null; });

      bool shouldError = false;
      try {
        await WebFControllerManager.instance.getController('test');
      } catch (e) {
        shouldError = true;
      }

      expect(shouldError, equals(true));

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
          name: 'test',
          mode: WebFLoadingMode.preloading,
          createController: () => TestWebFController(),
          bundle: fastBundle,
          timeout: Duration(seconds: 2)
      );

      final fastController = await fastUpdateFuture;

      WebFController? currentController = await WebFControllerManager.instance.getController('test');
      expect(currentController, equals(fastController));
    });

    test('pending prerendering request with timeout should failed', () async {
      Completer<void> timeoutCompleter = Completer();
      final MockTimedBundle timeoutBundle = MockTimedBundle.controlled(completer: timeoutCompleter);
      // Start and await the fast update
      manager.addOrUpdateControllerWithLoading(
          name: 'test',
          mode: WebFLoadingMode.preRendering,
          createController: () => TestWebFController(),
          bundle: timeoutBundle,
          timeout: Duration(seconds: 2)
      ).catchError((e, _) { return null; });

      bool shouldError = false;
      try {
        await WebFControllerManager.instance.getController('test');
      } catch (e) {
        shouldError = true;
      }

      expect(shouldError, equals(true));

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');
      // Start and await the fast update
      final fastUpdateFuture = manager.addOrUpdateControllerWithLoading(
          name: 'test',
          mode: WebFLoadingMode.preRendering,
          createController: () => TestWebFController(),
          bundle: fastBundle,
          timeout: Duration(seconds: 2)
      );

      final fastController = await fastUpdateFuture;

      WebFController? currentController = await WebFControllerManager.instance.getController('test');
      expect(currentController, equals(fastController));
    });
  });
}
