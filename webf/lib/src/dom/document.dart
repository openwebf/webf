/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'dart:async';
import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/bridge.dart';
import 'package:webf/widget.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/css/query_selector.dart' as query_selector;
import 'package:webf/src/dom/element_registry.dart' as element_registry;
import 'package:webf/src/dom/intersection_observer.dart';


// Removed _InactiveRenderObjects helper (unused).

enum DocumentReadyState { loading, interactive, complete }

enum VisibilityState { visible, hidden }

class Document extends ContainerNode {
  final WebFController controller;
  late AnimationTimeline animationTimeline;
  Map<String, List<Element>> elementsByID = {};
  Map<String, List<Element>> elementsByName = {};
  // Fast indices to support targeted invalidation
  // - elementsByClass: maps a class token to connected elements with that class
  // - elementsByAttr: maps an attribute name (UPPERCASED) to connected elements where that attribute is present
  // These indices are maintained by Element on connect/disconnect and attribute/class changes.
  Map<String, List<Element>> elementsByClass = {};
  Map<String, List<Element>> elementsByAttr = {};

  final List<AsyncCallback> pendingPreloadingScriptCallbacks = [];

  final Set<int> _styleDirtyElements = {};

  final Set<IntersectionObserver> _intersectionObserverList = {};

  void markElementStyleDirty(Element element, {String? reason}) {
    _styleDirtyElements.add(element.pointer!.address);
    // Ensure a future flush runs even when only element-level changes occur
    // (no stylesheet updates). This coalesces via the existing scheduler.
    scheduleStyleUpdate();
  }

  void clearElementStyleDirty(Element element) {
    _styleDirtyElements.remove(element.pointer!.address);
  }

  final NthIndexCache _nthIndexCache = NthIndexCache();

  NthIndexCache get nthIndexCache => _nthIndexCache;

  StyleNodeManager get styleNodeManager => _styleNodeManager;
  late StyleNodeManager _styleNodeManager;

  late RuleSet ruleSet;
  // Bumps on every handleStyleSheets() to invalidate element-level memoization.
  int ruleSetVersion = 0;

  bool _styleUpdateScheduled = false;
  Timer? _styleUpdateDebounceTimer;

  String? _domain;
  final String _compatMode = 'CSS1Compat';

  String? _readyState;
  VisibilityState _visibilityState = VisibilityState.hidden;

  @override
  bool get isConnected => true;

  Document(BindingContext context, {required this.controller}) : super(NodeType.DOCUMENT_NODE, context) {
    _styleNodeManager = StyleNodeManager(this);
    _scriptRunner = ScriptRunner(this, context.contextId);
    ruleSet = RuleSet(this);
    animationTimeline = AnimationTimeline(this);
  }

