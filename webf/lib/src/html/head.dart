/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';
import 'package:ffi/ffi.dart';

// FFI callback for native method result
void _handleParseStyleSheetResult(Object handle, Pointer<NativeValue> result) {
  final _ParseStyleSheetContext ctx = handle as _ParseStyleSheetContext;
  // Free allocated native resources
  malloc.free(ctx.method);
  malloc.free(ctx.argv);
  malloc.free(result);
  // Complete the operation
  ctx.completer.complete();
}

class _ParseStyleSheetContext {
  _ParseStyleSheetContext(this.completer, this.method, this.argv);
  final Completer<void> completer;
  final Pointer<NativeValue> method;
  final Pointer<NativeValue> argv;
}

// Children of the <head> element all have display:none
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: NONE,
};

const String HEAD = 'HEAD';
const String LINK = 'LINK';
const String META = 'META';
const String TITLE = 'TITLE';
const String STYLE = 'STYLE';
const String NOSCRIPT = 'NOSCRIPT';
const String SCRIPT = 'SCRIPT';

class HeadElement extends Element {
  HeadElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  @override
  void childrenChanged(ChildrenChange change) {
    // Coalesce stylesheet-related updates when batching is enabled.
    if (DebugFlags.enableCssBatchStyleUpdates) {
      final Node? node = change.siblingChanged;
      final bool isStyleNode = node is StyleElementMixin || node is LinkElement;
      final bool isStyleText = change.type == ChildrenChangeType.TEXT_CHANGE &&
          node != null && node.parentNode is StyleElementMixin;
      if (isStyleNode || isStyleText || change.isChildElementChange()) {
        if (DebugFlags.enableCssMultiStyleTrace) {
          cssLogger.info('[trace][multi-style][head] childrenChanged type=${change.type} scheduling style update');
        }
        ownerDocument.scheduleStyleUpdate();
        return;
      }
    }
    super.childrenChanged(change);
  }
}

// Resolve @import rules within a stylesheet by fetching and inlining imported rules.
Future<void> _resolveCSSImports(Document document, CSSStyleSheet sheet) async {
  // Determine environment for parsing imported sheets
  double windowWidth = document.viewport?.viewportSize.width ?? document.preloadViewportSize?.width ?? -1;
  double windowHeight = document.viewport?.viewportSize.height ?? document.preloadViewportSize?.height ?? -1;
  bool isDarkMode = document.controller.view.rootController.isDarkMode ?? false;

  // Base URL to resolve relative imports
  String base = sheet.href ?? document.controller.url;

  // Walk through rules and inline imported sheets
  int i = 0;
  while (i < sheet.cssRules.length) {
    final rule = sheet.cssRules[i];
    if (rule is CSSImportRule) {
      String href = rule.href.trim();
      if (href.isEmpty) {
        // Remove empty @import to avoid infinite loops
        sheet.cssRules.removeAt(i);
        continue;
      }

      // Resolve URL relative to stylesheet/document
      Uri resolved = document.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(href));

      // Load CSS text
      WebFBundle bundle = document.controller.getPreloadBundleFromUrl(resolved.toString()) ?? WebFBundle.fromUrl(resolved.toString());
      try {
        // Track network activity
        document.incrementRequestCount();
        await bundle.resolve(baseUrl: document.controller.url, uriParser: document.controller.uriParser);
        await bundle.obtainData(document.ownerView.contextId);

        final String cssText = await resolveStringFromData(bundle.data!);

        // Parse imported sheet with its own href so url() inside resolves correctly
        CSSStyleSheet imported = CSSParser(cssText, href: resolved.toString())
            .parse(windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: isDarkMode);
        imported.href = resolved.toString();

        // Recursively resolve nested imports
        await _resolveCSSImports(document, imported);

        // Replace @import with imported rules (flatten)
        sheet.cssRules.removeAt(i);
        if (imported.cssRules.isNotEmpty) {
          sheet.cssRules.insertAll(i, imported.cssRules);
          i += imported.cssRules.length;
        }

        // Mark this stylesheet as pending so StyleNodeManager will re-index
        // even if the candidate set is unchanged. This ensures newly inlined
        // @import rules take effect.

        document.styleNodeManager.appendPendingStyleSheet(sheet);
        // Trigger a style update; flushStyle() will update active sheets first
        // and mark only impacted elements dirty.
        if (DebugFlags.enableCssBatchStyleUpdates) {
          document.scheduleStyleUpdate();
        } else {
          document.updateStyleIfNeeded();
        }
      } catch (e) {
        // On failure, drop the import to avoid blocking style application
        sheet.cssRules.removeAt(i);
      } finally {
        document.decrementRequestCount();
        bundle.dispose();
      }
    } else {
      i++;
    }
  }
}

