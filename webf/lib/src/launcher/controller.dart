/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart'
    show RouteInformation, WidgetsBinding, WidgetsBindingObserver, AnimationController;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';
import 'package:webf/devtools.dart';
import 'package:webf/webf.dart';

// Error handler when load bundle failed.
typedef LoadErrorHandler = void Function(FlutterError error, StackTrace stack);
typedef LoadHandler = void Function(WebFController controller);
typedef TitleChangedHandler = void Function(String title);
typedef JSErrorHandler = void Function(String message);
typedef JSLogHandler = void Function(int level, String message);
typedef PendingCallback = void Function();
typedef OnCustomElementAttached = void Function(WebFWidgetElementToWidgetAdapter newWidget);
typedef OnCustomElementDetached = void Function(WebFWidgetElementToWidgetAdapter detachedWidget);

typedef TraverseElementCallback = void Function(Element element);

// Traverse DOM element.
void traverseElement(Element element, TraverseElementCallback callback) {
  callback(element);
  for (Element el in element.children) {
    traverseElement(el, callback);
  }
}

// See http://github.com/flutter/flutter/wiki/Desktop-shells
/// If the current platform is a desktop platform that isn't yet supported by
/// TargetPlatform, override the default platform to one that is.
/// Otherwise, do nothing.
/// No need to handle macOS, as it has now been added to TargetPlatform.
void setTargetPlatformForDesktop() {
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

abstract class DevToolsService {
  /// Design prevDevTool for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static DevToolsService? prevDevTools;

  static final Map<int, DevToolsService> _contextDevToolMap = {};
  static DevToolsService? getDevToolOfContextId(int contextId) {
    return _contextDevToolMap[contextId];
  }

  /// Used for debugger inspector.
  UIInspector? _uiInspector;
  UIInspector? get uiInspector => _uiInspector;

  late Isolate _isolateServer;
  Isolate get isolateServer => _isolateServer;
  set isolateServer(Isolate isolate) {
    _isolateServer = isolate;
  }

  SendPort? _isolateServerPort;
  SendPort? get isolateServerPort => _isolateServerPort;
  set isolateServerPort(SendPort? value) {
    _isolateServerPort = value;
  }

  WebFController? _controller;
  WebFController? get controller => _controller;

  void init(WebFController controller) {
    _contextDevToolMap[controller.view.contextId] = this;
    _controller = controller;
    spawnIsolateInspectorServer(this, controller);
    _uiInspector = UIInspector(this);
    controller.view.debugDOMTreeChanged = uiInspector!.onDOMTreeChanged;
  }

  bool get isReloading => _reloading;
  bool _reloading = false;

  void willReload() {
    _reloading = true;
  }

  void didReload() {
    _reloading = false;
    controller!.view.debugDOMTreeChanged = _uiInspector!.onDOMTreeChanged;
    _isolateServerPort!.send(InspectorReload(_controller!.view.contextId));
  }

  void dispose() {
    _uiInspector?.dispose();
    _contextDevToolMap.remove(controller!.view.contextId);
    _controller = null;
    _isolateServerPort = null;
    _isolateServer.kill();
  }
}

// An kraken View Controller designed for multiple kraken view control.
class WebFViewController implements WidgetsBindingObserver {
  WebFController rootController;

  // The methods of the KrakenNavigateDelegation help you implement custom behaviors that are triggered
  // during a kraken view's process of loading, and completing a navigation request.
  WebFNavigationDelegate? navigationDelegate;

  GestureListener? gestureListener;

  List<Cookie>? initialCookies;

  double _viewportWidth;
  double get viewportWidth => _viewportWidth;
  set viewportWidth(double value) {
    if (value != _viewportWidth) {
      _viewportWidth = value;
      viewport.viewportSize = ui.Size(_viewportWidth, _viewportHeight);
    }
  }

  double _viewportHeight;
  double get viewportHeight => _viewportHeight;
  set viewportHeight(double value) {
    if (value != _viewportHeight) {
      _viewportHeight = value;
      viewport.viewportSize = ui.Size(_viewportWidth, _viewportHeight);
    }
  }

  Color? background;

  WebFViewController(this._viewportWidth, this._viewportHeight,
      {this.background,
      this.enableDebug = false,
      required this.rootController,
      this.navigationDelegate,
      this.gestureListener,
      this.initialCookies,
      // Viewport won't change when kraken page reload, should reuse previous page's viewportBox.
      RenderViewportBox? originalViewport}) {
    if (enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }
    BindingBridge.setup();
    _contextId = initBridge(this);

    if (originalViewport != null) {
      viewport = originalViewport;
    } else {
      viewport = RenderViewportBox(
          background: background, viewportSize: ui.Size(viewportWidth, viewportHeight), controller: rootController);
    }

    _setupObserver();

    defineBuiltInElements();

    // Wait viewport mounted on the outside renderObject tree.
    Future.microtask(() {
      // Execute UICommand.createDocument and UICommand.createWindow to initialize window and document.
      flushUICommand(this);
    });

    SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
  }

  void _postFrameCallback(Duration timeStamp) {
    if (disposed) return;
    flushUICommand(this);
    SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
  }

  final Map<int, BindingObject> _nativeObjects = {};

  T? getBindingObject<T>(Pointer pointer) {
    return _nativeObjects[pointer.address] as T?;
  }

  bool hasBindingObject(Pointer pointer) {
    return _nativeObjects.containsKey(pointer.address);
  }

  void setBindingObject(Pointer pointer, BindingObject bindingObject) {
    assert(!_nativeObjects.containsKey(pointer.address));
    _nativeObjects[pointer.address] = bindingObject;
  }

  void removeBindingObject(Pointer pointer) {
    _nativeObjects.remove(pointer.address);
  }

  // Index value which identify javascript runtime context.
  late int _contextId;
  int get contextId => _contextId;

  // Enable print debug message when rendering.
  bool enableDebug;

  // Kraken have already disposed.
  bool _disposed = false;

  bool get disposed => _disposed;

  late RenderViewportBox viewport;
  late Document document;
  late Window window;

  void initDocument(view, Pointer<NativeBindingObject> pointer) {
    document = Document(
      BindingContext(view, _contextId, pointer),
      viewport: viewport,
      controller: rootController,
      gestureListener: gestureListener,
      initialCookies: initialCookies,
    );

    // Listeners need to be registered to window in order to dispatch events on demand.
    if (gestureListener != null) {
      GestureListener listener = gestureListener!;
      if (listener.onTouchStart != null) {
        document.addEventListener(EVENT_TOUCH_START, (Event event) => listener.onTouchStart!(event as TouchEvent));
      }

      if (listener.onTouchMove != null) {
        document.addEventListener(EVENT_TOUCH_MOVE, (Event event) => listener.onTouchMove!(event as TouchEvent));
      }

      if (listener.onTouchEnd != null) {
        document.addEventListener(EVENT_TOUCH_END, (Event event) => listener.onTouchEnd!(event as TouchEvent));
      }

      if (listener.onDrag != null) {
        document.addEventListener(EVENT_DRAG, (Event event) => listener.onDrag!(event as GestureEvent));
      }
    }
  }

  void initWindow(WebFViewController view, Pointer<NativeBindingObject> pointer) {
    window = Window(BindingContext(view, _contextId, pointer), document);
    _registerPlatformBrightnessChange();

    // Blur input element when new input focused.
    window.addEventListener(EVENT_CLICK, (event) {
      if (event.target is Element) {
        Element? focusedElement = document.focusedElement;
        if (focusedElement != null && focusedElement != event.target) {
          document.focusedElement!.blur();
        }
        (event.target as Element).focus();
      }
    });
  }

  void setCookie(List<Cookie> cookies, [Uri? uri]) {
    document.cookie.setCookie(cookies, uri);
  }

  void clearCookie() {
    document.cookie.clearCookie();
  }

  void evaluateJavaScripts(String code) async {
    assert(!_disposed, 'WebF have already disposed');
    List<int> data = utf8.encode(code);
    await evaluateScripts(_contextId, Uint8List.fromList(data));
  }

  void _setupObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _teardownObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  // Attach kraken's renderObject to an renderObject.
  void attachTo(RenderObject parent, [RenderObject? previousSibling]) {
    if (parent is ContainerRenderObjectMixin) {
      parent.insert(document.renderer!, after: previousSibling);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = document.renderer;
    }
  }

  // Dispose controller and recycle all resources.
  void dispose() {
    _disposed = true;
    debugDOMTreeChanged = null;

    _teardownObserver();
    _unregisterPlatformBrightnessChange();

    // Should clear previous page cached ui commands
    clearUICommand(_contextId);

    disposePage(_contextId);

    clearCssLength();

    _nativeObjects.forEach((key, object) {
      object.dispose();
    });
    _nativeObjects.clear();

    document.dispose();
    window.dispose();
  }

  VoidCallback? _originalOnPlatformBrightnessChanged;

  void _registerPlatformBrightnessChange() {
    _originalOnPlatformBrightnessChanged = rootController.ownerFlutterView.platformDispatcher.onPlatformBrightnessChanged;
    rootController.ownerFlutterView.platformDispatcher.onPlatformBrightnessChanged = _onPlatformBrightnessChanged;
  }

  void _unregisterPlatformBrightnessChange() {
    rootController.ownerFlutterView.platformDispatcher.onPlatformBrightnessChanged = _originalOnPlatformBrightnessChanged;
    _originalOnPlatformBrightnessChanged = null;
  }

  void _onPlatformBrightnessChanged() {
    if (_originalOnPlatformBrightnessChanged != null) {
      _originalOnPlatformBrightnessChanged!();
    }
    window.dispatchEvent(ColorSchemeChangeEvent(window.colorScheme));
  }

  // export Uint8List bytes from rendered result.
  Future<Uint8List> toImage(double devicePixelRatio, [Pointer<Void>? eventTargetPointer]) {
    assert(!_disposed, 'WebF have already disposed');
    Completer<Uint8List> completer = Completer();
    try {
      if (eventTargetPointer != null && !hasBindingObject(eventTargetPointer)) {
        String msg = 'toImage: unknown node id: $eventTargetPointer';
        completer.completeError(Exception(msg));
        return completer.future;
      }
      var node = eventTargetPointer == null ? document.documentElement : getBindingObject(eventTargetPointer);
      if (node is Element) {
        if (!node.isRendererAttached) {
          String msg = 'toImage: the element is not attached to document tree.';
          completer.completeError(Exception(msg));
          return completer.future;
        }

        node.toBlob(devicePixelRatio: devicePixelRatio).then((Uint8List bytes) {
          completer.complete(bytes);
        }).catchError((e, stack) {
          String msg = 'toBlob: failed to export image data from element id: $eventTargetPointer. error: $e}.\n$stack';
          completer.completeError(Exception(msg));
        });
      } else {
        String msg = 'toBlob: node is not an element, id: $eventTargetPointer';
        completer.completeError(Exception(msg));
      }
    } catch (e, stack) {
      completer.completeError(e, stack);
    }
    return completer.future;
  }

  void createElement(Pointer<NativeBindingObject> nativePtr, String tagName) {
    assert(!hasBindingObject(nativePtr), 'ERROR: Can not create element with same id "$nativePtr"');
    document.createElement(tagName.toUpperCase(), BindingContext(document.controller.view, _contextId, nativePtr));
  }

  void createElementNS(Pointer<NativeBindingObject> nativePtr, String uri, String tagName) {
    assert(!hasBindingObject(nativePtr), 'ERROR: Can not create element with same id "$nativePtr"');
    document.createElementNS(uri, tagName.toUpperCase(), BindingContext(document.controller.view, _contextId, nativePtr));
  }

  void createTextNode(Pointer<NativeBindingObject> nativePtr, String data) {
    document.createTextNode(data, BindingContext(document.controller.view, _contextId, nativePtr));
  }

  void createComment(Pointer<NativeBindingObject> nativePtr) {
    document.createComment(BindingContext(document.controller.view, _contextId, nativePtr));
  }

  void createDocumentFragment(Pointer<NativeBindingObject> nativePtr) {
    document.createDocumentFragment(BindingContext(document.controller.view, _contextId, nativePtr));
  }

  void addEvent(Pointer<NativeBindingObject> nativePtr, String eventType, {Pointer<AddEventListenerOptions>? addEventListenerOptions}) {
    if (!hasBindingObject(nativePtr)) return;
    EventTarget? target = getBindingObject<EventTarget>(nativePtr);
    if (target != null) {
      BindingBridge.listenEvent(target, eventType, addEventListenerOptions: addEventListenerOptions);
    }
  }

  void removeEvent(Pointer<NativeBindingObject> nativePtr, String eventType, {bool isCapture = false}) {
    if (!hasBindingObject(nativePtr)) return;
    EventTarget? target = getBindingObject<EventTarget>(nativePtr);
    if (target != null) {
      BindingBridge.unlistenEvent(target, eventType, isCapture: isCapture);
    }
  }

  void cloneNode(Pointer<NativeBindingObject> selfPtr, Pointer<NativeBindingObject> newPtr) {
    EventTarget originalTarget = getBindingObject<EventTarget>(selfPtr)!;
    EventTarget newTarget = getBindingObject<EventTarget>(newPtr)!;

    // Current only element clone will process in dart.
    if (originalTarget is Element) {
      Element newElement = newTarget as Element;
      // Copy inline style.
      originalTarget.inlineStyle.forEach((key, value) {
        newElement.setInlineStyle(key, value);
      });
      // Copy element attributes.
      originalTarget.attributes.forEach((key, value) {
        newElement.setAttribute(key, value);
      });
      newElement.className = originalTarget.className;
      newElement.id = originalTarget.id;
    }
  }

  void removeNode(Pointer pointer) {
    assert(hasBindingObject(pointer), 'pointer: $pointer');

    Node target = getBindingObject<Node>(pointer)!;
    target.parentNode?.removeChild(target);

    _debugDOMTreeChanged();
  }

  /// <!-- beforebegin -->
  /// <p>
  ///   <!-- afterbegin -->
  ///   foo
  ///   <!-- beforeend -->
  /// </p>
  /// <!-- afterend -->
  void insertAdjacentNode(Pointer<NativeBindingObject> selfPointer, String position, Pointer<NativeBindingObject> newPointer) {
    assert(hasBindingObject(selfPointer), 'targetId: $selfPointer position: $position newTargetId: $newPointer');
    assert(hasBindingObject(selfPointer), 'newTargetId: $newPointer position: $position');

    Node target = getBindingObject<Node>(selfPointer)!;
    Node newNode = getBindingObject<Node>(newPointer)!;
    Node? targetParentNode = target.parentNode;

    switch (position) {
      case 'beforebegin':
        targetParentNode!.insertBefore(newNode, target);
        break;
      case 'afterbegin':
        target.insertBefore(newNode, target.firstChild!);
        break;
      case 'beforeend':
        target.appendChild(newNode);
        break;
      case 'afterend':
        if (targetParentNode!.lastChild == target) {
          targetParentNode.appendChild(newNode);
        } else {
          targetParentNode.insertBefore(
            newNode,
            target.nextSibling!
          );
        }
        break;
    }

    _debugDOMTreeChanged();
  }

  void setAttribute(Pointer<NativeBindingObject> selfPtr, String key, String value) {
    assert(hasBindingObject(selfPtr), 'selfPtr: $selfPtr key: $key value: $value');
    Node target = getBindingObject<Node>(selfPtr)!;

    if (target is Element) {
      // Only element has properties.
      target.setAttribute(key, value);
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      target.data = value;
    } else {
      debugPrint('Only element has properties, try setting $key to Node(#$selfPtr).');
    }
  }

  String? getAttribute(Pointer selfPtr, String key) {
    assert(hasBindingObject(selfPtr), 'targetId: $selfPtr key: $key');
    Node target = getBindingObject<Node>(selfPtr)!;

    if (target is Element) {
      // Only element has attributes.
      return target.getAttribute(key);
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      // @TODO: property is not attribute.
      return target.data;
    } else {
      return null;
    }
  }

  void removeAttribute(Pointer selfPtr, String key) {
    assert(hasBindingObject(selfPtr), 'targetId: $selfPtr key: $key');
    Node target = getBindingObject<Node>(selfPtr)!;

    if (target is Element) {
      target.removeAttribute(key);
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      // @TODO: property is not attribute.
      target.data = '';
    } else {
      debugPrint('Only element has attributes, try removing $key from Node(#$selfPtr).');
    }
  }

  void setInlineStyle(Pointer selfPtr, String key, String value) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr key: $key value: $value');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

    if (target is Element) {
      target.setInlineStyle(key, value);
    } else {
      debugPrint('Only element has style, try setting style.$key from Node(#$selfPtr).');
    }
  }

  void clearInlineStyle(Pointer selfPtr) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

    if (target is Element) {
      target.clearInlineStyle();
    } else {
      debugPrint('Only element has style, try clear style from Node(#$selfPtr).');
    }
  }

  void flushPendingStyleProperties(int address) {
    if (!hasBindingObject(Pointer.fromAddress(address))) return;
    Node? target = getBindingObject<Node>(Pointer.fromAddress(address));
    if (target == null) return;

    if (target is Element) {
      target.style.flushPendingProperties();
    } else {
      debugPrint('Only element has style, try flushPendingStyleProperties from Node(#${Pointer.fromAddress(address)}).');
    }
  }

  void recalculateStyle(int address) {
    if (!hasBindingObject(Pointer.fromAddress(address))) return;
    Node? target = getBindingObject<Node>(Pointer.fromAddress(address));
    if (target == null) return;

    if (target is Element) {
      target.tryRecalculateStyle();
    } else {
      debugPrint('Only element has style, try recalculateStyle from Node(#${Pointer.fromAddress(address)}).');
    }
  }

  // Hooks for DevTools.
  VoidCallback? debugDOMTreeChanged;
  void _debugDOMTreeChanged() {
    VoidCallback? f = debugDOMTreeChanged;
    if (f != null) {
      f();
    }
  }

  Future<void> handleNavigationAction(String? sourceUrl, String targetUrl, WebFNavigationType navigationType) async {
    WebFNavigationAction action = WebFNavigationAction(sourceUrl, targetUrl, navigationType);

    WebFNavigationDelegate _delegate = navigationDelegate!;

    try {
      WebFNavigationActionPolicy policy = await _delegate.dispatchDecisionHandler(action);
      if (policy == WebFNavigationActionPolicy.cancel) return;

      switch (action.navigationType) {
        case WebFNavigationType.navigate:
          await rootController.load(rootController.getPreloadBundleFromUrl(action.target) ?? WebFBundle.fromUrl(action.target));
          break;
        case WebFNavigationType.reload:
          await rootController.reload();
          break;
        default:
        // Navigate and other type, do nothing.
      }
    } catch (e, stack) {
      if (_delegate.errorHandler != null) {
        _delegate.errorHandler!(e, stack);
      } else {
        print('WebF navigation failed: $e\n$stack');
      }
    }
  }

  // Call from JS Bridge when the BindingObject class on the JS side had been Garbage collected.
  void disposeBindingObject(WebFViewController view, Pointer<NativeBindingObject> pointer) async {
    BindingObject? bindingObject = getBindingObject(pointer);
    bindingObject?.dispose();
    view.removeBindingObject(pointer);
    malloc.free(pointer);
  }

  RenderObject getRootRenderObject() {
    return viewport;
  }

  @override
  void didChangeAccessibilityFeatures() {
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        document.visibilityChange(VisibilityState.visible);
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        document.visibilityChange(VisibilityState.hidden);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
  }

  static double FOCUS_VIEWINSET_BOTTOM_OVERALL = 32;

  @override
  void didChangeMetrics() {
    final ownerView = rootController.ownerFlutterView;

    final bool resizeToAvoidBottomInsets = rootController.resizeToAvoidBottomInsets;
    final double bottomInsets;
    if (resizeToAvoidBottomInsets) {
      bottomInsets = ownerView.viewInsets.bottom / ownerView.devicePixelRatio;
    } else {
      bottomInsets = 0;
    }

    if (resizeToAvoidBottomInsets) {
      bool shouldScrollByToCenter = false;
      Element? focusedElement = document.focusedElement;
      double scrollOffset = 0;
      if (focusedElement != null) {
        RenderBox? renderer = focusedElement.renderer;
        if (renderer != null && renderer.attached && renderer.hasSize) {
          Offset focusOffset = renderer.localToGlobal(Offset.zero);
          // FOCUS_VIEWINSET_BOTTOM_OVERALL to meet border case.
          if (focusOffset.dy > viewportHeight - bottomInsets - FOCUS_VIEWINSET_BOTTOM_OVERALL) {
            shouldScrollByToCenter = true;
            scrollOffset =
                focusOffset.dy - (viewportHeight - bottomInsets) + renderer.size.height + FOCUS_VIEWINSET_BOTTOM_OVERALL;
          }
        }
      }
      // Show keyboard
      if (shouldScrollByToCenter) {
        window.scrollBy(0, scrollOffset, true);
      }
    }
    viewport.bottomInset = bottomInsets;
  }

  @override
  void didChangePlatformBrightness() {
  }

  @override
  void didChangeTextScaleFactor() {
  }

  @override
  void didHaveMemoryPressure() {
  }

  @override
  Future<bool> didPopRoute() async {

    return false;
  }

  @override
  Future<bool> didPushRoute(String route) async {
    return false;
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    return false;
  }

  @override
  Future<ui.AppExitResponse> didRequestAppExit() async {
    return ui.AppExitResponse.exit;
  }
}

