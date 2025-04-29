/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';
import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/launcher.dart';

typedef OnControllerCreated = void Function(WebFController controller);

/// The entry-point widget class responsible for rendering all content created by HTML, CSS, and JavaScript in WebF.
///
/// WebF can be used in two ways:
/// 1. Directly with a WebFController instance using the default constructor
/// 2. By referencing a controller name managed by WebFControllerManager using `WebF.fromControllerName`
///
/// The second approach supports automatic initialization of controllers that don't exist yet,
/// if proper bundle and initialization parameters are provided.
class WebF extends StatefulWidget {
  /// The WebF controller to use for rendering content
  final WebFController controller;

  /// Widget to display while loading the controller when using controllerName
  final Widget? loadingWidget;

  /// The default route path for the hybrid router in WebF.
  ///
  /// Sets the initial path that the router will navigate to when the application starts.
  /// This is the entry point for the hybrid routing system in WebF.
  final String? initialRoute;

  /// The default route state for the hybrid router in WebF.
  ///
  /// Users can read this value by webf.hybridRouter.state when loading by initialRoute path.
  final Map<String, dynamic>? initialState;

  /// Custom error builder when using controllerName
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Callbacks for this controller of WebF had been disposed
  final VoidCallback? onDispose;

  // Set webf http cache mode.
  static void setHttpCacheMode(HttpCacheMode mode) {
    HttpCacheController.mode = mode;
    if (kDebugMode) {
      print('WebF http cache mode set to $mode.');
    }
  }

  static bool _isValidCustomElementName(localName) {
    return RegExp(r'^[a-z][.0-9_a-z]*-[\-.0-9_a-z]*$').hasMatch(localName);
  }

  static void defineCustomElement(String tagName, ElementCreator creator) {
    if (!_isValidCustomElementName(tagName)) {
      throw ArgumentError('The element name "$tagName" is not valid.');
    }
    defineWidgetElement(tagName.toUpperCase(), creator);
  }

  static void overrideCustomElement(String tagName, ElementCreator creator) {
    if (!_isValidCustomElementName(tagName)) {
      throw ArgumentError('The element name "$tagName" is not valid.');
    }
    defineOverrideWidgetElement(tagName.toUpperCase(), creator);
  }

  static void defineModule(ModuleCreator creator) {
    ModuleManager.defineModule(creator);
  }

  /// Create a WebF widget with an existing controller.
  ///
  /// If the controller is managed by WebFControllerManager, the widget will
  /// coordinate with the manager for proper lifecycle management.
  const WebF({
    Key? key,
    this.loadingWidget,
    this.initialRoute,
    this.initialState,
    this.errorBuilder,
    this.onDispose,
    required this.controller,
  })  : super(key: key);

  /// Create a WebF widget using a controller name from WebFControllerManager.
  ///
  /// This constructor will asynchronously load the controller and automatically handle
  /// recreation of disposed controllers.
  ///
  /// If the controller doesn't exist and a bundle is provided, it will be automatically
  /// initialized with addOrUpdateWithPreload.
  ///
  /// You can customize the loading experience with loadingWidget and handle errors
  /// with errorBuilder. The builder allows you to create custom UI with the controller.
  static AutoManagedWebF fromControllerName(
      {Key? key,
      required String controllerName,
      String? initialRoute,
      Map<String, dynamic>? initialState,
      Widget? loadingWidget,
      Widget Function(BuildContext context, Object error)? errorBuilder,
      // Parameters for auto-initialization if controller is not found
      WebFBundle? bundle,
      ControllerFactory? createController,
      Map<String, SubViewBuilder>? routes,
      VoidCallback? onDispose,
      ControllerSetup? setup}) {
    return AutoManagedWebF(
        controllerName: controllerName,
        loadingWidget: loadingWidget,
        errorBuilder: errorBuilder,
        initialRoute: initialRoute,
        initialState: initialState,
        bundle: bundle,
        onDispose: onDispose,
        createController: createController,
        routes: routes,
        key: key,
        setup: setup);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('controller', controller.toString()));

    final name = WebFControllerManager.instance.getControllerName(controller);
    if (name != null) {
      properties.add(StringProperty('controllerName', name));
    }
  }

  @override
  State<WebF> createState() {
    return WebFState();
  }

  @override
  StatefulElement createElement() {
    return WebFStateElement(this);
  }
}

