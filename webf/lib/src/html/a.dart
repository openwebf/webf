/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

const String ANCHOR = 'A';
const String _TARGET_SELF = 'self';

class HTMLAnchorElement extends Element {
  HTMLAnchorElement([BindingContext? context]) : super(context) {
    addEventListener(EVENT_CLICK, _handleClick);
  }

  void _handleClick(Event event) {
    String? href = attributes['href'];
    if (href != null && href.isNotEmpty) {
      String baseUrl = ownerDocument.controller.url;
      Uri baseUri = Uri.parse(baseUrl);
      Uri resolvedUri = ownerDocument.controller.uriParser!.resolve(baseUri, Uri.parse(href));
      ownerDocument.controller.view
          .handleNavigationAction(baseUrl, resolvedUri.toString(), _getNavigationType(resolvedUri.scheme));
    }
  }

  WebFNavigationType _getNavigationType(String scheme) {
    switch (scheme.toLowerCase()) {
      case 'http':
      case 'https':
      case 'file':
        if (target.isEmpty || target == _TARGET_SELF) {
          return WebFNavigationType.reload;
        }
    }

    return WebFNavigationType.navigate;
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['href'] = BindingObjectProperty(getter: () => href, setter: (value) => href = castToType<String>(value));
    properties['target'] =
        BindingObjectProperty(getter: () => target, setter: (value) => target = castToType<String>(value));
    properties['rel'] = BindingObjectProperty(getter: () => rel, setter: (value) => rel = castToType<String>(value));
    properties['type'] = BindingObjectProperty(getter: () => type, setter: (value) => type = castToType<String>(value));
    properties['protocol'] =
        BindingObjectProperty(getter: () => protocol, setter: (value) => protocol = castToType<String>(value));
    properties['host'] = BindingObjectProperty(getter: () => host, setter: (value) => host = castToType<String>(value));
    properties['hostname'] =
        BindingObjectProperty(getter: () => hostname, setter: (value) => hostname = castToType<String>(value));
    properties['port'] = BindingObjectProperty(getter: () => port, setter: (value) => port = castToType<String>(value));
    properties['pathname'] =
        BindingObjectProperty(getter: () => pathname, setter: (value) => pathname = castToType<String>(value));
    properties['search'] =
        BindingObjectProperty(getter: () => search, setter: (value) => search = castToType<String>(value));
    properties['hash'] = BindingObjectProperty(getter: () => hash, setter: (value) => hash = castToType<String>(value));
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['href'] =
        ElementAttributeProperty(setter: (value) => href = attributeToProperty<String>(value), getter: () => href);
    attributes['protocol'] = ElementAttributeProperty(
        getter: () => protocol, setter: (value) => protocol = attributeToProperty<String>(value));
    attributes['host'] =
        ElementAttributeProperty(getter: () => host, setter: (value) => host = attributeToProperty<String>(value));
    attributes['hostname'] = ElementAttributeProperty(
        getter: () => hostname, setter: (value) => hostname = attributeToProperty<String>(value));
    attributes['port'] =
        ElementAttributeProperty(getter: () => port, setter: (value) => port = attributeToProperty<String>(value));
    attributes['pathname'] = ElementAttributeProperty(
        getter: () => pathname, setter: (value) => pathname = attributeToProperty<String>(value));
    attributes['port'] =
        ElementAttributeProperty(getter: () => port, setter: (value) => port = attributeToProperty<String>(value));
    attributes['pathname'] = ElementAttributeProperty(
        getter: () => pathname, setter: (value) => pathname = attributeToProperty<String>(value));
    attributes['search'] =
        ElementAttributeProperty(getter: () => search, setter: (value) => search = attributeToProperty<String>(value));
    attributes['hash'] = ElementAttributeProperty(
      getter: () => hash,
      setter: (value) => hash = attributeToProperty<String>(value)
    );
  }

  // Reference: https://www.w3.org/TR/2011/WD-html5-author-20110809/the-a-element.html
  // Supported properties:
  // - href: the address of the hyperlink.
  // - target: Specifies how the content of the open target URL is displayed to the user.
  //           Only used when the href attribute is present.
  // - rel: Specifies the relationship between the current document and the target URL.
  //        Only used when the href attribute is present.
  // - type: The MIME type of the linked document.
  // URL decomposition IDL attributes
  // - attribute DOMString protocol;
  // - attribute DOMString host;
  // - attribute DOMString hostname;
  // - attribute DOMString port;
  // - attribute DOMString pathname;
  // - attribute DOMString search;
  // - attribute DOMString hash;
  // The IDL attribute relList must reflect the rel content attribute.
  String get href => _resolvedHyperlink?.toString() ?? '';

