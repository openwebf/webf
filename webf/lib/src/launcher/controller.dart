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
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show
        AnimationController,
        BuildContext,
        ModalRoute,
        RouteInformation,
        RouteObserver,
        View,
        WidgetsBinding,
        WidgetsBindingObserver;
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
typedef OnCustomElementAttached = void Function(WidgetElementAdapter newWidget);
typedef OnCustomElementDetached = void Function(WidgetElementAdapter detachedWidget);

typedef TraverseElementCallback = void Function(Element element);

enum WebFLoadingMode {
  /// The default loading mode.
  /// All associated page resources begin loading once the WebF widget is mounted into the Flutter tree.
  standard,

  /// This mode preloads remote resources into memory and begins execution when the WebF widget is mounted into the Flutter tree.
  /// If the entrypoint is an HTML file, the HTML will be parsed, and its elements will be organized into a DOM tree.
  /// CSS files loaded through `<style>` and `<link>` elements will be parsed and the calculated styles applied to the corresponding DOM elements.
  /// However, JavaScript code will not be executed in this mode.
  /// If the entrypoint is a JavaScript file, WebF only do loading until the WebF widget is mounted into the Flutter tree.
  /// Using this mode can save up to 50% of loading time, while maintaining a high level of compatibility with the standard mode.
  /// It's safe and recommended to use this mode for all types of pages.
  preloading,

  /// The `aggressive` mode is a step further than `preloading`, cutting down up to 90% of loading time for optimal performance.
  /// This mode simulates the instantaneous response of native Flutter pages but may require modifications in the existing web codes for compatibility.
  /// In this mode, all remote resources are loaded and executed similarly to the standard mode, but with an offline-like behavior.
  /// Given that JavaScript is executed in this mode, properties like `clientWidth` and `clientHeight` from the CSSOM-view spec always return 0. This is because
  /// no layout or paint processes occur during preRendering.
  /// If your application depends on CSSOM-view properties to work, ensure that the related code is placed within the `load` and `DOMContentLoaded` event callbacks of the window.
  /// These callbacks are triggered once the WebF widget is mounted into the Flutter tree.
  /// Apps optimized for this mode remain compatible with both `standard` and `preloading` modes.
  preRendering
}

enum PreloadingStatus {
  none,
  preloading,
  done,
}

enum PreRenderingStatus { none, preloading, evaluate, rendering, done }

class WebFController {
  /// The background color for viewport, default to transparent.
  final Color? background;

  /// the width of WebF Widget
  /// default: the value of max-width in constraints.
  final double? viewportWidth;

  /// the height of WebF Widget
  /// default: the value if max-height in constraints.
  final double? viewportHeight;

  /// The methods of the webFNavigateDelegation help you implement custom behaviors that are triggered
  /// during a webf view's process of loading, and completing a navigation request.
  final WebFNavigationDelegate? navigationDelegate;

  /// A method channel for receiving messaged from JavaScript code and sending message to JavaScript.
  final WebFMethodChannel? javaScriptChannel;

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

  /// Callback triggered when a network error occurs during loading.
  LoadErrorHandler? onLoadError;

  /// Callback triggered when the app is fully loaded, including DOM, CSS, JavaScript, and images.
  LoadHandler? onLoad;

  /// Callback triggered when the app's DOM and CSS have finished loading.
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Document/DOMContentLoaded_event
  LoadHandler? onDOMContentLoaded;

  /// Callback triggered when a JavaScript error occurs during loading.
  JSErrorHandler? onJSError;

  // Open a service to support Chrome DevTools for debugging.
  final DevToolsService? devToolsService;

  final GestureListener? gestureListener;

  final HttpClientInterceptor? httpClientInterceptor;

  UriParser? uriParser;

  /// Remote resources (HTML, CSS, JavaScript, Images, and other content loadable via WebFBundle) can be pre-loaded before WebF is mounted in Flutter.
  /// Use this property to reduce loading times when a WebF application attempts to load external resources on pages.
  final List<WebFBundle>? preloadedBundles;

  /// The initial cookies to set.
  final List<Cookie>? initialCookies;

  /// The path of the first route to show
  final String? initialRoute;

  /// A Navigator observer that notifies RouteAwares of changes to the state of their route.
  /// The RouteObserver is essential for notifying hybrid router change events, allowing WebF to subscribe to route changes.
  final RouteObserver<ModalRoute<void>>? routeObserver;

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

