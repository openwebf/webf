/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

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

const String _REL_STYLESHEET = 'stylesheet';

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
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['disabled'] =
        BindingObjectProperty(getter: () => disabled, setter: (value) => disabled = castToType<bool>(value));
    properties['rel'] = BindingObjectProperty(getter: () => rel, setter: (value) => rel = castToType<String>(value));
    properties['href'] = BindingObjectProperty(getter: () => href, setter: (value) => href = castToType<String>(value));
    properties['type'] = BindingObjectProperty(getter: () => type, setter: (value) => type = castToType<String>(value));
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

  void _resolveHyperlink() {
    String? href = getAttribute('href');
    if (href != null) {
      String base = ownerDocument.controller.url;
      try {
        _resolvedHyperlink = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(href));
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
    Future.microtask(() {
      _fetchAndApplyCSSStyle();
    });
  }

  void _fetchAndApplyCSSStyle() async {
    if (_resolvedHyperlink != null &&
        rel == _REL_STYLESHEET &&
        isConnected &&
        !_stylesheetLoaded.containsKey(_resolvedHyperlink.toString())) {
      String url = _resolvedHyperlink.toString();
      WebFBundle bundle = ownerDocument.controller.getPreloadBundleFromUrl(url) ?? WebFBundle.fromUrl(url);
      _stylesheetLoaded[url] = true;
      try {
        _loading = true;
        // Increment count when request.
        ownerDocument.incrementRequestCount();

        await bundle.resolve(baseUrl: ownerDocument.controller.url, uriParser: ownerDocument.controller.uriParser);
        await bundle.obtainData();
        assert(bundle.isResolved, 'Failed to obtain $url');
        _loading = false;
        // Decrement count when response.
        ownerDocument.decrementRequestCount();

        final String cssString = await resolveStringFromData(bundle.data!);
        _styleSheet = CSSParser(cssString, href: href).parse();
        _styleSheet?.href = href;
        ownerDocument.styleDirtyElements.add(ownerDocument.documentElement!);
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
      }
      SchedulerBinding.instance.scheduleFrame();
    }
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
    properties['type'] = BindingObjectProperty(
        getter: () => type,
        setter: (value) => type = castToType<String>(value));
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['type'] = ElementAttributeProperty(
        setter: (value) => type = attributeToProperty<String>(value));
  }

  void _recalculateStyle() {
    String? text = collectElementChildText();
    if (text != null) {
      if (_styleSheet != null) {
        _styleSheet!.replace(text);
      } else {
        _styleSheet = CSSParser(text).parse();
      }
      if (_styleSheet != null) {
        ownerDocument.styleDirtyElements.add(ownerDocument.documentElement!);
        ownerDocument.styleNodeManager.appendPendingStyleSheet(_styleSheet!);
        ownerDocument.updateStyleIfNeeded();
      }
    }
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
