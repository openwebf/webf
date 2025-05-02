/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';

/// Configuration options for the WebFControllerManager.
///
/// This class provides settings to control how the manager handles controller
/// lifecycle, resource limits, and notifications. Key configuration options include:
/// - Maximum number of alive and attached controllers
/// - Auto-disposal policy for controllers
/// - Callbacks for controller lifecycle events
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
/// }
/// ```
class WebFControllerManagerConfig {
  /// Maximum number of WebFController instances that can be alive at the same time.
  ///
  /// When this limit is reached and a new controller is requested, the least
  /// recently used controller will be disposed if autoDisposeWhenLimitReached is true.
  final int maxAliveInstances;

  /// Maximum number of WebFController instances that can be attached to Flutter at the same time.
  ///
  /// When this limit is reached and a new controller is attached, the least
  /// recently used attached controller will be detached (but not disposed).
  final int maxAttachedInstances;

  /// Whether to automatically dispose controllers when limits are exceeded.
  ///
  /// When true, the manager will dispose the least recently used controllers
  /// when the maxAliveInstances limit is reached. When false, the limit acts
  /// as a soft limit and new controllers will still be created.
  final bool autoDisposeWhenLimitReached;

  /// Callback triggered when a controller is disposed.
  ///
  /// This callback is invoked whenever a controller is disposed, whether due to
  /// resource limits being reached or explicit disposal by the application.
  final void Function(String name, WebFController controller)? onControllerDisposed;

  /// Callback triggered when a controller is detached from Flutter.
  ///
  /// This callback is invoked whenever a controller is detached, whether due to
  /// attachment limits being reached or explicit detachment by the application.
  final void Function(String name, WebFController controller)? onControllerDetached;

  /// Creates a new configuration object for WebFControllerManager.
  ///
  /// All parameters have reasonable defaults suitable for most applications.
  const WebFControllerManagerConfig({
    this.maxAliveInstances = 5,
    this.maxAttachedInstances = 3,
    this.autoDisposeWhenLimitReached = true,
    this.onControllerDisposed,
    this.onControllerDetached,
  });
}

/// Represents the possible states of a controller within the manager.
///
/// - attached: Controller is connected to Flutter and actively rendering
/// - detached: Controller is loaded but not currently rendering
/// - disposed: Controller has released its resources and is no longer usable
enum ControllerState {
  attached, // Controller is attached to Flutter
  detached, // Controller is loaded but detached
  disposed // Controller is disposed
}

/// Internal class that pairs a controller with its current state.
///
/// Used to track controllers in the manager's collections.
class _ControllerInstance {
  WebFController controller;
  ControllerState state;

  _ControllerInstance(this.controller, this.state);
}

/// Represents the loading state of a controller during initialization.
///
/// - idle: Controller is not currently loading anything
/// - loading: Controller is in the process of loading
/// - success: Controller has successfully loaded its content
/// - error: Controller encountered an error during loading
enum ControllerLoadState { idle, loading, success, error }

/// Internal class used to track controllers during concurrent loading operations.
///
/// Maintains the controller reference, a stopwatch to measure loading time,
/// and the current loading state.
class _ConcurrencyControllerInstance {
  WebFController controller;
  Stopwatch stopwatch;
  ControllerLoadState state;

  _ConcurrencyControllerInstance(this.controller, this.stopwatch, this.state);
}

/// Function type for factory methods that create new WebFController instances.
///
/// Used when adding or updating controllers to create new instances on demand.
typedef ControllerFactory = WebFController Function();

/// Function type for setup callbacks that configure a controller after creation.
///
/// Used to customize a controller's properties or behavior before it's used.
typedef ControllerSetup = Function(WebFController controller);

/// Function type for creating widgets using a WebFController.
///
/// Used for defining route handlers and subviews in the hybrid routing system.
typedef SubViewBuilder = Widget Function(BuildContext context, WebFController);

/// A manager class that holds multiple WebFController instances.
///
/// It manages the lifecycle of controllers and enforces resource limits to prevent
/// memory leaks while providing efficient controller reuse. Key features include:
///
/// - Caching and reusing controllers by name
/// - Automatic recreation of disposed controllers when needed
/// - Limiting the number of active and attached controllers
/// - Handling concurrent requests for the same controller
/// - Supporting preloading and prerendering for optimal performance
class WebFControllerManager {
  /// The singleton instance of the manager.
  static final WebFControllerManager _instance = WebFControllerManager._internal();

  /// The configuration for the manager.
  WebFControllerManagerConfig _config;

