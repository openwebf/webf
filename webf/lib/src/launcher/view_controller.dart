/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2024-present The OpenWebF(Cayman) company. All rights reserved.
 */

// An View Controller designed for multiple view control.
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/src/dom/intersection_observer.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Element;
import 'package:ffi/ffi.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/html/canvas/canvas_context_2d.dart';
import 'package:webf/src/html/text.dart';
import 'package:webf/webf.dart';

// FFI binding for the C++ batch free function
typedef NativeBatchFreeFunction = Void Function(Pointer<Void> pointers, Int32 count);
typedef DartBatchFreeFunction = void Function(Pointer<Void> pointers, int count);

final DartBatchFreeFunction _batchFreeNativeBindingObjects = WebFDynamicLibrary.ref
    .lookupFunction<NativeBatchFreeFunction, DartBatchFreeFunction>('batchFreeNativeBindingObjects');

class WebFViewController with Diagnosticable implements WidgetsBindingObserver {
  WebFController rootController;

  // The methods of the WebFNavigationDelegate help you implement custom behaviors that are triggered
  // during a view's process of loading, and completing a navigation request.
  WebFNavigationDelegate? navigationDelegate;

  List<Cookie>? initialCookies;

  final List<List<UICommand>> pendingUICommands = [];

  Color? background;
  WebFThread runningThread;

  bool firstLoad = true;

  // Idle cleanup state
  static final Map<double, List<Pointer>> _pendingPointers = {};
  static final Map<double, List<Pointer>> _pendingPointersWithEvents = {};
  static const int _batchThreshold = 2000;

  WebFViewController(
      {this.background,
      this.enableDebug = false,
      this.enableBlink = false,
      required this.rootController,
      required this.runningThread,
      this.navigationDelegate,
      this.initialCookies});

  bool _inited = false;

  bool get inited => _inited;

  static const Duration _nativeMediaQueryAffectingValueDebounceDuration = Duration(milliseconds: 16);
  Timer? _nativeMediaQueryAffectingValueDebounceTimer;
  bool _nativeMediaQueryAffectingValuePostFrameCallbackScheduled = false;
  double? _lastNotifiedViewportWidth;
  double? _lastNotifiedViewportHeight;
  double? _lastNotifiedDevicePixelRatio;
  int? _lastNotifiedPageAddress;