class AutoManagedWebFState extends State<AutoManagedWebF> {
  Widget buildWebF(WebFController controller) {
    return WebF(
        controller: controller,
        key: controller.key,
        initialRoute: widget.initialRoute,
        initialState: widget.initialState,
        errorBuilder: widget.errorBuilder,
        onDispose: () {
          print('webf $controller disposed');
          setState(() {});
        },
        loadingWidget: widget.loadingWidget ??
            const SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ));
  }

  // This function tries to create a controller if it doesn't exist
  Future<WebFController?> _getOrCreateController() async {
    WebFController? controller = await WebFControllerManager.instance.getController(widget.controllerName);

    // If controller doesn't exist but we have enough info to create it
    if (controller == null && widget.bundle != null) {
      // Create a controller factory if not provided
      ControllerFactory actualCreateController = widget.createController ??
          (() => WebFController(initialRoute: widget.initialRoute ?? '/'));

      controller = await WebFControllerManager.instance.addOrUpdateWithPreload(
          name: widget.controllerName,
          createController: actualCreateController,
          bundle: widget.bundle!,
          routes: widget.routes,
          setup: widget.setup
      );
    }

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebFController?>(
      future: _getOrCreateController(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return widget.loadingWidget ??
              const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
        }

        if (snapshot.hasError) {
          return widget.errorBuilder != null
              ? widget.errorBuilder!(context, snapshot.error!)
              : Center(child: Text('Error: ${snapshot.error}\n  ${snapshot.stackTrace}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          final String errorMsg;
          if (widget.bundle == null) {
            errorMsg = 'Controller "${widget.controllerName}" not found and no bundle provided for auto-initialization';
          } else {
            errorMsg = 'Failed to initialize controller "${widget.controllerName}"';
          }
          return widget.errorBuilder != null ? widget.errorBuilder!(context, errorMsg) : Center(child: Text(errorMsg));
        }

        return buildWebF(snapshot.data!);
      },
    );
  }
}

class AutoManagedWebF extends StatefulWidget {
  final String controllerName;
  final Widget? loadingWidget;
  final String? initialRoute;
  final Map<String, dynamic>? initialState;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  /// Callbacks for this controller of WebF had been disposed
  final VoidCallback? onDispose;

  // Auto-initialization parameters
  final WebFBundle? bundle;
  final ControllerFactory? createController;
  final Map<String, SubViewBuilder>? routes;
  final ControllerSetup? setup;

  AutoManagedWebF({
    required this.controllerName,
    this.loadingWidget,
    this.errorBuilder,
    this.initialRoute,
    this.initialState,
    this.onDispose,
    // Auto-initialization parameters
    this.bundle,
    this.createController,
    this.routes,
    this.setup,
    super.key
  });

  @override
  State<StatefulWidget> createState() {
    return AutoManagedWebFState();
  }
}

/// The state for WebF when using a direct controller reference
class WebFState extends State<WebF> with RouteAware {
  bool _flutterScreenIsReady = false;

  watchWindowIsReady() {
    ui.FlutterView view = PlatformDispatcher.instance.views.first;

    double viewportWidth = view.physicalSize.width / view.devicePixelRatio;
    double viewportHeight = view.physicalSize.height / view.devicePixelRatio;

    if (viewportWidth == 0.0 && viewportHeight == 0.0) {
      // window.physicalSize are Size.zero when app first loaded. This only happened on Android and iOS physical devices with release build.
      // We should wait for onMetricsChanged when window.physicalSize get updated from Flutter Engine.
      VoidCallback? _ordinaryOnMetricsChanged = PlatformDispatcher.instance.onMetricsChanged;
      PlatformDispatcher.instance.onMetricsChanged = () async {
        if (view.physicalSize == ui.Size.zero) {
          return;
        }
        setState(() {
          _flutterScreenIsReady = true;
        });

        // Should proxy to ordinary window.onMetricsChanged callbacks.
        if (_ordinaryOnMetricsChanged != null) {
          _ordinaryOnMetricsChanged();
          // Recover ordinary callback to window.onMetricsChanged
          PlatformDispatcher.instance.onMetricsChanged = _ordinaryOnMetricsChanged;
        }
      };
    } else {
      _flutterScreenIsReady = true;
    }
  }

  @override
  void initState() {
    super.initState();
    watchWindowIsReady();

    widget.controller.attachWebFState(this);

    if (widget.initialRoute != null) {
      widget.controller.initialState = widget.initialState;
      widget.controller.initialRoute = widget.initialRoute ?? '/';
    }
  }

  @override
  void didPop() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? widget.controller.initialRoute;

