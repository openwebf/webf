/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';

const String SVG = 'svg';

class FlutterSvgElement extends WidgetElement {
  FlutterSvgElement(super.context);

  FlutterSvgElement? _nearestAncestorSvgRoot() {
    dom.Element? el = parentElement;
    while (el != null) {
      if (el is FlutterSvgElement) return el;
      el = el.parentElement;
    }
    return null;
  }

  void _notifyAncestorSvgToRebuild() {
    final FlutterSvgElement? root = _nearestAncestorSvgRoot();
    if (root == null) return;
    if (root.state != null) {
      root.state!.requestUpdateState();
    } else {
      root.renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    }
  }

  @override
  WebFWidgetElementState createState() => _FlutterSvgElementState(this);

  @override
  Map<String, dynamic> get defaultStyle => const {
        DISPLAY: INLINE_BLOCK,
      };

  @override
  void childrenChanged(dom.ChildrenChange change) {
    super.childrenChanged(change);
    // If this <svg> is nested under another <svg>, notify the ancestor to rebuild.
    _notifyAncestorSvgToRebuild();
  }

  @override
  void setInlineStyle(String property, String value, {String? baseHref}) {
    super.setInlineStyle(property, value, baseHref: baseHref);
    _notifyAncestorSvgToRebuild();
  }

  @override
  void clearInlineStyle() {
    super.clearInlineStyle();
    _notifyAncestorSvgToRebuild();
  }

  @override
  void setAttribute(String key, value) {
    super.setAttribute(key, value);
    _notifyAncestorSvgToRebuild();
  }

  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    _notifyAncestorSvgToRebuild();
  }
}

// SVG child nodes live only for data (not rendered as regular DOM boxes).
// Any change should notify the nearest <svg> ancestor to rebuild the SVG string.
class FlutterSVGChildElement extends dom.Element {
  FlutterSVGChildElement(super.context);

  FlutterSvgElement? _nearestSvgRoot() {
    dom.Element? el = parentElement;
    while (el != null) {
      if (el is FlutterSvgElement) return el;
      el = el.parentElement;
    }
    return null;
  }

  void _notifyRootSvgToRebuild() {
    final FlutterSvgElement? root = _nearestSvgRoot();
    // Prefer going through the widget state to ensure a proper rebuild.
    if (root?.state != null) {
      root!.state!.requestUpdateState();
    } else if (root != null) {
      // Fallback: ask renderStyle pipeline to rebuild.
      root.renderStyle.requestWidgetToRebuild(UpdateChildNodeUpdateReason());
    }
  }

  @override
  void childrenChanged(dom.ChildrenChange change) {
    super.childrenChanged(change);
    _notifyRootSvgToRebuild();
  }

  @override
  void setInlineStyle(String property, String value, {String? baseHref}) {
    super.setInlineStyle(property, value, baseHref: baseHref);
    _notifyRootSvgToRebuild();
  }

  @override
  void clearInlineStyle() {
    super.clearInlineStyle();
    _notifyRootSvgToRebuild();
  }

  @override
  void setAttribute(String key, value) {
    super.setAttribute(key, value);
    _notifyRootSvgToRebuild();
  }

  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    _notifyRootSvgToRebuild();
  }
}

class _FlutterSvgElementState extends WebFWidgetElementState {
  _FlutterSvgElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Respect display:none from CSS.
    if (widgetElement.renderStyle.display == CSSDisplay.none) {
      return const SizedBox.shrink();
    }

    final String rawSvg = _buildSvgString();
    if (rawSvg == null || rawSvg.isEmpty) {
      // Nothing to render yet.
      return const SizedBox.shrink();
    }

    // Resolve width/height for the inner picture:
    // - If CSS width/height are explicitly set, let layout constraints drive sizing.
    // - Otherwise, try to honor root <svg> width/height attributes for intrinsic size.
    final bool cssWidthSet = widgetElement.renderStyle.width.isNotAuto;
    final bool cssHeightSet = widgetElement.renderStyle.height.isNotAuto;

