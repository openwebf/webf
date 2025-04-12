/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:path/path.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/module.dart';
import 'package:webf/src/css/computed_style_declaration.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget {
  final Document document;
  Screen? _screen;
  Screen get screen {
    if (document.controller.ownerFlutterView == null) return Screen.zero(contextId!, null, document.controller.view);

    _screen ??= Screen(contextId!, document.controller.ownerFlutterView, document.controller.view);
    return _screen!;
  }

  Window(BindingContext? context, this.document)
      : super(context) {
    BindingBridge.listenEvent(this, 'load');
    BindingBridge.listenEvent(this, 'gcopen');
  }

  @override
  EventTarget? get parentEventTarget => null;

  static final StaticDefinedSyncBindingObjectMethodMap _syncWindowMethods = {
    'scroll': StaticDefinedSyncBindingObjectMethod(
        call: (window, args) => castToType<Window>(window).scrollTo(castToType<double>(args[0]), castToType<double>(args[1]))),
    'scrollTo': StaticDefinedSyncBindingObjectMethod(
        call: (window, args) => castToType<Window>(window).scrollTo(castToType<double>(args[0]), castToType<double>(args[1]))),
    'scrollBy': StaticDefinedSyncBindingObjectMethod(
        call: (window, args) => castToType<Window>(window).scrollBy(castToType<double>(args[0]), castToType<double>(args[1]))),
    'open':
        StaticDefinedSyncBindingObjectMethod(call: (window, args) => castToType<Window>(window).open(castToType<String>(args[0]))),
    'getComputedStyle': StaticDefinedSyncBindingObjectMethod(
        call: (window, args) => castToType<Window>(window).getComputedStyle(args[0] as Element)),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _syncWindowMethods];

  static final StaticDefinedBindingPropertyMap _syncWindowProperties = {
    'innerWidth': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).innerWidth),
    'innerHeight': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).innerHeight),
    'scrollX': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).scrollX),
    'scrollY': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).scrollY),
    'pageXOffset': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).scrollX),
    'pageYOffset': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).scrollY),
    'screen': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).screen),
    'colorScheme': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).colorScheme),
    'devicePixelRatio': StaticDefinedBindingProperty(getter: (window) => castToType<Window>(window).devicePixelRatio),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _syncWindowProperties];

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-window-interface
  }

  void open(String url) {
    String? sourceUrl = document.controller.view.rootController.url;
    document.controller.view.handleNavigationAction(sourceUrl, url, WebFNavigationType.navigate);
  }

  ComputedCSSStyleDeclaration getComputedStyle(Element element) {
    return ComputedCSSStyleDeclaration(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), element, element.tagName);
  }

  double get scrollX => document.documentElement!.scrollLeft;

  double get scrollY => document.documentElement!.scrollTop;

  void scrollTo(double x, double y, [bool withAnimation = false]) {
    document.flushStyle();
    document.documentElement!
      ..flushLayout()
      ..scrollTo(x, y, withAnimation);
  }

  void scrollBy(double x, double y, [bool withAnimation = false]) {
    document.flushStyle();
    document.documentElement!
      ..flushLayout()
      ..scrollBy(x, y, withAnimation);
  }

  final Set<Element> _watchedViewportElements = {};

  void watchViewportSizeChangeForElement(Element element) {
    _watchedViewportElements.add(element);
  }

  void unwatchViewportSizeChangeForElement(Element element) {
    _watchedViewportElements.remove(element);
  }

  String get colorScheme =>
      document.controller.ownerFlutterView?.platformDispatcher.platformBrightness == Brightness.light ? 'light' : 'dark';

  double get devicePixelRatio {
    return document.controller.ownerFlutterView?.devicePixelRatio ?? 1.0;
  }

  // The innerWidth/innerHeight attribute must return the viewport width/height
  // including the size of a rendered scroll bar (if any), or zero if there is no viewport.
  // https://drafts.csswg.org/cssom-view/#dom-window-innerwidth
  // This is a read only idl attribute.
  double get innerWidth => _viewportSize.width;

  double get innerHeight => _viewportSize.height;

  Size get _viewportSize {
    RenderViewportBox? viewport = document.viewport;
    if (viewport != null && viewport.hasSize) {
      return viewport.size;
    } else {
      return Size.zero;
    }
  }

  @override
  Future<void> dispatchEvent(Event event) async {
    // Events such as EVENT_DOM_CONTENT_LOADED need to ensure that listeners are flushed and registered.
    if (contextId != null && event.type == EVENT_DOM_CONTENT_LOADED ||
        event.type == EVENT_LOAD ||
        event.type == EVENT_ERROR) {
      flushUICommandWithContextId(contextId!, pointer!);
    }
    return super.dispatchEvent(event);
  }

  @override
  void addEventListener(String eventType, EventHandler handler, {EventListenerOptions? addEventListenerOptions, bool builtInCallback = false}) {
    super.addEventListener(eventType, handler, addEventListenerOptions: addEventListenerOptions);
    switch (eventType) {
      case EVENT_SCROLL:
        // Fired at the Document or element when the viewport or element is scrolled, respectively.
        document.documentElement
            ?.addEventListener(eventType, handler, addEventListenerOptions: addEventListenerOptions);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _watchedViewportElements.clear();
  }

  @override
  void removeEventListener(String eventType, EventHandler handler, {bool isCapture = false, bool builtInCallback = false}) {
    super.removeEventListener(eventType, handler, isCapture: isCapture);
    switch (eventType) {
      case EVENT_SCROLL:
        document.documentElement?.removeEventListener(eventType, handler);
        break;
    }
  }

  /// Moves the focus to the window's browsing context, if any.
  /// https://html.spec.whatwg.org/multipage/interaction.html#dom-window-focus
  void focus() {
    // TODO
  }
}