    Event event = HybridRouterChangeEvent(state: state ?? widget.controller.initialState, kind: 'didPop', path: path);
    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.controller.initialRoute);
    routerLinkElement?.dispatchEvent(event);
  }

  @override
  void didPopNext() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? widget.controller.initialRoute ?? '';

    Event event =
        HybridRouterChangeEvent(state: state ?? widget.controller.initialState, kind: 'didPopNext', path: path);
    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.controller.initialRoute);
    routerLinkElement?.dispatchEvent(event);
  }

  @override
  void didPush() async {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? widget.controller.initialRoute ?? '';

    Event event = HybridRouterChangeEvent(state: state ?? widget.controller.initialState, kind: 'didPush', path: path);
    widget.controller.view.document.dispatchEventUtilAdded(event);

    if (widget.controller.initialRoute != '/') {
      await widget.controller.view.awaitForHybridRouteLoaded(widget.controller.initialRoute);
    }
    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.controller.initialRoute);
    routerLinkElement?.dispatchEventUtilAdded(event);
  }

  @override
  void didPushNext() async {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? widget.controller.initialRoute ?? '';

    Event event =
        HybridRouterChangeEvent(state: state ?? widget.controller.initialState, kind: 'didPushNext', path: path);
    widget.controller.view.document.dispatchEventUtilAdded(event);

    if (widget.controller.initialRoute != '/') {
      await widget.controller.view.awaitForHybridRouteLoaded(widget.controller.initialRoute);
    }
    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.controller.initialRoute);
    routerLinkElement?.dispatchEventUtilAdded(event);
  }

  void requestForUpdate(AdapterUpdateReason reason) {
    if (!mounted) return;

    if (reason is ControllerDisposeChangeReason && widget.onDispose != null) {
      widget.onDispose!();
    }

    setState(() {});
  }

  Widget buildViewport(List<Widget> children) {
    return WebFRootViewport(
      widget.controller,
      key: widget.controller.key,
      viewportWidth: widget.controller.viewportWidth,
      viewportHeight: widget.controller.viewportHeight,
      background: widget.controller.background,
      resizeToAvoidBottomInsets: widget.controller.resizeToAvoidBottomInsets,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_flutterScreenIsReady) {
      return const SizedBox(width: 0, height: 0);
    }

    if (widget.controller.hasLoadingError) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, widget.controller.loadingError!);
      }
      return Center(child: Text('Error loading: ' + widget.controller.loadingError!.toString()));
    }

    String initialRoute = widget.initialRoute ?? widget.controller.initialRoute;

    List<Future> pendingFutures = [
      widget.controller.controllerOnDOMContentLoadedCompleter.future,
      widget.controller.viewportLayoutCompleter.future
    ];
    if (initialRoute != '/') {
      pendingFutures.add(widget.controller.view.awaitForHybridRouteLoaded(initialRoute));
    }

    return buildViewport([
      FutureBuilder(
          future: Future.wait(pendingFutures),
          key: widget.controller.key,
          builder: (context, snapshot) {
            if (!widget.controller.evaluated && snapshot.connectionState != ConnectionState.done) {
              return widget.loadingWidget ??
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
            }

            return buildRootView(initialRoute);
          })
    ]);
  }

  Widget buildRootView(String initialRoute) {
    if (initialRoute != '/') {
      RouterLinkElement? child = widget.controller.view.getHybridRouterView(initialRoute);
      if (child == null) {
        return WebFHTMLElement(
            tagName: 'DIV',
            controller: widget.controller,
            parentElement: null,
            children: [Text('Loading Error: the route path for $initialRoute was not found')]);
      }

      return child.toWidget();
    }

    if (widget.controller.view.document.documentElement == null) {
      return WebFHTMLElement(
          tagName: 'DIV',
          controller: widget.controller,
          parentElement: null,
          children: [Text('Loading Error: the documentElement is Null')]);
    }

    return widget.controller.view.document.documentElement!.toWidget();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.routeObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.routeObserver?.unsubscribe(this);
    widget.controller.removeWebFState(this);
  }
}

class WebFStateElement extends StatefulElement {
  WebFStateElement(super.widget);

  @override
  void markNeedsBuild() {
    super.markNeedsBuild();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    // Get controller name from the WebFControllerManager
    String? controllerName = WebFControllerManager.instance.getControllerName(widget.controller);

    // If the controller is managed by WebFControllerManager, use its attach method
    if (controllerName != null) {
      WebFControllerManager.instance.attachController(controllerName, this);
    } else {
      // Fallback to direct attachment if not managed by WebFControllerManager
      widget.controller.attachToFlutter(this);
    }

    startForLoading();
  }

  @override
  void unmount() {
    // Get controller name from the WebFControllerManager
    String? controllerName = WebFControllerManager.instance.getControllerName(widget.controller);

    // If the controller is managed by WebFControllerManager, use its detach method
    if (controllerName != null) {
      WebFControllerManager.instance.detachController(controllerName, this);
    } else {
      // Fallback to direct detachment if not managed by WebFControllerManager
      widget.controller.detachFromFlutter(this);
    }

    widget.controller.pause();

    super.unmount();
  }