// An controller designed to control kraken's functional modules.
class WebFModuleController with TimerMixin, ScheduleFrameMixin {
  late ModuleManager _moduleManager;
  ModuleManager get moduleManager => _moduleManager;

  WebFModuleController(WebFController controller, int contextId) {
    _moduleManager = ModuleManager(controller, contextId);
  }

  Future<void> initialize() async {
    await _moduleManager.initialize();
  }

  void dispose() {
    disposeTimer();
    disposeScheduleFrame();
    _moduleManager.dispose();
  }
}

class WebFController {
  static final Map<int, WebFController?> _controllerMap = {};
  static final Map<String, int> _nameIdMap = {};

  UriParser? uriParser;

  static WebFController? getControllerOfJSContextId(int? contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  static Map<int, WebFController?> getControllerMap() {
    return _controllerMap;
  }

  static WebFController? getControllerOfName(String name) {
    if (!_nameIdMap.containsKey(name)) return null;
    int? contextId = _nameIdMap[name];
    return getControllerOfJSContextId(contextId);
  }

  GestureDispatcher gestureDispatcher = GestureDispatcher();

  LoadHandler? onLoad;
  LoadHandler? onDOMContentLoaded;
  TitleChangedHandler? onTitleChanged;

  // Error handler when load bundle failed.
  LoadErrorHandler? onLoadError;

  // Error handler when got javascript error when evaluate javascript codes.
  JSErrorHandler? onJSError;

  final DevToolsService? devToolsService;
  final HttpClientInterceptor? httpClientInterceptor;

  WebFMethodChannel? _methodChannel;

  WebFMethodChannel? get methodChannel => _methodChannel;

  JSLogHandler? _onJSLog;
  JSLogHandler? get onJSLog => _onJSLog;
  set onJSLog(JSLogHandler? jsLogHandler) {
    _onJSLog = jsLogHandler;
  }

  // Internal usable. Notifications to WebF widget when custom element had changed.
  OnCustomElementAttached? onCustomElementAttached;
  OnCustomElementDetached? onCustomElementDetached;

  final List<Cookie>? initialCookies;

  final ui.FlutterView ownerFlutterView;
  bool resizeToAvoidBottomInsets;

  String? _name;
  String? get name => _name;
  set name(String? value) {
    if (value == null) return;
    if (_name != null) {
      int? contextId = _nameIdMap[_name];
      _nameIdMap.remove(_name);
      _nameIdMap[value] = contextId!;
    }
    _name = value;
  }

  final GestureListener? _gestureListener;

  final List<WebFBundle>? preloadedBundles;
  Map<String, WebFBundle>? _preloadBundleIndex;
  WebFBundle? getPreloadBundleFromUrl(String url) {
    return _preloadBundleIndex?[url];
  }
  void _initializePreloadBundle() {
    if (preloadedBundles == null) return;
    _preloadBundleIndex = {};
    preloadedBundles!.forEach((bundle) {
      _preloadBundleIndex![bundle.url] = bundle;
    });
  }

  // The kraken view entrypoint bundle.
  WebFBundle? _entrypoint;

  WebFController(
    String? name,
    double viewportWidth,
    double viewportHeight, {
    bool showPerformanceOverlay = false,
    bool enableDebug = false,
    bool autoExecuteEntrypoint = true,
    Color? background,
    GestureListener? gestureListener,
    WebFNavigationDelegate? navigationDelegate,
    WebFMethodChannel? methodChannel,
    WebFBundle? entrypoint,
    this.onCustomElementAttached,
    this.onCustomElementDetached,
    this.onLoad,
    this.onDOMContentLoaded,
    this.onLoadError,
    this.onJSError,
    this.httpClientInterceptor,
    this.devToolsService,
    this.uriParser,
    this.preloadedBundles,
    this.initialCookies,
    required this.ownerFlutterView,
    this.resizeToAvoidBottomInsets = true,
  })  : _name = name,
        _entrypoint = entrypoint,
        _gestureListener = gestureListener {

    _initializePreloadBundle();

    _methodChannel = methodChannel;
    WebFMethodChannel.setJSMethodCallCallback(this);

    _view = WebFViewController(
      viewportWidth,
      viewportHeight,
      background: background,
      enableDebug: enableDebug,
      rootController: this,
      navigationDelegate: navigationDelegate ?? WebFNavigationDelegate(),
      gestureListener: _gestureListener,
      initialCookies: initialCookies
    );

    final int contextId = _view.contextId;

    _module = WebFModuleController(this, contextId);

    if (entrypoint != null) {
      HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
      historyModule.add(entrypoint);
    }

    assert(!_controllerMap.containsKey(contextId), 'found exist contextId of WebFController, contextId: $contextId');
    _controllerMap[contextId] = this;
    assert(!_nameIdMap.containsKey(name), 'found exist name of WebFController, name: $name');
    if (name != null) {
      _nameIdMap[name] = contextId;
    }

    setupHttpOverrides(httpClientInterceptor, contextId: contextId);

    uriParser ??= UriParser();

    if (devToolsService != null) {
      devToolsService!.init(this);
    }

    if (autoExecuteEntrypoint) {
      executeEntrypoint();
    }
  }

  late WebFViewController _view;

  WebFViewController get view {
    return _view;
  }

  late WebFModuleController _module;

  WebFModuleController get module {
    return _module;
  }

  final Queue<HistoryItem> previousHistoryStack = Queue();
  final Queue<HistoryItem> nextHistoryStack = Queue();

  final Map<String, String> sessionStorage = {};

  HistoryModule get history => _module.moduleManager.getModule('History')!;

  static Uri fallbackBundleUri([int? id]) {
    // The fallback origin uri, like `vm://bundle/0`
    return Uri(scheme: 'vm', host: 'bundle', path: id != null ? '$id' : null);
  }

  void setNavigationDelegate(WebFNavigationDelegate delegate) {
    _view.navigationDelegate = delegate;
  }

  Future<void> unload() async {
    assert(!_view._disposed, 'WebF have already disposed');
    // Should clear previous page cached ui commands
    clearUICommand(_view.contextId);

    // Wait for next microtask to make sure C++ native Elements are GC collected.
    Completer completer = Completer();
    Future.microtask(() {
      _module.dispose();
      _view.dispose();
      // RenderViewportBox will not disposed when reload, just remove all children and clean all resources.
      _view.viewport.reload();

      int oldId = _view.contextId;

      _view = WebFViewController(view.viewportWidth, view.viewportHeight,
          background: _view.background,
          enableDebug: _view.enableDebug,
          rootController: this,
          navigationDelegate: _view.navigationDelegate,
          gestureListener: _view.gestureListener,
          originalViewport: _view.viewport);

      _module = WebFModuleController(this, _view.contextId);

      // Reconnect the new contextId to the Controller
      _controllerMap.remove(oldId);
      _controllerMap[_view.contextId] = this;
      if (name != null) {
        _nameIdMap[name!] = _view.contextId;
      }

      completer.complete();
    });

    return completer.future;
  }

  String? get _url {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    return historyModule.stackTop?.url;
  }

  Uri? get _uri {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    return historyModule.stackTop?.resolvedUri;
  }

  String get url => _url ?? '';
  Uri? get uri => _uri;

  _addHistory(WebFBundle bundle) {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    historyModule.add(bundle);
  }

  Future<void> reload() async {
    assert(!_view._disposed, 'WebF have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    _isComplete = false;

    await unload();
    await executeEntrypoint();

    if (devToolsService != null) {
      devToolsService!.didReload();
    }
  }

  Future<void> load(WebFBundle bundle) async {
    assert(!_view._disposed, 'WebF have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    await unload();

    // Update entrypoint.
    _entrypoint = bundle;
    _addHistory(bundle);

    await executeEntrypoint();

    if (devToolsService != null) {
      devToolsService!.didReload();
    }
  }

  String? getResourceContent(String? url) {
    WebFBundle? entrypoint = _entrypoint;
    if (url == this.url && entrypoint != null && entrypoint.isResolved) {
      return utf8.decode(entrypoint.data!);
    }
    return null;
  }

  bool _paused = false;
  bool get paused => _paused;

  final List<PendingCallback> _pendingCallbacks = [];

  void pushPendingCallbacks(PendingCallback callback) {
    _pendingCallbacks.add(callback);
  }

  void flushPendingCallbacks() {
    for (int i = 0; i < _pendingCallbacks.length; i++) {
      _pendingCallbacks[i]();
    }
    _pendingCallbacks.clear();
  }

  // Pause all timers and callbacks if kraken page are invisible.
  void pause() {
    _paused = true;
    module.pauseInterval();
  }

  // Resume all timers and callbacks if kraken page now visible.
  void resume() {
    _paused = false;
    flushPendingCallbacks();
    module.resumeInterval();
  }

  bool _disposed = false;
  bool get disposed => _disposed;
  void dispose() {
    _module.dispose();
    _view.dispose();
    _controllerMap[_view.contextId] = null;
    _controllerMap.remove(_view.contextId);
    _nameIdMap.remove(name);
    // To release entrypoint bundle memory.
    _entrypoint?.dispose();

    devToolsService?.dispose();
    _disposed = true;
  }

  String get origin {
    Uri uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  Future<void> executeEntrypoint(
      {bool shouldResolve = true, bool shouldEvaluate = true, AnimationController? animationController}) async {
    if (_entrypoint != null && shouldResolve) {
      await Future.wait([
        _resolveEntrypoint(),
        _module.initialize()
      ]);
      if (_entrypoint!.isResolved && shouldEvaluate) {
        await _evaluateEntrypoint(animationController: animationController);
      } else {
        throw FlutterError('Unable to resolve $_entrypoint');
      }
    } else {
      throw FlutterError('Entrypoint is empty.');
    }
  }

  // Resolve the entrypoint bundle.
  // In general you should use executeEntrypoint, which including resolving and evaluating.
  Future<void> _resolveEntrypoint() async {
    assert(!_view._disposed, 'WebF have already disposed');

    WebFBundle? bundleToLoad = _entrypoint;
    if (bundleToLoad == null) {
      // Do nothing if bundle is null.
      return;
    }

    // Resolve the bundle, including network download or other fetching ways.
    try {
      await bundleToLoad.resolve(baseUrl: url, uriParser: uriParser);
      await bundleToLoad.obtainData();
    } catch (e, stack) {
      if (onLoadError != null) {
        onLoadError!(FlutterError(e.toString()), stack);
      }
      // Not to dismiss this error.
      rethrow;
    }
  }

  // Execute the content from entrypoint bundle.
  Future<void> _evaluateEntrypoint({AnimationController? animationController}) async {
    // @HACK: Execute JavaScript scripts will block the Flutter UI Threads.
    // Listen for animationController listener to make sure to execute Javascript after route transition had completed.
    if (animationController != null) {
      animationController.addStatusListener((AnimationStatus status) async {
        if (status == AnimationStatus.completed) {
          await _evaluateEntrypoint();
        }
      });
      return;
    }

    assert(!_view._disposed, 'WebF have already disposed');
    if (_entrypoint != null) {
      WebFBundle entrypoint = _entrypoint!;
      int contextId = _view.contextId;
      assert(entrypoint.isResolved, 'The webf bundle $entrypoint is not resolved to evaluate.');

      // entry point start parse.
      _view.document.parsing = true;

      Uint8List data = entrypoint.data!;
      if (entrypoint.isJavascript) {
        assert(isValidUTF8String(data), 'The JavaScript codes should be in UTF-8 encoding format');
        // Prefer sync decode in loading entrypoint.
        await evaluateScripts(contextId, data, url: url);
      } else if (entrypoint.isBytecode) {
        evaluateQuickjsByteCode(contextId, data);
      } else if (entrypoint.isHTML) {
        assert(isValidUTF8String(data), 'The HTML codes should be in UTF-8 encoding format');
        parseHTML(contextId, data);
      } else if (entrypoint.contentType.primaryType == 'text') {
        // Fallback treating text content as JavaScript.
        try {
          assert(isValidUTF8String(data), 'The JavaScript codes should be in UTF-8 encoding format');
          await evaluateScripts(contextId, data, url: url);
        } catch (error) {
          print('Fallback to execute JavaScript content of $url');
          rethrow;
        }
      } else {
        // The resource type can not be evaluated.
        throw FlutterError('Can\'t evaluate content of $url');
      }

      // entry point end parse.
      _view.document.parsing = false;

      // Should check completed when parse end.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // UICommand list is read in the next frame, so we need to determine whether there are labels
        // such as images and scripts after it to check is completed.
        checkCompleted();
      });
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.h#L470
  bool _isComplete = false;

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.cpp#L840
  // Check whether the document has been loaded, such as html has parsed (main of JS has evaled) and images/scripts has loaded.
  void checkCompleted() {
    if (_isComplete) return;

    // Are we still parsing?
    if (_view.document.parsing) return;

    // Are all script element complete?
    if (_view.document.isDelayingDOMContentLoadedEvent) return;

    _view.document.readyState = DocumentReadyState.interactive;
    _dispatchDOMContentLoadedEvent();

    // Still waiting for images/scripts?
    if (_view.document.hasPendingRequest) return;

    // Still waiting for elements that don't go through a FrameLoader?
    if (_view.document.isDelayingLoadEvent) return;

    // Any frame that hasn't completed yet?
    // TODO:

    _isComplete = true;

    _dispatchWindowLoadEvent();
    _view.document.readyState = DocumentReadyState.complete;
  }

  void _dispatchDOMContentLoadedEvent() {
    Event event = Event(EVENT_DOM_CONTENT_LOADED);
    EventTarget window = view.window;
    window.dispatchEvent(event);
    _view.document.dispatchEvent(event);
    if (onDOMContentLoaded != null) {
      onDOMContentLoaded!(this);
    }
  }

  void _dispatchWindowLoadEvent() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // DOM element are created at next frame, so we should trigger onload callback in the next frame.
      Event event = Event(EVENT_LOAD);
      _view.window.dispatchEvent(event);

      if (onLoad != null) {
        onLoad!(this);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }
}
