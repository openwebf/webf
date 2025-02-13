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
import 'package:webf/gesture.dart';

typedef OnControllerCreated = void Function(WebFController controller);

class WebF extends StatefulWidget {
  /// The background color for viewport, default to transparent.
  final Color? background;

  /// the width of webFWidget
  final double? viewportWidth;

  /// the height of webFWidget
  final double? viewportHeight;

  /// The methods of the webFNavigateDelegation help you implement custom behaviors that are triggered
  /// during a webf view's process of loading, and completing a navigation request.
  final WebFNavigationDelegate? navigationDelegate;

  /// A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final WebFMethodChannel? javaScriptChannel;

  /// Register the RouteObserver to observer page navigation.
  /// This is useful if you wants to pause webf timers and callbacks when webf widget are hidden by page route.
  /// https://api.flutter.dev/flutter/widgets/RouteObserver-class.html
  final RouteObserver<ModalRoute<void>>? routeObserver;

  /// Trigger when webf controller once created.
  final OnControllerCreated? onControllerCreated;

  /// Specify the running thread for your JavaScript codes.
  /// Default value: DedicatedThread();
  ///
  /// [DedicatedThread] : Executes your JavaScript code in a dedicated thread.
  ///   Advantage: Ideal for developers building applications with hundreds of DOM elements in JavaScript,
  ///     where common user interactions like scrolling and swiping do not heavily depend on the JavaScript.
  ///   Disadvantages: Increase communicate overhead since the JavaScript is runs in a separate thread.
  ///     Data exchanges between Dart and JavaScript requires mutex and synchronization.
  ///
  /// [DedicatedThreadGroup] : Executes multiple JavaScript contexts in a single thread.
  ///     Rather than creating a new thread for each WebF instance, this option allows placing multiple WebF instances and their JavaScript contexts
  ///     into one dedicated thread.
  ///   Advantage: JavaScript contexts in the same group can share global class and string data, reducing initialization time
  ///     for new WebF instances and their JavaScript contexts in this thread.
  ///   Disadvantages: Since all group members run in the same thread, one can block the others, even if they are not strong related.
  ///
  /// [FlutterUIThread] : Executes your JavaScript code within the Flutter UI thread.
  ///   Advantage: This is the best mode for minimizing communication time between Dart and JavaScript, especially when you have animations
  ///     controlled by JavaScript and rendered by Flutter. If you're building animations influenced by user interactions, like figure gestures,
  ///     setting the runningThread to [FlutterUIThread] is the optimal choice.
  ///   Disadvantages: Any executing of JavaScript will block the executing of Dart codes.
  ///     If a JavaScript function takes longer than a single frame, it could cause lag, as all Dart code executing will be blocked by your JavaScript.
  ///     Be mindful of JavaScript executing times when using this mode.
  ///
  final WebFThread? runningThread;

  final LoadErrorHandler? onLoadError;

  final LoadHandler? onLoad;

  /// https://developer.mozilla.org/en-US/docs/Web/API/Document/DOMContentLoaded_event
  final LoadHandler? onDOMContentLoaded;

  final JSErrorHandler? onJSError;

  // Open a service to support Chrome DevTools for debugging.
  final DevToolsService? devToolsService;

  final GestureListener? gestureListener;

  final HttpClientInterceptor? httpClientInterceptor;

  final UriParser? uriParser;

  /// Remote resources (HTML, CSS, JavaScript, Images, and other content loadable via WebFBundle) can be pre-loaded before WebF is mounted in Flutter.
  /// Use this property to reduce loading times when a WebF application attempts to load external resources on pages.
  final List<WebFBundle>? preloadedBundles;

  /// The initial cookies to set.
  final List<Cookie>? initialCookies;

  final WebFController controller;

  /// If true the content should size itself to avoid the onscreen keyboard
  /// whose height is defined by the ambient [FlutterView]'s
  /// [FlutterView.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the widget,
  /// the view can be resized to avoid overlapping the keyboard, which prevents
  /// widgets inside the view from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInsets;

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

  WebF(
      {Key? key,
      this.viewportWidth,
      this.viewportHeight,
      this.onControllerCreated,
      this.onLoad,
      this.onDOMContentLoaded,
      this.navigationDelegate,
      this.javaScriptChannel,
      this.background,
      this.gestureListener,
      this.devToolsService,
      // webf's http client interceptor.
      this.httpClientInterceptor,
      this.uriParser,
      WebFThread? runningThread,
      this.routeObserver,
      this.initialCookies,
      this.preloadedBundles,
      required this.controller,
      // webf's viewportWidth options only works fine when viewportWidth is equal to window.physicalSize.width / window.devicePixelRatio.
      // Maybe got unexpected error when change to other values, use this at your own risk!
      // We will fixed this on next version released. (v0.6.0)
      // Disable viewportWidth check and no assertion error report.
      bool disableViewportWidthAssertion = false,
      // webf's viewportHeight options only works fine when viewportHeight is equal to window.physicalSize.height / window.devicePixelRatio.
      // Maybe got unexpected error when change to other values, use this at your own risk!
      // We will fixed this on next version release. (v0.6.0)
      // Disable viewportHeight check and no assertion error report.
      bool disableViewportHeightAssertion = false,
      // Callback functions when loading Javascript scripts failed.
      this.onLoadError,
      this.onJSError,
      this.resizeToAvoidBottomInsets = true})
      : runningThread = runningThread ?? DedicatedThread(),
        super(key: key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('viewportWidth', viewportWidth));
    properties.add(DiagnosticsProperty<double>('viewportHeight', viewportHeight));
  }

  @override
  WebFState createState() => WebFState();
}

