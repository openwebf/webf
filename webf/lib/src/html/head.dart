/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:io';

import 'package:flutter/scheduler.dart';
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

const String REL_STYLESHEET = 'stylesheet';
const String DNS_PREFETCH = 'dns-prefetch';

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
        setter: (element, value) => castToType<LinkElement>(element).media = castToType<String>(value))
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
    _process();
  }

  String get type => getAttribute('type') ?? '';

  set type(String value) {
    internalSetAttribute('type', value);
  }

  String get media => getAttribute('media') ?? '';

  set media(String value) {
    internalSetAttribute('media', value);
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

    if (_styleSheet != null) {
      _styleSheet!.replaceSync(_cachedStyleSheetText!,
          windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
    } else {
      _styleSheet = CSSParser(_cachedStyleSheetText!)
          .parse(windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
    }
    if (_styleSheet != null) {
      ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
      ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
      ownerDocument.updateStyleIfNeeded();
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

        if (enableWebFProfileTracking) {
          WebFProfiler.instance.startTrackUICommand();
          WebFProfiler.instance.startTrackUICommandStep('Style.parseCSS');
        }

        _styleSheet = CSSParser(cssString, href: href).parse(
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
        _styleSheet?.href = href;

        if (enableWebFProfileTracking) {
          WebFProfiler.instance.finishTrackUICommandStep();
        }

        ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        ownerDocument.updateStyleIfNeeded();

        if (enableWebFProfileTracking) {
          WebFProfiler.instance.finishTrackUICommand();
        }

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
      _fetchAndApplyCSSStyle();
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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackUICommandStep('$this.parseInlineStyle');
    }
    String? text = collectElementChildText();
    if (text != null) {
      if (_styleSheet != null) {
        _styleSheet!.replaceSync(text,
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
      } else {
        _styleSheet = CSSParser(text).parse(
            windowWidth: windowWidth, windowHeight: windowHeight, isDarkMode: ownerView.rootController.isDarkMode);
      }
      if (_styleSheet != null) {
        ownerDocument.markElementStyleDirty(ownerDocument.documentElement!);
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        ownerDocument.updateStyleIfNeeded();
      }
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
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
    super.disconnectedCallback();
  }
}

// https://www.w3.org/TR/2011/WD-html5-author-20110809/the-style-element.html
class StyleElement extends Element with StyleElementMixin {
  StyleElement([BindingContext? context]) : super(context);
}
