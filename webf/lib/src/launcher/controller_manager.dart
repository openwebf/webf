/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
/// Usage example:
/// ```dart
/// // Initialize the manager (usually in your app's main() function)
/// void main() {
///   WebFControllerManager.instance.initialize(
///     WebFControllerManagerConfig(
///       maxAliveInstances: 5,
///       maxAttachedInstances: 3,
///       onControllerDisposed: (name, controller) {
///         print('Controller $name was disposed');
///       },
///       onControllerDetached: (name, controller) {
///         print('Controller $name was detached');
///       }
///     )
///   );
///
///   // Add controllers
///   await WebFControllerManager.instance.addWithPrerendering(
///     name: 'home',
///     createController: () => WebFController(),
///     bundle: WebFBundle.fromUrl('https://example.com'),
///   );
///
///   // To use a controller with automatic lifecycle management:
///   runApp(AsyncWebF(controllerName: 'home'));
///
///   // Or use the controller directly:
///   final controller = await WebFControllerManager.instance.getController('home');
///   runApp(WebF(controller: controller!));
/// }
/// ```
class WebFControllerManagerConfig {
  /// Maximum number of WebFController instances that can be alive at the same time
  final int maxAliveInstances;

  /// Maximum number of attached WebFController instances at the same time
  final int maxAttachedInstances;

  /// Whether to dispose controllers when they exceed the maximum limit
  final bool autoDisposeWhenLimitReached;

  /// Callback triggered when a controller is disposed due to limit being reached
  final void Function(String name, WebFController controller)? onControllerDisposed;

  /// Callback triggered when a controller is detached due to limit being reached
  final void Function(String name, WebFController controller)? onControllerDetached;

  /// Constructor for WebFControllerManagerConfig
  const WebFControllerManagerConfig({
    this.maxAliveInstances = 5,
    this.maxAttachedInstances = 3,
    this.autoDisposeWhenLimitReached = true,
    this.onControllerDisposed,
    this.onControllerDetached,
  });
}

/// Controller state within the manager
enum ControllerState {
  attached,   // Controller is attached to Flutter
  detached,   // Controller is loaded but detached
  disposed    // Controller is disposed
}

/// Instance configuration holding controller and state
class _ControllerInstance {
  WebFController controller;
  ControllerState state;

  _ControllerInstance(this.controller, this.state);
}

/// Function that creates a WebFController
typedef ControllerFactory = WebFController Function();

/// Function for configuring a controller
typedef ControllerSetup = Function(WebFController controller);

/// Function that creates an WebFSubView
typedef SubViewBuilder = Widget Function(BuildContext context, WebFController);

/// A manager class that holds multiple WebFController instances
/// It manages the lifecycle of controllers and enforces resource limits
class WebFControllerManager {
  /// The singleton instance of the manager
  static final WebFControllerManager _instance = WebFControllerManager._internal();

  /// The configuration for the manager
  WebFControllerManagerConfig _config;

  /// Map of controller instances by name
  final Map<String, _ControllerInstance> _controllersByName = {};

  /// Queue to track the order of controller usage for LRU tracking
  final Queue<String> _recentlyUsedControllers = Queue<String>();

  /// Queue to track attached controllers
  final Queue<String> _attachedControllers = Queue<String>();

  /// Map to store creation parameters for re-initialization
  final Map<String, Map<String, dynamic>> _controllerInitParams = {};

  /// Private constructor for singleton
  WebFControllerManager._internal() : _config = const WebFControllerManagerConfig();

  /// Get the singleton instance of the manager
  static WebFControllerManager get instance => _instance;

  /// Get all registered router configs
  Map<String, WidgetBuilder> get routes {
    Map<String, WidgetBuilder> routes = {};
    _controllersByName.forEach((name, instance) {
      instance.controller.routes?.forEach((routeName, builder) {
        if (routes.containsKey(routeName)) {
          throw FlutterError('Found repeat routing name registered. Exist: $routeName, new: $routeName');
        }
        routes[routeName] = (context) => builder(context, instance.controller);
      });
    });
    return routes;
  }

