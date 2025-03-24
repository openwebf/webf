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
import 'package:webf/launcher.dart';

typedef OnControllerCreated = void Function(WebFController controller);

/// The entry-point widget class responsible for rendering all content created by HTML, CSS, and JavaScript in WebF.
class WebF extends StatefulWidget {
  /// The WebF controller to use for rendering content
  final WebFController? controller;

  /// The name of the controller to fetch from WebFControllerManager
  final String? controllerName;

  /// Widget to display while loading the controller when using controllerName
  final Widget? loadingWidget;

  /// Custom error builder when using controllerName
  final Widget Function(BuildContext context, Object error)? errorBuilder;

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
    required this.controller,
  })  : controllerName = null,
        errorBuilder = null,
        super(key: key);

  /// Create a WebF widget using a controller name from WebFControllerManager.
  ///
  /// This constructor will asynchronously load the controller and automatically handle
  /// recreation of disposed controllers.
  ///
  /// You can customize the loading experience with loadingWidget and handle errors
  /// with errorBuilder. The builder allows you to create custom UI with the controller.
  const WebF.fromControllerName({
    Key? key,
    required String this.controllerName,
    this.loadingWidget,
    this.errorBuilder,
  })  : controller = null,
        super(key: key);

  /// Create a WebF widget synchronously using a controller from WebFControllerManager.
  ///
  /// This constructor doesn't handle recreation of disposed controllers,
  /// so only use it when you know the controller exists and is not disposed.
  factory WebF.sync(String controllerName, {Key? key}) {
    final controller = WebFControllerManager.instance.getControllerSync(controllerName);
    if (controller == null) {
      throw FlutterError('Controller with name "$controllerName" not found in WebFControllerManager.');
    }
    return WebF(key: key, controller: controller);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    if (controller != null) {
      properties.add(StringProperty('controller', controller.toString()));

      final name = WebFControllerManager.instance.getControllerName(controller!);
      if (name != null) {
        properties.add(StringProperty('controllerName', name));
      }
    } else if (controllerName != null) {
      properties.add(StringProperty('controllerName', controllerName));
    }
  }

  @override
  State<WebF> createState() {
    if (controller != null) {
      return WebFDirectState();
    } else {
      return _WebFAsyncState();
    }
  }
}

/// The state for WebF when using a direct controller reference
class WebFDirectState extends State<WebF> with RouteAware {
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
    _isWebFInitReady = widget.controller!.evaluated;

    if (!widget.controller!.isComplete) {
      widget.controller!.controlledInitCompleter.future.then((_) {
        if (mounted) {
          setState(() {
            _isWebFInitReady = true;
          });
        }
      });
    }
  }

  Future<void> load(WebFBundle bundle) async {
    await widget.controller!.load(bundle);
  }

  Future<void> reload() async {
    await widget.controller!.reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get controller name from the WebFControllerManager
    String? controllerName = WebFControllerManager.instance.getControllerName(widget.controller!);

    // If the controller is managed by WebFControllerManager, use its attach method
    if (controllerName != null) {
      WebFControllerManager.instance.attachController(controllerName, context);
    } else {
      // Fallback to direct attachment if not managed by WebFControllerManager
      widget.controller!.attachToFlutter(context);
    }
  }

  void requestForUpdate(AdapterUpdateReason reason) {
    if (!mounted) return;

    if (reason is WebFInitReason) {
      setState(() {
        _isWebFInitReady = true;
      });
    } else if (reason is DocumentElementChangedReason) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_flutterScreenIsReady) {
      return const SizedBox(width: 0, height: 0);
    }

    List<Widget> children = [];

    if (_isWebFInitReady &&
        widget.controller!.controlledInitCompleter.isCompleted &&
        widget.controller!.view.document.documentElement != null) {
      children = [widget.controller!.view.document.documentElement!.toWidget()];
    }

    Widget result = RepaintBoundary(
      child: WebFContext(
        child: WebFRootViewport(
          widget.controller!,
          viewportWidth: widget.controller!.viewportWidth,
          viewportHeight: widget.controller!.viewportHeight,
          background: widget.controller!.background,
          resizeToAvoidBottomInsets: widget.controller!.resizeToAvoidBottomInsets,
          children: children,
        ),
      ),
    );

    return result;
  }

  @override
  void dispose() {
    super.dispose();

    // Get controller name from the WebFControllerManager
    String? controllerName = WebFControllerManager.instance.getControllerName(widget.controller!);

    // If the controller is managed by WebFControllerManager, use its detach method
    if (controllerName != null) {
      WebFControllerManager.instance.detachController(controllerName);
    } else {
      // Fallback to direct detachment if not managed by WebFControllerManager
      widget.controller!.detachFromFlutter();
    }
  }
}

/// The state for WebF when using a controller name (async loading)
class _WebFAsyncState extends State<WebF> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebFController?>(
      future: WebFControllerManager.instance.getController(widget.controllerName!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        return WebF(
            controller: snapshot.data!,
            loadingWidget: widget.loadingWidget ??
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ));
      },
    );
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

class WebFRootViewport extends MultiChildRenderObjectWidget {
  final bool resizeToAvoidBottomInsets;
  final WebFController controller;
  final Color? background;
  final double? viewportWidth;
  final double? viewportHeight;

  // Creates a widget that visually hides its child.
  WebFRootViewport(
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
  _WebFRenderObjectElement(WebFRootViewport widget) : super(widget);

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
        final webFState = findAncestorStateOfType<WebFDirectState>();

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
        webFState?.requestForUpdate(WebFInitReason());
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
  WebFRootViewport get widget => super.widget as WebFRootViewport;
}