const String REL_STYLESHEET = 'stylesheet';
const String DNS_PREFETCH = 'dns-prefetch';
const String REL_PRELOAD = 'preload';

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-link-element.html#the-link-element
class LinkElement extends Element {
  LinkElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  CSSStyleSheet? get styleSheet => _styleSheet;
  CSSStyleSheet? _styleSheet;

  bool _loading = false;

  bool get loading => _loading;

  Uri? _resolvedHyperlink;
  final Map<String, bool> _stylesheetLoaded = {};

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['disabled'] = ElementAttributeProperty(setter: (value) => disabled = attributeToProperty<bool>(value));
    attributes['rel'] = ElementAttributeProperty(setter: (value) => rel = attributeToProperty<String>(value));
    attributes['href'] = ElementAttributeProperty(setter: (value) => href = attributeToProperty<String>(value));
    attributes['type'] = ElementAttributeProperty(setter: (value) => type = attributeToProperty<String>(value));
    attributes['media'] = ElementAttributeProperty(setter: (value) => media = attributeToProperty<String>(value));
    attributes['as'] = ElementAttributeProperty(setter: (value) => as = attributeToProperty<String>(value));
  }

  static final StaticDefinedBindingPropertyMap _linkElementProperties = {
    'disabled': StaticDefinedBindingProperty(
        getter: (element) => castToType<LinkElement>(element).disabled,
        setter: (element, value) => castToType<LinkElement>(element).disabled = castToType<bool>(value)),
    'rel': StaticDefinedBindingProperty(
        getter: (element) => castToType<LinkElement>(element).rel,
        setter: (element, value) => castToType<LinkElement>(element).rel = castToType<String>(value)),
    'href': StaticDefinedBindingProperty(
        getter: (element) => castToType<LinkElement>(element).href,
        setter: (element, value) => castToType<LinkElement>(element).href = castToType<String>(value)),
    'type': StaticDefinedBindingProperty(
        getter: (element) => castToType<LinkElement>(element).type,
        setter: (element, value) => castToType<LinkElement>(element).type = castToType<String>(value)),
    'media': StaticDefinedBindingProperty(
        getter: (element) => castToType<LinkElement>(element).media,
        setter: (element, value) => castToType<LinkElement>(element).media = castToType<String>(value)),
    'as': StaticDefinedBindingProperty(
        getter: (element) => castToType<LinkElement>(element).as,
        setter: (element, value) => castToType<LinkElement>(element).as = castToType<String>(value))
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _linkElementProperties];

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
  }

  bool get disabled => getAttribute('disabled') != null;

  set disabled(bool value) {
    if (value) {
      internalSetAttribute('disabled', '');
    } else {
      removeAttribute('disabled');
    }
  }

  String get href => _resolvedHyperlink?.toString() ?? '';

  set href(String value) {
    internalSetAttribute('href', value);
    _resolveHyperlink();
    _process();
  }

  String get rel => getAttribute('rel') ?? '';

  set rel(String value) {
    internalSetAttribute('rel', value);
    if (value == REL_PRELOAD) {
      _handlePreload();
    } else {
      _process();
    }
  }

  String get type => getAttribute('type') ?? '';

  set type(String value) {
    internalSetAttribute('type', value);
  }

  String get media => getAttribute('media') ?? '';

  set media(String value) {
    internalSetAttribute('media', value);
  }

  String get as => getAttribute('as') ?? 'image';

  set as(String value) {
    internalSetAttribute('as', value);
    if (rel == REL_PRELOAD) {
      _handlePreload();
    }
  }

  void fetchAndApplyCSSStyle() {
    Future.microtask(() {
      _fetchAndApplyCSSStyle();
    });
  }

  String? _cachedStyleSheetText;

  void reloadStyle() {
    if (_cachedStyleSheetText == null) {
      _fetchAndApplyCSSStyle();
      return;
    }

    // When Blink CSS is enabled, send stylesheet text to native side.
    if (ownerView.enableBlink == true) {
      _sendStyleSheetToNative(_cachedStyleSheetText!, href: href);
      return;
    }

    if (_styleSheet != null) {
      // Ensure the stylesheet carries an absolute href for correct URL resolution
      if (_resolvedHyperlink != null) {
        _styleSheet!.href = _resolvedHyperlink.toString();
      } else if (href != null) {
        _styleSheet!.href = href;
      }
      _styleSheet!.replaceSync(_cachedStyleSheetText!,
          windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
    } else {
      final String? sheetHref = _resolvedHyperlink?.toString() ?? href;
      _styleSheet = CSSParser(_cachedStyleSheetText!, href: sheetHref)
          .parse(windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
      _styleSheet?.href = sheetHref;
    }
      if (_styleSheet != null) {
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        if (DebugFlags.enableCssBatchStyleUpdates) {
          ownerDocument.scheduleStyleUpdate();
        } else {
          ownerDocument.updateStyleIfNeeded();
        }
        // Re-resolve @import for reloaded stylesheet
        () async {
          if (_styleSheet != null) {
            await _resolveCSSImports(ownerDocument, _styleSheet!);
          if (DebugFlags.enableCssBatchStyleUpdates) {
            ownerDocument.scheduleStyleUpdate();
          } else {
            ownerDocument.updateStyleIfNeeded();
          }
          }
        }();
      }
  }

  Future<void> _resolveHyperlink() async {
    String? href = getAttribute('href');
    String? rel = getAttribute('rel');
    if (href != null) {
      String base = ownerDocument.controller.url;
      try {
        Uri hrefUri = Uri.parse(href);
        if (rel != null && rel == DNS_PREFETCH) {
          await InternetAddress.lookup(hrefUri.host);
        }

        _resolvedHyperlink = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), hrefUri);
      } catch (_) {
        // Ignoring the failure of resolving, but to remove the resolved hyperlink.
        _resolvedHyperlink = null;
      }
    }
  }

  void _process() {
    if (_resolvedHyperlink != null && _stylesheetLoaded.containsKey(_resolvedHyperlink.toString())) {
      return;
    }
    if (_resolvedHyperlink != null) {
      _stylesheetLoaded.remove(_resolvedHyperlink.toString());
    }
    if (!ownerView.enableBlink && _styleSheet != null) {
      ownerDocument.styleNodeManager.removePendingStyleSheet(_styleSheet!);
    }
    fetchAndApplyCSSStyle();
  }

  void _handlePreload() async {
    if (_resolvedHyperlink == null) {
      await _resolveHyperlink();
    }

    if (_resolvedHyperlink == null || !isConnected) {
      return;
    }

    String url = _resolvedHyperlink.toString();
    String asType = as.toLowerCase();

    // Only handle image preloading for now
    if (asType != 'image') {
      return;
    }

    // Don't preload if already preloaded
    if (ownerDocument.controller.getPreloadBundleFromUrl(url) != null) {
      return;
    }

    try {
      // Increment count when request
      ownerDocument.incrementRequestCount();

      // Create a WebFBundle for the resource
      WebFBundle bundle = WebFBundle.fromUrl(url);

      await bundle.resolve(baseUrl: ownerDocument.controller.url, uriParser: ownerDocument.controller.uriParser);
      await bundle.obtainData(ownerView.contextId);

      // Add the preloaded bundle to the controller
      _addBundleToPreloadedBundles(bundle);

      // Decrement count when response
      ownerDocument.decrementRequestCount();
    } catch (e) {
    }
  }

  bool isCSSStyleSheetLoaded() {
    return _stylesheetLoaded.containsKey(_resolvedHyperlink.toString());
  }

  void _fetchAndApplyCSSStyle() async {
    if (_resolvedHyperlink != null &&
        rel == REL_STYLESHEET &&
        isConnected && !_stylesheetLoaded.containsKey(_resolvedHyperlink.toString())) {
      if (!isValidMedia(media)) {
        return;
      }

      // Increase the pending count for preloading resources.
      if (ownerDocument.controller.preloadStatus != PreloadingStatus.none) {
        ownerDocument.controller.unfinishedPreloadResources++;
      }

      String url = _resolvedHyperlink.toString();
      WebFBundle bundle = ownerDocument.controller.getPreloadBundleFromUrl(url) ?? WebFBundle.fromUrl(url);
      _stylesheetLoaded[url] = true;
      try {
        _loading = true;
        // Increment count when request.
        ownerDocument.incrementRequestCount();

        await bundle.resolve(baseUrl: ownerDocument.controller.url, uriParser: ownerDocument.controller.uriParser);
        await bundle.obtainData(ownerView.contextId);
        assert(bundle.isResolved, 'Failed to obtain $url');
        _loading = false;
        // Decrement count when response.
        ownerDocument.decrementRequestCount();

        final String cssString = _cachedStyleSheetText = await resolveStringFromData(bundle.data!);



        final String? sheetHref = _resolvedHyperlink?.toString() ?? href;
        _styleSheet = CSSParser(cssString, href: sheetHref).parse(
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
        _styleSheet?.href = sheetHref;
        // If Blink CSS stack is enabled, forward stylesheet to native; otherwise parse in Dart.
        if (ownerView.enableBlink) {
          await _sendStyleSheetToNative(cssString, href: href);
        } else {
          final String? sheetHref = _resolvedHyperlink?.toString() ?? href;
          _styleSheet = CSSParser(cssString, href: sheetHref).parse(
              windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
          _styleSheet?.href = sheetHref;

          // Resolve and inline any @import rules before applying
          await _resolveCSSImports(ownerDocument, _styleSheet!);
          // Ensure style manager re-indexes rules after imports
          ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
          if (DebugFlags.enableCssBatchStyleUpdates) {
            ownerDocument.scheduleStyleUpdate();
          } else {
            ownerDocument.updateStyleIfNeeded();
          }

          // Successful load.
          SchedulerBinding.instance.addPostFrameCallback((_) {
            dispatchEvent(Event(EVENT_LOAD));
          });
          // Resolve and inline any @import rules before applying
          await _resolveCSSImports(ownerDocument, _styleSheet!);
          // Ensure style manager re-indexes rules after imports
          ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);

          ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
          ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
          ownerDocument.updateStyleIfNeeded();
        }

        // Successful load: In Blink mode, C++ dispatches 'load'. Avoid double-dispatch here.
        if (!ownerView.enableBlink) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            dispatchEvent(Event(EVENT_LOAD));
          });
        }
      } catch (e) {
        // Error: In Blink mode, dispatch on C++ side only.
        if (!ownerView.enableBlink) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            dispatchEvent(Event(EVENT_ERROR));
          });
        }
      } finally {
        bundle.dispose();

        if (ownerDocument.controller.preloadStatus != PreloadingStatus.done) {
          ownerDocument.controller.unfinishedPreloadResources--;
          ownerDocument.controller.checkPreloadCompleted();
        }
      }
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  double get windowWidth {
    return ownerDocument.viewport?.viewportSize.width ?? ownerDocument.preloadViewportSize?.width ?? -1;
  }

  double get windowHeight {
    return ownerDocument.viewport?.viewportSize.height ?? ownerDocument.preloadViewportSize?.height ?? -1;
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    if (!ownerView.enableBlink) {
      ownerDocument.styleNodeManager.addStyleSheetCandidateNode(this);
    }

    if (_resolvedHyperlink != null) {
      if (rel == REL_PRELOAD) {
        _handlePreload();
      } else if (rel == REL_STYLESHEET) {

        _fetchAndApplyCSSStyle();
      }
    }
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    if (!ownerView.enableBlink) {
      if (_styleSheet != null) {
        ownerDocument.styleNodeManager.removePendingStyleSheet(_styleSheet!);
      }
      ownerDocument.styleNodeManager.removeStyleSheetCandidateNode(this);
    }
  }

  Future<void> _sendStyleSheetToNative(String cssText, {String? href}) async {
    // Ensure we have a native binding object to call.
    final pointer = this.pointer;
    if (pointer == null || isBindingObjectDisposed(pointer) || pointer.ref.invokeBindingMethodFromDart == nullptr) {
      return;
    }

    final completer = Completer<void>();
    final bindingObject = this as BindingObject;

    // Prepare method name and arguments
    final Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, 'parseAuthorStyleSheet');
    final Pointer<NativeValue> argv = makeNativeValueArguments(bindingObject, <dynamic>[cssText, href ?? '']);

    final ctx = _ParseStyleSheetContext(completer, method, argv);
    final callback = Pointer.fromFunction<NativeInvokeResultCallback>(_handleParseStyleSheetResult);

    // Invoke native method asynchronously
    final f = pointer.ref.invokeBindingMethodFromDart.asFunction<DartInvokeBindingMethodsFromDart>();
    Future.microtask(() {
      f(pointer, ownerView.contextId, method, 2, argv, ctx, callback);
    });

    await completer.future;
  }

  //https://www.w3schools.com/cssref/css3_pr_mediaquery.php
  //https://www.w3school.com.cn/cssref/pr_mediaquery.asp
  Map<String, bool> mediaMap = {};

  bool isValidMedia(String media) {
    bool isValid = true;
    if (media.isEmpty) {
      return isValid;
    }
    if (mediaMap.containsKey(media)) {
      return mediaMap[media] ?? isValid;
    }
    media = media.toLowerCase();
    String mediaType = '';
    String lastOperator = '';
    Map<String, String> andMap = {};
    Map<String, String> notMap = {};
    Map<String, String> onlyMap = {};
    int startIndex = 0;
    int conditionStartIndex = 0;
    for (int index = 0; index < media.length; index++) {
      int code = media.codeUnitAt(index);
      if (code == TokenChar.LPAREN) {
        conditionStartIndex = index;
      } else if (conditionStartIndex > 0) {
        if (code == TokenChar.RPAREN) {
          String condition = media.substring(conditionStartIndex + 1, index).replaceAll(' ', '');
          List<String> cp = condition.split(':');
          if (lastOperator == MediaOperator.AND) {
            andMap[cp[0]] = cp[1];
          } else if (lastOperator == MediaOperator.ONLY) {
            onlyMap[cp[0]] = cp[1];
          } else if (lastOperator == MediaOperator.NOT) {
            notMap[cp[0]] = cp[1];
          }
          startIndex = index;
          conditionStartIndex = -1;
        }
      } else if (code == TokenChar.SPACE) {
        String key = media.substring(startIndex, index).replaceAll(' ', '');
        startIndex = index;
        if (key == MediaType.ALL || key == MediaType.SCREEN) {
          mediaType = key;
        } else if (key == MediaOperator.AND || key == MediaOperator.NOT || key == MediaOperator.ONLY) {
          lastOperator = key;
        }
      }
    }
    // mediaType:screen, lastOperator:and, andMap {max-width: 300px}, onlyMap {}, notMap {}
    if (mediaType == MediaType.ALL || mediaType == MediaType.SCREEN) {
      double maxWidthValue = CSSLength.parseLength(andMap['max-width'] ?? '0px', null).value ?? -1;
      double minWidthValue = CSSLength.parseLength(andMap['min-width'] ?? '0px', null).value ?? -1;
      if (maxWidthValue < windowWidth || minWidthValue > windowWidth) {
        isValid = false;
      }
    }
    mediaMap[media] = isValid;
    return isValid;
  }

  void _addBundleToPreloadedBundles(WebFBundle bundle) {
    WebFController controller = ownerDocument.controller;
    controller.addPreloadedBundle(bundle);
  }

  @override
  void dispose() {
    super.dispose();
    _cachedStyleSheetText = null;
  }
}

