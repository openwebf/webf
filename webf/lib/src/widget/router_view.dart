/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/html.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class WebFRouterViewport extends MultiChildRenderObjectWidget {
  final WebFController controller;

  WebFRouterViewport({required this.controller, super.children, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    RouterViewViewportBox root = RouterViewViewportBox(viewportSize: null, controller: controller);
    return root;
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
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
    String path = route.settings.name ?? '';

    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPop', path: path);

    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);
    routerLinkElement?.dispatchEventUtilAdded(event);
  }

  @override
  void didPopNext() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? '';

    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPopNext', path: path);

    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);
    routerLinkElement?.dispatchEventUtilAdded(event);
  }

  @override
  void didPush() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? '';

    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPush', path: path);

    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);

    if (routerLinkElement?.attachedRenderer != null) {
      routerLinkElement?.dispatchEventUtilAdded(event);
    } else {
      routerLinkElement?.dispatchEventByDeps(event, 'onscreen');
    }
  }

  @override
  void didPushNext() {
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String path = route.settings.name ?? '';

    dom.Event event = dom.HybridRouterChangeEvent(state: state, kind: 'didPushNext', path: path);

    widget.controller.view.document.dispatchEvent(event);

    RouterLinkElement? routerLinkElement = widget.controller.view.getHybridRouterView(widget.path);

    if (routerLinkElement?.attachedRenderer != null) {
      routerLinkElement?.dispatchEventUtilAdded(event);
    } else {
      routerLinkElement?.dispatchEventByDeps(event, 'onscreen');
    }
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

  WebFRouterView({required this.controller, required this.path, this.defaultViewBuilder});

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
    widget.controller.popBuildContext(context: this, routePath: widget.path);
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

  _AsyncWebFRouterView(
      {required this.controllerName, required this.path, this.builder, this.loadingWidget, this.errorBuilder});

  @override
  State<_AsyncWebFRouterView> createState() => _AsyncWebFRouterViewState();
}

class _AsyncWebFRouterViewState extends State<_AsyncWebFRouterView> {
  // Capture start time when state is created for performance tracking
  final DateTime _pfStartTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: WebFControllerManager.instance.getController(widget.controllerName),
        builder: (context, snapshot) {
          WebFController? existController = WebFControllerManager.instance.getControllerSync(widget.controllerName);
          if (existController == null ||
              !existController.evaluated ||
              snapshot.connectionState == ConnectionState.waiting) {
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