  Future<void> initialize() async {
    if (enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    _contextId = await initBridge(this, runningThread, enableBlink);

    _inited = true;

    _setupObserver();

    defineBuiltInElements();
  }

  bool _isAnimationTimelineStopped = false;

  bool get isAnimationTimelineStopped => _isAnimationTimelineStopped;
  final List<VoidCallback> _pendingAnimationTimesLines = [];

  void stopAnimationsTimeLine() {
    _isAnimationTimelineStopped = true;
  }

  void addPendingAnimationTimeline(VoidCallback callback) {
    _pendingAnimationTimesLines.add(callback);
  }

  void resumeAnimationTimeline() {

    for (var callback in _pendingAnimationTimesLines) {
      try {
        callback();
      } catch (_) {}
    }
    _pendingAnimationTimesLines.clear();
    _isAnimationTimelineStopped = false;
  }

  bool _isFrameBindingAttached = false;

  void flushPendingCommandsPerFrame() {
    if (disposed && _isFrameBindingAttached) return;
    _isFrameBindingAttached = true;
    flushUICommand(this, window.pointer!);
    // Deliver pending IntersectionObserver entries to JS side.
    // Safe to call every frame; it will no-op when there are no entries.
    deliverIntersectionObserver();
    SchedulerBinding.instance.addPostFrameCallback((_) => flushPendingCommandsPerFrame());
  }

  final Map<String, Completer<void>> _hybridRouteLoadCompleter = {};

  Future<void> awaitForHybridRouteLoaded(String routePath) {
    if (!_hybridRouteLoadCompleter.containsKey(routePath)) {
      _hybridRouteLoadCompleter[routePath] = Completer<void>();

      // Add timeout fallback for route load.
      Timer(Duration(seconds: 20), () {
        if (_hybridRouteLoadCompleter[routePath]?.isCompleted == false) {
          _hybridRouteLoadCompleter[routePath]!.complete();
        }
      });
    }
    return _hybridRouteLoadCompleter[routePath]!.future;
  }

  final Map<String, WidgetElement> _hybridRouterViews = {};

  void setHybridRouterView(String path, WidgetElement root) {
    _hybridRouterViews[path] = root;

    if (!_hybridRouteLoadCompleter.containsKey(path)) {
      _hybridRouteLoadCompleter[path] = Completer();
    }

    if (!_hybridRouteLoadCompleter[path]!.isCompleted) {
      _hybridRouteLoadCompleter[path]!.complete();
    }
  }

  RouterLinkElement? getHybridRouterView(String path) {
    // First try exact match (for static routes)
    if (_hybridRouterViews.containsKey(path)) {
      return _hybridRouterViews[path] as RouterLinkElement?;
    }

    // Then try pattern matching for dynamic routes
    for (String pattern in _hybridRouterViews.keys) {
      if (pattern.contains(':')) {
        // This is a dynamic route pattern like "/user/:userId"
        if (_matchesPattern(pattern, path)) {
          return _hybridRouterViews[pattern] as RouterLinkElement?;
        }
      }
    }

    return null;
  }

  // Helper method to match dynamic route patterns
  bool _matchesPattern(String pattern, String path) {
    // Convert pattern like "/user/:userId" to regex like "^/user/([^/]+)$"
    String regexPattern = pattern.replaceAllMapped(RegExp(r':([^/]+)'), (match) => r'([^/]+)');
    regexPattern = '^${regexPattern.replaceAll('/', r'\/')}\$';

    RegExp regex = RegExp(regexPattern);
    return regex.hasMatch(path);
  }

  void removeHybridRouterView(String path) {
    _hybridRouterViews.remove(path);
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

  // fix New version of chrome devTools castrating the last three digits of long targetId num strings and replacing them with 0
  int _nodeIdCount = 0;
  final Map<int, int> _targetIdToDevNodeIdMap = {};

  Map<int, int> get targetIdToDevNodeIdMap => _targetIdToDevNodeIdMap;

  int getTargetIdByNodeId(int? address) {
    if (address == null) {
      return 0;
    }
    int targetId = targetIdToDevNodeIdMap.keys.firstWhere((k) => targetIdToDevNodeIdMap[k] == address, orElse: () => 0);
    return targetId;
  }

  void disposeTargetIdToDevNodeIdMap(BindingObject? object) {
    _targetIdToDevNodeIdMap.remove(object?.pointer?.address);
  }

  int forDevtoolsNodeId(BindingObject object) {
    int? nativeAddress = object.pointer?.address;
    if (nativeAddress != null) {
      if (targetIdToDevNodeIdMap[nativeAddress] != null) {
        return targetIdToDevNodeIdMap[nativeAddress]!;
      }
      _nodeIdCount++;
      targetIdToDevNodeIdMap[nativeAddress] = _nodeIdCount;
      return _nodeIdCount;
    }
    return 0;
  }

  // fix New version of chrome devTools end

  // Index value which identify javascript runtime context.
  late double _contextId;

  double get contextId => _contextId;

  // Enable print debug message when rendering.
  bool enableDebug;

  // Enable Blink CSS stack
  bool enableBlink;

  // have already disposed.
  bool _disposed = false;

  bool get disposed => _disposed;

  // Root viewport for the full WebF widget.
  RootRenderViewportBox? viewport;

  // Viewport used when rendering a hybrid router subview (WebFSubView/WebFRouterView).
  RouterViewViewportBox? routerViewport;

  // The effective viewport for DOM APIs like window.innerWidth/innerHeight.
  RenderViewportBox? get currentViewport => routerViewport ?? viewport;
  late Document document;
  late Window window;

  final List<ui.VoidCallback> _onFlutterAttached = [];

  void registerCallbackOnceForFlutterAttached(ui.VoidCallback callback) {
    _onFlutterAttached.add(callback);
  }

  void attachToFlutter(BuildContext context) {
    _registerPlatformBrightnessChange();
    // Resume animation timeline when attached back to Flutter

    document.animationTimeline.resume();
    // Also clear the stopped guard and run any pending animation starters.
    resumeAnimationTimeline();
    for (int i = 0; i < _onFlutterAttached.length; i++) {
      _onFlutterAttached[i]();
    }
    _onFlutterAttached.clear();
  }

  void detachFromFlutter() {
    _unregisterPlatformBrightnessChange();
    // Pause animation timeline to prevent ticker from running when detached
    document.animationTimeline.pause();
    viewport = null;
    routerViewport = null;
  }

  void initDocument(view, Pointer<NativeBindingObject> pointer) {
    document = Document(
      BindingContext(view, _contextId, pointer),
      controller: rootController,
    );

    firstLoad = false;
  }

  void initWindow(WebFViewController view, Pointer<NativeBindingObject> pointer) {
    window = Window(BindingContext(view, _contextId, pointer), document);

    // 3 seconds should be enough for page loading, make sure the JavaScript GC was opened.
    Timer(Duration(seconds: 3), () {
      window.dispatchEvent(Event('gcopen'));
    });
  }

  Future<void> evaluateJavaScripts(String code) async {
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

  // Dispose controller and recycle all resources.
  Future<void> dispose() async {
    if (!_inited) return;
    _nativeMediaQueryAffectingValueDebounceTimer?.cancel();
    _nativeMediaQueryAffectingValueDebounceTimer = null;
    _nativeMediaQueryAffectingValuePostFrameCallbackScheduled = false;
    routerViewport = null;
    await waitingSyncTaskComplete(contextId);
    _disposed = true;
    debugDOMTreeChanged = null;
    _hybridRouteLoadCompleter.clear();

    _teardownObserver();
    _unregisterPlatformBrightnessChange();

    // Should clear previous page cached ui commands
    clearUICommand(_contextId);

    await disposePage(runningThread is FlutterUIThread, _contextId);

    clearCssLength();

    await disposeAllBindingObjects();

    document.dispose();
    window.dispose();

    _targetIdToDevNodeIdMap.clear();

    // Force batch free all pending pointers when controller is disposed
    _batchFreePointers(_contextId);

    // Also free pointers with pending events since controller is being disposed
    _batchFreePointersWithEvents(_contextId);

    // Dispose shared Dio client bound to this context
    disposeSharedDioForContext(_contextId);
  }

  void _scheduleNativeMediaQueryAffectingValueChanged() {
    if (_nativeMediaQueryAffectingValueDebounceTimer != null) return;
    _nativeMediaQueryAffectingValueDebounceTimer =
        Timer(_nativeMediaQueryAffectingValueDebounceDuration, _scheduleNativeMediaQueryAffectingValueFlushAfterFrame);
  }

  void _scheduleNativeMediaQueryAffectingValueFlushAfterFrame() {
    _nativeMediaQueryAffectingValueDebounceTimer = null;
    if (_nativeMediaQueryAffectingValuePostFrameCallbackScheduled) return;
    _nativeMediaQueryAffectingValuePostFrameCallbackScheduled = true;

    // Ensure viewport RenderObject has the latest size before C++ side reads
    // window.innerWidth/innerHeight (used for media query evaluation).
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _nativeMediaQueryAffectingValuePostFrameCallbackScheduled = false;
      _flushNativeMediaQueryAffectingValueChanged();
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _flushNativeMediaQueryAffectingValueChanged() {
    if (!_inited || _disposed || WebFController.getControllerOfJSContextId(_contextId) == null) {
      return;
    }

    final Pointer<Void>? page = getAllocatedPage(_contextId);
    if (page == null) return;

    if (_lastNotifiedPageAddress != page.address) {
      _lastNotifiedPageAddress = page.address;
      _lastNotifiedViewportWidth = null;
      _lastNotifiedViewportHeight = null;
      _lastNotifiedDevicePixelRatio = null;
    }

    final double width = window.innerWidth;
    final double height = window.innerHeight;
    bool shouldDispatchResizeEvent = false;
    if (_lastNotifiedViewportWidth != width || _lastNotifiedViewportHeight != height) {
      nativeOnViewportSizeChanged(page, width, height);
      _lastNotifiedViewportWidth = width;
      _lastNotifiedViewportHeight = height;
      shouldDispatchResizeEvent = true;
    }

    final double dpr = window.devicePixelRatio;
    if (_lastNotifiedDevicePixelRatio != dpr) {
      nativeOnDevicePixelRatioChanged(page, dpr);
      _lastNotifiedDevicePixelRatio = dpr;
      shouldDispatchResizeEvent = true;
    }

    if (shouldDispatchResizeEvent) {
      // Fire standard window resize event for JS frameworks and user code.
      rootController.dispatchWindowResizeEvent();
    }
  }

  VoidCallback? _originalOnPlatformBrightnessChanged;

  void _registerPlatformBrightnessChange() {
    _originalOnPlatformBrightnessChanged =
        rootController.ownerFlutterView?.platformDispatcher.onPlatformBrightnessChanged;
    rootController.ownerFlutterView?.platformDispatcher.onPlatformBrightnessChanged = onPlatformBrightnessChanged;
  }

  void _unregisterPlatformBrightnessChange() {
    if (_originalOnPlatformBrightnessChanged == null) return;
    rootController.ownerFlutterView?.platformDispatcher.onPlatformBrightnessChanged =
        _originalOnPlatformBrightnessChanged;
    _originalOnPlatformBrightnessChanged = null;
  }

  void onPlatformBrightnessChanged() {
    if (_originalOnPlatformBrightnessChanged != null) {
      _originalOnPlatformBrightnessChanged!();
    }

    window.dispatchEvent(ColorSchemeChangeEvent(window.colorScheme));

    // Recalculate styles so prefers-color-scheme media queries re-evaluate
    document.recalculateStyleImmediately();
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
        SchedulerBinding.instance.addPostFrameCallback((_) {
          node.toBlob(devicePixelRatio: devicePixelRatio).then((Uint8List bytes) {
            completer.complete(bytes);
          }).catchError((e, stack) {
            String msg =
                'toBlob: failed to export image data from element id: $eventTargetPointer. error: $e}.\n$stack';
            completer.completeError(Exception(msg));
          });
        });
        SchedulerBinding.instance.scheduleFrame();
        return completer.future;
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
    document.createElementNS(
        uri, tagName, BindingContext(document.controller.view, _contextId, nativePtr));
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

  void addIntersectionObserver(
      Pointer<NativeBindingObject> observerPointer, Pointer<NativeBindingObject> elementPointer) {
    assert(hasBindingObject(observerPointer), 'observer: $observerPointer');
    assert(hasBindingObject(elementPointer), 'element: $elementPointer');

    IntersectionObserver? observer = getBindingObject<IntersectionObserver>(observerPointer);
    Element? element = getBindingObject<Element>(elementPointer);
    if (null == observer || null == element) {
      return;
    }

    document.addIntersectionObserver(observer, element);
  }

  void removeIntersectionObserver(
      Pointer<NativeBindingObject> observerPointer, Pointer<NativeBindingObject> elementPointer) {
    assert(hasBindingObject(observerPointer), 'observer: $observerPointer');
    assert(hasBindingObject(elementPointer), 'element: $elementPointer');

    IntersectionObserver? observer = getBindingObject<IntersectionObserver>(observerPointer);
    Element? element = getBindingObject<Element>(elementPointer);
    if (null == observer || null == element) {
      return;
    }

    document.removeIntersectionObserver(observer, element);
  }

  void disconnectIntersectionObserver(Pointer<NativeBindingObject> observerPointer) {
    assert(hasBindingObject(observerPointer), 'observer: $observerPointer');

    IntersectionObserver? observer = getBindingObject<IntersectionObserver>(observerPointer);
    if (null == observer) {
      return;
    }

    document.disconnectIntersectionObserver(observer);
  }

  void deliverIntersectionObserver() {
    document.deliverIntersectionObserver();
  }

  void addEvent(Pointer<NativeBindingObject> nativePtr, String eventType,
      {Pointer<AddEventListenerOptions>? addEventListenerOptions}) {
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
    assert(hasBindingObject(selfPtr));
    assert(hasBindingObject(newPtr));

    EventTarget? originalTarget = getBindingObject<EventTarget>(selfPtr);
    EventTarget? newTarget = getBindingObject<EventTarget>(newPtr);

    if (originalTarget == null || newTarget == null) return;

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
    if (!hasBindingObject(pointer)) return;

    Node? target = getBindingObject<Node>(pointer);
    Node? parent = target?.parentNode;
    target?.parentNode?.removeChild(target);

    final cb = devtoolsChildNodeRemoved;
    if (parent != null && target != null && cb != null) {
      try {
        cb(parent, target);
      } catch (_) {}
    } else {
      // Fallback to legacy full refresh
      _debugDOMTreeChanged();
    }
  }

  /// <!-- beforebegin -->
  /// <p>
  ///   <!-- afterbegin -->
  ///   foo
  ///   <!-- beforeend -->
  /// </p>
  /// <!-- afterend -->
  void insertAdjacentNode(
      Pointer<NativeBindingObject> selfPointer, String position, Pointer<NativeBindingObject> newPointer) {
    assert(hasBindingObject(selfPointer), 'targetId: $selfPointer position: $position newTargetId: $newPointer');
    assert(hasBindingObject(newPointer), 'newTargetId: $newPointer position: $position');

    Node? target = getBindingObject<Node>(selfPointer);
    Node? newNode = getBindingObject<Node>(newPointer);

    if (target == null || newNode == null) {
      return;
    }

    Node? targetParentNode = target.parentNode;

    switch (position) {
      case 'beforebegin':
        Node? previousSibling = target.previousSibling;
        targetParentNode!.insertBefore(newNode, target);
        final cb = devtoolsChildNodeInserted;
        if (cb != null) cb(targetParentNode, newNode, previousSibling);
        break;
      case 'afterbegin':
        Node? previousSibling;
        target.insertBefore(newNode, target.firstChild!);
        final cb = devtoolsChildNodeInserted;
        if (cb != null) cb(target, newNode, previousSibling);
        break;
      case 'beforeend':
        Node? previousSibling = target.lastChild;
        target.appendChild(newNode);
        final cb = devtoolsChildNodeInserted;
        if (cb != null) cb(target, newNode, previousSibling);
        break;
      case 'afterend':
        if (targetParentNode!.lastChild == target) {
          Node? previousSibling = target;
          targetParentNode.appendChild(newNode);
          final cb = devtoolsChildNodeInserted;
          if (cb != null) cb(targetParentNode, newNode, previousSibling);
        } else {
          Node? previousSibling = target;
          targetParentNode.insertBefore(newNode, target.nextSibling!);
          final cb = devtoolsChildNodeInserted;
          if (cb != null) cb(targetParentNode, newNode, previousSibling);
        }
        break;
    }

    if (devtoolsChildNodeInserted == null) {
      _debugDOMTreeChanged();
    }
  }

  void setAttribute(Pointer<NativeBindingObject> selfPtr, String key, String value) {
    assert(hasBindingObject(selfPtr), 'selfPtr: $selfPtr key: $key value: $value');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

    if (target is Element) {
      // Only element has properties.
      // Element.setAttribute now emits DOM.attributeModified via DevTools hooks;
      // avoid double-emitting here.
      target.setAttribute(key, value);
      if (devtoolsAttributeModified == null) {
        _debugDOMTreeChanged();
      }
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      // TextNode.data setter will emit DevTools DOM.characterDataModified when hooks are present.
      target.data = value;
      if (devtoolsCharacterDataModified == null) {
        _debugDOMTreeChanged();
      }

      if (target.parentNode is WebFTextElement) {
        (target.parentNode as WebFTextElement).notifyRootTextElement();
      }
    } else {
      debugPrint('Only element has properties, try setting $key to Node(#$selfPtr).');
    }
  }

  String? getAttribute(Pointer selfPtr, String key) {
    assert(hasBindingObject(selfPtr), 'targetId: $selfPtr key: $key');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return null;

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
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

    if (target is Element) {
      // Element.removeAttribute now emits DOM.attributeRemoved via DevTools hooks;
      // avoid double-emitting here.
      target.removeAttribute(key);
      if (devtoolsAttributeRemoved == null) {
        _debugDOMTreeChanged();
      }
    } else if (target is TextNode && (key == 'data' || key == 'nodeValue')) {
      // property is not attribute; TextNode.data setter will emit DevTools event if hooks present.
      target.data = '';
      if (devtoolsCharacterDataModified == null) {
        _debugDOMTreeChanged();
      }
    } else {
      debugPrint('Only element has attributes, try removing $key from Node(#$selfPtr).');
    }
  }

  void requestCanvasPaint(Pointer selfPtr) {
    assert(hasBindingObject(selfPtr), 'targetId: $selfPtr');
    CanvasRenderingContext2D? context2d = getBindingObject<CanvasRenderingContext2D>(selfPtr);
    context2d?.requestPaint();
  }

  void setInlineStyle(Pointer selfPtr, String key, String value, {String? baseHref}) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr key: $key value: $value');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

    if (target is Element) {
      target.setInlineStyle(key, value, baseHref: baseHref, fromNative: true);
    }
  }

  void clearInlineStyle(Pointer selfPtr) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

    if (target is Element) {
      target.clearInlineStyle();
    }
  }

  void setPseudoStyle(Pointer selfPtr, String args, String key, String value, {String? baseHref}) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;
    if (target is! Element) {
      debugPrint("[setPseudoStyle] target is not an element");
      return;
    }

    switch(args) {
      case 'before':
      case 'after':
      case 'first-letter':
      case 'first-line':
        target.setPseudoStyle(args, key, value, baseHref: baseHref, fromNative: true);
        break;

      default:
        debugPrint("[setPseudoStyle] Not supported pseudo element: $args");
    }
  }

  void removePseudoStyle(Pointer selfPtr, String args, String key) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;
    if (target is! Element) {
      debugPrint("[removePseudoStyle] target is not an element");
      return;
    }

    switch(args) {
      case 'before':
      case 'after':
      case 'first-letter':
      case 'first-line':
        target.removePseudoStyle(args, key);
        break;
      default:
        debugPrint("[removePseudoStyle] Not supported pseudo element: $args");
    }
  }

  void clearPseudoStyle(Pointer selfPtr, String args) {
    assert(hasBindingObject(selfPtr), 'id: $selfPtr');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;
    if (target is! Element) {
      debugPrint("[clearPseudoStyle] target is not an element");
      return;
    }

    switch (args) {
      case 'before':
      case 'after':
      case 'first-letter':
      case 'first-line':
        target.clearPseudoStyle(args);
        break;
      default:
        debugPrint("[clearPseudoStyle] Not supported pseudo element: $args");
    }
  }

  void flushPendingStyleProperties(int address) {
    if (!hasBindingObject(Pointer.fromAddress(address))) return;
    Node? target = getBindingObject<Node>(Pointer.fromAddress(address));
    if (target == null) return;

    if (target is Element) {
      target.style.flushPendingProperties();
    }
  }

  // Hooks for DevTools.
  VoidCallback? debugDOMTreeChanged;

  // Incremental DOM mutation hooks
  void Function(Node parent, Node node, Node? previousSibling)? devtoolsChildNodeInserted;
  void Function(Node parent, Node node)? devtoolsChildNodeRemoved;
  void Function(Element element, String name, String? value)? devtoolsAttributeModified;
  void Function(Element element, String name)? devtoolsAttributeRemoved;
  void Function(TextNode node)? devtoolsCharacterDataModified;

  void _debugDOMTreeChanged() {
    VoidCallback? f = debugDOMTreeChanged;
    if (f != null) {
      f();
    }
  }

  Future<void> handleNavigationAction(String? sourceUrl, String targetUrl, WebFNavigationType navigationType) async {
    WebFNavigationAction action = WebFNavigationAction(sourceUrl, targetUrl, navigationType);

    WebFNavigationDelegate delegate = navigationDelegate!;

    try {
      WebFNavigationActionPolicy policy = await delegate.dispatchDecisionHandler(action);
      if (policy == WebFNavigationActionPolicy.cancel) return;

      String targetPath = action.target;

      if (!Uri.parse(targetPath).isAbsolute) {
        String base = rootController.url;
        targetPath = rootController.uriParser!.resolve(Uri.parse(base), Uri.parse(targetPath)).toString();
      }

      if (action.target.trim().startsWith('#')) {
        String oldUrl = rootController.url;
        HistoryModule historyModule = rootController.module.moduleManager.getModule('History')!;
        historyModule.pushState(null, url: targetPath);
        await window.dispatchEvent(HashChangeEvent(newUrl: targetPath, oldUrl: oldUrl));
        return;
      }

      switch (action.navigationType) {
        case WebFNavigationType.navigate:
          await rootController
              .load(rootController.getPreloadBundleFromUrl(targetPath) ?? WebFBundle.fromUrl(targetPath));
          break;
        case WebFNavigationType.reload:
          await rootController.reload();
          break;
        default:
        // Navigate and other type, do nothing.
      }
    } catch (e, stack) {
      if (delegate.errorHandler != null) {
        delegate.errorHandler!(e, stack);
      } else {
        widgetLogger.warning('WebF navigation failed', e, stack);
      }
    }
  }

  // Call from JS Bridge when the BindingObject class on the JS side had been Garbage collected.
  static void disposeBindingObject(WebFViewController view, Pointer<NativeBindingObject> pointer) async {
    BindingObject? bindingObject = view.getBindingObject(pointer);

    // Check if this is an EventTarget with pending events
    bool hasPendingEvents = false;
    if (bindingObject is EventTarget && bindingObject.hasPendingEvents()) {
      hasPendingEvents = true;
    }

    bindingObject?.dispose();
    view.removeBindingObject(pointer);
    view.disposeTargetIdToDevNodeIdMap(bindingObject);

    // Schedule pointer to be batch freed
    if (hasPendingEvents) {
      // Add to special list for pointers with pending events
      // These will only be freed when the controller is disposed
      _addPendingPointerWithEvents(view._contextId, pointer);
    } else {
      // Regular cleanup for pointers without pending events
      _schedulePointerCleanup(view._contextId, pointer);
    }
  }

  Future<void> disposeAllBindingObjects() async {
    _nativeObjects.forEach((address, bindingObject) {
      Pointer pointer = bindingObject.pointer!;
      bindingObject.dispose();
      disposeTargetIdToDevNodeIdMap(bindingObject);
      _schedulePointerCleanup(contextId, pointer);
    });
    _nativeObjects.clear();
  }

  static List<Pointer> _getOrCreatePendingPointers(double contextId) {
    return _pendingPointers.putIfAbsent(contextId, () => <Pointer>[]);
  }

  static List<Pointer> _getOrCreatePendingPointersWithEvents(double contextId) {
    return _pendingPointersWithEvents.putIfAbsent(contextId, () => <Pointer>[]);
  }

  static void _addPendingPointerWithEvents(double contextId, Pointer pointer) {
    List<Pointer> pendingPointersWithEvents = _getOrCreatePendingPointersWithEvents(contextId);
    pendingPointersWithEvents.add(pointer);
  }

  /// Schedule a pointer to be freed in batch during idle time
  static void _schedulePointerCleanup(double contextId, Pointer pointer) {
    List<Pointer> pendingPointers = _getOrCreatePendingPointers(contextId);
    pendingPointers.add(pointer);

    // Only trigger immediate batch free when we hit the threshold
    // Do not schedule idle cleanup - pointers will be freed when controller is disposed or threshold is hit
    if (pendingPointers.length >= _batchThreshold) {
      _batchFreePointers(contextId);
    }
  }

  /// Batch free all pending pointers immediately
  static void _batchFreePointers(double contextId) {
    List<Pointer>? pendingPointers = _pendingPointers[contextId];
    if (pendingPointers == null || pendingPointers.isEmpty) return;

    List<Pointer> pointersToFree = List.from(pendingPointers);
    pendingPointers.clear();
    _pendingPointers.remove(contextId);

    try {
      _batchFreePointersArray(pointersToFree);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in immediate batch pointer cleanup: $e');
      }
    }
  }