class WebFState extends State<WebF> with RouteAware {
  bool _flutterScreenIsReady = false;
  bool _isWebFInitReady = false;

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
    _isWebFInitReady = widget.controller.evaluated;
  }

  Future<void> load(WebFBundle bundle) async {
    await widget.controller.load(bundle);
  }

  Future<void> reload() async {
    await widget.controller.reload();
  }

  void requestForUpdate(AdapterUpdateReason reason) {
    if (reason is WebFInitReason) {
      setState(() {
        _isWebFInitReady = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    if (!_flutterScreenIsReady) {
      return SizedBox(width: 0, height: 0);
    }

    List<Widget> children = [];

    if (_isWebFInitReady) {
      children = [widget.controller.view.document.documentElement!.toWidget()];
    }

    return RepaintBoundary(
      child: WebFContext(
        child: WebFRootRenderObjectWidget(
          widget.controller,
          background: widget.background,
          children: children,
          resizeToAvoidBottomInsets: widget.resizeToAvoidBottomInsets,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.routeObserver != null) {
      widget.routeObserver!.subscribe(this, ModalRoute.of(context)!);
    }
    if (widget.controller.routeObserver != null) {
      widget.controller.routeObserver!.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didUpdateWidget(WebF oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resizeToAvoidBottomInsets != widget.resizeToAvoidBottomInsets) {
      widget.controller.resizeToAvoidBottomInsets = widget.resizeToAvoidBottomInsets;
    }
  }

  @override
  void dispose() {
    if (widget.routeObserver != null) {
      widget.routeObserver!.unsubscribe(this);
    }
    super.dispose();
  }
}

class WebFContext extends InheritedWidget {
  WebFContext({required super.child, this.controller});

  final WebFController? controller;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
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

class WebFRootRenderObjectWidget extends MultiChildRenderObjectWidget {
  final bool resizeToAvoidBottomInsets;
  final WebFController controller;
  final Color? background;
  final double? viewportWidth;
  final double? viewportHeight;

  // Creates a widget that visually hides its child.
  WebFRootRenderObjectWidget(
    this.controller, {
    Key? key,
    this.background,
    this.viewportWidth,
    this.viewportHeight,
    required List<Widget> children,
    this.resizeToAvoidBottomInsets = true,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    RenderViewportBox root = RenderViewportBox(
        background: background,
        viewportSize:
            (viewportWidth != null && viewportHeight != null) ? ui.Size(viewportWidth!, viewportHeight!) : null,
        controller: controller);
    controller.view.viewport = root;

    return root;
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    if (controller.disposed) return;
  }

  @override
  _WebFRenderObjectElement createElement() {
    return _WebFRenderObjectElement(this);
  }
}

class _WebFRenderObjectElement extends MultiChildRenderObjectElement {
  _WebFRenderObjectElement(WebFRootRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) async {
    super.mount(parent, newSlot);
    assert(parent is WebFContextInheritElement);
    WebFController controller = widget.controller;
    (parent as WebFContextInheritElement).controller = controller;

    await controller.controlledInitCompleter.future;
    controller.buildContextStack.add(this);

    if (controller.entrypoint == null) {
      throw FlutterError('Consider providing a WebFBundle resource as the entry point for WebF');
    }

    // Sync element state.
    flushUICommand(controller.view, nullptr);

    // Should schedule to the next frame to make sure the RenderViewportBox(WebF's root renderObject) had been layout.
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        WebFState webFState = findAncestorStateOfType<WebFState>()!;

        if (controller.evaluated) {
          controller.view.document.initializeRootElementSize();
          if (!controller.view.firstLoad) {
            controller.resume();
          }
          return;
        }
        // Sync viewport size to the documentElement.
        controller.view.document.initializeRootElementSize();
        // Starting to flush ui commands every frames.
        controller.view.flushPendingCommandsPerFrame();

        // Bundle could be executed before mount to the flutter tree.
        if (controller.mode == WebFLoadingMode.standard) {
          await controller.executeEntrypoint();
        } else if (controller.mode == WebFLoadingMode.preloading) {
          await controller.controllerPreloadingCompleter.future;
          assert(controller.entrypoint!.isResolved);
          assert(controller.entrypoint!.isDataObtained);
          if (controller.unfinishedPreloadResources == 0 && controller.entrypoint!.isHTML) {
            await controller.view.document.scriptRunner.executePreloadedBundles();
          } else if (controller.entrypoint!.isJavascript || controller.entrypoint!.isBytecode) {
            await controller.evaluateEntrypoint();
          }

          flushUICommand(controller.view, nullptr);

          controller.checkCompleted();
          controller.dispatchWindowPreloadedEvent();
        } else if (controller.mode == WebFLoadingMode.preRendering) {
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
        }

        controller.evaluated = true;
        webFState.requestForUpdate(WebFInitReason());
      });
    } catch (e, stack) {
      print('$e\n$stack');
    }
  }

  @override
  void unmount() {
    WebFController controller = widget.controller;
    super.unmount();
    controller.pause();
    controller.buildContextStack.removeLast();
  }

  @override
  WebFRootRenderObjectWidget get widget => super.widget as WebFRootRenderObjectWidget;
}
