/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';

/// WebFController is the main controller for WebF applications.
///
/// This manager (WebFControllerManager) provides a way to:
/// 1. Keep track of multiple WebFController instances
/// 2. Cache and reuse controllers by name
/// 3. Limit the number of active controllers to prevent memory leaks
/// 4. Dispose controllers when they are no longer needed
///
/// Configuration for the WebFControllerManager
class WebFControllerManagerConfig {
  /// Maximum number of WebFController instances that can be alive at the same time
  final int maxAliveInstances;

  /// Whether to dispose controllers when they exceed the maximum limit
  final bool autoDisposeWhenLimitReached;

  /// Callback triggered when a controller is disposed due to limit being reached
  final void Function(String name, WebFController controller)? onControllerDisposed;

  /// Constructor for WebFControllerManagerConfig
  const WebFControllerManagerConfig({
    this.maxAliveInstances = 5,
    this.autoDisposeWhenLimitReached = true,
    this.onControllerDisposed,
  });
}


/// Function that creates a WebFController
typedef ControllerFactory = WebFController Function();

/// Function for configuring a controller
typedef ControllerSetup = Function(WebFController controller);


/// A manager class that holds multiple WebFController instances
/// It manages the lifecycle of controllers and enforces resource limits
class WebFControllerManager {
  /// The singleton instance of the manager
  static final WebFControllerManager _instance = WebFControllerManager._internal();

  /// The configuration for the manager
  WebFControllerManagerConfig _config;

  /// Map of controller instances by name
  final Map<String, WebFController> _controllersByName = {};

  /// Queue to track the order of controller usage for LRU disposal
  final Queue<String> _recentlyUsedControllers = Queue<String>();

  /// Private constructor for singleton
  WebFControllerManager._internal() : _config = const WebFControllerManagerConfig();

  /// Get the singleton instance of the manager
  static WebFControllerManager get instance => _instance;

  /// Initialize the manager with custom configuration
  void initialize(WebFControllerManagerConfig config) {
    _config = config;
  }

  /// Adds a controller to the manager using a factory function
  /// This allows flexible creation and configuration of controllers
  /// Returns the configured and registered controller
  Future<WebFController> add({
    required String name,
    required ControllerFactory createController,
    ControllerSetup? setup
  }) async {
    // Create the controller using the factory function
    WebFController controller = createController();

    // Wait for controller initialization
    await controller.controlledInitCompleter.future;

    // Apply optional setup
    if (setup != null) {
      setup(controller);
    }

    // Register the controller
    return registerController(name, controller);
  }

  /// Adds a controller with preloading enabled
  /// This handles controller creation, initialization, preloading, and registration
  /// Returns the preloaded controller ready for use
  Future<WebFController> addWithPreload({
    required String name,
    required ControllerFactory createController,
    required WebFBundle bundle,
    ControllerSetup? setup
  }) async {
    // Create the controller
    WebFController controller = createController();

    // Wait for initialization
    await controller.controlledInitCompleter.future;

    // Apply optional setup
    if (setup != null) {
      setup(controller);
    }

    // Preload the bundle
    await controller.preload(bundle);

    // Register the controller
    return registerController(name, controller);
  }

  /// Adds a controller with prerendering enabled
  /// This handles controller creation, initialization, prerendering, and registration
  /// Returns the prerendered controller ready for use
  Future<WebFController> addWithPrerendering({
    required String name,
    required ControllerFactory createController,
    required WebFBundle bundle,
    ControllerSetup? setup
  }) async {
    // Create the controller
    WebFController controller = createController();
    registerController(name, controller);

    // Wait for initialization
    await controller.controlledInitCompleter.future;

    // Apply optional setup
    if (setup != null) {
      setup(controller);
    }

    // Prerender the bundle
    await controller.preRendering(bundle);

    // Register the controller
    return controller;
  }

  /// Register a controller with the manager
  /// Returns the registered controller for chaining
  WebFController registerController(String name, WebFController controller) {
    // Check if we've reached max capacity
    if (_controllersByName.length >= _config.maxAliveInstances &&
        _config.autoDisposeWhenLimitReached) {
      _disposeLeastRecentlyUsed();
    }

    // Register the controller and update usage order
    _controllersByName[name] = controller;
    _updateUsageOrder(name);
    return controller;
  }

  /// Get a controller instance by name
  /// If the controller doesn't exist, returns null
  static WebFController? getInstance(String name) {
    return _instance.getController(name);
  }

  /// Get a controller by name
  /// Updates usage order if found
  WebFController? getController(String name) {
    if (_controllersByName.containsKey(name)) {
      _updateUsageOrder(name);
      return _controllersByName[name];
    }
    return null;
  }

  /// Update the usage order for LRU tracking
  void _updateUsageOrder(String name) {
    // Remove the name from its current position in the queue
    _recentlyUsedControllers.removeWhere((element) => element == name);
    // Add it to the end (most recently used)
    _recentlyUsedControllers.add(name);
  }

  /// Dispose the least recently used controller
  void _disposeLeastRecentlyUsed() {
    if (_recentlyUsedControllers.isEmpty) return;

    // Get the least recently used controller name
    final String leastRecentlyUsedName = _recentlyUsedControllers.removeFirst();
    final WebFController? controller = _controllersByName.remove(leastRecentlyUsedName);

    // Dispose the controller if it exists
    if (controller != null && !controller.disposed) {
      // Notify through callback if provided
      if (_config.onControllerDisposed != null) {
        _config.onControllerDisposed!(leastRecentlyUsedName, controller);
      }
      controller.dispose();
    }
  }

  /// Check if a controller with the given name exists
  bool hasController(String name) {
    return _controllersByName.containsKey(name);
  }

  /// Get all controller names
  List<String> get controllerNames => _controllersByName.keys.toList();

  /// Get the number of active controllers
  int get controllerCount => _controllersByName.length;

  /// Remove a controller by name without disposing it
  WebFController? removeController(String name) {
    final controller = _controllersByName.remove(name);
    _recentlyUsedControllers.removeWhere((element) => element == name);
    return controller;
  }

  /// Remove and dispose a controller by name
  Future<void> removeAndDisposeController(String name) async {
    final controller = removeController(name);
    if (controller != null && !controller.disposed) {
      await controller.dispose();
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    // Create a copy of the keys to avoid concurrent modification issues
    final names = List<String>.from(_controllersByName.keys);

    // Dispose each controller
    for (final name in names) {
      await removeAndDisposeController(name);
    }

    _controllersByName.clear();
    _recentlyUsedControllers.clear();
  }

  /// Get the configuration
  WebFControllerManagerConfig get config => _config;
}