  /// Get the router entry widget by router settings.
  Widget? getRouterBuilderBySettings(BuildContext context, String pageName, RouteSettings settings) {
    _ControllerInstance? instance = _controllersByName[pageName];
    if (instance == null) return null;
    SubViewBuilder? builder = instance.controller.routes?[settings.name];
    if (builder == null) return null;
    return builder(context, instance.controller);
  }

  /// Initialize the manager with custom configuration
  void initialize(WebFControllerManagerConfig config) {
    _config = config;
  }

  /// Count of attached controllers
  int get attachedControllersCount => _attachedControllers.length;

  /// Count of detached controllers
  int get detachedControllersCount =>
      _controllersByName.values.where((i) => i.state == ControllerState.detached).length;

  /// Manages controller lifecycle with preloading
  /// Works as both adding a new controller or updating an existing one
  /// Returns the preloaded controller ready for use
  ///
  /// When used as addWithPreload (createController is required):
  ///   - Creates a new controller with the factory
  ///   - Registers it with the provided name
  ///   - Preloads the bundle
  ///
  /// When used as updateWithPreload (createController is optional):
  ///   - If an existing controller is found, it preserves its context and state
  ///   - Creates a new controller instance to replace the old one
  ///   - Maintains attachment state and context
  ///   - Disposes the old controller once the new one is ready
  Future<WebFController> addOrUpdateWithPreload({
    required String name,
    ControllerFactory? createController,
    required WebFBundle bundle,
    Map<String, SubViewBuilder>? routes,
    ControllerSetup? setup,
    bool forceReplace = false
  }) async {
    // Check if controller already exists
    final oldController = getControllerSync(name);
    final currentState = getControllerState(name);
    final Map<String, SubViewBuilder>? oldRoutes = oldController?.routes;

    // Get existing initialization parameters if available
    final oldParams = _controllerInitParams[name];

    // Determine which factory to use - logic differs based on whether this is an add or update
    ControllerFactory actualCreateController;
    if (createController != null) {
      // Explicit factory provided
      actualCreateController = createController;
    } else if (oldParams != null && oldParams['createController'] != null) {
      // Use previously stored factory for update case
      actualCreateController = oldParams['createController'];
    } else {
      // Add operation requires a factory
      throw ArgumentError('createController is required when adding a new controller');
    }

    // If we have an existing controller and force replace is false, just update usage and return
    if (oldController != null && !forceReplace && currentState != ControllerState.disposed) {
      _updateUsageOrder(name);
      return oldController;
    }

    // Check if we've reached max capacity and enforce limits if needed (only for new controllers)
    if ((oldController == null || currentState == ControllerState.disposed) &&
        _controllersByName.length >= _config.maxAliveInstances &&
        _config.autoDisposeWhenLimitReached) {
      _disposeLeastRecentlyUsed();
    }

    // Create a new controller instance
    WebFController newController = actualCreateController();

    // Handle routes - preserve old routes if needed
    if (routes == null && oldRoutes != null) {
      newController.routes = oldRoutes;
    } else if (routes != null) {
      newController.routes = routes;
    }

    // Store initialization parameters for potential re-initialization
    _controllerInitParams[name] = {
      'type': 'preload',
      'createController': actualCreateController,
      'bundle': bundle,
      'routes': newController.routes,
      'setup': setup ?? oldParams?['setup'],
    };

    // Wait for the new controller to initialize
    await newController.controlledInitCompleter.future;

    // Apply optional setup
    if (setup != null) {
      setup(newController);
    } else if (oldParams?['setup'] != null) {
      // Apply the previous setup if available and no new setup is provided
      ControllerSetup oldSetup = oldParams!['setup'];
      oldSetup(newController);
    }

    // Preload the bundle
    await newController.preload(bundle);

    // Should check if this controller was canceled during preloading
    if (newController.preloadStatus == PreloadingStatus.fail) {
      return oldController ?? newController;
    }

    // Remove the old controller from tracking if it exists
    final instance = _controllersByName.remove(name);
    _recentlyUsedControllers.removeWhere((element) => element == name);
    _attachedControllers.removeWhere((element) => element == name);

    // Register the new controller with the same name and preserve attached state if needed
    _controllersByName[name] = _ControllerInstance(
      newController,
      ControllerState.detached
    );
    _updateUsageOrder(name);

    // Schedule disposal of the old controller after returning the new one, if it exists
    if (instance != null && !instance.controller.disposed) {
      Future.microtask(() async {
        await instance.controller.dispose();
      });
    }

    return newController;
  }

