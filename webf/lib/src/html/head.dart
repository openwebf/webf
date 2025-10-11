/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

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
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] @import flattened into sheet href=' + (sheet.href?.toString() ?? 'inline') +
              '; marking sheet pending for update');
        }
        document.styleNodeManager.appendPendingStyleSheet(sheet);
        // Mark style dirty and trigger update after resolution
        document.markElementStyleDirty(document.documentElement!);
        document.updateStyleIfNeeded();
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
    if (kDebugMode && DebugFlags.enableCssLogs) {
      debugPrint('[webf][style] <link rel=stylesheet> reloadStyle href=' + (_resolvedHyperlink?.toString() ?? href));
    }
    if (_cachedStyleSheetText == null) {
      _fetchAndApplyCSSStyle();
      return;
    }

    if (_styleSheet != null) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][style] <link> replaceSync (darkMode=' + ownerView.rootController.isDarkMode.toString() + ')');
      }
      // Ensure the stylesheet carries an absolute href for correct URL resolution
      if (_resolvedHyperlink != null) {
        _styleSheet!.href = _resolvedHyperlink.toString();
      } else if (href != null) {
        _styleSheet!.href = href;
      }
      _styleSheet!.replaceSync(_cachedStyleSheetText!,
          windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
    } else {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][style] <link> parse (darkMode=' + ownerView.rootController.isDarkMode.toString() + ')');
      }
      final String? sheetHref = _resolvedHyperlink?.toString() ?? href;
      _styleSheet = CSSParser(_cachedStyleSheetText!, href: sheetHref)
          .parse(windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
      _styleSheet?.href = sheetHref;
    }
    if (_styleSheet != null) {
      ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
      ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
      ownerDocument.updateStyleIfNeeded();
      // Re-resolve @import for reloaded stylesheet
      () async {
        if (_styleSheet != null) {
          await _resolveCSSImports(ownerDocument, _styleSheet!);
          ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
          ownerDocument.updateStyleIfNeeded();
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
    if (_styleSheet != null) {
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
        if (kDebugMode && DebugFlags.enableCssLogs) {
          debugPrint('[webf][style] <link> fetched href=' + href + ' len=' + cssString.length.toString());
        }

        if (kDebugMode && DebugFlags.enableCssLogs) {
          debugPrint('[webf][style] <link> parse (darkMode=' + ownerView.rootController.isDarkMode.toString() + ')');
        }
        final String? sheetHref = _resolvedHyperlink?.toString() ?? href;
        _styleSheet = CSSParser(cssString, href: sheetHref).parse(
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
        _styleSheet?.href = sheetHref;

        // Resolve and inline any @import rules before applying
        await _resolveCSSImports(ownerDocument, _styleSheet!);
        // Ensure style manager re-indexes rules after imports
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);

        ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        ownerDocument.updateStyleIfNeeded();

        // Successful load.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_LOAD));
        });
      } catch (e) {
        // An error occurred.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          dispatchEvent(Event(EVENT_ERROR));
        });
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
    ownerDocument.styleNodeManager.addStyleSheetCandidateNode(this);

    if (_resolvedHyperlink != null) {
      if (rel == REL_PRELOAD) {
        _handlePreload();
      } else if (rel == REL_STYLESHEET) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] <link> connected: fetch+apply href=' + (_resolvedHyperlink?.toString() ?? href));
        }
        _fetchAndApplyCSSStyle();
      }
    }
  }

  @override
  void disconnectedCallback() {
    super.disconnectedCallback();
    if (_styleSheet != null) {
      ownerDocument.styleNodeManager.removePendingStyleSheet(_styleSheet!);
    }
    ownerDocument.styleNodeManager.removeStyleSheetCandidateNode(this);
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

  void _recalculateStyle() {
    String? text = collectElementChildText();

    // TODO(CGQAQ): Dispatch an event to notify C++ blink side to recalculate style if we are in Blink css mode.
    // Question1: How to know if we are in Blink css mode?
    // Question2: Pass the text to C++ blink side through UICommand? Do we already have the style text on c++ side?
    // Question3: Animation timeline should send a command to c++ side to recalculate style or we just do it in dart side?

    if (text != null) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] <style> recalc begin (len=${text.length}, connected=$isConnected, tracked=${ownerDocument.styleNodeManager.styleSheetCandidateNodes.contains(this)})');
      }
      if (_styleSheet != null) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] <style> replaceSync (len=' + text.length.toString() + ', darkMode=' + (ownerView.rootController.isDarkMode?.toString() ?? 'null') + ')');
        }
        _styleSheet!.replaceSync(text,
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
      } else {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] <style> parse (len=' + text.length.toString() + ', darkMode=' + (ownerView.rootController.isDarkMode?.toString() ?? 'null') + ')');
        }
        _styleSheet = CSSParser(text).parse(
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
        // Resolve @import in the parsed inline stylesheet asynchronously
        () async {
          if (_styleSheet != null) {
            await _resolveCSSImports(ownerDocument, _styleSheet!);
            // Mark sheet pending so changes are picked up without candidate changes
            ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
            ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
            ownerDocument.updateStyleIfNeeded();
          }
        }();
      }
      if (_styleSheet != null) {
        ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        ownerDocument.updateStyleIfNeeded();
      }
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
      if (_styleSheet == null) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] <style> connected -> recalc');
        }
        _recalculateStyle();
      }
      ownerDocument.styleNodeManager.addStyleSheetCandidateNode(this);
    }
  }

  @override
  void disconnectedCallback() {
    if (_styleSheet != null) {
      ownerDocument.styleNodeManager.removePendingStyleSheet(_styleSheet!);
      ownerDocument.styleNodeManager.removeStyleSheetCandidateNode(this);
    }
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] <style> disconnected');
    }
    super.disconnectedCallback();
  }
}

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-style-element.html
class StyleElement extends Element with StyleElementMixin {
  StyleElement([BindingContext? context]) : super(context);
}