    final double? attrWidthPx = cssWidthSet ? null : _attributeLengthPx(widgetElement, 'width', Axis.horizontal);
    final double? attrHeightPx = cssHeightSet ? null : _attributeLengthPx(widgetElement, 'height', Axis.vertical);

    Widget svg = SvgPicture.string(
      rawSvg,
      allowDrawingOutsideViewBox: true,
      width: attrWidthPx,
      height: attrHeightPx,
      fit: BoxFit.contain,
    );

    // If no explicit dimensions from CSS or attributes and a valid viewBox exists,
    // wrap with AspectRatio so height follows available width.
    if (!cssWidthSet && !cssHeightSet && attrWidthPx == null && attrHeightPx == null) {
      final double? ratio = _parseViewBoxAspectRatio(widgetElement.getAttribute('viewBox'));
      if (ratio != null && ratio > 0) {
        svg = AspectRatio(aspectRatio: ratio, child: svg);
      }
    }

    return svg;
  }

  String _buildSvgString() {
    final dom.Element root = widgetElement;

    if (!root.hasChildren()) return '';

    // Build a full <svg>...</svg> document with namespace.
    final StringBuffer sb = StringBuffer();

    // Collect root attributes (if any) and ensure xmlns is set.
    final Map<String, String> attrs = {};
    attrs.addAll(root.attributes);
    attrs.putIfAbsent('xmlns', () => 'http://www.w3.org/2000/svg');

    sb.write('<svg');
    _writeAttributes(sb, attrs);
    sb.write('>');

    // Serialize descendants.
    for (final dom.Node node in root.childNodes) {
      _serializeNode(sb, node);
    }

    sb.write('</svg>');
    return sb.toString();
  }

  void _serializeNode(StringBuffer sb, dom.Node node) {
    if (node is dom.TextNode) {
      sb.write(_escapeText(node.data));
      return;
    }
    if (node is dom.Element) {
      _serializeElement(sb, node);
      return;
    }
    // Ignore comments / others for now.
  }

  void _serializeElement(StringBuffer sb, dom.Element el) {
    final String tag = el.tagName;
    sb
      ..write('<')
      ..write(tag);

    if (el.attributes.isNotEmpty) {
      _writeAttributes(sb, el.attributes);
    }

    // Children or self-closing.
    if (el.firstChild == null) {
      sb.write('/>');
      return;
    }

    sb.write('>');
    for (final dom.Node child in el.childNodes) {
      _serializeNode(sb, child);
    }
    sb
      ..write('</')
      ..write(tag)
      ..write('>');
  }

  void _writeAttributes(StringBuffer sb, Map<String, String> attributes) {
    attributes.forEach((String key, String value) {
      if (value.isEmpty) {
        sb
          ..write(' ')
          ..write(key);
      } else {
        sb
          ..write(' ')
          ..write(key)
          ..write('="')
          ..write(_escapeAttribute(value))
          ..write('"');
      }
    });
  }

  String _escapeText(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  String _escapeAttribute(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  double? _attributeLengthPx(dom.Element el, String name, [Axis? axis]) {
    final String? v = el.getAttribute(name);
    if (v == null || v.isEmpty) return null;
    final CSSLengthValue parsed = CSSLength.parseLength(v, el.renderStyle, name, axis);
    // Ignore unknown/auto/none for intrinsic sizing purposes.
    if (parsed == CSSLengthValue.unknown ||
        parsed == CSSLengthValue.auto ||
        parsed == CSSLengthValue.none ||
        parsed == CSSLengthValue.initial) {
      return null;
    }
    // computedValue handles px/unit translations.
    final double px = parsed.computedValue;
    if (px.isNaN || !px.isFinite) return null;
    // Avoid zero which can collapse rendering; respect explicit 0 though.
    if (px < 0) return null;
    return px;
  }

  double? _parseViewBoxAspectRatio(String? viewBox) {
    if (viewBox == null) return null;
    final parts = viewBox.trim().split(RegExp(r'\s+'));
    if (parts.length != 4) return null;
    final double? w = double.tryParse(parts[2]);
    final double? h = double.tryParse(parts[3]);
    if (w == null || h == null || h == 0) return null;
    return w / h;
  }
}
