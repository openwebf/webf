/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
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

// Removed _InactiveRenderObjects helper (unused).

enum DocumentReadyState { loading, interactive, complete }

enum VisibilityState { visible, hidden }

class Document extends ContainerNode {
  final WebFController controller;
  late AnimationTimeline animationTimeline;
  Map<String, List<Element>> elementsByID = {};
  Map<String, List<Element>> elementsByName = {};

  final List<AsyncCallback> pendingPreloadingScriptCallbacks = [];

  final Set<int> _styleDirtyElements = {};

  void markElementStyleDirty(Element element) {
    _styleDirtyElements.add(element.pointer!.address);
  }

  void clearElementStyleDirty(Element element) {
    _styleDirtyElements.remove(element.pointer!.address);
  }

  final NthIndexCache _nthIndexCache = NthIndexCache();

  NthIndexCache get nthIndexCache => _nthIndexCache;

  StyleNodeManager get styleNodeManager => _styleNodeManager;
  late StyleNodeManager _styleNodeManager;

  late RuleSet ruleSet;

  String? _domain;
  final String _compatMode = 'CSS1Compat';

  String? _readyState;
  VisibilityState _visibilityState = VisibilityState.hidden;

  @override
  bool get isConnected => true;

  Document(BindingContext context, {required this.controller})
      : super(NodeType.DOCUMENT_NODE, context) {
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

  RootRenderViewportBox? get viewport => controller.view.viewport;

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
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] handleStyleSheets: new sheets=' + sheets.length.toString() + ' (old=' + styleSheets.length.toString() + ')');
    }
    styleSheets.clear();
    styleSheets.addAll(sheets.map((e) => e.clone()));
    ruleSet.reset();
    for (var sheet in sheets) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] adding rules from sheet href=' + (sheet.href?.toString() ?? 'inline') + ' rules=' + sheet.cssRules.length.toString());
      }
      ruleSet.addRules(sheet.cssRules, baseHref: sheet.href);
    }
  }

  bool _recalculating = false;

  void updateStyleIfNeeded() {
    if (!styleNodeManager.hasPendingStyleSheet && !styleNodeManager.isStyleSheetCandidateNodeChanged) {
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] updateStyleIfNeeded: no pending or candidate changes');
    }
      return;
    }
    if (_recalculating) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] updateStyleIfNeeded: already recalculating, skip');
      }
      return;
    }
    _recalculating = true;
    if (styleSheets.isEmpty && styleNodeManager.hasPendingStyleSheet) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] updateStyleIfNeeded: empty styleSheets with pending, flushStyle(rebuild: true)');
      }
      flushStyle(rebuild: true);
      return;
    }
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] updateStyleIfNeeded: flushStyle()');
    }
    flushStyle();
  }

  void flushStyle({bool rebuild = false}) {
    if (_styleDirtyElements.isEmpty) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] flushStyle: no dirty elements');
      }
      _recalculating = false;
      return;
    }
    if (!styleNodeManager.updateActiveStyleSheets(rebuild: rebuild)) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] flushStyle: no active stylesheet update');
      }
      _recalculating = false;
      _styleDirtyElements.clear();
      return;
    }
    if (_styleDirtyElements.any((address) {
          BindingObject bindingObject = ownerView.getBindingObject(Pointer.fromAddress(address));
          return bindingObject is HeadElement || bindingObject is HTMLElement;
        }) ||
        rebuild) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] flushStyle: recalculating from root');
      }
      documentElement?.recalculateStyle(rebuildNested: true);
    } else {
      for (int address in _styleDirtyElements) {
        Element? element = ownerView.getBindingObject(Pointer.fromAddress(address)) as Element?;
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] flushStyle: recalc element ' + (element?.tagName ?? '') + '#' + (element?.hashCode.toString() ?? ''));
        }
        element?.recalculateStyle();
      }
    }
    _styleDirtyElements.clear();
    _recalculating = false;
  }

  void recalculateStyleImmediately() {
    var styleSheetNodes = styleNodeManager.styleSheetCandidateNodes;
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] recalculateStyleImmediately: candidates=' + styleSheetNodes.length.toString());
    }
    for (final element in styleSheetNodes) {
      if (element is StyleElementMixin) {
        if (kDebugMode) {
          debugPrint('[webf][style] recalc <style> node');
        }
        element.reloadStyle();
      } else if (element is LinkElement && element.isCSSStyleSheetLoaded()) {
        if (kDebugMode) {
          debugPrint('[webf][style] recalc <link> node href=' + element.href);
        }
        element.reloadStyle();
      }
    }
  }

  @override
  Future<void> dispose() async {
    styleSheets.clear();
    nthIndexCache.clearAll();
    adoptedStyleSheets.clear();
    _styleDirtyElements.clear();
    pendingPreloadingScriptCallbacks.clear();
    _documentElement = null;
    // Dispose animation timeline to stop ticker and prevent memory leaks
    animationTimeline.dispose();
    super.dispose();
  }

  @override
  bool get isRendererAttached => viewport?.attached == true;

  @override
  bool get isRendererAttachedToSegmentTree => viewport?.parent != null;
}