  /// Adds a controller with preloading enabled (legacy support)
  /// This handles controller creation, initialization, preloading, and registration
  /// Returns the preloaded controller ready for use
  @Deprecated('Use addOrUpdateWithPreload instead')
  Future<WebFController> addWithPreload({
    required String name,
    required ControllerFactory createController,
    required WebFBundle bundle,
    Map<String, SubViewBuilder>? routes,
    ControllerSetup? setup
  }) async {
    return addOrUpdateWithPreload(
      name: name,
      createController: createController,
      bundle: bundle,
      routes: routes,
      setup: setup,
      forceReplace: false,
    );
  }

  /// Adds a controller with prerendering enabled
  /// This handles controller creation, initialization, prerendering, and registration
  /// Returns the prerendered controller ready for use
  Future<WebFController> addWithPrerendering({
    required String name,
    required ControllerFactory createController,
    required WebFBundle bundle,
    Map<String, SubViewBuilder>? routes,
    ControllerSetup? setup
  }) async {
    // Store initialization parameters for potential re-initialization
    _controllerInitParams[name] = {
      'type': 'prerendering',
      'createController': createController,
      'bundle': bundle,
      'routes': routes,
      'setup': setup,
    };

    // Check if controller already exists
    if (_controllersByName.containsKey(name)) {
      final instance = _controllersByName[name]!;

      // If it's disposed, remove it
      if (instance.state == ControllerState.disposed) {
        _controllersByName.remove(name);
      } else {
        // If it's not disposed, update usage order and return
        _updateUsageOrder(name);
        return instance.controller;
      }
    }

    // Check if we've reached max capacity and enforce limits if needed
    if (_controllersByName.length >= _config.maxAliveInstances &&
        _config.autoDisposeWhenLimitReached) {
      _disposeLeastRecentlyUsed();
    }

    // Create the controller
    WebFController controller = createController();

    // Register first to establish name mapping (state will be detached)
    registerController(name, controller);

    // Set routes
    controller.routes = routes;

    // Wait for initialization
    await controller.controlledInitCompleter.future;

    // Apply optional setup
    if (setup != null) {
      setup(controller);
    }

    // Prerender the bundle
    await controller.preRendering(bundle);

    // Return the registered controller
    return controller;
  }

  /// Stop the current pending loading or updating controller to be added in this manager
  void cancelUpdateOrLoadingIfNecessary(String name) {
    final _ControllerInstance? instance = _controllersByName[name];
    if (instance != null) {
      // Set status to prevent further processing
      if (instance.controller.preloadStatus == PreloadingStatus.preloading) {
        instance.controller.preloadStatus = PreloadingStatus.fail;
      }
      if (instance.controller.preRenderingStatus == PreRenderingStatus.preloading ||
          instance.controller.preRenderingStatus == PreRenderingStatus.evaluate ||
          instance.controller.preRenderingStatus == PreRenderingStatus.rendering) {
        instance.controller.preRenderingStatus = PreRenderingStatus.fail;
      }
    }
  }

  /// Re-create a controller that was previously disposed using stored parameters
  Future<WebFController> _recreateController(String name) async {
    // Remove the disposed controller instance
    _controllersByName.remove(name);

    // Get stored parameters
    final params = _controllerInitParams[name]!;

    // Re-create based on type
    if (params['type'] == 'preload') {
      return await addOrUpdateWithPreload(
        name: name,
        createController: params['createController'],
        bundle: params['bundle'],
        routes: params['routes'],
        setup: params['setup'],
      );
    } else {
      return await addWithPrerendering(
        name: name,
        createController: params['createController'],
        bundle: params['bundle'],
        routes: params['routes'],
        setup: params['setup'],
      );
    }
  }