  set href(String value) {
    _resolveHyperlink(value);
    // Set href will not reflect to attribute href.
  }

  String get target => _DOMString(getAttribute('target'));
  set target(String value) {
    internalSetAttribute('target', value);
  }

  String get rel => _DOMString(getAttribute('rel'));
  set rel(String value) {
    internalSetAttribute('rel', value);
  }

  String get type => _DOMString(getAttribute('type'));
  set type(String value) {
    internalSetAttribute('type', value);
  }

  String get protocol => _DOMString(_resolvedHyperlink?.scheme) + ':';
  set protocol(String value) {
    if (_resolvedHyperlink == null) return;

    if (!value.endsWith(':')) {
      value += ':';
      internalSetAttribute('protocol', value);
    }

    // Remove the ending `:`
    String scheme = value.substring(0, value.length - 1);
    _resolvedHyperlink = _resolvedHyperlink!.replace(scheme: scheme);
    _reflectToAttributeHref();
  }

  String get host {
    String? host;
    Uri? resolved = _resolvedHyperlink;
    if (resolved != null) {
      host = resolved.host + ':' + (resolved.hasPort ? resolved.port.toString() : '');
    }
    return _DOMString(host);
  }

  set host(String value) {
    if (_resolvedHyperlink == null) return;
    String host = value;
    String port = this.port;

    // If input host including port.
    if (value.contains(':')) {
      List<String> split = value.split(':');
      host = split[0];
      port = split[1];
    }

    _resolvedHyperlink = _resolvedHyperlink!.replace(host: host, port: int.parse(port));
    _reflectToAttributeHref();
  }

  String get hostname => _DOMString(_resolvedHyperlink?.host);

  set hostname(String value) {
    if (_resolvedHyperlink == null) return;
    _resolvedHyperlink = _resolvedHyperlink!.replace(host: value);
    _reflectToAttributeHref();
  }

  String get port => _DOMString(_resolvedHyperlink?.port.toString());

  set port(String value) {
    if (_resolvedHyperlink == null) return;
    int? port = int.tryParse(value);
    if (port != null) {
      _resolvedHyperlink = _resolvedHyperlink!.replace(port: port);
      _reflectToAttributeHref();
    }
  }

  String get pathname => _DOMString(_resolvedHyperlink?.path);

  set pathname(String value) {
    if (_resolvedHyperlink == null) return;
    _resolvedHyperlink = _resolvedHyperlink!.replace(path: value);
    _reflectToAttributeHref();
  }

  String get search {
    String? search;
    String? query = _resolvedHyperlink?.query;
    if (query != null && query.isNotEmpty) {
      search = '?' + query;
    }
    return _DOMString(search);
  }

  set search(String value) {
    if (_resolvedHyperlink == null) return;
    // Remove starting `?`.
    if (value.startsWith('?')) {
      value = value.substring(1);
    }

    _resolvedHyperlink = _resolvedHyperlink!.replace(query: value);
    _reflectToAttributeHref();
  }

  String get hash => _DOMString(_resolvedHyperlink?.fragment);

  set hash(String value) {
    if (_resolvedHyperlink == null) return;
    _resolvedHyperlink = _resolvedHyperlink!.replace(fragment: value);
    _reflectToAttributeHref();
  }

  // Web IDL attributes must return DOMString, it's a non-null value.
  String _DOMString(String? input) {
    return input ?? '';
  }

  Uri? _resolvedHyperlink;

  // Resolve the href into uri entity, for convenience of URL decomposition IDL attributes to get value.
  void _resolveHyperlink(String href) {
    String base = ownerDocument.controller.url;
    try {
      _resolvedHyperlink = ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(href));
    } catch (_) {
      // Ignoring the failure of resolving, but to remove the resolved hyperlink.
      _resolvedHyperlink = null;
    }
  }

  // If URL decomposition IDL attributes changed, we should sync href attribute to changed value.
  void _reflectToAttributeHref() {
    if (_resolvedHyperlink != null) {
      internalSetAttribute('href', _resolvedHyperlink.toString());
    }
  }
}