class MetaElement extends Element {
  MetaElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class TitleElement extends Element {
  TitleElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class NoScriptElement extends Element {
  NoScriptElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

const String _CSS_MIME = 'text/css';

mixin StyleElementMixin on Element {
  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  String _type = _CSS_MIME;

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  CSSStyleSheet? _styleSheet;

  CSSStyleSheet? get styleSheet => _styleSheet;

  // Cache signature of the last parsed stylesheet so we can skip redundant
  // replaceSync()/appendPendingStyleSheet cycles when neither the inline CSS
  // text nor the evaluation context (viewport size / dark mode) has changed.
  int? _lastStyleSheetSignature;

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['type'] = BindingObjectProperty(getter: () => type, setter: (value) => type = castToType<String>(value));
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['type'] = ElementAttributeProperty(setter: (value) => type = attributeToProperty<String>(value));
  }

  void reloadStyle() {
    _recalculateStyle();
  }

  @override
  void childrenChanged(ChildrenChange change) {
    // Text changes within <style> often occur as incremental DOM operations.
    // When batching is enabled, defer style updates to the scheduler.
    if (DebugFlags.enableCssBatchStyleUpdates) {
      if (DebugFlags.enableCssMultiStyleTrace) {
        cssLogger.info('[trace][multi-style][style] childrenChanged type=${change.type} scheduling style update');
      }
      ownerDocument.scheduleStyleUpdate();
      return;
    }
    super.childrenChanged(change);
  }

  void _recalculateStyle() {
    // When Blink CSS is enabled, let native side handle inline <style> processing.
    if (ownerView.enableBlink == true) {
      return;
    }

    String? text = collectElementChildText();

    if (text != null) {
      // Inline stylesheet parsing depends on the raw CSS text plus runtime
      // context (viewport size + dark mode). If none of these inputs changed,
      // we can skip scheduling another stylesheet update entirely.
      final bool? darkMode = ownerView.rootController.isDarkMode;
      final double w = windowWidth;
      final double h = windowHeight;
      final int newSignature = Object.hash(text, w, h, darkMode);

      if (_styleSheet != null && _lastStyleSheetSignature == newSignature) {

        return;
      }


      if (_styleSheet != null) {

        _styleSheet!.replaceSync(text,
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
      } else {

        _styleSheet = CSSParser(text).parse(
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
        // Resolve @import in the parsed inline stylesheet asynchronously
        () async {
          if (_styleSheet != null) {
            await _resolveCSSImports(ownerDocument, _styleSheet!);
            // Mark sheet pending so changes are picked up without candidate changes
            ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
            if (DebugFlags.enableCssBatchStyleUpdates) {
              ownerDocument.scheduleStyleUpdate();
            } else {
              ownerDocument.updateStyleIfNeeded();
            }
          }
        }();
      }

      _lastStyleSheetSignature = newSignature;
      if (_styleSheet != null) {
        if (DebugFlags.enableCssMultiStyleTrace) {
          final parentTag = parentElement?.tagName ?? 'UNKNOWN';
          cssLogger.info('[trace][multi-style][style] apply sheet (parent=$parentTag)');
        }
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        if (DebugFlags.enableCssBatchStyleUpdates) {
          ownerDocument.scheduleStyleUpdate();
        } else {
          ownerDocument.updateStyleIfNeeded();
        }
      }
    } else {
      // No inline CSS text → drop the cache so future additions re-parse.
      _lastStyleSheetSignature = null;
    }
  }

  double get windowWidth {
    return ownerDocument.preloadViewportSize?.width ?? ownerDocument.viewport?.viewportSize.width ?? -1;
  }

  double get windowHeight {
    return ownerDocument.preloadViewportSize?.height ?? ownerDocument.viewport?.viewportSize.height ?? -1;
  }

  @override
  Node appendChild(Node child) {
    Node ret = super.appendChild(child);
    _recalculateStyle();
    return ret;
  }

  @override
  Node insertBefore(Node child, Node referenceNode) {
    Node ret = super.insertBefore(child, referenceNode);
    _recalculateStyle();
    return ret;
  }

  @override
  Node removeChild(Node child) {
    Node ret = super.removeChild(child);
    _recalculateStyle();
    return ret;
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    if (_type == _CSS_MIME) {
      if (ownerView.enableBlink) {
        // Native side will process inline styles via lifecycle hooks.
        return;
      }
      if (_styleSheet == null) {
        _recalculateStyle();
      }
      ownerDocument.styleNodeManager.addStyleSheetCandidateNode(this);
    }
  }

  @override
  void disconnectedCallback() {
    if (!ownerView.enableBlink) {
      if (_styleSheet != null) {
        ownerDocument.styleNodeManager.removePendingStyleSheet(_styleSheet!);
        ownerDocument.styleNodeManager.removeStyleSheetCandidateNode(this);
      }
    }
    super.disconnectedCallback();
  }
}

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-style-element.html
class StyleElement extends Element with StyleElementMixin {
  StyleElement([BindingContext? context]) : super(context);
}