  /// Attaches a controller to Flutter
  /// Call this when the WebF widget is mounted
  void attachController(String name, BuildContext context) {
    if (!_controllersByName.containsKey(name)) {
      throw FlutterError('Cannot attach non-existent controller: $name');
    }

    final instance = _controllersByName[name]!;
    final controller = instance.controller;

    // If already attached, just update usage order
    if (instance.state == ControllerState.attached) {
      _updateAttachedOrder(name);
      _updateUsageOrder(name);
      return;
    }

    // Check attached limit and detach least recently used if needed
    if (_attachedControllers.length >= _config.maxAttachedInstances) {
      _detachLeastRecentlyUsed();
    }

    // Attach controller to Flutter
    controller.attachToFlutter(context);
    instance.state = ControllerState.attached;

    // Update tracking queues
    _attachedControllers.add(name);
    _updateUsageOrder(name);
  }

  /// Detaches a controller from Flutter
  /// Call this when the WebF widget is unmounted
  void detachController(String name, BuildContext context) {
    if (!_controllersByName.containsKey(name)) {
      return;
    }

    final instance = _controllersByName[name]!;
    final controller = instance.controller;

    // Only detach if currently attached
    if (instance.state == ControllerState.attached) {
      controller.detachFromFlutter(context);
      instance.state = ControllerState.detached;

      // Update tracking queue
      _attachedControllers.removeWhere((element) => element == name);

      // Notify through callback if provided
      if (_config.onControllerDetached != null) {
        _config.onControllerDetached!(name, controller);
      }
    }
  }

  /// Update the order of attached controllers for LRU tracking
  void _updateAttachedOrder(String name) {
    // Remove the name from its current position in the queue
    _attachedControllers.removeWhere((element) => element == name);
    // Add it to the end (most recently used)
    _attachedControllers.add(name);
  }

  /// Detach the least recently used attached controller
  void _detachLeastRecentlyUsed() {
    if (_attachedControllers.isEmpty) return;

    // Get the least recently used attached controller name
    final String leastRecentlyUsedName = _attachedControllers.removeFirst();
    final _ControllerInstance? instance = _controllersByName[leastRecentlyUsedName];

    // Detach the controller if it exists and is attached
    if (instance != null && instance.state == ControllerState.attached) {
      final controller = instance.controller;
      controller.detachFromFlutter(null);
      instance.state = ControllerState.detached;

      // Notify through callback if provided
      if (_config.onControllerDetached != null) {
        _config.onControllerDetached!(leastRecentlyUsedName, controller);
      }
    }
  }

  /// Register a controller with the manager
  /// Returns the registered controller for chaining
  WebFController registerController(String name, WebFController controller) {
    // If a controller with this name already exists, update its usage order and return it
    if (_controllersByName.containsKey(name) &&
        _controllersByName[name]!.state != ControllerState.disposed) {
      _updateUsageOrder(name);
      return _controllersByName[name]!.controller;
    }

    // Remove any disposed controller with this name
    if (_controllersByName.containsKey(name) &&
        _controllersByName[name]!.state == ControllerState.disposed) {
      _controllersByName.remove(name);
      // Also cleanup from usage tracking
      _recentlyUsedControllers.removeWhere((element) => element == name);
    }

    // Check if we've reached max capacity and dispose if needed
    if (_controllersByName.length >= _config.maxAliveInstances &&
        _config.autoDisposeWhenLimitReached) {
      _disposeLeastRecentlyUsed();
    }

    // Register the controller in detached state initially
    _controllersByName[name] = _ControllerInstance(controller, ControllerState.detached);
    _updateUsageOrder(name);
    return controller;
  }

