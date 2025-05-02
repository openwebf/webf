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
        StatefulElement,
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
/// A callback that is invoked when a WebFController is fully initialized but before the content is executed.
///
/// Use this to perform early configuration or setup of the WebF environment before any content is loaded.
/// This provides a chance to interact with the controller when its native components are ready but before
/// the JavaScript execution begins.
///
/// The callback must return a Future to allow for asynchronous setup operations.
typedef OnControllerInit = Future<void> Function(WebFController controller);
typedef LoadHandler = void Function(WebFController controller);
typedef TitleChangedHandler = void Function(String title);
typedef JSErrorHandler = void Function(String message);
typedef JSLogHandler = void Function(int level, String message);
typedef PendingCallback = void Function();

typedef TraverseElementCallback = void Function(Element element);

class HybridRoutePageContext {
  /// The route path for the hybrid router in WebF.
  String path;

  /// The attached flutter buildContexts for this hybrid route page.
  BuildContext context;

  HybridRoutePageContext(this.path, this.context);
}

enum WebFLoadingMode {
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
  fail,
}

enum PreRenderingStatus { none, preloading, evaluate, rendering, done, fail }

class WebFController with Diagnosticable {
  /// The background color for viewport, default to transparent.
  /// This determines the background color of the WebF widget content area.
  final Color? background;

  /// The width of WebF Widget.
  /// Default: the value of max-width in constraints.
  /// This allows you to explicitly set the width of the WebF rendering area regardless of parent constraints.
  final double? viewportWidth;

  /// The height of WebF Widget.
  /// Default: the value of max-height in constraints.
  /// This allows you to explicitly set the height of the WebF rendering area regardless of parent constraints.
  final double? viewportHeight;

  /// The methods of the webFNavigateDelegation help you implement custom behaviors that are triggered
  /// during a webf view's process of loading, and completing a navigation request.
  ///
  /// Use this to intercept and handle navigation events such as page redirects or link clicks.
  final WebFNavigationDelegate? navigationDelegate;

  /// A method channel for receiving messages from JavaScript code and sending messages to JavaScript.
  ///
  /// This enables bidirectional communication between Dart and JavaScript, allowing you to expose
  /// native functionality to web content or get data from the JavaScript environment.
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
  ///
  /// Use this to handle and possibly recover from network failures when loading resources.
  LoadErrorHandler? onLoadError;

  /// Callback triggered when the app is fully loaded, including DOM, CSS, JavaScript, and images.
  ///
  /// This is equivalent to the window.onload event in web browsers and indicates all resources
  /// have been loaded and rendered.
  LoadHandler? onLoad;

  /// Callback triggered when the app's DOM and CSS have finished loading.
  ///
  /// This is equivalent to the DOMContentLoaded event in web browsers and fires when the initial
  /// HTML document has been completely loaded and parsed, without waiting for stylesheets,
  /// images, and subframes to finish loading.
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Document/DOMContentLoaded_event
  LoadHandler? onDOMContentLoaded;

  /// Callback triggered after the controller is fully initialized but before content loading.
  ///
  /// This callback provides an opportunity to perform setup tasks after the WebF controller
  /// has been initialized with all its core components, but before any content has been evaluated.
  /// Use this for early controller configuration, such as setting up custom JavaScript APIs or
  /// initializing features that need to be available when the page loads.
  ///
  /// Since this is executed during the controller's initialization phase, any asynchronous operations
  /// performed here will block the controller initialization completion (controlledInitCompleter),
  /// ensuring your setup is complete before any content begins loading.
  ///
  /// ```dart
  /// WebFController(
  ///   onControllerInit: (controller) async {
  ///     // Perform early setup before any content loads
  ///     await controller.methodChannel.invokeMethod('registerCustomAPI', {...});
  ///   }
  /// )
  /// ```
  OnControllerInit? onControllerInit;

  /// Callback triggered when a JavaScript error occurs during loading.
  ///
  /// Use this to catch and handle JavaScript execution errors in the web content.
  JSErrorHandler? onJSError;

  /// Open a service to support Chrome DevTools for debugging.
  ///
  /// When enabled, allows you to connect Chrome DevTools to inspect rendered DOM elements,
  /// debug JavaScript, monitor network requests, and analyze performance of the WebF content.
  final DevToolsService? devToolsService;