  static final Map<double, WebFController?> _controllerMap = {};
  static final Map<String, double> _nameIdMap = {};

  WebFLoadingMode mode = WebFLoadingMode.standard;

  bool get isPreLoadingOrPreRenderingComplete =>
      preloadStatus == PreloadingStatus.done || preRenderingStatus == PreRenderingStatus.done;

  static WebFController? getControllerOfJSContextId(double? contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  static Map<double, WebFController?> getControllerMap() {
    return _controllerMap;
  }

  static WebFController? getControllerOfName(String name) {
    if (!_nameIdMap.containsKey(name)) return null;
    double? contextId = _nameIdMap[name];
    return getControllerOfJSContextId(contextId);
  }

  TitleChangedHandler? onTitleChanged;

  WebFMethodChannel? _methodChannel;

  WebFMethodChannel? get methodChannel => _methodChannel;

  JSLogHandler? _onJSLog;

  JSLogHandler? get onJSLog => _onJSLog;

  set onJSLog(JSLogHandler? jsLogHandler) {
    _onJSLog = jsLogHandler;
  }

  ui.FlutterView? _ownerFlutterView;

  ui.FlutterView get ownerFlutterView => _ownerFlutterView!;

  List<BuildContext> buildContextStack = [];

  bool? _darkModeOverride;

  set darkModeOverride(value) {
    _darkModeOverride = value;
  }

  bool get isDarkMode {
    return _darkModeOverride ?? ownerFlutterView.platformDispatcher.platformBrightness != Brightness.light;
  }

  final GestureListener? _gestureListener;
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

  // The view entrypoint bundle.
  WebFBundle? _entrypoint;

  WebFBundle? get entrypoint => _entrypoint;
  ui.Size? _viewportSize;

  ui.Size? get viewportSize => _viewportSize;

  Completer controlledInitCompleter = Completer();
  Completer controllerPreloadingCompleter = Completer();
  Completer controllerPreRenderingCompleter = Completer();

  bool externalController;

  WebFController({
    bool enableDebug = false,
    WebFBundle? bundle,
    WebFThread? runningThread,
    this.background,
    this.viewportWidth,
    this.viewportHeight,
    this.gestureListener,
    this.javaScriptChannel,
    this.navigationDelegate,
    this.onLoad,
    this.onDOMContentLoaded,
    this.onLoadError,
    this.onJSError,
    this.httpClientInterceptor,
    this.devToolsService,
    this.uriParser,
    this.preloadedBundles,
    this.initialCookies,
    this.initialRoute,
    this.routeObserver,
    this.externalController = true,
    this.resizeToAvoidBottomInsets = true,
  })  : _entrypoint = bundle,
        _gestureListener = gestureListener,
        runningThread = runningThread ?? DedicatedThread(),
        _methodChannel = javaScriptChannel {
    _initializePreloadBundle();
    if (enableWebFProfileTracking) {
      WebFProfiler.initialize();
    }

    _methodChannel = methodChannel;
    WebFMethodChannel.setJSMethodCallCallback(this);

    _view = WebFViewController(
        background: background,
        enableDebug: enableDebug,
        rootController: this,
        runningThread: this.runningThread!,
        navigationDelegate: navigationDelegate ?? WebFNavigationDelegate(),
        gestureListener: _gestureListener,
        initialCookies: initialCookies);

    _view.initialize().then((_) {
      final double contextId = _view.contextId;

      _module = WebFModuleController(this, contextId);

      if (bundle != null) {
        HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
        historyModule.add(bundle);
      }

      assert(!_controllerMap.containsKey(contextId), 'found exist contextId of WebFController, contextId: $contextId');
      _controllerMap[contextId] = this;

      setupHttpOverrides(httpClientInterceptor, contextId: contextId);

      uriParser ??= UriParser();

      if (devToolsService != null) {
        devToolsService!.init(this);
      }

      flushUICommand(view, nullptr);

      controlledInitCompleter.complete();
    }).then((_) {
      if (externalController && _entrypoint != null) {
        preload(_entrypoint!);
      }
    });
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

  HybridHistoryModule get hybridHistory => _module.moduleManager.getModule('HybridHistory')!;

  static Uri fallbackBundleUri([double? id]) {
    // The fallback origin uri, like `vm://bundle/0`
    return Uri(scheme: 'vm', host: 'bundle', path: id != null ? '$id' : null);
  }

  void setNavigationDelegate(WebFNavigationDelegate delegate) {
    _view.navigationDelegate = delegate;
  }

  bool isFontsLoading = false;

  void _watchFontLoading() {
    isFontsLoading = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      isFontsLoading = false;
    });
  }

