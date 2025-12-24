/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/html.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class WebFRouterViewport extends MultiChildRenderObjectWidget {
  final WebFController controller;

  const WebFRouterViewport({required this.controller, super.children, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    RouterViewViewportBox root = RouterViewViewportBox(viewportSize: null, controller: controller);
    controller.view.routerViewport = root;
    return root;
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
    if (controller.view.routerViewport == renderObject) {
      controller.view.routerViewport = null;
    }
  }
}

class WebFRouterViewState extends State<WebFRouterView> with RouteAware {
  @override
  Widget build(BuildContext context) {
    WidgetElement? child = widget.controller.view.getHybridRouterView(widget.path);
    if (child == null) {
      if (widget.defaultViewBuilder == null) {
        return SizedBox.shrink();
      }

      return widget.defaultViewBuilder!(context);
    }

    return WebFContext(
        controller: widget.controller,
        child: WebFRouterViewport(controller: widget.controller, key: child.key, children: [child.toWidget()]));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.updateTextSettingsFromContext(context);
    widget.controller.routeObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    widget.controller.routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;

    // CRITICAL FIX: Use widget.path instead of route.settings.name for consistency
    String path = widget.path;


    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPop', path: path);

    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);
    routerLinkElement?.dispatchEventUtilAdded(event);
  }

  @override
  void didPopNext() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;

    // CRITICAL FIX: Use widget.path instead of route.settings.name for consistency
    String path = widget.path;
    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPopNext', path: path);

    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);
    routerLinkElement?.dispatchEventUtilAdded(event);
  }

  @override
  void didPush() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;

    // CRITICAL FIX: Use widget.path (the actual route path) instead of route.settings.name
    // because go_router's universal catch-all route always returns 'universal-webf-route' as the name
    String path = widget.path;

    // Create event with the actual navigation path (widget.path)
    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPush', path: path);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);
    routerLinkElement?.addPostEventListenerOnce(dom.EVENT_ON_SCREEN, (_) async {
      widget.controller.view.document.dispatchEvent(event);
    });
  }

  @override
  void didPushNext() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;

    // CRITICAL FIX: Use widget.path (the actual route path) instead of route.settings.name
    // because go_router's universal catch-all route always returns 'universal-webf-route' as the name
    String path = widget.path;
    // Create event with the actual navigation path (widget.path)
    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPushNext', path: path);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);
    routerLinkElement?.addPostEventListenerOnce(dom.EVENT_ON_SCREEN, (_) async {
      widget.controller.view.document.dispatchEvent(event);
    });
  }
}

class WebFRouterView extends StatefulWidget {
  final WebFController controller;
  final String path;
  final WidgetBuilder? defaultViewBuilder;

  /// Create a WebFRouterView widget using a controller name from WebFControllerManager.
  ///
  /// This constructor will asynchronously load the controller and automatically handle
  /// recreation of disposed controllers.
  ///
  /// You can customize the loading experience with loadingWidget and handle errors
  /// with errorBuilder. The builder allows you to create custom UI with the controller.
  static Widget fromControllerName(
      {required String controllerName,
      required String path,
      Widget? loadingWidget,
      WebFRouterViewBuilder? builder,
      Widget Function(BuildContext context, Object error)? errorBuilder}) {
    return _AsyncWebFRouterView(
        controllerName: controllerName,
        path: path,
        builder: builder,
        loadingWidget: loadingWidget,
        errorBuilder: errorBuilder);
  }

  const WebFRouterView({super.key, required this.controller, required this.path, this.defaultViewBuilder});

  @override
  State<StatefulWidget> createState() {
    return WebFRouterViewState();
  }

  @override
  StatefulElement createElement() {
    return _WebFRouterViewElement(this);
  }
}

class _WebFRouterViewElement extends StatefulElement {
  _WebFRouterViewElement(super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    ModalRoute? route = ModalRoute.of(this);
    var state = route?.settings.arguments;

    widget.controller.pushNewBuildContext(context: this, routePath: widget.path, state: state);
  }