  /// Map of controller instances by name.
  final Map<String, _ControllerInstance> _controllersByName = {};

  /// Map of controller instances requested in concurrency at the same time by name.
  final Map<String, List<_ConcurrencyControllerInstance>> _concurrencyControllerByName = {};

  /// Map of completers used to coordinate concurrent requests for the same controller.
  final Map<String, Completer<WebFController>> _concurrencyRaceCompleter = {};

  /// Queue to track the order of controller usage for LRU tracking.
  final Queue<String> _recentlyUsedControllers = Queue<String>();

  /// Queue to track attached controllers.
  final Queue<String> _attachedControllers = Queue<String>();

  /// Map to store creation parameters for future re-initialization.
  final Map<String, Map<String, dynamic>> _controllerInitParams = {};

  /// Private constructor for the singleton implementation.
  WebFControllerManager._internal() : _config = const WebFControllerManagerConfig();

  /// Gets the singleton instance of the manager.
  static WebFControllerManager get instance => _instance;

  /// Gets all registered route configurations from all controllers.
  ///
  /// This collects all routes registered with individual controllers and combines them
  /// into a single map that can be used with Flutter navigation.
  ///
  /// Returns a map where keys are route paths and values are WidgetBuilder functions
  /// that construct the appropriate view for each route.
  ///
  /// Throws a FlutterError if duplicate route names are detected across controllers.
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

  /// Gets the appropriate widget for a specific route within a named controller.
  ///
  /// This method looks up a named controller and attempts to find a matching route handler
  /// within that controller's registered routes.
  ///
  /// [context] The BuildContext to be passed to the route builder.
  /// [pageName] The name of the controller to look up.
  /// [settings] The route settings containing the path to match.
  ///
  /// Returns a Widget if the controller and route are found, null otherwise.
  Widget? getRouterBuilderBySettings(BuildContext context, String pageName, RouteSettings settings) {
    _ControllerInstance? instance = _controllersByName[pageName];
    if (instance == null) return null;
    SubViewBuilder? builder = instance.controller.routes?[settings.name];
    if (builder == null) return null;
    return builder(context, instance.controller);
  }

  /// Initializes the manager with custom configuration.
  ///
  /// This method allows customizing the behavior of the controller manager, including
  /// setting resource limits and callback handlers.
  ///
  /// [config] The configuration object containing settings such as max instances,
  ///          auto-disposal behavior, and callbacks for lifecycle events.
  void initialize(WebFControllerManagerConfig config) {
    _config = config;
  }

  /// Gets the count of currently attached controllers.
  int get attachedControllersCount => _attachedControllers.length;

  /// Gets the count of currently detached controllers.
  int get detachedControllersCount =>
      _controllersByName.values.where((i) => i.state == ControllerState.detached).length;

  /// Handles concurrent requests for the same controller.
  ///
  /// This internal method ensures that multiple simultaneous requests for the same
  /// controller are handled efficiently with a race condition pattern. Only one request
  /// will actually create the controller, and all other concurrent requests will wait
  /// for that one to complete and then receive the same controller instance.
  ///
  /// [name] The unique name of the controller being requested.
  /// [actualCreateController] The factory function to create the controller.
  /// [bundle] The content bundle to load.
  /// [mode] The loading mode (preloading or prerendering).
  /// [routes] Optional routing configuration.
  /// [setup] Optional function to configure the controller.
  /// [oldController] Optional existing controller to use as fallback.
  /// [oldParams] Optional previously stored parameters for this controller.
  ///
  /// Returns a WebFController instance that satisfies all concurrent requests.
  Future<WebFController> _raceConcurrencyController(
    String name,
    WebFController newController,
    Future<void> newControllerRequestFuture,
    _ConcurrencyControllerInstance newControllerConcurrencyInstance,
    List<_ConcurrencyControllerInstance> concurrencyLists,
    Completer<WebFController> raceCompleter,
  ) async {
    newControllerRequestFuture.then((_) {
      debugPrint('WebFControllerManager: $newController load success');
      newControllerConcurrencyInstance.state = ControllerLoadState.success;

      if (raceCompleter.isCompleted) return;

      // Handing single success request.
      if (concurrencyLists.length == 1) {
        _concurrencyRaceCompleter[name]!.complete(concurrencyLists[0].controller);
      } else {
        int errorAmount = 0;
        // Handing multiple requests
        // For multiple requests, we check the race state and return the final winner controller instance.
        for (int i = concurrencyLists.length - 1; i >= 0; i--) {
          _ConcurrencyControllerInstance instance = concurrencyLists[i];
          // If the last concurrency was success, the winner is him.
          if (i == concurrencyLists.length - 1 - errorAmount && instance.state == ControllerLoadState.success) {
            _concurrencyRaceCompleter[name]!.complete(instance.controller);
          }
          if (instance.state == ControllerLoadState.error) {
            errorAmount++;
          }
        }
        // if the resolved controller was not in the last one, we do nothing and wait for the last one to finish.
      }
    }).catchError((e, stack) {
      debugPrint('WebFControllerManager: $newController load failed');
      newControllerConcurrencyInstance.state = ControllerLoadState.error;

      if (raceCompleter.isCompleted) return;

      // Handing single failed request.
      if (concurrencyLists.length == 1) {
        raceCompleter.completeError(e, stack);
      } else {
        for (int i = concurrencyLists.length - 1; i >= 0; i--) {
          _ConcurrencyControllerInstance instance = concurrencyLists[i];
          // If there are still pending instance, waiting for the last one returns.
          if (instance.state == ControllerLoadState.loading) return;
          // Use the most closest previous sibling as possible
          if (instance.state == ControllerLoadState.success) {
            raceCompleter.complete(instance.controller);
            return;
          }
        }
        // No available success controller instance found.
        raceCompleter.completeError(e, stack);
      }
    });

    return _concurrencyRaceCompleter[name]!.future;
  }