  /// Batch free all pending pointers with events
  static void _batchFreePointersWithEvents(double contextId) {
    List<Pointer>? pendingPointersWithEvents = _pendingPointersWithEvents[contextId];
    if (pendingPointersWithEvents == null || pendingPointersWithEvents.isEmpty) return;

    List<Pointer> pointersToFree = List.from(pendingPointersWithEvents);
    pendingPointersWithEvents.clear();
    _pendingPointersWithEvents.remove(contextId);

    try {
      _batchFreePointersArray(pointersToFree);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in batch pointer cleanup for pointers with events: $e');
      }
    }
  }

  /// Call the C++ batch free function with an array of pointers
  static void _batchFreePointersArray(List<Pointer> pointers) {
    if (pointers.isEmpty) return;

    // Convert Dart List<Pointer> to C array
    Pointer<Pointer<Void>> pointersArray = malloc<Pointer<Void>>(pointers.length);

    for (int i = 0; i < pointers.length; i++) {
      pointersArray[i] = pointers[i].cast<Void>();
    }

    try {
      // Call the C++ batch free function
      _batchFreeNativeBindingObjects(pointersArray.cast<Void>(), pointers.length);
    } finally {
      // Always free the temporary array
      malloc.free(pointersArray);
    }
  }

  RenderBox? getRootRenderObject() {
    return document.viewport;
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (firstLoad) return;
    switch (state) {
      case AppLifecycleState.resumed:
        document.visibilityChange(VisibilityState.visible);
        rootController.resume();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        document.visibilityChange(VisibilityState.hidden);
        rootController.pause();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        rootController.pause();
        break;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {}

  static const double focusViewInsetBottomOverall = 32;

  @override
  void didChangeMetrics() {
    // Notify C++ Blink style engine about viewport and DPR changes so that
    // media queries depending on width/height/device-size and resolution can
    // be re-evaluated.
    if (_inited && !_disposed && WebFController.getControllerOfJSContextId(_contextId) != null) {
      _scheduleNativeMediaQueryAffectingValueChanged();
    }

    window.resizeViewportRelatedElements();
  }

  @override
  void didChangePlatformBrightness() {
    // If dark mode was override by the caller, watch the system platform changes to update platform brightness
    if (rootController.darkModeOverride == null) {
      // Notify C++ Blink style engine that color-scheme changed, so
      // prefers-color-scheme media queries can react to the new value.
      if (_inited && !_disposed && WebFController.getControllerOfJSContextId(_contextId) != null) {
        final Pointer<Void>? page = getAllocatedPage(_contextId);
        if (page != null) {
          final String scheme = window.colorScheme;
          final Pointer<Utf8> schemePtr = scheme.toNativeUtf8();
          nativeOnColorSchemeChanged(page, schemePtr, scheme.length);
          malloc.free(schemePtr);
        }
      }

      document.recalculateStyleImmediately();
    }
  }

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

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

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(backEvent) {
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(backEvent) {}

  @override
  void didChangeViewFocus(event) {}

  @override
  String toStringShort() {
    return describeIdentity(this);
  }
}