  @override
  void unmount() {
    // Store widget reference before unmounting to avoid null access
    final path = widget.path;
    final controller = widget.controller;

    controller.popBuildContext(context: this, routePath: path);
    super.unmount();
  }

  @override
  WebFRouterView get widget => super.widget as WebFRouterView;
}

typedef WebFRouterViewBuilder = Widget Function(BuildContext context, WebFController controller);

class _AsyncWebFRouterView extends StatefulWidget {
  final String controllerName;
  final String path;
  final Widget? loadingWidget;
  final WebFRouterViewBuilder? builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const _AsyncWebFRouterView(
      {required this.controllerName, required this.path, this.builder, this.loadingWidget, this.errorBuilder});

  @override
  State<_AsyncWebFRouterView> createState() => _AsyncWebFRouterViewState();
}

class _AsyncWebFRouterViewState extends State<_AsyncWebFRouterView> {
  // Capture start time when state is created for performance tracking
  final DateTime _pfStartTime = DateTime.now();
  late Future<WebFController?> _controllerFuture;

  @override
  void initState() {
    super.initState();
    _controllerFuture = WebFControllerManager.instance.getController(widget.controllerName);
  }

  @override
  void didUpdateWidget(covariant _AsyncWebFRouterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controllerName != widget.controllerName) {
      _controllerFuture = WebFControllerManager.instance.getController(widget.controllerName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existController = WebFControllerManager.instance.getControllerSync(widget.controllerName);
    // Keep the existing (evaluated) controller view alive across router rebuilds.
    // go_router rebuilds the page stack when navigating, and creating a new Future in build
    // can briefly put FutureBuilder back into `waiting`, which would otherwise replace the
    // subtree (disposing WebFRouterView) even though the controller is already ready.
    if (existController != null && existController.evaluated && !existController.disposed) {
      existController.updateTextSettingsFromContext(context);
      return widget.builder != null
          ? widget.builder!(context, existController)
          : _WebFRouterViewWithStartTime(controller: existController, path: widget.path, startTime: _pfStartTime);
    }

    return FutureBuilder<WebFController?>(
        future: _controllerFuture,
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
                : Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            final errorMsg = 'Controller "${widget.controllerName}" not found';
            return widget.errorBuilder != null ? widget.errorBuilder!(context, errorMsg) : Center(child: Text(errorMsg));
          }

          WebFController controller = snapshot.data!;
          controller.updateTextSettingsFromContext(context);

          return widget.builder != null
              ? widget.builder!(context, controller)
              : _WebFRouterViewWithStartTime(controller: snapshot.data!, path: widget.path, startTime: _pfStartTime);
        });
  }
}

// A wrapper widget to pass the start time to WebFRouterView
class _WebFRouterViewWithStartTime extends StatefulWidget {
  final WebFController controller;
  final String path;
  final DateTime startTime;

  const _WebFRouterViewWithStartTime({
    required this.controller,
    required this.path,
    required this.startTime,
  });

  @override
  State<_WebFRouterViewWithStartTime> createState() => _WebFRouterViewWithStartTimeState();

  @override
  StatefulElement createElement() {
    return _WebFRouterViewWithStartTimeElement(this);
  }
}

class _WebFRouterViewWithStartTimeState extends State<_WebFRouterViewWithStartTime> {
  @override
  Widget build(BuildContext context) {
    return WebFRouterView(controller: widget.controller, path: widget.path);
  }
}

class _WebFRouterViewWithStartTimeElement extends StatefulElement {
  _WebFRouterViewWithStartTimeElement(super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    // Only initialize performance tracking with the captured start time
    // The actual route push/pop is handled by _WebFRouterViewElement
    widget.controller.initializePerformanceTracking(widget.startTime);
  }

  @override
  _WebFRouterViewWithStartTime get widget => super.widget as _WebFRouterViewWithStartTime;
}