  /// Unified method to add or update a controller with preloading or prerendering.
  ///
  /// This is the core method that handles all controller lifecycle operations, including:
  /// - Creating new controllers
  /// - Updating existing controllers
  /// - Preloading or prerendering content
  /// - Managing fallback mechanisms for error handling
  /// - Enforcing resource limits
  /// - Tracking controller state and usage
  ///
  /// When adding a new controller (createController is required):
  ///   - Creates a new controller with the factory function
  ///   - Registers it with the provided name
  ///   - Preloads the bundle using the specified mode
  ///   - Tracks initialization parameters for potential recreation
  ///
  /// When updating an existing controller:
  ///   - If forceReplace is false and a valid controller exists, returns it immediately
  ///   - Otherwise, creates a new controller instance to replace the old one
  ///   - Preserves routes and setup configurations when appropriate
  ///   - Maintains initialization parameters for future recreation
  ///   - Safely disposes the old controller after successful update
  ///
  /// Error handling:
  ///   - If controller creation fails, falls back to existing controller if available
  ///   - If preloading fails, attempts to return to previous working controller
  ///   - If all attempts fail, throws an appropriate error
  ///
  /// [name] The unique name to identify this controller.
  /// [createController] Optional factory function to create a controller (required for new controllers).
  /// [bundle] The content bundle to load.
  /// [mode] The loading mode (preloading or prerendering).
  /// [routes] Optional routing configuration.
  /// [setup] Optional function to configure the controller after creation.
  /// [forceReplace] Whether to force replacement of an existing controller.
  ///
  /// Returns the created or updated controller, or null if the controller was canceled due to concurrency rules.
  /// The return value is nullable to handle race conditions where another concurrent request won.
  Future<WebFController?> addOrUpdateControllerWithLoading(
      {required String name,
      ControllerFactory? createController,
      required WebFBundle bundle,
      required WebFLoadingMode mode,
      Map<String, SubViewBuilder>? routes,
      ControllerSetup? setup,
      bool forceReplace = false}) async {
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
      debugPrint('WebFControllerManager: use cached $oldController for ${oldController.entrypoint}');
      return oldController;
    }

    // Check if we've reached max capacity and enforce limits if needed (only for new controllers)
    if ((oldController == null || currentState == ControllerState.disposed) &&
        _controllersByName.length >= _config.maxAliveInstances &&
        _config.autoDisposeWhenLimitReached) {
      _disposeLeastRecentlyUsed();
    }

    // Create a new controller instance with fallback
    WebFController newController;
    try {
      newController = actualCreateController();
    } catch (e) {
      // If creating a new controller fails and we have an old one, log and return old controller
      if (oldController != null && currentState != ControllerState.disposed) {
        print('WebFControllerManager: Failed to create new controller, $e. Falling back to existing controller.');
        return oldController;
      }
      // If no fallback is available, rethrow the error
      rethrow;
    }

    debugPrint('WebFControllerManager: new controller: $newController with bundle: $bundle created');

    // Handle routes - preserve old routes if needed
    if (routes == null && oldRoutes != null) {
      newController.routes = oldRoutes;
    } else if (routes != null) {
      newController.routes = routes;
    }