  /// Interceptor for HTTP client operations initiated by JavaScript code.
  ///
  /// This allows you to intercept, modify, redirect or mock network requests made from JavaScript,
  /// giving you control over the network layer of the WebF environment.
  final HttpClientInterceptor? httpClientInterceptor;

  /// Parser for handling and potentially transforming URIs within WebF.
  ///
  /// This can be used to customize how URLs are resolved, redirected, or rewritten
  /// before they are processed by the WebF engine.
  UriParser? uriParser;

  /// Remote resources (HTML, CSS, JavaScript, Images, and other content loadable via WebFBundle)
  /// that can be pre-loaded before WebF is mounted in Flutter.
  ///
  /// Use this property to reduce loading times when a WebF application attempts to load external
  /// resources. Pre-loading can significantly improve startup performance, especially for frequently
  /// accessed resources.
  final List<WebFBundle>? preloadedBundles;

  /// The initial cookies to set for the JavaScript environment.
  ///
  /// These cookies will be available to JavaScript and network requests from the start.
  final List<Cookie>? initialCookies;

  /// Cookie manager that provides methods to manipulate cookies.
  ///
  /// Allows developers to create, read, update, and delete cookies with full control.
  late CookieManager cookieManager;

  /// The default route path for the hybrid router in WebF.
  ///
  /// Sets the initial path that the router will navigate to when the application starts.
  /// This is the entry point for the hybrid routing system in WebF.
  String? initialRoute;

  /// The default route state for the hybrid router in WebF.
  ///
  /// Users can read this value by webf.hybridRouter.state when loading by initialRoute path.
  Map<String, dynamic>? initialState;

  /// A Navigator observer that notifies RouteAwares of changes to the state of their route.
  ///
  /// The RouteObserver is essential for the hybrid routing system, enabling WebF to
  /// subscribe to Flutter route changes and maintain synchronization between Flutter
  /// navigation and WebF's routing system.
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

  /// The routing table for the WebF hybrid router.
  ///
  /// Maps route paths to Flutter widgets, enabling the hybrid navigation system where
  /// routes can be handled by either WebF content or native Flutter components.
  /// This allows seamless integration between WebF-rendered content and Flutter widgets.
  Map<String, SubViewBuilder>? routes;

  static final Map<double, WebFController?> _controllerMap = {};

  /// The loading mode for WebF content.
  ///
  /// Controls how resources are loaded and when execution occurs.
  /// Default is standard mode where everything is loaded and executed when mounted.
  WebFLoadingMode mode = WebFLoadingMode.preloading;

  static WebFController? getControllerOfJSContextId(double? contextId) {
    if (!_controllerMap.containsKey(contextId)) {
      return null;
    }

    return _controllerMap[contextId];
  }

  static Map<double, WebFController?> getControllerMap() {
    return _controllerMap;
  }

  /// Prints the render object tree for debugging purposes.
  ///
  /// @param routePath Optional path to a specific route whose render tree should be printed.
  ///                 If null or matches initialRoute, prints the root render object tree.
  ///                 Otherwise prints the render tree of the specified hybrid route view.
  void printRenderObjectTree(String? routePath) {
    if (routePath == null || routePath == initialRoute) {
      debugPrint(view.getRootRenderObject()?.toStringDeep());
    } else {
      RouterLinkElement? routeLinkElement = view.getHybridRouterView(routePath);
      String? renderObjectTree = routeLinkElement?.getRenderObjectTree();
      debugPrint(renderObjectTree);
    }
  }

  /// Prints the render object tree for debugging purposes.
  ///
  /// @param routePath Optional path to a specific route whose render tree should be printed.
  ///                 If null or matches initialRoute, prints the root DOM tree.
  ///                 Otherwise prints the render tree of the specified hybrid route view.
  void printDOMTree(String? routePath) {
    if (routePath == null || routePath == initialRoute) {
      debugPrint(view.document.toStringDeep());
    } else {
      RouterLinkElement? routeLinkElement = view.getHybridRouterView(routePath);
      String? domTree = routeLinkElement?.toStringDeep();
      debugPrint(domTree);
    }
  }