  void initializeCookieJarForUrl(String url) {
    controller.cookieManager.initialize(url: url, initialCookies: controller.initialCookies);
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/Document.h#L1898
  late ScriptRunner _scriptRunner;

  ScriptRunner get scriptRunner => _scriptRunner;

  // Removed unused inactive render objects holder to satisfy lints.

  @override
  EventTarget? get parentEventTarget => defaultView;

  RenderViewportBox? get viewport => controller.view.currentViewport;

  ui.Size? _preloadViewportSize;

  set preloadViewportSize(viewportSize) {
    _preloadViewportSize = viewportSize;
  }

  ui.Size? get preloadViewportSize => _preloadViewportSize;

  @override
  Document get ownerDocument => this;

  // Returns the Window object of the active document.
  // https://html.spec.whatwg.org/multipage/window-object.html#dom-document-defaultview-dev
  Window get defaultView => controller.view.window;

  @override
  String get nodeName => '#document';

  RenderBox? get domRenderer => viewport;

  @override
  RenderBox? get attachedRenderer => viewport;

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/Document.h#L770
  bool parsing = false;

  int _requestCount = 0;

  bool get hasPendingRequest => _requestCount > 0;

  void incrementRequestCount() {
    _requestCount++;
  }

  void decrementRequestCount() {
    assert(_requestCount > 0);
    _requestCount--;
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/Document.h#L2091
  // Counters that currently need to delay load event, such as parsing a script.
  int _loadEventDelayCount = 0;

  bool get isDelayingLoadEvent => _loadEventDelayCount > 0;

  void incrementLoadEventDelayCount() {
    _loadEventDelayCount++;
  }

  void decrementLoadEventDelayCount() {
    _loadEventDelayCount--;

    // Try to check when the request is complete.
    if (_loadEventDelayCount == 0) {
      controller.checkCompleted();
    }
  }

  int _domContentLoadedEventDelayCount = 0;

  bool get isDelayingDOMContentLoadedEvent => _domContentLoadedEventDelayCount > 0;

  void incrementDOMContentLoadedEventDelayCount() {
    _domContentLoadedEventDelayCount++;
  }

  void decrementDOMContentLoadedEventDelayCount() {
    _domContentLoadedEventDelayCount--;

    // Try to check when the request is complete.
    if (_domContentLoadedEventDelayCount == 0) {
      controller.checkCompleted();
    }
  }

  String get cookie {
    CookieManager cookieManager = controller.cookieManager;
    return cookieManager.getCookieString(controller.url);
  }

  set cookie(Object? value) {
    if (value is! String) return;
    CookieManager cookieManager = controller.cookieManager;
    cookieManager.setCookieString(controller.url, value);
  }

  static final StaticDefinedBindingPropertyMap _documentProperties = {
    'cookie': StaticDefinedBindingProperty(
        getter: (document) => castToType<Document>(document).cookie,
        setter: (document, value) => castToType<Document>(document).cookie = value),
    'compatMode': StaticDefinedBindingProperty(getter: (document) => castToType<Document>(document).compatMode),
    'domain': StaticDefinedBindingProperty(
        getter: (document) => castToType<Document>(document).domain,
        setter: (document, value) => castToType<Document>(document).domain = value),
    'readyState': StaticDefinedBindingProperty(getter: (document) => castToType<Document>(document).readyState),
    'visibilityState':
        StaticDefinedBindingProperty(getter: (document) => castToType<Document>(document).visibilityState),
    'hidden': StaticDefinedBindingProperty(getter: (document) => castToType<Document>(document).hidden),
    'title': StaticDefinedBindingProperty(
        getter: (document) => castToType<Document>(document)._title ?? '',
        setter: (document, value) {
          castToType<Document>(document)._title = value ?? '';
          castToType<Document>(document).controller.onTitleChanged?.call(castToType<Document>(document).title);
        })
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _documentProperties];

  static final StaticDefinedSyncBindingObjectMethodMap _syncDocumentMethods = {
    'querySelectorAll': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).querySelectorAll(args)),
    'querySelector': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).querySelector(args)),
    'getElementById': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).getElementById(args)),
    'getElementsByClassName': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).getElementsByClassName(args)),
    'getElementsByTagName': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).getElementsByTagName(args)),
    'getElementsByName': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).getElementsByName(args)),
    'elementFromPoint': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) =>
            castToType<Document>(document).elementFromPoint(castToType<double>(args[0]), castToType<double>(args[1]))),
  };

  // Methods getter overridden below to include debug methods conditionally.

  static final StaticDefinedSyncBindingObjectMethodMap _debugDocumentMethods = {
    '___clear_cookies__': StaticDefinedSyncBindingObjectMethod(
        call: (document, args) => castToType<Document>(document).debugClearCookies(args)),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods {
    final list = <StaticDefinedSyncBindingObjectMethodMap>[...super.methods, _syncDocumentMethods];
    if (kDebugMode || kProfileMode) {
      list.add(_debugDocumentMethods);
    }
    return list;
  }

  get readyState {
    _readyState ??= 'loading';
    return _readyState;
  }

  set readyState(value) {
    if (value is DocumentReadyState) {
      String readyStateValue = resolveReadyState(value);
      if (readyStateValue != _readyState) {
        _readyState = readyStateValue;
        _dispatchReadyStateChangeEvent();
      }
    }
  }

  get visibilityState {
    return _visibilityState.name;
  }

  get hidden {
    return _visibilityState == VisibilityState.hidden;
  }

  void visibilityChange(VisibilityState state) {
    _visibilityState = state;
    ownerDocument.dispatchEvent(Event('visibilitychange'));
  }

  void _dispatchReadyStateChangeEvent() {
    Event event = Event(EVENT_READY_STATE_CHANGE);
    defaultView.dispatchEvent(event);
  }

  String resolveReadyState(DocumentReadyState documentReadyState) {
    switch (documentReadyState) {
      case DocumentReadyState.loading:
        return 'loading';
      case DocumentReadyState.interactive:
        return 'interactive';
      case DocumentReadyState.complete:
        return 'complete';
    }
  }

  dynamic get compatMode => _compatMode;

  String get title => _title ?? '';
  String? _title;

  get domain {
    Uri uri = Uri.parse(controller.url);
    _domain ??= uri.host;
    return _domain;
  }

  set domain(value) {
    _domain = value;
  }

  dynamic debugClearCookies(List<dynamic> args) {
    controller.cookieManager.clearAllCookies();
  }

  dynamic querySelector(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return null;
    return query_selector.querySelector(this, args.first);
  }

  dynamic elementFromPoint(double x, double y) {
    return hitTestPoint(x, y);
  }

  Element? hitTestPoint(double x, double y) {
    HitTestResult hitTestResult = hitTestInDocument(x, y);
    Iterable<HitTestEntry> hitTestEntrys = hitTestResult.path;
    if (hitTestResult.path.isNotEmpty) {
      if (hitTestEntrys.first.target is RenderBoxModel) {
        return (hitTestEntrys.first.target as RenderBoxModel).renderStyle.target;
      }
    }
    return null;
  }

  HitTestResult hitTestInDocument(double x, double y) {
    BoxHitTestResult boxHitTestResult = BoxHitTestResult();
    Offset offset = Offset(x, y);
    documentElement?.attachedRenderer?.hitTest(boxHitTestResult, position: offset);
    return boxHitTestResult;
  }

  dynamic querySelectorAll(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return [];
    return query_selector.querySelectorAll(this, args.first);
  }

  dynamic getElementById(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return null;
    final elements = elementsByID[args.first];
    if (elements == null || elements.isEmpty) {
      return null;
    }
    if (elements.length == 1) {
      return elements.last;
    } else if (elements.length > 1) {
      Queue<Node> queue = Queue();
      queue.add(this);
      while (queue.isNotEmpty) {
        Node node = queue.removeFirst();
        if (elements.contains(node)) {
          return node;
        }
        if (node.childNodes.isNotEmpty) {
          for (Node child in node.childNodes) {
            queue.add(child);
          }
        }
      }
    }
    return null;
  }

  dynamic getElementsByClassName(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return [];
    String selector = (args.first as String).split(classNameSplitRegExp).map((e) => '.$e').join('');
    return query_selector.querySelectorAll(this, selector);
  }

  dynamic getElementsByTagName(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return [];
    return query_selector.querySelectorAll(this, args.first);
  }

  dynamic getElementsByName(List<dynamic> args) {
    if (args[0].runtimeType == String && (args[0] as String).isEmpty) return [];
    return elementsByName[args.first];
  }

  HTMLElement? _documentElement;

  HTMLElement? get documentElement => _documentElement;

  set documentElement(Element? element) {
    if (_documentElement == element) {
      return;
    }

    // Track element changes implicitly by comparing current and previous values.
    // When document is disposed, viewport is null.
    if (viewport != null) {
      _visibilityState = VisibilityState.visible;
    }

    _documentElement = element as HTMLElement?;
  }

  BodyElement? get bodyElement {
    final HTMLElement? root = _documentElement;
    if (root == null) return null;
    Node? child = root.firstChild;
    while (child != null) {
      if (child is BodyElement) {
        return child;
      }
      child = child.nextSibling;
    }
    return null;
  }

  void syncViewportBackground() {
    final RenderViewportBox? vp = viewport;
    if (vp == null) {
      return;
    }

    ui.Color? resolved;

    final BodyElement? body = bodyElement;
    final ui.Color? bodyColor = body?.renderStyle.backgroundColor?.value;
    final bool bodyHasColor = bodyColor != null && bodyColor.a != 0;

    if (bodyHasColor) {
      resolved = bodyColor;
    } else {
      final ui.Color? htmlColor = documentElement?.renderStyle.backgroundColor?.value;
      final bool htmlHasColor = htmlColor != null && htmlColor.a != 0;
      if (htmlHasColor) {
        resolved = htmlColor;
      }
    }

    if (vp.background != resolved) {
      vp.background = resolved;
      vp.markNeedsPaint();
    }
  }

  @override
  Node appendChild(Node child) {
    if (child is Element) {
      documentElement ??= child;
    } else {
      throw UnsupportedError('Only Element can be appended to Document');
    }
    return super.appendChild(child);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Document($hashCode)';
  }

  @override
  Node insertBefore(Node child, Node referenceNode) {
    if (child is Element) {
      documentElement ??= child;
    } else {
      throw UnsupportedError('Only Element can be inserted to Document');
    }
    return super.insertBefore(child, referenceNode);
  }

  @override
  Node? removeChild(Node child) {
    Node? result = super.removeChild(child);
    if (documentElement == child) {
      documentElement = null;
      ruleSet.reset();
      styleSheets.clear();
    }
    return result;
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);

    flutter.BuildContext? rootBuildContext = ownerView.rootController.rootBuildContext?.context;
    if (rootBuildContext != null) {
      WebFState state = (rootBuildContext as flutter.StatefulElement).state as WebFState;
      state.requestForUpdate(DocumentElementChangedReason());
    }
  }

  @override
  Node? replaceChild(Node newNode, Node oldNode) {
    if (documentElement == oldNode) {
      documentElement = newNode is Element ? newNode : null;
    }
    return super.replaceChild(newNode, oldNode);
  }

  Element createElement(String type, BindingContext context) {
    Element element = element_registry.createElement(type, context);
    return element;
  }

  Element createElementNS(String uri, String type, BindingContext context) {
    Element element = element_registry.createElementNS(uri, type, context);
    return element;
  }

  TextNode createTextNode(String data, BindingContext context) {
    TextNode textNode = TextNode(data, context);
    return textNode;
  }

  DocumentFragment createDocumentFragment(BindingContext context) {
    DocumentFragment documentFragment = DocumentFragment(context);
    return documentFragment;
  }

  Comment createComment(BindingContext context) {
    Comment comment = Comment(context);
    return comment;
  }

  // TODO: https://wicg.github.io/construct-stylesheets/#using-constructed-stylesheets
  List<CSSStyleSheet> adoptedStyleSheets = [];

  // The styleSheets attribute is readonly attribute.
  final List<CSSStyleSheet> styleSheets = [];

  void handleStyleSheets(List<CSSStyleSheet> sheets) {
    styleSheets.clear();
    styleSheets.addAll(sheets.map((e) => e.clone()));

    ruleSet.reset();
    for (var sheet in sheets) {
      ruleSet.addRules(sheet.cssRules, baseHref: sheet.href);
    }
    // Increment the ruleset version to bust element-level caches.
    ruleSetVersion++;

  }

  bool _recalculating = false;

  void updateStyleIfNeeded() {
    // If a debounced update was previously scheduled, cancel it now since we are
    // about to run a synchronous update. This prevents stray pending timers in
    // tests when callers explicitly flush styles (e.g., after class changes).
    _styleUpdateDebounceTimer?.cancel();
    _styleUpdateDebounceTimer = null;
    _styleUpdateScheduled = false;
    // Only early-return when there are truly no pending updates of any kind:
    // - no pending stylesheet changes
    // - no candidate sheet node changes
    // - no element-level dirty marks
    if (!styleNodeManager.hasPendingStyleSheet &&
        !styleNodeManager.isStyleSheetCandidateNodeChanged &&
        _styleDirtyElements.isEmpty) {

      return;
    }
    if (_recalculating) {

      return;
    }
    _recalculating = true;
    if (styleSheets.isEmpty && styleNodeManager.hasPendingStyleSheet) {
      flushStyle(rebuild: true);
      return;
    }

    flushStyle();
  }

  void flushStyle({bool rebuild = false}) {

    final int dirtyAtStart = _styleDirtyElements.length;
    // Always attempt to update active stylesheets first so changedRuleSet can
    // mark targeted elements dirty (even if we had no prior dirty set).
    final bool sheetsUpdated = styleNodeManager.updateActiveStyleSheets(rebuild: rebuild);

    if (DebugFlags.enableCssMultiStyleTrace) {
      cssLogger.info('[trace][multi-style][flush] sheetsUpdated=$sheetsUpdated pendingNow=${styleNodeManager.pendingStyleSheetCount} '
          'candidates=${styleNodeManager.styleSheetCandidateNodes.length} dirtyAtStart=$dirtyAtStart');
    }
    // Recompute dirty count after stylesheets may have targeted elements.
    final int dirtyAfterSheets = _styleDirtyElements.length;

    if (dirtyAfterSheets == 0 && !sheetsUpdated) {

      _recalculating = false;
      return;
    }
    bool recalcFromRoot = _styleDirtyElements.any((address) {
          final BindingObject? bindingObject = ownerView.getBindingObject(Pointer.fromAddress(address));
          if (bindingObject == null) {
            return false;
          }
          return bindingObject is HeadElement || bindingObject is HTMLElement;
        }) ||
        rebuild;
    if (DebugFlags.enableCssDisableRootRecalc && recalcFromRoot) {
      recalcFromRoot = false;
    }

    if (recalcFromRoot) {

      documentElement?.recalculateStyle(rebuildNested: true);
    } else {
      for (int address in _styleDirtyElements) {
        Element? element = ownerView.getBindingObject(Pointer.fromAddress(address)) as Element?;
        element?.recalculateStyle();
      }
    }
    _styleDirtyElements.clear();
    _recalculating = false;

  }

  void scheduleStyleUpdate() {
    // If only element-level dirties are pending (e.g., class/id/attr mutations)
    // and there are no stylesheet loads or candidate node changes, avoid the
    // debounce window so tests and interactive style changes observe updates
    // promptly within the next microtask/frame.
    final bool elementOnlyDirty = _styleDirtyElements.isNotEmpty &&
        !styleNodeManager.hasPendingStyleSheet &&
        !styleNodeManager.isStyleSheetCandidateNodeChanged;

    final bool useDebounce = DebugFlags.enableCssBatchStyleUpdates &&
        DebugFlags.cssBatchStyleUpdatesDebounceMs > 0 &&
        !elementOnlyDirty;
    if (useDebounce) {
      // Debounce across frames/time: reset the timer on each call.
      _styleUpdateScheduled = true;
      _styleUpdateDebounceTimer?.cancel();
      if (DebugFlags.enableCssMultiStyleTrace) {
        cssLogger.info('[trace][multi-style][schedule] style update scheduled via debounce(${DebugFlags.cssBatchStyleUpdatesDebounceMs}ms)');
      }
      _styleUpdateDebounceTimer = Timer(Duration(milliseconds: DebugFlags.cssBatchStyleUpdatesDebounceMs), () {
        // Skip if nothing pending (including element-level dirties).
        if (!styleNodeManager.hasPendingStyleSheet &&
            !styleNodeManager.isStyleSheetCandidateNodeChanged &&
            _styleDirtyElements.isEmpty) {
          _styleUpdateScheduled = false;
          return;
        }
        if (DebugFlags.enableCssMultiStyleTrace) {
          cssLogger.info('[trace][multi-style][schedule] style update running (debounce)');
        }
        updateStyleIfNeeded();
        _styleUpdateScheduled = false;
      });
      return;
    }

    if (_styleUpdateScheduled) return;
    _styleUpdateScheduled = true;
    final bool perFrame = DebugFlags.enableCssBatchStyleUpdatesPerFrame && DebugFlags.enableCssBatchStyleUpdates;
    if (DebugFlags.enableCssMultiStyleTrace) {
      cssLogger.info('[trace][multi-style][schedule] style update scheduled via ${perFrame ? 'frame' : 'microtask'}');
    }
    if (perFrame) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!styleNodeManager.hasPendingStyleSheet &&
            !styleNodeManager.isStyleSheetCandidateNodeChanged &&
            _styleDirtyElements.isEmpty) {
          _styleUpdateScheduled = false;
          return;
        }
        if (DebugFlags.enableCssMultiStyleTrace) {
          cssLogger.info('[trace][multi-style][schedule] style update running (frame)');
        }
        updateStyleIfNeeded();
        _styleUpdateScheduled = false;
      });
      SchedulerBinding.instance.scheduleFrame();
    } else {
      scheduleMicrotask(() {
        if (!styleNodeManager.hasPendingStyleSheet &&
            !styleNodeManager.isStyleSheetCandidateNodeChanged &&
            _styleDirtyElements.isEmpty) {
          _styleUpdateScheduled = false;
          return;
        }
        if (DebugFlags.enableCssMultiStyleTrace) {
          cssLogger.info('[trace][multi-style][schedule] style update running (microtask)');
        }
        updateStyleIfNeeded();
        _styleUpdateScheduled = false;
      });
    }
  }

  void recalculateStyleImmediately() {
    var styleSheetNodes = styleNodeManager.styleSheetCandidateNodes;

    for (final element in styleSheetNodes) {
      if (element is StyleElementMixin) {

        element.reloadStyle();
      } else if (element is LinkElement && element.isCSSStyleSheetLoaded()) {

        element.reloadStyle();
      }
    }
  }

  @override
  Future<void> dispose() async {
    styleSheets.clear();
    nthIndexCache.clearAll();
    adoptedStyleSheets.clear();
    // Cancel any pending scheduled style updates to avoid leaking timers in tests.
    _styleUpdateDebounceTimer?.cancel();
    _styleUpdateDebounceTimer = null;
    _styleUpdateScheduled = false;
    _styleDirtyElements.clear();
    pendingPreloadingScriptCallbacks.clear();
    elementsByID.clear();
    elementsByName.clear();
    elementsByClass.clear();
    elementsByAttr.clear();
    _documentElement = null;
    // Dispose animation timeline to stop ticker and prevent memory leaks
    animationTimeline.dispose();
    _intersectionObserverList.clear();
    super.dispose();
  }

  @override
  bool get isRendererAttached => viewport?.attached == true;

  bool get isRendererAttachedToSegmentTree => viewport?.parent != null;

  void addIntersectionObserver(IntersectionObserver observer, Element element) {
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] document add observer=${observer.pointer} target=${element.pointer}');
    }
    observer.observe(element);
    _intersectionObserverList.add(observer);
  }

  void removeIntersectionObserver(IntersectionObserver observer, Element element) {
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] document remove observer=${observer.pointer} target=${element.pointer}');
    }
    observer.unobserve(element);
    if (!observer.hasObservations()) {
      _intersectionObserverList.remove(observer);
    }
  }

  void disconnectIntersectionObserver(IntersectionObserver observer) {
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] document disconnect observer=${observer.pointer}');
    }
    observer.disconnect();
    _intersectionObserverList.remove(observer);
  }

  void deliverIntersectionObserver() {
    if (_intersectionObserverList.isEmpty) {
      return;
    }

    int delivered = 0;
    for (final IntersectionObserver observer in _intersectionObserverList) {
      if (!observer.hasPendingRecords) continue;
      delivered++;
      observer.deliver(controller);
    }

    if (enableWebFCommandLog && delivered > 0) {
      domLogger.fine('[IntersectionObserver] deliver records observers=$delivered');
    }
  }
}
