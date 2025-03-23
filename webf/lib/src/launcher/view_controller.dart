/*
 * Copyright (C) 2024-present The OpenWebF(Cayman) company. All rights reserved.
 */

// An View Controller designed for multiple view control.
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Element;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

class WebFViewController implements WidgetsBindingObserver {
  WebFController rootController;

  // The methods of the WebFNavigationDelegate help you implement custom behaviors that are triggered
  // during a view's process of loading, and completing a navigation request.
  WebFNavigationDelegate? navigationDelegate;

  GestureListener? gestureListener;

  List<Cookie>? initialCookies;

  final List<List<UICommand>> pendingUICommands = [];

  Color? background;
  WebFThread runningThread;

  bool firstLoad = true;

  WebFViewController(
      {this.background,
        this.enableDebug = false,
        required this.rootController,
        required this.runningThread,
        this.navigationDelegate,
        this.gestureListener,
        this.initialCookies}) {}

  Future<void> initialize() async {
    if (enableDebug) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      debugPaintSizeEnabled = true;
    }

    _contextId = await initBridge(this, runningThread);

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
    _pendingAnimationTimesLines.forEach((callback) {
      callback();
    });
    _pendingAnimationTimesLines.clear();
    _isAnimationTimelineStopped = false;
  }

  bool _isFrameBindingAttached = false;

  void flushPendingCommandsPerFrame() {
    if (disposed && _isFrameBindingAttached) return;
    _isFrameBindingAttached = true;
    flushUICommand(this, window.pointer!);
    SchedulerBinding.instance.addPostFrameCallback((_) => flushPendingCommandsPerFrame());
  }

  final Map<String, WidgetElement> _hybridRouterViews = {};

  void setHybridRouterView(String path, WidgetElement root) {
    _hybridRouterViews[path] = root;
  }

  RouterLinkElement? getHybridRouterView(String path) {
    return _hybridRouterViews[path] as RouterLinkElement?;
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

  // have already disposed.
  bool _disposed = false;

  bool get disposed => _disposed;

  RenderViewportBox? viewport;
  late Document document;
  late Window window;

  final List<ui.VoidCallback> _onFlutterAttached = [];

  void registerCallbackOnceForFlutterAttached(ui.VoidCallback callback) {
    _onFlutterAttached.add(callback);
  }

  void attachToFlutter(BuildContext context) {
    _registerPlatformBrightnessChange();
    for (int i = 0; i < _onFlutterAttached.length; i ++) {
      _onFlutterAttached[i]();
    }
    _onFlutterAttached.clear();
  }

  void detachFromFlutter() {
    _unregisterPlatformBrightnessChange();
    viewport = null;
  }

  void initDocument(view, Pointer<NativeBindingObject> pointer) {
    document = Document(
      BindingContext(view, _contextId, pointer),
      controller: rootController,
      gestureListener: gestureListener,
      initialCookies: initialCookies,
    );

    // Listeners need to be registered to window in order to dispatch events on demand.
    if (gestureListener != null) {
      GestureListener listener = gestureListener!;
      if (listener.onTouchStart != null) {
        document.addEventListener(
            EVENT_TOUCH_START, (Event event) async => listener.onTouchStart!(event as TouchEvent));
      }

      if (listener.onTouchMove != null) {
        document.addEventListener(EVENT_TOUCH_MOVE, (Event event) async => listener.onTouchMove!(event as TouchEvent));
      }

      if (listener.onTouchEnd != null) {
        document.addEventListener(EVENT_TOUCH_END, (Event event) async => listener.onTouchEnd!(event as TouchEvent));
      }

      if (listener.onDrag != null) {
        document.addEventListener(EVENT_DRAG, (Event event) async => listener.onDrag!(event as GestureEvent));
      }
    }

    firstLoad = false;
  }

  void initWindow(WebFViewController view, Pointer<NativeBindingObject> pointer) {
    window = Window(BindingContext(view, _contextId, pointer), document);

    // 3 seconds should be enough for page loading, make sure the JavaScript GC was opened.
    Timer(Duration(seconds: 3), () {
      window.dispatchEvent(Event('gcopen'));
    });

    // Blur input element when new input focused.
    window.addEventListener(EVENT_CLICK, (event) async {
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

  // Attach renderObject to an renderObject.
  void attachTo(RenderObject parent, [RenderObject? previousSibling]) {
    if (parent is ContainerRenderObjectMixin) {
      parent.insert(document.domRenderer!, after: previousSibling);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = document.domRenderer;
    }
  }

  // Dispose controller and recycle all resources.
  Future<void> dispose() async {
    await waitingSyncTaskComplete(contextId);
    _disposed = true;
    debugDOMTreeChanged = null;

    _teardownObserver();
    _unregisterPlatformBrightnessChange();

    // Should clear previous page cached ui commands
    clearUICommand(_contextId);

    await disposePage(runningThread is FlutterUIThread, _contextId);

    clearCssLength();

    _nativeObjects.forEach((key, object) {
      object.dispose();
    });
    _nativeObjects.clear();

    document.dispose();
    window.dispose();

    _targetIdToDevNodeIdMap.clear();
  }

  VoidCallback? _originalOnPlatformBrightnessChanged;

  void _registerPlatformBrightnessChange() {
    _originalOnPlatformBrightnessChanged =
        rootController.ownerFlutterView.platformDispatcher.onPlatformBrightnessChanged;
    rootController.ownerFlutterView.platformDispatcher.onPlatformBrightnessChanged = onPlatformBrightnessChanged;
  }

  void _unregisterPlatformBrightnessChange() {
    if (_originalOnPlatformBrightnessChanged == null) return;
    rootController.ownerFlutterView.platformDispatcher.onPlatformBrightnessChanged =
        _originalOnPlatformBrightnessChanged;
    _originalOnPlatformBrightnessChanged = null;
  }

  void onPlatformBrightnessChanged() {
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
        uri, tagName.toUpperCase(), BindingContext(document.controller.view, _contextId, nativePtr));
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
    target?.parentNode?.removeChild(target);

    _debugDOMTreeChanged();
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
          targetParentNode.insertBefore(newNode, target.nextSibling!);
        }
        break;
    }

    _debugDOMTreeChanged();
  }

  void setAttribute(Pointer<NativeBindingObject> selfPtr, String key, String value) {
    assert(hasBindingObject(selfPtr), 'selfPtr: $selfPtr key: $key value: $value');
    Node? target = getBindingObject<Node>(selfPtr);
    if (target == null) return;

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

  void flushPendingStyleProperties(int address) {
    if (!hasBindingObject(Pointer.fromAddress(address))) return;
    Node? target = getBindingObject<Node>(Pointer.fromAddress(address));
    if (target == null) return;

    if (target is Element && target.isConnected) {
      target.style.flushPendingProperties();
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

      String targetPath = action.target;

      if (!Uri.parse(targetPath).isAbsolute) {
        String base = rootController.url;
        targetPath = rootController.uriParser!.resolve(Uri.parse(base), Uri.parse(targetPath)).toString();
      }

      if (action.target.trim().startsWith('#')) {
        String oldUrl = rootController.url;
        HistoryModule historyModule = rootController.module.moduleManager.getModule('History')!;
        historyModule.pushState(null, url: targetPath);
        window.dispatchEvent(HashChangeEvent(newUrl: targetPath, oldUrl: oldUrl));
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
      if (_delegate.errorHandler != null) {
        _delegate.errorHandler!(e, stack);
      } else {
        print('WebF navigation failed: $e\n$stack');
      }
    }
  }

  // Call from JS Bridge when the BindingObject class on the JS side had been Garbage collected.
  static void disposeBindingObject(WebFViewController view, Pointer<NativeBindingObject> pointer) async {
    BindingObject? bindingObject = view.getBindingObject(pointer);
    bindingObject?.dispose();
    view.removeBindingObject(pointer);
    view.disposeTargetIdToDevNodeIdMap(bindingObject);
    malloc.free(pointer);
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

  static double FOCUS_VIEWINSET_BOTTOM_OVERALL = 32;

  @override
  void didChangeMetrics() {
    if (!rootController.isFlutterAttached) return;
    final ownerView = rootController.ownerFlutterView;
    final bool resizeToAvoidBottomInsets = rootController.resizeToAvoidBottomInsets;
    final double bottomInsets;
    if (resizeToAvoidBottomInsets) {
      bottomInsets = ownerView.viewInsets.bottom / ownerView.devicePixelRatio;
    } else {
      bottomInsets = 0;
    }

    if (resizeToAvoidBottomInsets && viewport?.hasSize == true) {
      bool shouldScrollByToCenter = false;
      Element? focusedElement = document.focusedElement;
      double scrollOffset = 0;
      if (focusedElement != null) {
        RenderBox? renderer = focusedElement.attachedRenderer;
        if (renderer != null && renderer.attached && renderer.hasSize) {
          Offset focusOffset = renderer.localToGlobal(Offset.zero);
          // FOCUS_VIEWINSET_BOTTOM_OVERALL to meet border case.
          if (focusOffset.dy > viewport!.size.height - bottomInsets - FOCUS_VIEWINSET_BOTTOM_OVERALL) {
            shouldScrollByToCenter = true;
            scrollOffset = focusOffset.dy -
                (viewport!.size.height - bottomInsets) +
                renderer.size.height +
                FOCUS_VIEWINSET_BOTTOM_OVERALL;
          }
        }
      }
      // Show keyboard
      if (shouldScrollByToCenter) {
        window.scrollBy(0, scrollOffset, false);
      }
    }
    viewport?.bottomInset = bottomInsets;
  }

  @override
  void didChangePlatformBrightness() {
    document.recalculateStyleImmediately();
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
}