  /// Callback triggered when the title of the document changes.
  ///
  /// This is invoked when the document title is updated through JavaScript,
  /// allowing the app to reflect title changes in the UI.
  TitleChangedHandler? onTitleChanged;

  WebFMethodChannel? _methodChannel;

  WebFMethodChannel? get methodChannel => _methodChannel;

  JSLogHandler? _onJSLog;

  JSLogHandler? get onJSLog => _onJSLog;

  set onJSLog(JSLogHandler? jsLogHandler) {
    _onJSLog = jsLogHandler;
  }

  ui.FlutterView? _ownerFlutterView;

  ui.FlutterView? get ownerFlutterView => _ownerFlutterView;

  final List<HybridRoutePageContext> _buildContextStack = [];

  /// Get current attached buildContexts.
  /// Especially useful to detect how many hybrid route pages attached to the Flutter tree.
  List<HybridRoutePageContext> get buildContextStack => _buildContextStack;

  void pushNewBuildContext({required BuildContext context, required String routePath}) {
    _buildContextStack.add(HybridRoutePageContext(routePath, context));
  }

  void popBuildContext({BuildContext? context, String? routePath}) {
    if (_buildContextStack.isNotEmpty) {
      if (context != null) {
        assert(routePath != null);
        _buildContextStack.removeWhere((context) => context.path == routePath);
      } else {
        _buildContextStack.removeLast();
      }
    }
  }

  final Set<WebFState> _rootState = {};

  WebFState? get state {
    final stateFinder = _rootState.where((state) => state.mounted == true);
    return stateFinder.isEmpty ? null : stateFinder.last;
  }

  void attachWebFState(WebFState state) {
    _rootState.add(state);
  }

  void removeWebFState(WebFState state) {
    _rootState.remove(state);
  }

  UniqueKey key = UniqueKey();

  HybridRoutePageContext? get currentBuildContext => _buildContextStack.isNotEmpty ? _buildContextStack.last : null;

  HybridRoutePageContext? get rootBuildContext => _buildContextStack.isNotEmpty ? _buildContextStack.first : null;

  bool? _darkModeOverride;

  set darkModeOverride(value) {
    _darkModeOverride = value;
  }

  /// Whether the current UI mode is dark mode.
  ///
  /// Returns true if dark mode is explicitly overridden to true via darkModeOverride
  /// or if the platform brightness is not light.
  bool get isDarkMode {
    return _darkModeOverride ?? ownerFlutterView?.platformDispatcher.platformBrightness != Brightness.light;
  }

  Map<String, WebFBundle>? _preloadBundleIndex;

  /// Retrieves a preloaded bundle that matches the given URL.
  ///
  /// Returns the WebFBundle if it exists in the preloaded bundles list, or null if not found.
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
  Completer controllerOnLoadCompleter = Completer();
  Completer controllerOnDOMContentLoadedCompleter = Completer();
  Completer viewportLayoutCompleter = Completer();

  WebFController({
    bool enableDebug = false,
    WebFBundle? bundle,
    WebFThread? runningThread,
    this.background,
    this.viewportWidth,
    this.viewportHeight,
    this.javaScriptChannel,
    this.navigationDelegate,
    this.onLoad,
    this.onDOMContentLoaded,
    this.onLoadError,
    this.onControllerInit,
    this.onJSError,
    this.httpClientInterceptor,
    this.devToolsService,
    this.uriParser,
    this.preloadedBundles,
    this.initialCookies,
    this.initialRoute,
    this.initialState,
    this.routeObserver,
    this.routes,
    this.resizeToAvoidBottomInsets = true,
  })  : _entrypoint = bundle,
        runningThread = runningThread ?? DedicatedThread(),
        _methodChannel = javaScriptChannel {
    _initializePreloadBundle();
    cookieManager = CookieManager();
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
        initialCookies: initialCookies);

