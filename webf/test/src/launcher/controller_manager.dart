/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/launcher.dart';
import 'package:mockito/mockito.dart';

import '../foundation/mock_bundle.dart';

// We'll need to patch the controller to avoid the actual attachToFlutter call
class TestWebFController extends WebFController {

  bool _isFlutterAttached = false;
  bool get isFlutterAttached => _isFlutterAttached;

  @override
  void attachToFlutter(BuildContext context) {
    // Skip the actual attachment which requires a real BuildContext
    _isFlutterAttached = true;
  }

  @override
  void detachFromFlutter() {
    // Skip the actual detachment
    _isFlutterAttached = false;
  }
}

// Simple mock context
class MockBuildContext extends Fake implements BuildContext {}

void main() {
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

    tearDown(() {
      // Clean up after each test
      manager.disposeAll();
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
      manager.detachController('test');

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
      final updatedController = await manager.updateWithPreload(
        name: 'test',
        bundle: updatedBundle,
      );

      expect(updatedController, isNot(equals(initialController)));
      expect(manager.hasController('test'), isTrue);
      expect(manager.controllerCount, 1);
    });

    // Test race condition handling
    test('should handle race condition in updateWithPreload', () async {
      final MockTimedBundle initialBundle = MockTimedBundle.fast(content: 'console.log("Initial")');
      final initialController = await manager.addWithPreload(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: initialBundle,
      );

      // Start two update operations - a slow one and a fast one
      final slowCompleter = Completer<void>();
      final MockTimedBundle slowBundle = MockTimedBundle.controlled(
        completer: slowCompleter,
        content: 'console.log("Slow Update")',
      );

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Update")');

      // Create a controller factory that will wait for the completer
      TestWebFController createSlowController() {
        final controller = TestWebFController();
        // We'll manually set it to done in the test
        return controller;
      }

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.updateWithPreload(
        name: 'test',
        createController: createSlowController,
        bundle: slowBundle,
      );

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      // Start and await the fast update
      final fastUpdateFuture = manager.updateWithPreload(
        name: 'test',
        bundle: fastBundle,
      );

      // Cancel the slow update operation
      manager.cancelUpdateOrLoadingIfNecessary('test');

      // Now allow the slow update to complete
      slowCompleter.complete();

      // Get both results
      final slowController = await slowUpdateFuture;
      final fastController = await fastUpdateFuture;

      // The fast controller should be the one that's active
      final currentController = await manager.getController('test');

      // Current controller should equal the fast controller, not the slow one
      expect(currentController, equals(fastController));
      expect(currentController, isNot(equals(slowController)));

      // There should still only be one controller
      expect(manager.controllerCount, 1);
    });

    test('should handle race condition in updateWithPrerendering', () async {
      final MockTimedBundle initialBundle = MockTimedBundle.fast(content: 'console.log("Initial")');
      final initialController = await manager.addWithPrerendering(
        name: 'test',
        createController: () => TestWebFController(),
        bundle: initialBundle,
      );

      // Start two update operations - a slow one and a fast one
      final slowCompleter = Completer<void>();
      final MockTimedBundle slowBundle = MockTimedBundle.controlled(
        completer: slowCompleter,
        content: 'console.log("Slow Prerender")',
      );

      final MockTimedBundle fastBundle = MockTimedBundle.fast(content: 'console.log("Fast Prerender")');

      // Create a controller factory that will wait for the completer
      TestWebFController createSlowController() {
        final controller = TestWebFController();

        // We'll manually set it to done in the test
        return controller;
      }

      // Start the slow update (but don't await it)
      final slowUpdateFuture = manager.updateWithPrerendering(
        name: 'test',
        createController: createSlowController,
        bundle: slowBundle,
      );

      // Give a small delay to ensure the slow update starts first
      await Future.delayed(const Duration(milliseconds: 20));

      // Start and await the fast update
      final fastUpdateFuture = manager.updateWithPrerendering(
        name: 'test',
        bundle: fastBundle,
      );

      // Cancel the slow update operation
      manager.cancelUpdateOrLoadingIfNecessary('test');

      // Now allow the slow update to complete
      slowCompleter.complete();

      // Get both results
      final slowController = await slowUpdateFuture;
      final fastController = await fastUpdateFuture;

      // The fast controller should be the one that's active
      final currentController = await manager.getController('test');

      // Current controller should equal the fast controller, not the slow one
      expect(currentController, equals(fastController));
      expect(currentController, isNot(equals(slowController)));

      // There should still only be one controller
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
  });
}