  Future<void> unload() async {
    assert(!_view.disposed, 'WebF have already disposed');
    // Should clear previous page cached ui commands
    clearUICommand(_view.contextId);

    await controlledInitCompleter.future;
    controlledInitCompleter = Completer();

    Future.microtask(() async {
      _module.dispose();
      await _view.dispose();

      double oldId = _view.contextId;

      _view = WebFViewController(
          background: _view.background,
          enableDebug: _view.enableDebug,
          rootController: this,
          navigationDelegate: _view.navigationDelegate,
          gestureListener: _view.gestureListener,
          runningThread: runningThread!);

      await _view.initialize();

      _module = WebFModuleController(this, _view.contextId);

      flushUICommand(view, nullptr);

      // Reconnect the new contextId to the Controller
      _controllerMap.remove(oldId);
      _controllerMap[_view.contextId] = this;

      controlledInitCompleter.complete();
    });

    return controlledInitCompleter.future;
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

  void _replaceCurrentHistory(WebFBundle bundle) {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    previousHistoryStack.clear();
    historyModule.add(bundle);
  }

  Future<void> reload() async {
    print('before reload');
    assert(!_view.disposed, 'WebF have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    _isComplete = false;
    _evaluated = false;

    RenderViewportBox? rootRenderObject = view.viewport;
    if (rootRenderObject == null) return;

    await unload();

    view.viewport = rootRenderObject;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Sync viewport size to the documentElement.
      view.document.initializeRootElementSize();
      // Starting to flush ui commands every frames.
      view.flushPendingCommandsPerFrame();

      await executeEntrypoint();

      flushUICommand(view, nullptr);

      evaluated = true;

      if (devToolsService != null) {
        devToolsService!.didReload();
      }
    });

    return controlledInitCompleter.future;
  }