    _view!.initialize().then((_) async {
      final double contextId = view.contextId;

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

      if (onControllerInit != null) {
        await onControllerInit!(this);
      }

      controlledInitCompleter.complete();
    });
  }

  WebFViewController? _view;

  /// The view controller that manages the visual rendering and DOM operations.
  ///
  /// Provides access to the document, window, viewport, and other rendering components.
  WebFViewController get view {
    return _view!;
  }

  WebFModuleController? _module;

  /// The module controller that manages JavaScript modules and features.
  ///
  /// Provides access to browser-like APIs such as history, timers, storage, and other modules.
  WebFModuleController get module {
    return _module!;
  }

  /// Queue of previous history items for the standard Web History API implementation.
  ///
  /// Used for tracking and enabling backward navigation with window.history.back().
  final Queue<HistoryItem> previousHistoryStack = Queue();

  /// Queue of next history items for the standard Web History API implementation.
  ///
  /// Used for tracking and enabling forward navigation with window.history.forward().
  final Queue<HistoryItem> nextHistoryStack = Queue();

  /// Storage for session data that implements the standard Web Storage API's sessionStorage.
  ///
  /// This maintains key-value pairs accessible through JavaScript's window.sessionStorage,
  /// which persists for the duration of the page session but is cleared when the page is closed.
  final Map<String, String> sessionStorage = {};

  /// Access to the standard Web History API implementation.
  ///
  /// Provides methods like back(), forward(), pushState(), etc., following the web standard.
  HistoryModule get history => module.moduleManager.getModule('History')!;

  /// Access to WebF's hybrid history implementation that integrates with Flutter navigation.
  ///
  /// Enables synchronized navigation between WebF content and native Flutter routes.
  HybridHistoryModule get hybridHistory => module.moduleManager.getModule('HybridHistory')!;

  /// Creates a fallback URI for WebF bundle content.
  ///
  /// Generates a URI in the format `vm://bundle/[id]` that serves as a virtual origin
  /// for WebF content that doesn't have a real URL. This is important for maintaining
  /// same-origin security policies in the JavaScript environment.
  ///
  /// @param id Optional JavaScript context ID to make the URI unique per context
  /// @return A URI object representing the virtual bundle location
  static Uri fallbackBundleUri([double? id]) {
    // The fallback origin uri, like `vm://bundle/0`
    return Uri(scheme: 'vm', host: 'bundle', path: id != null ? '$id' : null);
  }

  /// Sets a navigation delegate to handle navigation events.
  ///
  /// The navigation delegate allows intercepting and controlling navigation actions
  /// such as page loads and redirects within the WebF content.
  ///
  /// Example:
  /// ```dart
  /// controller.setNavigationDelegate(WebFNavigationDelegate(
  ///   decidePolicyForNavigation: (request) {
  ///     // Block navigation to external websites
  ///     if (request.url.startsWith('https://external.com')) {
  ///       return WebFNavigationDecision.prevent;
  ///     }
  ///     return WebFNavigationDecision.allow;
  ///   }
  /// ));
  /// ```
  void setNavigationDelegate(WebFNavigationDelegate delegate) {
    view.navigationDelegate = delegate;
  }

  /// Flag indicating whether fonts are currently being loaded.
  ///
  /// When true, indicates that system fonts are in the process of loading,
  /// which may affect text rendering in the WebF content.
  bool isFontsLoading = false;

  /// Watches for font loading events and updates the isFontsLoading flag.
  ///
  /// This method is registered as a listener with the system fonts service to track
  /// when fonts are being loaded, which can affect text layout and rendering.
  void _watchFontLoading() {
    isFontsLoading = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      isFontsLoading = false;
    });
  }

  String? get _url {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    return historyModule.stackTop?.url;
  }

  Uri? get _uri {
    HistoryModule historyModule = module.moduleManager.getModule<HistoryModule>('History')!;
    return historyModule.stackTop?.resolvedUri;
  }

  /// The current URL of the WebF content.
  ///
  /// Returns the URL string from the current history item or an empty string if not available.
  String get url => _url ?? '';

  /// The current URI of the WebF content as a Uri object.
  ///
  /// Returns the resolved Uri from the current history item or null if not available.
  /// Useful for accessing and manipulating individual components of the current URL.
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

  /// Reloads the current WebF content.
  ///
  /// This performs a full reload of the current content, including disposing the old
  /// environment and re-executing the entrypoint JavaScript/HTML.
  Future<WebFController?> reload() async {
    assert(!_view!.disposed, 'WebF have already disposed');

    String? currentPageId = WebFControllerManager.instance.getControllerName(this);

    if (currentPageId == null) return null;

    return WebFControllerManager.instance
        .addOrUpdateControllerWithLoading(name: currentPageId, bundle: entrypoint!, forceReplace: true, mode: mode);
  }

  /// Loads content from the provided WebFBundle.
  ///
  /// Unloads any existing content, adds the bundle to history, and executes the new content.
  /// This is the main method for loading new content into WebF.
  Future<WebFController?> load(WebFBundle bundle) async {
    assert(!_view!.disposed, 'WebF have already disposed');

    String? currentPageId = WebFControllerManager.instance.getControllerName(this);

    if (currentPageId == null) return null;

    return WebFControllerManager.instance
        .addOrUpdateControllerWithLoading(name: currentPageId, bundle: bundle, forceReplace: true, mode: mode);
  }

  PreloadingStatus _preloadStatus = PreloadingStatus.none;

  PreloadingStatus get preloadStatus => _preloadStatus;

  /// Sets the preloading status
  ///
  /// This is used internally and by WebFControllerManager to control the preloading state
  set preloadStatus(PreloadingStatus status) {
    _preloadStatus = status;
  }

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
    view.document.initializeCookieJarForUrl(url);

    mode = WebFLoadingMode.preloading;

    // Initialize document, window and the documentElement.
    flushUICommand(view, nullptr);

    // Set the status value for preloading.
    _preloadStatus = PreloadingStatus.preloading;

    view.document.preloadViewportSize = _viewportSize;
    // Manually initialize the root element and create renderObjects for each elements.
    view.document.documentElement!.applyStyle(view.document.documentElement!.style);

    try {
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
    } catch (e, stack) {
      _preloadStatus = PreloadingStatus.fail;
      _handlingLoadingError(e, stack);
      controllerPreloadingCompleter.completeError(e, stack);
    }

    return controllerPreloadingCompleter.future;
  }

  Object? _loadingError;

  Object? get loadingError => _loadingError;

  bool get hasLoadingError => _loadingError != null;

  void _handlingLoadingError(Object error, StackTrace stack) {
    if (onLoadError != null) {
      onLoadError!(FlutterError(error.toString()), stack);
    }
    _loadingError = error;
  }

  PreRenderingStatus _preRenderingStatus = PreRenderingStatus.none;

  PreRenderingStatus get preRenderingStatus => _preRenderingStatus;

  /// Sets the prerendering status
  ///
  /// This is used internally and by WebFControllerManager to control the prerendering state
  set preRenderingStatus(PreRenderingStatus status) {
    _preRenderingStatus = status;
  }

  /// The `aggressive` mode is a step further than `preloading`, cutting down up to 90% of loading time for optimal performance.
  /// This mode simulates the instantaneous response of native Flutter pages but may require modifications in the existing web codes for compatibility.
  /// In this mode, all remote resources are loaded and executed similarly to the standard mode, but with an offline-like behavior.
  /// Given that JavaScript is executed in this mode, properties like `clientWidth` and `clientHeight` from the viewModule always return 0. This is because
  /// no layout or paint processes occur during preRendering.
  /// If your application depends on viewModule properties, ensure that the related code is placed within the `load` and `DOMContentLoaded` or `prerendered` event callbacks of the window.
  /// These callbacks are triggered once the WebF widget is mounted into the Flutter tree.
  /// Apps optimized for this mode remain compatible with both `standard` and `preloading` modes.
  /// Aggressively preloads and prerenders content from the provided WebFBundle.
  ///
  /// This mode loads, parses, and executes content in a simulated environment before mounting.
  /// Can improve loading performance by up to 90%, but requires special handling for dimension-dependent code.
  Future<void> preRendering(WebFBundle bundle) async {
    if (_preRenderingStatus == PreRenderingStatus.done) return;

    controllerPreRenderingCompleter = Completer();

    await controlledInitCompleter.future;

    if (_preRenderingStatus != PreRenderingStatus.none) return;
    if (_preloadStatus != PreloadingStatus.none) return;

    // Update entrypoint.
    _entrypoint = bundle;
    _replaceCurrentHistory(bundle);
    view.document.initializeCookieJarForUrl(url);

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

    try {
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

      evaluated = true;

      view.flushPendingCommandsPerFrame();
    } catch (e, stack) {
      _preRenderingStatus = PreRenderingStatus.fail;
      _handlingLoadingError(e, stack);
      controllerPreRenderingCompleter.complete();
      return;
    }

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
  /// Pauses all timers, animations, and JavaScript execution.
  ///
  /// Useful when the WebF content is not visible or the app is in the background.
  /// Reduces resource usage by suspending non-essential operations.
  void pause() {
    if (_paused) return;
    _paused = true;
    module.pauseTimer();
    module.pauseAnimationFrame();
    view.stopAnimationsTimeLine();
  }

  // Resume all timers and callbacks if page now visible.
  /// Resumes all timers, animations, and JavaScript execution that were paused.
  ///
  /// Call this when the WebF content becomes visible again or the app returns to the foreground.
  /// Restores normal operation of the paused WebF environment.
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

  /// Disposes the WebF controller and all associated resources.
  ///
  /// Cleans up native resources, listeners, and cached data. Should be called when
  /// the controller is no longer needed to prevent memory leaks.
  Future<void> dispose() async {
    PaintingBinding.instance.systemFonts.removeListener(_watchFontLoading);
    removeHttpOverrides(contextId: _view!.contextId);
    await _view?.dispose();
    _module?.dispose();
    if (_view?.inited == true) {
      _controllerMap[_view!.contextId] = null;
      _controllerMap.remove(_view!.contextId);
    }

    if (isFlutterAttached) {
      BuildContext? rootBuildContext = this.rootBuildContext?.context;
      if (rootBuildContext != null) {
        WebFState state = (rootBuildContext as StatefulElement).state as WebFState;
        state.requestForUpdate(ControllerDisposeChangeReason());
      }
    }

    // To release entrypoint bundle memory.
    _entrypoint?.dispose();

    devToolsService?.dispose();
    routes = null;
    _loadingError = null;
    _disposed = true;
  }

  String get origin {
    Uri uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  Future<void> executeEntrypoint(
      {bool shouldResolve = true, bool shouldEvaluate = true, AnimationController? animationController}) async {
    if (_entrypoint != null && shouldResolve) {
      await controlledInitCompleter.future;
      await Future.wait([_resolveEntrypoint(), _module!.initialize()]);
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
    assert(!_view!.disposed, 'WebF have already disposed');

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
      // Not to dismiss this error.
      rethrow;
    }
  }

  bool _isFlutterAttached = false;

  bool get isFlutterAttached => _isFlutterAttached;

  /// Attaches the WebF controller to a Flutter BuildContext.
  ///
  /// This connects the WebF environment to the Flutter widget tree, enabling rendering
  /// and interactions. Must be called before content can be displayed.
  void attachToFlutter(BuildContext context) {
    _ownerFlutterView = View.of(context);
    view.attachToFlutter(context);
    PaintingBinding.instance.systemFonts.addListener(_watchFontLoading);
    _isFlutterAttached = true;
    pushNewBuildContext(context: context, routePath: initialRoute ?? '/');
  }

  /// Detaches the WebF controller from the Flutter widget tree.
  ///
  /// Disconnects the WebF environment from Flutter, stopping rendering and interactions.
  /// Should be called when the WebF content is no longer displayed or needed.
  void detachFromFlutter(BuildContext? context) {
    view.detachFromFlutter();
    PaintingBinding.instance.systemFonts.removeListener(_watchFontLoading);
    _isFlutterAttached = false;
    _ownerFlutterView = null;
    popBuildContext(context: context, routePath: initialRoute ?? '/');
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

    assert(!_view!.disposed, 'WebF have already disposed');
    if (_entrypoint != null) {
      EvaluateOpItem? evaluateOpItem;
      if (enableWebFProfileTracking) {
        evaluateOpItem = WebFProfiler.instance.startTrackEvaluate('WebFController.evaluateEntrypoint');
      }

      WebFBundle entrypoint = _entrypoint!;
      double contextId = _view!.contextId;
      assert(entrypoint.isResolved, 'The webf bundle $entrypoint is not resolved to evaluate.');

      // entry point start parse.
      _view!.document.parsing = true;

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
      _view!.document.parsing = false;

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

  // window.onload
  bool _isComplete = false;

  bool get isComplete => _isComplete;

  bool _isCanceled = false;

  bool get isCanceled => _isCanceled;

  set isCanceled(bool value) {
    _isCanceled = value;
  }

  // window.onDOMContentLoaded
  bool _isDOMComplete = false;

  bool get isDOMComplete => _isDOMComplete;

  bool _evaluated = false;

  bool get evaluated => _evaluated;

  set evaluated(value) {
    _evaluated = value;
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/loader/FrameLoader.cpp#L840
  // Check whether the document has been loaded, such as html has parsed (main of JS has evaled) and images/scripts has loaded.
  void checkCompleted() {
    // Are we still parsing?
    if (_view!.document.parsing) return;

    // Are all script element complete?
    if (_view!.document.isDelayingDOMContentLoadedEvent) return;

    if (_isDOMComplete) return;

    _view!.document.readyState = DocumentReadyState.interactive;
    dispatchDOMContentLoadedEvent();
    _isDOMComplete = true;

    controllerOnDOMContentLoadedCompleter.complete();

    // Still waiting for images/scripts?
    if (_view!.document.hasPendingRequest) return;

    // Still waiting for elements that don't go through a FrameLoader?
    if (_view!.document.isDelayingLoadEvent) return;

    if (_isComplete) return;

    // The page load was complete
    _isComplete = true;
    controllerOnLoadCompleter.complete();

    dispatchWindowLoadEvent();
    _view!.document.readyState = DocumentReadyState.complete;

    if (mode == WebFLoadingMode.preRendering) {
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

  /// Dispatches the DOMContentLoaded event to the document and window.
  ///
  /// This is equivalent to the standard Web DOMContentLoaded event, which fires when the
  /// initial HTML document has been completely loaded and parsed, without waiting for
  /// stylesheets, images, and other resources to finish loading.
  ///
  /// Also calls the onDOMContentLoaded callback if one is provided.
  void dispatchDOMContentLoadedEvent() {
    if (_domContentLoadedEventDispatched) return;

    _domContentLoadedEventDispatched = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_view == null) return;
      Event event = Event(EVENT_DOM_CONTENT_LOADED);
      EventTarget window = view.window;
      window.dispatchEvent(event);
      _view!.document.dispatchEvent(event);
      if (onDOMContentLoaded != null) {
        onDOMContentLoaded!(this);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  bool _loadEventDispatched = false;

  /// Dispatches the load event to the window.
  ///
  /// This is equivalent to the standard Web window.onload event, which fires when the
  /// whole page has loaded, including all dependent resources such as stylesheets and images.
  ///
  /// Also calls the onLoad callback if one is provided.
  void dispatchWindowLoadEvent() {
    if (_loadEventDispatched) return;
    _loadEventDispatched = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // DOM element are created at next frame, so we should trigger onload callback in the next frame.
      Event event = Event(EVENT_LOAD);
      _view!.window.dispatchEvent(event);

      if (onLoad != null) {
        onLoad!(this);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  bool _preloadEventDispatched = false;

  /// Dispatches the preloaded event to the window.
  ///
  /// This custom WebF event fires when content has been preloaded using the
  /// preloading mode. JavaScript code can listen for this event to know
  /// when preloading has completed.
  void dispatchWindowPreloadedEvent() {
    if (_preloadEventDispatched) return;
    _preloadEventDispatched = true;
    Event event = Event(EVENT_PRELOADED);
    view.window.dispatchEvent(event);
  }

  bool _preRenderedEventDispatched = false;

  /// Dispatches the prerendered event to the window.
  ///
  /// This custom WebF event fires when content has been prerendered using the
  /// preRendering mode. JavaScript code can listen for this event to know
  /// when prerendering has completed and perform any operations that depend
  /// on accurate viewport dimensions.
  void dispatchWindowPreRenderedEvent() {
    if (_preRenderedEventDispatched) return;
    _preRenderedEventDispatched = true;
    Event event = Event(EVENT_PRERENDERED);
    view.window.dispatchEvent(event);
  }

  /// Dispatches the resize event to the window.
  ///
  /// This is equivalent to the standard Web window.onresize event, which fires when
  /// the document view has been resized. In WebF, this occurs when the viewport size
  /// changes due to device rotation, window resizing, or other layout changes.
  ///
  /// Returns a Future that completes when the event has been dispatched.
  Future<void> dispatchWindowResizeEvent() async {
    Event event = Event(EVENT_RESIZE);
    await view.window.dispatchEvent(event);
  }

  @override
  String toStringShort() {
    String status = mode == WebFLoadingMode.preloading ? _preloadStatus.toString() : _preRenderingStatus.toString();
    return '${describeIdentity(this)} (disposed: $disposed, evaluated: $evaluated, status: $status)';
  }
}

/// Abstract base class for implementing DevTools debugging services for WebF content.
///
/// Provides the infrastructure needed to connect Chrome DevTools to a WebF instance,
/// enabling inspection of DOM elements, JavaScript debugging, network monitoring,
/// and other developer tools features.
abstract class DevToolsService {
  /// Previous instance of DevToolsService during a page reload.
  ///
  /// Design prevDevTool for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static DevToolsService? prevDevTools;

  static final Map<double, DevToolsService> _contextDevToolMap = {};

  /// Retrieves the DevTools service instance associated with a specific JavaScript context ID.
  ///
  /// @param contextId The unique identifier for a JavaScript context
  /// @return The DevToolsService instance for the context, or null if none exists
  static DevToolsService? getDevToolOfContextId(double contextId) {
    return _contextDevToolMap[contextId];
  }

  /// Used for debugger inspector.
  UIInspector? _uiInspector;

  /// Provides access to the UI inspector for debugging DOM elements.
  ///
  /// The UI inspector enables visualization and inspection of the DOM structure
  /// and rendered elements in DevTools.
  UIInspector? get uiInspector => _uiInspector;

  /// The Dart isolate running the DevTools server.
  ///
  /// DevTools runs in a separate isolate to avoid impacting the performance
  /// of the main Flutter application.
  Isolate? _isolateServer;

  /// Access to the isolate running the DevTools server.
  ///
  /// This isolate handles communication with Chrome DevTools.
  Isolate get isolateServer => _isolateServer!;

  /// Sets the isolate for the DevTools server.
  ///
  /// @param isolate The Dart isolate instance handling DevTools communication
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

  /// Initializes the DevTools service for a WebF controller.
  ///
  /// Sets up the inspector server and UI inspector, enabling Chrome DevTools
  /// to connect to and debug the WebF content.
  ///
  /// @param controller The WebFController instance to enable debugging for
  void init(WebFController controller) {
    _contextDevToolMap[controller.view.contextId] = this;
    _controller = controller;
    spawnIsolateInspectorServer(this, controller);
    _uiInspector = UIInspector(this);
    controller.view.debugDOMTreeChanged = uiInspector!.onDOMTreeChanged;
  }

  /// Indicates whether the WebF content is currently being reloaded.
  ///
  /// Used to manage DevTools state during page reloads.
  bool get isReloading => _reloading;

  /// Internal flag to track reload state.
  bool _reloading = false;

  /// Called before WebF content is reloaded to prepare DevTools.
  ///
  /// Sets the reloading flag to true to prevent DevTools operations during reload.
  void willReload() {
    _reloading = true;
  }

  /// Called after WebF content has been reloaded to reconnect DevTools.
  ///
  /// Updates the DOM tree change handlers and notifies the inspector server
  /// about the reload completion.
  void didReload() {
    _reloading = false;
    controller!.view.debugDOMTreeChanged = _uiInspector!.onDOMTreeChanged;
    _isolateServerPort!.send(InspectorReload(_controller!.view.contextId));
  }

  /// Disposes the DevTools service and releases all resources.
  ///
  /// Cleans up the UI inspector, removes context mappings, and terminates
  /// the inspector isolate server.
  void dispose() {
    _uiInspector?.dispose();
    _contextDevToolMap.remove(controller?.view.contextId);
    _controller = null;
    _isolateServerPort = null;
    _isolateServer?.kill();
  }
}