    // Store initialization parameters for potential re-initialization
    _controllerInitParams[name] = {
      'type': mode,
      'createController': actualCreateController,
      'bundle': bundle,
      'routes': newController.routes,
      'setup': setup ?? oldParams?['setup'],
    };

    if (!_concurrencyControllerByName.containsKey(name)) {
      _concurrencyControllerByName[name] = [];
      _concurrencyRaceCompleter[name] = Completer<WebFController>();
    }

    Completer<WebFController> raceCompleter = _concurrencyRaceCompleter[name]!;

    Stopwatch stopwatch = Stopwatch()..start();

    // Record an request for the concurrency checks
    _ConcurrencyControllerInstance _concurrencyControllerInstance =
        _ConcurrencyControllerInstance(newController, stopwatch, ControllerLoadState.idle);

    List<_ConcurrencyControllerInstance> concurrencyInstanceList = _concurrencyControllerByName[name]!;
    concurrencyInstanceList.add(_concurrencyControllerInstance);

    // Wait for the new controller to initialize with fallback
    await newController.controlledInitCompleter.future;

    debugPrint('WebFControllerManager: $newController init complete, start for the bundle loading..');

    // Apply optional setup with fallback
    if (setup != null) {
      setup(newController);
    } else if (oldParams?['setup'] != null) {
      // Apply the previous setup if available and no new setup is provided
      ControllerSetup oldSetup = oldParams!['setup'];
      oldSetup(newController);
    }

    Future<void> newControllerRequestFuture;

    _concurrencyControllerInstance.state = ControllerLoadState.loading;

    switch (mode) {
      case WebFLoadingMode.preloading:
        newControllerRequestFuture = newController.preload(bundle);
        break;
      case WebFLoadingMode.preRendering:
        newControllerRequestFuture = newController.preRendering(bundle);
        break;
    }

    try {
      // Race the concurrency request and find the target controller instance.
      // Success! Now we can safely replace the old controller
      WebFController winnerController = await _raceConcurrencyController(name, newController,
          newControllerRequestFuture, _concurrencyControllerInstance, concurrencyInstanceList, raceCompleter);

      // The newController was failed to win the race.
      if (winnerController != newController) {
        // Dispose the abandon controller instance
        Future.microtask(() async {
          debugPrint('WebFControllerManager: dispose loser controller: $newController');
          await newController.dispose();
        });

        // The new controller was been replaced by the winner controller
        return null;
      } else {
        debugPrint('WebFControllerManager: the winner controller is $winnerController');
      }

      // Clear the race check status
      _concurrencyControllerByName.remove(name);
      _concurrencyRaceCompleter.remove(name);

      // Remove the old controller from tracking
      final instance = _controllersByName.remove(name);
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);

      // Register the new controller with the same name and preserve attached state if needed
      _controllersByName[name] = _ControllerInstance(winnerController, ControllerState.detached);
      _updateUsageOrder(name);

      print('WebFControllerManager: $newController preload complete with '
          'bundle: $bundle, time: ${stopwatch.elapsedMilliseconds}ms');

      // Schedule disposal of the old controller after returning the new one, if it exists
      if (instance != null && !instance.controller.disposed) {
        Future.microtask(() async {
          // Notify through callback if provided
          if (_config.onControllerDisposed != null) {
            _config.onControllerDisposed!(name, instance.controller);
          }
          print('WebFControllerManager: dispose the replaced controller ${instance.controller}');
          await instance.controller.dispose();
        });
      }