  /// Get a controller instance by name
  /// If the controller doesn't exist, returns null
  static Future<WebFController?> getInstance(String name) async {
    return await _instance.getController(name);
  }

  /// Get a controller instance by name synchronously
  /// Unlike getController, this won't attempt to recreate disposed controllers
  /// Use this when you need immediate access without recreation
  WebFController? getControllerSync(String name) {
    if (_controllersByName.containsKey(name)) {
      final instance = _controllersByName[name]!;

      // If controller is disposed, remove it and return null
      if (instance.state == ControllerState.disposed) {
        // Remove from tracking collections to prevent memory leaks
        _controllersByName.remove(name);
        _recentlyUsedControllers.removeWhere((element) => element == name);
        _attachedControllers.removeWhere((element) => element == name);
        return null;
      }

      // Update usage order for non-disposed controllers
      _updateUsageOrder(name);
      return instance.controller;
    }
    return null;
  }

  /// Get a controller instance by name synchronously
  /// Unlike getController, this won't attempt to recreate disposed controllers
  static WebFController? getInstanceSync(String name) {
    return _instance.getControllerSync(name);
  }

  /// Get a controller by name
  /// Updates usage order if found
  /// Automatically recreates the controller if it was disposed but init params exist
  Future<WebFController?> getController(String name) async {
    // If the controller exists
    if (_controllersByName.containsKey(name)) {
      final instance = _controllersByName[name]!;

      // If controller is in disposed state but we have init params, recreate it
      if (instance.state == ControllerState.disposed) {
        // First remove the disposed instance to prevent memory leaks
        _controllersByName.remove(name);
        _recentlyUsedControllers.removeWhere((element) => element == name);

        // Then recreate if we have initialization parameters
        if (_controllerInitParams.containsKey(name)) {
          return await _recreateController(name);
        }

        // If no init params, return null
        return null;
      }

      // Update usage order for non-disposed controllers
      _updateUsageOrder(name);
      return instance.controller;
    }

    // If controller doesn't exist but we have init params, recreate it
    if (_controllerInitParams.containsKey(name)) {
      return await _recreateController(name);
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

    // Find the least recently used controller that's not attached
    String? leastRecentlyUsedName;
    for (final name in _recentlyUsedControllers) {
      final instance = _controllersByName[name];
      if (instance != null && instance.state != ControllerState.attached) {
        leastRecentlyUsedName = name;
        break;
      }
    }

    // If all are attached, return without disposing
    if (leastRecentlyUsedName == null) return;

    // Remove from queue
    _recentlyUsedControllers.remove(leastRecentlyUsedName);

    // Get the controller
    final _ControllerInstance? instance = _controllersByName[leastRecentlyUsedName];

    // Update state to disposed
    if (instance != null && !instance.controller.disposed) {
      final controller = instance.controller;

      // Remove from map to avoid memory leaks
      _controllersByName.remove(leastRecentlyUsedName);

      // Notify through callback if provided
      if (_config.onControllerDisposed != null) {
        _config.onControllerDisposed!(leastRecentlyUsedName, controller);
      }

      // Make sure script fully evaluated
      controller.controllerOnDOMContentLoadedCompleter.future.then((_) {
        // Delay dispose and waiting for the executing for current scripts
        controller.dispose();
      });
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

  /// Get the state of a controller
  ControllerState? getControllerState(String name) {
    return _controllersByName[name]?.state;
  }

  /// Find the name of a controller by its instance
  String? getControllerName(WebFController controller) {
    for (final entry in _controllersByName.entries) {
      if (entry.value.controller == controller) {
        return entry.key;
      }
    }
    return null;
  }

  /// Updates a controller by creating a new instance with preload
  /// This replaces the existing controller with a fresh instance
  /// Returns the new controller ready for use
  @Deprecated('Use addOrUpdateWithPreload instead')
  Future<WebFController> updateWithPreload({
    required String name,
    ControllerFactory? createController,
    required WebFBundle bundle,
    Map<String, SubViewBuilder>? routes,
    ControllerSetup? setup
  }) async {
    return addOrUpdateWithPreload(
      name: name,
      createController: createController,
      bundle: bundle,
      routes: routes,
      setup: setup,
      forceReplace: true, // Update always forces replacement
    );
  }

  /// Updates a controller by creating a new instance with prerendering
  /// This replaces the existing controller with a fresh instance
  /// Returns the new controller ready for use
  Future<WebFController> updateWithPrerendering({
    required String name,
    ControllerFactory? createController,
    required WebFBundle bundle,
    Map<String, SubViewBuilder>? routes,
    ControllerSetup? setup
  }) async {
    final oldController = getControllerSync(name);
    Map<String, SubViewBuilder>? oldRoutes = oldController?.routes;

    // Get existing initialization parameters if available
    final oldParams = _controllerInitParams[name];

    // Determine which factory to use (prefer provided, fallback to existing, or create default)
    ControllerFactory actualCreateController;
    if (createController != null) {
      actualCreateController = createController;
    } else if (oldParams != null && oldParams['createController'] != null) {
      actualCreateController = oldParams['createController'];
    } else {
      actualCreateController = () => WebFController();
    }

    // Create a new controller instance
    WebFController newController = actualCreateController();

    // Copy relevant properties from old controller to new controller
    if (routes == null && oldRoutes != null) {
      newController.routes = oldRoutes;
    } else if (routes != null) {
      newController.routes = routes;
    }

    // Store updated initialization parameters
    _controllerInitParams[name] = {
      'type': 'prerendering',
      'createController': actualCreateController,
      'bundle': bundle,
      'routes': newController.routes,
      'setup': setup ?? oldParams?['setup'],
    };

    // Wait for the new controller to initialize
    await newController.controlledInitCompleter.future;

    // Apply optional setup
    if (setup != null) {
      setup(newController);
    } else if (oldParams?['setup'] != null) {
      // Apply the previous setup if available and no new setup is provided
      ControllerSetup oldSetup = oldParams!['setup'];
      oldSetup(newController);
    }

    // Prerender the new bundle
    await newController.preRendering(bundle);

    // Should check if this controller was canceled during prerendering
    if (newController.preRenderingStatus == PreRenderingStatus.fail) {
      return oldController ?? newController;
    }

    // Remove the old controller from tracking if it exists
    final instance = _controllersByName.remove(name);
    _recentlyUsedControllers.removeWhere((element) => element == name);
    _attachedControllers.removeWhere((element) => element == name);

    // Register the new controller with the same name
    _controllersByName[name] = _ControllerInstance(
      newController,
      ControllerState.detached
    );
    _updateUsageOrder(name);

    // Schedule disposal of the old controller after returning the new one, if it exists
    if (instance != null && !instance.controller.disposed) {
      Future.microtask(() async {
        await instance.controller.dispose();
      });
    }

    return newController;
  }

  /// Remove a controller by name without disposing it
  WebFController? removeController(String name) {
    final instance = _controllersByName.remove(name);
    if (instance != null) {
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);
      return instance.controller;
    }
    return null;
  }

  /// Remove and dispose a controller by name
  Future<void> removeAndDisposeController(String name) async {
    final instance = _controllersByName[name];
    if (instance != null && !instance.controller.disposed) {
      // Detach first if attached
      if (instance.state == ControllerState.attached) {
        instance.controller.detachFromFlutter();
        _attachedControllers.removeWhere((element) => element == name);
      }

      // Get reference to controller before removing from map
      final controller = instance.controller;

      // Remove from all tracking collections to prevent memory leaks
      _controllersByName.remove(name);
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);

      // Then dispose
      await controller.dispose();
    } else if (instance != null) {
      // Even if already disposed, remove from tracking collections
      _controllersByName.remove(name);
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);
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

    // Clear all tracking structures
    _controllersByName.clear();
    _recentlyUsedControllers.clear();
    _attachedControllers.clear();
    _controllerInitParams.clear();
  }

  /// Get the configuration
  WebFControllerManagerConfig get config => _config;
}