  Future<void> startForLoading() async {
    WebFController controller = widget.controller;
    if (controller.entrypoint == null) {
      throw FlutterError('Consider providing a WebFBundle resource as the entry point for WebF');
    }

    debugPrint('WebF: start for loading ${controller.entrypoint?.url}..');

    await controller.controlledInitCompleter.future;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Sync element state.
      flushUICommand(controller.view, nullptr);

      if (controller.evaluated) {
        _resumeForLoaded();
        return;
      }

      if (controller.hasLoadingError) {
        markNeedsBuild();
        return;
      }

      // Starting to flush ui commands every frames.
      controller.view.flushPendingCommandsPerFrame();

      // Bundle could be executed before mount to the flutter tree.
      if (controller.mode == WebFLoadingMode.standard) {
        await _loadingInNormalMode();
      } else if (controller.mode == WebFLoadingMode.preloading) {
        await _loadingInPreloadMode();
      } else if (controller.mode == WebFLoadingMode.preRendering) {
        await _loadingInPreRenderingMode();
      }

      controller.evaluated = true;
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  Future<void> _loadingInNormalMode() async {
    await widget.controller.executeEntrypoint();
  }

  Future<void> _loadingInPreloadMode() async {
    WebFController controller = widget.controller;
    await controller.controllerPreloadingCompleter.future;
    assert(controller.entrypoint!.isResolved);
    assert(controller.entrypoint!.isDataObtained);

    if (controller.unfinishedPreloadResources == 0 && controller.entrypoint!.isHTML) {
      await controller.view.document.scriptRunner.executePreloadedBundles();
    } else if (controller.entrypoint!.isJavascript || controller.entrypoint!.isBytecode) {
      await controller.evaluateEntrypoint();
    }

    flushUICommand(controller.view, nullptr);

    controller.dispatchWindowPreloadedEvent();
    controller.checkCompleted();
  }

  Future<void> _loadingInPreRenderingMode() async {
    WebFController controller = widget.controller;

    await controller.controllerPreRenderingCompleter.future;
    // Make sure fontSize of HTMLElement are correct
    await controller.dispatchWindowResizeEvent();

    // Sync element state.
    flushUICommand(controller.view, nullptr);

    controller.module.resumeAnimationFrame();

    HTMLElement rootElement = controller.view.document.documentElement as HTMLElement;
    rootElement.flushPendingStylePropertiesForWholeTree();

    controller.view.resumeAnimationTimeline();

    controller.dispatchDOMContentLoadedEvent();
    controller.dispatchWindowLoadEvent();
    controller.dispatchWindowPreRenderedEvent();
    controller.checkCompleted();
  }

  void _resumeForLoaded() {
    WebFController controller = widget.controller;
    if (!controller.view.firstLoad) {
      controller.resume();
    }
  }

  @override
  WebF get widget => super.widget as WebF;
}

class WebFContext extends InheritedWidget {
  WebFContext({required super.child, this.controller});

  final WebFController? controller;

  @override
  bool updateShouldNotify(WebFContext oldWidget) {
    return oldWidget.controller != controller;
  }

  static WebFContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WebFContext>();
  }

  @override
  InheritedElement createElement() {
    return WebFContextInheritElement(this, controller);
  }
}

class WebFContextInheritElement extends InheritedElement {
  WebFContextInheritElement(super.widget, this.controller);

  WebFController? controller;

  @override
  void unmount() {
    super.unmount();
    controller = null;
  }
}

class WebFRootViewport extends MultiChildRenderObjectWidget {
  final bool resizeToAvoidBottomInsets;
  final WebFController controller;
  final Color? background;
  final double? viewportWidth;
  final double? viewportHeight;

  // Creates a widget that visually hides its child.
  const WebFRootViewport(
    this.controller, {
    super.key,
    this.background,
    this.viewportWidth,
    this.viewportHeight,
    required List<Widget> children,
    this.resizeToAvoidBottomInsets = true,
  }) : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    RootRenderViewportBox root = RootRenderViewportBox(
        background: background,
        viewportSize:
            (viewportWidth != null && viewportHeight != null) ? ui.Size(viewportWidth!, viewportHeight!) : null,
        controller: controller);
    controller.view.viewport = root;

    if (!controller.viewportLayoutCompleter.isCompleted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller.viewportLayoutCompleter.complete();
      });
    }

    return root;
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);

    controller.view.viewport = null;
    controller.viewportLayoutCompleter = Completer();
  }
}