      return winnerController;
    } catch (e, stack) {
      // Dispose the abandon controller instance
      Future.microtask(() async {
        debugPrint('WebFControllerManager: dispose loser controller: $newController');
        await newController.dispose();
      });
      // Clear the race check status
      _concurrencyControllerByName.remove(name);
      _concurrencyRaceCompleter.remove(name);
      rethrow;
    }
  }

  /// Adds a new controller with preloading enabled.
  ///
  /// This is a convenience method that calls addOrUpdateControllerWithLoading with
  /// the preloading mode. It creates a new controller, preloads the bundle, and
  /// registers it with the manager.
  ///
  /// Use this method when you want to create a controller that loads resources
  /// but doesn't execute JavaScript until the WebF widget is mounted.
  ///
  /// [name] The unique name to identify this controller.
  /// [createController] Factory function to create the controller.
  /// [bundle] The content bundle to load.
  /// [routes] Optional routing configuration.
  /// [setup] Optional function to configure the controller.
  ///
  /// Returns the preloaded controller ready for use, or null if the controller was canceled due to concurrency rules.
  /// The return value is nullable to handle race conditions where another concurrent request won.
  Future<WebFController?> addWithPreload(
      {required String name,
      required ControllerFactory createController,
      required WebFBundle bundle,
      Map<String, SubViewBuilder>? routes,
      ControllerSetup? setup}) async {
    return addOrUpdateControllerWithLoading(
      name: name,
      createController: createController,
      mode: WebFLoadingMode.preloading,
      bundle: bundle,
      routes: routes,
      setup: setup,
      forceReplace: false,
    );
  }

  /// Adds a new controller with prerendering enabled.
  ///
  /// This is a convenience method that calls addOrUpdateControllerWithLoading with
  /// the prerendering mode. It creates a new controller, prerenders the bundle content
  /// (including executing JavaScript), and registers it with the manager.
  ///
  /// Use this method when you want a controller that aggressively preloads content
  /// for the fastest possible rendering time, at the cost of some compatibility issues
  /// with dimension-dependent code.
  ///
  /// [name] The unique name to identify this controller.
  /// [createController] Factory function to create the controller.
  /// [bundle] The content bundle to load.
  /// [routes] Optional routing configuration.
  /// [setup] Optional function to configure the controller.
  ///
  /// Returns the prerendered controller ready for use, or null if the controller was canceled due to concurrency rules.
  /// The return value is nullable to handle race conditions where another concurrent request won.
  Future<WebFController?> addWithPrerendering(
      {required String name,
      required ControllerFactory createController,
      required WebFBundle bundle,
      Map<String, SubViewBuilder>? routes,
      ControllerSetup? setup}) async {
    return addOrUpdateControllerWithLoading(
      name: name,
      createController: createController,
      mode: WebFLoadingMode.preRendering,
      bundle: bundle,
      routes: routes,
      setup: setup,
      forceReplace: false,
    );
  }

  /// Cancels a controller's loading or preloading process.
  ///
  /// This internal method is used to mark a controller as canceled when a newer
  /// controller is being loaded with the same name. This prevents resource conflicts
  /// and ensures that only the most recently requested controller continues loading.
  ///
  /// [controller] The controller to cancel.
  void _cancelUpdateOrLoadingIfNecessary(WebFController controller) {
    debugPrint('WebFControllerManager: cancel $controller');
    controller.isCanceled = true;
  }

  /// Recreates a controller using previously stored initialization parameters.
  ///
  /// This internal method reconstructs controllers that were disposed
  /// but might be needed again. It uses the stored initialization parameters to
  /// create a new instance with the same configuration as the original.
  ///
  /// [name] The name of the controller to recreate.
  ///
  /// Returns a newly created controller with the same configuration as the original, or null if the controller was canceled due to concurrency rules.
  /// The return value is nullable to handle race conditions where another concurrent request won.
  Future<WebFController?> _recreateController(String name) async {
    // Remove the disposed controller instance
    _controllersByName.remove(name);

    // Get stored parameters
    final params = _controllerInitParams[name]!;

    // Re-create based on type
    if (params['type'] == WebFLoadingMode.preloading) {
      return await addOrUpdateControllerWithLoading(
        name: name,
        mode: WebFLoadingMode.preloading,
        createController: params['createController'],
        bundle: params['bundle'],
        routes: params['routes'],
        setup: params['setup'],
      );
    } else {
      return await addOrUpdateControllerWithLoading(
        name: name,
        mode: WebFLoadingMode.preRendering,
        createController: params['createController'],
        bundle: params['bundle'],
        routes: params['routes'],
        setup: params['setup'],
      );
    }
  }

  /// Attaches a named controller to a Flutter BuildContext.
  ///
  /// This method should be called when a WebF widget using this controller is mounted
  /// in the Flutter widget tree. It manages the controller's state, enforces attachment
  /// limits, and handles the physical connection between the controller and Flutter.
  ///
  /// [name] The name of the controller to attach.
  /// [context] The Flutter BuildContext to attach the controller to.
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

  /// Detaches a named controller from a Flutter BuildContext.
  ///
  /// This method should be called when a WebF widget using this controller is unmounted
  /// from the Flutter widget tree. It updates the controller's state, removes it from
  /// the attached controllers list, and physically detaches it from Flutter while keeping
  /// it available for future reuse.
  ///
  /// [name] The name of the controller to detach.
  /// [context] The Flutter BuildContext the controller was attached to.
  void detachController(String name, BuildContext? context) {
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

  /// Updates the order of attached controllers for LRU (Least Recently Used) tracking.
  ///
  /// This internal method ensures that the most recently used controller is
  /// always at the end of the queue, allowing the least recently used one
  /// to be identified and potentially detached when limits are reached.
  ///
  /// [name] The name of the controller whose usage order is being updated.
  void _updateAttachedOrder(String name) {
    // Remove the name from its current position in the queue
    _attachedControllers.removeWhere((element) => element == name);
    // Add it to the end (most recently used)
    _attachedControllers.add(name);
  }

  /// Detaches the least recently used controller when attachment limits are reached.
  ///
  /// This internal method is called when the number of attached controllers exceeds
  /// the configured limit. It identifies the least recently used controller,
  /// detaches it from Flutter, and updates its state to detached while keeping
  /// it available in memory for future reuse.
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

  /// Manually registers an existing WebFController with the manager.
  ///
  /// This method allows registering an externally created controller with the manager.
  /// It handles duplicate name resolution, enforces resource limits, and adds the
  /// controller to the tracking systems.
  ///
  /// [name] The unique name to identify this controller.
  /// [controller] The existing WebFController instance to register.
  ///
  /// Returns the registered controller (which might be a different instance if the name was already in use).
  WebFController registerController(String name, WebFController controller) {
    // If a controller with this name already exists, update its usage order and return it
    if (_controllersByName.containsKey(name) && _controllersByName[name]!.state != ControllerState.disposed) {
      _updateUsageOrder(name);
      return _controllersByName[name]!.controller;
    }

    // Remove any disposed controller with this name
    if (_controllersByName.containsKey(name) && _controllersByName[name]!.state == ControllerState.disposed) {
      _controllersByName.remove(name);
      // Also cleanup from usage tracking
      _recentlyUsedControllers.removeWhere((element) => element == name);
    }

    // Check if we've reached max capacity and dispose if needed
    if (_controllersByName.length >= _config.maxAliveInstances && _config.autoDisposeWhenLimitReached) {
      _disposeLeastRecentlyUsed();
    }

    // Register the controller in detached state initially
    _controllersByName[name] = _ControllerInstance(controller, ControllerState.detached);
    _updateUsageOrder(name);
    return controller;
  }

  /// Static convenience method to get a controller by name.
  ///
  /// This is a static shorthand for calling instance.getController(name).
  /// It asynchronously retrieves a controller by name, potentially recreating it
  /// if it was disposed but has initialization parameters stored.
  ///
  /// [name] The unique name of the controller to retrieve.
  ///
  /// Returns the controller if found or recreated, null otherwise.
  static Future<WebFController?> getInstance(String name) async {
    return await _instance.getController(name);
  }

  /// Synchronously retrieves a controller by name without recreation.
  ///
  /// Unlike getController, this method only returns existing, non-disposed controllers.
  /// It will not attempt to recreate controllers that were disposed, making it
  /// suitable for cases where you need immediate access without the asynchronous delay
  /// of potential recreation.
  ///
  /// This method updates the usage order of returned controllers, keeping them
  /// from being disposed due to inactivity.
  ///
  /// [name] The unique name of the controller to retrieve.
  ///
  /// Returns the controller if found and not disposed, null otherwise.
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

  /// Static convenience method to get a controller synchronously.
  ///
  /// This is a static shorthand for calling instance.getControllerSync(name).
  /// It synchronously retrieves a controller by name without attempting recreation
  /// of disposed controllers.
  ///
  /// [name] The unique name of the controller to retrieve.
  ///
  /// Returns the controller if found and not disposed, null otherwise.
  static WebFController? getInstanceSync(String name) {
    return _instance.getControllerSync(name);
  }

  /// Asynchronously retrieves or recreates a controller by name.
  ///
  /// This method attempts to find a controller with the given name and:
  /// - Returns it directly if it exists and is not disposed
  /// - Recreates it if it was disposed but has initialization parameters
  /// - Returns null if it doesn't exist and cannot be recreated
  ///
  /// When a controller is returned, its usage order is updated to keep
  /// it from being disposed due to inactivity.
  ///
  /// [name] The unique name of the controller to retrieve.
  ///
  /// Returns the controller if found or recreated, null otherwise.
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

    // If the controller was in race conditions,
    if (_concurrencyControllerByName.containsKey(name)) {
      Completer<WebFController> completer = Completer<WebFController>();
      _concurrencyRaceCompleter[name]!.future.then((WebFController controller) {
        // Should schedule to next microtask to make sure controllerManager._controllersByName had been updated.
        scheduleMicrotask(() {
          completer.complete(controller);
        });
      }).catchError((e, stack) {
        scheduleMicrotask(() {
          completer.completeError(e, stack);
        });
      });
      return completer.future;
    }

    // If controller doesn't exist but we have init params, recreate it
    if (_controllerInitParams.containsKey(name)) {
      return await _recreateController(name);
    }

    return null;
  }

  /// Checks if a controller with the given name exists and is managed.
  ///
  /// This method verifies whether a controller with the specified name is currently
  /// registered with the manager, regardless of its state (attached, detached, or disposed).
  /// It is similar to hasController() but with a more descriptive name for the UI context.
  ///
  /// [name] The name of the controller to check.
  ///
  /// Returns true if a controller with this name exists, false otherwise.
  bool isControllerAlive(String name) {
    return _controllersByName.containsKey(name);
  }

  /// Checks if a controller is currently attached to Flutter.
  ///
  /// This method determines whether a named controller is in the attached state,
  /// meaning it is currently connected to the Flutter widget tree and actively rendering.
  /// This is useful for UI logic that needs to know a controller's attachment state.
  ///
  /// [name] The name of the controller to check.
  ///
  /// Returns true if the controller exists and is attached, false otherwise.
  bool isControllerAttached(String name) {
    return _attachedControllers.contains(name);
  }

  /// Updates the usage order of controllers for LRU (Least Recently Used) tracking.
  ///
  /// This internal method ensures that the most recently used controller is
  /// always at the end of the queue, allowing the least recently used one
  /// to be identified and potentially disposed when limits are reached.
  ///
  /// [name] The name of the controller whose usage order is being updated.
  void _updateUsageOrder(String name) {
    // Remove the name from its current position in the queue
    _recentlyUsedControllers.removeWhere((element) => element == name);
    // Add it to the end (most recently used)
    _recentlyUsedControllers.add(name);
  }

  /// Disposes the least recently used, non-attached controller when limits are reached
  ///
  /// This internal method is called when the number of controllers exceeds
  /// the configured limit. It identifies the least recently used controller that
  /// is not currently attached to Flutter, and disposes it to free up resources.
  ///
  /// The method takes care to avoid disposing controllers that are currently
  /// attached to the UI, even if they are the least recently used.
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
        debugPrint('WebFControllerManager: dispose controller $controller due to out of LRU cache');
        controller.dispose();
      });
    }
  }

  /// Checks if a controller with the given name exists in the manager
  ///
  /// This method verifies whether a controller with the specified name is currently
  /// registered with the manager, regardless of its state (attached, detached, or disposed).
  ///
  /// @param name The name to check for existence
  /// @return true if a controller with this name exists, false otherwise
  bool hasController(String name) {
    return _controllersByName.containsKey(name);
  }

  /// Gets a list of all controller names currently registered with the manager
  ///
  /// This property returns the names of all controllers, regardless of their state
  /// (attached, detached, or disposed).
  List<String> get controllerNames => _controllersByName.keys.toList();

  /// Gets the total number of controllers currently managed
  ///
  /// This property returns the count of all controllers, regardless of their state
  /// (attached, detached, or disposed).
  int get controllerCount => _controllersByName.length;

  /// Gets the current state of a named controller
  ///
  /// Returns the state of the controller (attached, detached, or disposed) if found.
  ///
  /// @param name The name of the controller to check
  /// @return The controller state if found, null otherwise
  ControllerState? getControllerState(String name) {
    return _controllersByName[name]?.state;
  }

  /// Finds the name associated with a specific controller instance
  ///
  /// This method searches for a controller by its instance reference rather than by name.
  /// It's useful when you have a controller instance and need to find its registered name.
  ///
  /// @param controller The controller instance to look up
  /// @return The name of the controller if found, null otherwise
  String? getControllerName(WebFController controller) {
    for (final entry in _controllersByName.entries) {
      if (entry.value.controller == controller) {
        return entry.key;
      }
    }
    return null;
  }

  /// Updates an existing controller with a new instance using preloading
  ///
  /// This deprecated method is maintained for backward compatibility.
  /// It calls addOrUpdateControllerWithLoading with forceReplace=true to
  /// ensure the controller is always replaced, not reused.
  ///
  /// Use addOrUpdateControllerWithLoading instead for more control and better
  /// error handling.
  ///
  /// @param name The name of the controller to update
  /// @param createController Optional factory to create the new controller
  /// @param bundle The content bundle to load
  /// @param routes Optional routing configuration
  /// @param setup Optional function to configure the controller
  /// @return The updated controller, or null if the controller was canceled due to concurrency rules.
  /// The return value is nullable to handle race conditions where another concurrent request won.
  @Deprecated('Use addOrUpdateWithPreload instead')
  Future<WebFController?> updateWithPreload(
      {required String name,
      ControllerFactory? createController,
      required WebFBundle bundle,
      Map<String, SubViewBuilder>? routes,
      ControllerSetup? setup}) async {
    return addOrUpdateControllerWithLoading(
      name: name,
      createController: createController,
      mode: WebFLoadingMode.preloading,
      bundle: bundle,
      routes: routes,
      setup: setup,
      forceReplace: true, // Update always forces replacement
    );
  }

  /// Updates an existing controller with a new instance using prerendering
  ///
  /// This method calls addOrUpdateControllerWithLoading with preRendering mode
  /// and forceReplace=true to ensure the controller is always replaced, not reused.
  ///
  /// Unlike the preloading version, this executes JavaScript code during prerendering,
  /// which can provide faster startup times at the cost of potential compatibility issues
  /// with dimension-dependent code.
  ///
  /// @param name The name of the controller to update
  /// @param createController Optional factory to create the new controller
  /// @param bundle The content bundle to load
  /// @param routes Optional routing configuration
  /// @param setup Optional function to configure the controller
  /// @return The updated controller, or null if the controller was canceled due to concurrency rules.
  /// The return value is nullable to handle race conditions where another concurrent request won.
  Future<WebFController?> updateWithPrerendering(
      {required String name,
      ControllerFactory? createController,
      required WebFBundle bundle,
      Map<String, SubViewBuilder>? routes,
      ControllerSetup? setup}) async {
    return addOrUpdateControllerWithLoading(
      name: name,
      createController: createController,
      mode: WebFLoadingMode.preRendering,
      bundle: bundle,
      routes: routes,
      setup: setup,
      forceReplace: true, // Update always forces replacement
    );
  }

  /// Removes a controller from the manager without disposing it
  ///
  /// This method unregisters a controller from the manager but does not dispose
  /// its resources. The controller remains valid and can be used directly or
  /// re-registered later.
  ///
  /// @param name The name of the controller to remove
  /// @return The removed controller if found, null otherwise
  WebFController? removeController(String name) {
    final instance = _controllersByName.remove(name);
    if (instance != null) {
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);
      return instance.controller;
    }
    return null;
  }

  /// Removes and fully disposes a controller by name
  ///
  /// This method completely removes a controller from the manager and releases
  /// all its resources. It ensures proper cleanup by:
  /// 1. Detaching from Flutter if currently attached
  /// 2. Removing from all tracking collections
  /// 3. Notifying via callback if configured
  /// 4. Disposing the controller itself
  ///
  /// @param name The name of the controller to remove and dispose
  Future<void> removeAndDisposeController(String name) async {
    final instance = _controllersByName[name];
    if (instance != null && !instance.controller.disposed) {
      // Detach first if attached
      if (instance.state == ControllerState.attached) {
        instance.controller.detachFromFlutter(null);
        _attachedControllers.removeWhere((element) => element == name);
      }

      // Get reference to controller before removing from map
      final controller = instance.controller;

      // Remove from all tracking collections to prevent memory leaks
      _controllersByName.remove(name);
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);

      // Notify through callback if provided
      if (_config.onControllerDisposed != null) {
        _config.onControllerDisposed!(name, controller);
      }
      // Then dispose
      await controller.dispose();
    } else if (instance != null) {
      // Even if already disposed, remove from tracking collections
      _controllersByName.remove(name);
      _recentlyUsedControllers.removeWhere((element) => element == name);
      _attachedControllers.removeWhere((element) => element == name);
    }
  }

  /// Disposes all controllers managed by this instance
  ///
  /// This method performs a complete cleanup of all controllers, detaching them
  /// from Flutter, disposing their resources, and clearing all tracking collections.
  /// It's typically used when shutting down the application or when you need to
  /// reset the entire WebF environment.
  Future<void> disposeAll() async {
    // Create a copy of the keys to avoid concurrent modification issues
    final names = List<String>.from(_controllersByName.keys);

    // Dispose each controller
    for (final name in names) {
      await removeAndDisposeController(name);
    }

    _concurrencyControllerByName.clear();
    _concurrencyRaceCompleter.clear();
    // Clear all tracking structures
    _controllersByName.clear();
    _recentlyUsedControllers.clear();
    _attachedControllers.clear();
    _controllerInitParams.clear();
  }

  /// Retrieves the current configuration of the manager
  ///
  /// This property provides access to the WebFControllerManagerConfig instance
  /// that controls the behavior of this manager, including resource limits
  /// and callback handlers.
  WebFControllerManagerConfig get config => _config;
}