  Future<void> load(WebFBundle bundle) async {
    assert(!_view.disposed, 'WebF have already disposed');

    if (devToolsService != null) {
      devToolsService!.willReload();
    }

    await controlledInitCompleter.future;

    RenderViewportBox rootRenderObject = view.viewport!;

    await unload();

    view.viewport = rootRenderObject;

    // Initialize document, window and the documentElement.
    flushUICommand(view, nullptr);

    // Update entrypoint.
    _entrypoint = bundle;
    _addHistory(bundle);

    Completer completer = Completer();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Sync viewport size to the documentElement.
      view.document.initializeRootElementSize();
      // Starting to flush ui commands every frames.
      view.flushPendingCommandsPerFrame();

      await executeEntrypoint();

      if (devToolsService != null) {
        devToolsService!.didReload();
      }

      completer.complete();
    });

    return completer.future;
  }

  PreloadingStatus _preloadStatus = PreloadingStatus.none;

  PreloadingStatus get preloadStatus => _preloadStatus;
  VoidCallback? _onPreloadingFinished;
  int unfinishedPreloadResources = 0;

  /// Preloads remote resources into memory and begins execution when the WebF widget is mounted into the Flutter tree.
  /// If the entrypoint is an HTML file, the HTML will be parsed, and its elements will be organized into a DOM tree.
  /// CSS files loaded through `<style>` and `<link>` elements will be parsed and the calculated styles applied to the corresponding DOM elements.
  /// However, JavaScript code will not be executed in this mode.
  /// If the entrypoint is a JavaScript file, WebF only do loading until the WebF widget is mounted into the Flutter tree.
  /// Using this mode can save up to 50% of loading time, while maintaining a high level of compatibility with the standard mode.
  /// It's safe and recommended to use this mode for all types of pages.
  Future<void> preload(WebFBundle bundle, {ui.Size? viewportSize}) async {
    if (_preloadStatus == PreloadingStatus.done) return;
    controllerPreloadingCompleter = Completer();

    await controlledInitCompleter.future;

    if (_preloadStatus != PreloadingStatus.none) return;
    if (_preRenderingStatus != PreRenderingStatus.none) return;

    _viewportSize = viewportSize;
    // Update entrypoint.
    _entrypoint = bundle;
    _replaceCurrentHistory(bundle);

    mode = WebFLoadingMode.preloading;

    // Initialize document, window and the documentElement.
    flushUICommand(view, nullptr);

    // Set the status value for preloading.
    _preloadStatus = PreloadingStatus.preloading;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }

    view.document.preloadViewportSize = _viewportSize;
    // Manually initialize the root element and create renderObjects for each elements.
    view.document.documentElement!.applyStyle(view.document.documentElement!.style);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }

    await Future.wait([_resolveEntrypoint(), module.initialize()]);

    if (_entrypoint!.isJavascript || _entrypoint!.isBytecode) {
      // Convert the JavaScript code into bytecode.
      if (_entrypoint!.isJavascript) {
        await _entrypoint!.preProcessing(view.contextId);
      }
      _preloadStatus = PreloadingStatus.done;
      controllerPreloadingCompleter.complete();
    } else if (_entrypoint!.isHTML) {
      EvaluateOpItem? evaluateOpItem;
      if (enableWebFProfileTracking) {
        evaluateOpItem = WebFProfiler.instance.startTrackEvaluate('parseHTML');
      }

      // Evaluate the HTML entry point, and loading the stylesheets and scripts.
      await parseHTML(view.contextId, _entrypoint!.data!, profileOp: evaluateOpItem);

      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackEvaluate(evaluateOpItem!);
      }

      // Initialize document, window and the documentElement.
      flushUICommand(view, view.window.pointer!);

      if (view.document.scriptRunner.hasPreloadScripts()) {
        _onPreloadingFinished = () {
          _preloadStatus = PreloadingStatus.done;
          controllerPreloadingCompleter.complete();
        };
      } else {
        _preloadStatus = PreloadingStatus.done;
        controllerPreloadingCompleter.complete();
      }
    }

    return controllerPreloadingCompleter.future;
  }

  PreRenderingStatus _preRenderingStatus = PreRenderingStatus.none;

  PreRenderingStatus get preRenderingStatus => _preRenderingStatus;

  /// The `aggressive` mode is a step further than `preloading`, cutting down up to 90% of loading time for optimal performance.
  /// This mode simulates the instantaneous response of native Flutter pages but may require modifications in the existing web codes for compatibility.
  /// In this mode, all remote resources are loaded and executed similarly to the standard mode, but with an offline-like behavior.
  /// Given that JavaScript is executed in this mode, properties like `clientWidth` and `clientHeight` from the viewModule always return 0. This is because
  /// no layout or paint processes occur during preRendering.
  /// If your application depends on viewModule properties, ensure that the related code is placed within the `load` and `DOMContentLoaded` or `prerendered` event callbacks of the window.
  /// These callbacks are triggered once the WebF widget is mounted into the Flutter tree.
  /// Apps optimized for this mode remain compatible with both `standard` and `preloading` modes.
  Future<void> preRendering(WebFBundle bundle) async {
    if (_preRenderingStatus == PreRenderingStatus.done) return;

    controllerPreRenderingCompleter = Completer();

    await controlledInitCompleter.future;

    if (_preRenderingStatus != PreRenderingStatus.none) return;
    if (_preloadStatus != PreloadingStatus.none) return;

    // Update entrypoint.
    _entrypoint = bundle;
    _replaceCurrentHistory(bundle);

    mode = WebFLoadingMode.preRendering;

    // Initialize document, window and the documentElement.
    flushUICommand(view, nullptr);

    // Set the status value for preloading.
    _preRenderingStatus = PreRenderingStatus.preloading;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }

    // Manually initialize the root element and create renderObjects for each elements.
    view.document.documentElement!.applyStyle(view.document.documentElement!.style);

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }

    // Preparing the entrypoint
    await Future.wait([_resolveEntrypoint(), module.initialize()]);

    // Stop the animation frame
    module.pauseAnimationFrame();

    // Pause the animation timeline.
    view.stopAnimationsTimeLine();

    view.window.addEventListener(EVENT_LOAD, (event) async {
      _preRenderingStatus = PreRenderingStatus.done;
    });

    if (_entrypoint!.isJavascript || _entrypoint!.isBytecode) {
      // Convert the JavaScript code into bytecode.
      if (_entrypoint!.isJavascript) {
        await _entrypoint!.preProcessing(view.contextId);
      }
    }

    _preRenderingStatus = PreRenderingStatus.evaluate;

    // Evaluate the entry point, and loading the stylesheets and scripts.
    await evaluateEntrypoint();

    view.flushPendingCommandsPerFrame();

    // If there are no <script /> elements, finish this prerendering process.
    if (!view.document.scriptRunner.hasPendingScripts()) {
      controllerPreRenderingCompleter.complete();
      return;
    }

    return controllerPreRenderingCompleter.future;
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

  void reactiveWidgetElements() {}

  // Pause all timers and callbacks if page are invisible.
  void pause() {
    if (_paused) return;
    _paused = true;
    module.pauseTimer();
    module.pauseAnimationFrame();
    view.stopAnimationsTimeLine();
  }

  // Resume all timers and callbacks if page now visible.
  void resume() {
    if (!_paused) return;

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommand();
    }

    _paused = false;
    flushPendingCallbacks();
    module.resumeTimer();
    module.resumeAnimationFrame();
    view.resumeAnimationTimeline();
    SchedulerBinding.instance.scheduleFrame();

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommand();
    }
  }

  bool _disposed = false;

  bool get disposed => _disposed;

  Future<void> dispose() async {
    _module.dispose();
    PaintingBinding.instance.systemFonts.removeListener(_watchFontLoading);
    await _view.dispose();
    _controllerMap[_view.contextId] = null;
    _controllerMap.remove(_view.contextId);
    // To release entrypoint bundle memory.
    _entrypoint?.dispose();

    devToolsService?.dispose();
    _disposed = true;
  }

  String get origin {
    Uri uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}:${uri.port}?query=${uri.query}';
  }

  Future<void> executeEntrypoint(
      {bool shouldResolve = true, bool shouldEvaluate = true, AnimationController? animationController}) async {
    if (_entrypoint != null && shouldResolve) {
      await controlledInitCompleter.future;
      await Future.wait([_resolveEntrypoint(), _module.initialize()]);
      if (_entrypoint!.isResolved && shouldEvaluate) {
        await evaluateEntrypoint(animationController: animationController);
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
    assert(!_view.disposed, 'WebF have already disposed');

    WebFBundle? bundleToLoad = _entrypoint;
    if (bundleToLoad == null) {
      // Do nothing if bundle is null.
      return;
    }

    // Resolve the bundle, including network download or other fetching ways.
    try {
      await bundleToLoad.resolve(baseUrl: url, uriParser: uriParser);
      await bundleToLoad.obtainData(view.contextId);
    } catch (e, stack) {
      if (onLoadError != null) {
        onLoadError!(FlutterError(e.toString()), stack);
      }
      // Not to dismiss this error.
      rethrow;
    }
  }

  bool _isFlutterAttached = false;

  bool get isFlutterAttached => _isFlutterAttached;

  void attachToFlutter(BuildContext context) {
    _ownerFlutterView = View.of(context);
    view.attachToFlutter(context);
    PaintingBinding.instance.systemFonts.addListener(_watchFontLoading);
    _isFlutterAttached = true;
  }

  void detachFromFlutter() {
    view.detachFromFlutter();
    PaintingBinding.instance.systemFonts.removeListener(_watchFontLoading);
    _isFlutterAttached = false;
    _ownerFlutterView = null;
  }

  // Execute the content from entrypoint bundle.
  Future<void> evaluateEntrypoint({AnimationController? animationController}) async {
    // @HACK: Execute JavaScript scripts will block the Flutter UI Threads.
    // Listen for animationController listener to make sure to execute Javascript after route transition had completed.
    if (animationController != null) {
      animationController.addStatusListener((AnimationStatus status) async {
        if (status == AnimationStatus.completed) {
          await evaluateEntrypoint();
        }
      });
      return;
    }

    assert(!_view.disposed, 'WebF have already disposed');
    if (_entrypoint != null) {
      EvaluateOpItem? evaluateOpItem;
      if (enableWebFProfileTracking) {
        evaluateOpItem = WebFProfiler.instance.startTrackEvaluate('WebFController.evaluateEntrypoint');
      }

      WebFBundle entrypoint = _entrypoint!;
      double contextId = _view.contextId;
      assert(entrypoint.isResolved, 'The webf bundle $entrypoint is not resolved to evaluate.');

      // entry point start parse.
      _view.document.parsing = true;

      Uint8List data = entrypoint.data!;
      if (entrypoint.isJavascript) {
        assert(isValidUTF8String(data), 'The JavaScript codes should be in UTF-8 encoding format');
        // Prefer sync decode in loading entrypoint.
        await evaluateScripts(contextId, data,
            url: url,
            cacheKey: entrypoint.cacheKey,
            loadedFromCache: entrypoint.loadedFromCache,
            profileOp: evaluateOpItem);
      } else if (entrypoint.isBytecode) {
        await evaluateQuickjsByteCode(contextId, data, profileOp: evaluateOpItem);
      } else if (entrypoint.isHTML) {
        assert(isValidUTF8String(data), 'The HTML codes should be in UTF-8 encoding format');
        await parseHTML(contextId, data, profileOp: evaluateOpItem);
      } else if (entrypoint.contentType.primaryType == 'text') {
        // Fallback treating text content as JavaScript.
        try {
          assert(isValidUTF8String(data), 'The JavaScript codes should be in UTF-8 encoding format');
          await evaluateScripts(contextId, data,
              loadedFromCache: entrypoint.loadedFromCache,
              cacheKey: entrypoint.cacheKey,
              url: url,
              profileOp: evaluateOpItem);
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

      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackEvaluate(evaluateOpItem!);
      }
    }
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.h#L470
  bool _isComplete = false;

  bool get isComplete => _isComplete;

  bool _evaluated = false;

  bool get evaluated => _evaluated;

  set evaluated(value) {
    _evaluated = value;
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.cpp#L840
  // Check whether the document has been loaded, such as html has parsed (main of JS has evaled) and images/scripts has loaded.
  void checkCompleted() {
    if (_isComplete) return;

    // Are we still parsing?
    if (_view.document.parsing) return;

    // Are all script element complete?
    if (_view.document.isDelayingDOMContentLoadedEvent) return;

    if (mode == WebFLoadingMode.standard || mode == WebFLoadingMode.preloading) {
      _view.document.readyState = DocumentReadyState.interactive;
      dispatchDOMContentLoadedEvent();
    }

    // Still waiting for images/scripts?
    if (_view.document.hasPendingRequest) return;

    // Still waiting for elements that don't go through a FrameLoader?
    if (_view.document.isDelayingLoadEvent) return;

    // Any frame that hasn't completed yet?
    // TODO:

    _isComplete = true;

    if (mode == WebFLoadingMode.standard || mode == WebFLoadingMode.preloading) {
      dispatchWindowLoadEvent();
      _view.document.readyState = DocumentReadyState.complete;
    } else if (mode == WebFLoadingMode.preRendering) {
      if (!controllerPreRenderingCompleter.isCompleted) {
        controllerPreRenderingCompleter.complete();
      }
    }
  }

  // Check whether the load was complete in preload mode.
  void checkPreloadCompleted() {
    if (unfinishedPreloadResources == 0 && _onPreloadingFinished != null) {
      _onPreloadingFinished!();
    }
  }

  bool _domContentLoadedEventDispatched = false;

  void dispatchDOMContentLoadedEvent() {
    if (_domContentLoadedEventDispatched) return;

    _domContentLoadedEventDispatched = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Event event = Event(EVENT_DOM_CONTENT_LOADED);
      EventTarget window = view.window;
      window.dispatchEvent(event);
      _view.document.dispatchEvent(event);
      if (onDOMContentLoaded != null) {
        onDOMContentLoaded!(this);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  bool _loadEventDispatched = false;

  void dispatchWindowLoadEvent() {
    if (_loadEventDispatched) return;
    _loadEventDispatched = true;
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

  bool _preloadEventDispatched = false;

  void dispatchWindowPreloadedEvent() {
    if (_preloadEventDispatched) return;
    _preloadEventDispatched = true;
    Event event = Event(EVENT_PRELOADED);
    _view.window.dispatchEvent(event);
  }

  bool _preRenderedEventDispatched = false;

  void dispatchWindowPreRenderedEvent() {
    if (_preRenderedEventDispatched) return;
    _preRenderedEventDispatched = true;
    Event event = Event(EVENT_PRERENDERED);
    _view.window.dispatchEvent(event);
  }

  Future<void> dispatchWindowResizeEvent() async {
    Event event = Event(EVENT_RESIZE);
    await _view.window.dispatchEvent(event);
  }
}

abstract class DevToolsService {
  /// Design prevDevTool for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static DevToolsService? prevDevTools;

  static final Map<double, DevToolsService> _contextDevToolMap = {};

  static DevToolsService? getDevToolOfContextId(double contextId) {
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
