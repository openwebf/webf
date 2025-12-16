/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

import 'dart:ffi';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';

const int INLINED_STYLESHEET_ID = 1;
const String ZERO_PX = '0px';

class InspectCSSModule extends UIInspectorModule {
  DebuggingContext? get dbgContext => devtoolsService.context;

  Document? get document => dbgContext?.document ?? devtoolsService.controller?.view.document;

  InspectCSSModule(super.devtoolsService);

  // Tracking support for CSS.computedStyleUpdates
  bool _trackComputedUpdates = false;
  final Set<int> _pendingComputedUpdates = <int>{};

  // Track forced pseudo states per frontend nodeId (e.g., ['hover','active'])
  final Map<int, Set<String>> _forcedPseudoStates = <int, Set<String>>{};

  void _trackNodeComputedUpdate(int nodeId) {
    if (_trackComputedUpdates) {
      _pendingComputedUpdates.add(nodeId);
    }
  }

  // Exposed for other modules to signal a node's computed style may have changed.
  void markComputedStyleDirtyByNodeId(int nodeId) => _trackNodeComputedUpdate(nodeId);

  @override
  String get name => 'CSS';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'enable':
        // No-op; return success so DevTools proceeds
        sendToFrontend(id, JSONEncodableMap({}));
        break;
      case 'disable':
        // No-op for now
        sendToFrontend(id, JSONEncodableMap({}));
        break;
      case 'getMatchedStylesForNode':
        handleGetMatchedStylesForNode(id, params!);
        break;
      case 'trackComputedStyleUpdates':
        _trackComputedUpdates = true;
        sendToFrontend(id, JSONEncodableMap({}));
        break;
      case 'takeComputedStyleUpdates':
        final updates = _pendingComputedUpdates.toList();
        _pendingComputedUpdates.clear();
        sendToFrontend(id, JSONEncodableMap({'computedStyleUpdates': updates}));
        break;
      case 'trackComputedStyleUpdatesForNode':
        final nodeId = params?['nodeId'];
        if (nodeId is int) _trackNodeComputedUpdate(nodeId);
        sendToFrontend(id, JSONEncodableMap({}));
        break;
      case 'getEnvironmentVariables':
        sendToFrontend(id, JSONEncodableMap({'variables': <Map<String, String>>[]}));
        break;
      case 'getAnimatedStylesForNode':
        sendToFrontend(id, JSONEncodableMap({'animationStyles': [], 'inherited': []}));
        break;
      case 'getComputedStyleForNode':
        handleGetComputedStyleForNode(id, params!);
        break;
      case 'getInlineStylesForNode':
        handleGetInlineStylesForNode(id, params!);
        break;
      case 'setStyleTexts':
        handleSetStyleTexts(id, params!);
        break;
      case 'setStyleSheetText':
        handleSetStyleSheetText(id, params!);
        break;
      case 'addRule':
        handleAddRule(id, params!);
        break;
      case 'getBackgroundColors':
        handleGetBackgroundColors(id, params!);
        break;
      case 'setEffectivePropertyValueForNode':
        handleSetEffectivePropertyValueForNode(id, params!);
        break;
      case 'collectClassNames':
        handleCollectClassNames(id, params!);
        break;
      case 'createStyleSheet':
        handleCreateStyleSheet(id, params ?? const {});
        break;
      case 'forcePseudoState':
        handleForcePseudoState(id, params ?? const {});
        break;
      case 'resolveValues':
        handleResolveValues(id, params ?? const {});
        break;
    }
  }

  void handleGetMatchedStylesForNode(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    int? targetId = ctx.getTargetIdByNodeId(params['nodeId']);
    if (targetId == null) {
      sendToFrontend(id, null);
      return;
    }
    BindingObject? element = ctx.getBindingObject(Pointer.fromAddress(targetId));
    if (element is Element) {
      MatchedStyles matchedStyles = MatchedStyles(
        inlineStyle: buildMatchedStyle(element),
      );
      sendToFrontend(id, matchedStyles);
    }
  }

  void handleGetComputedStyleForNode(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    int? targetId = ctx.getTargetIdByNodeId(params['nodeId']);
    if (targetId == null) {
      sendToFrontend(id, null);
      return;
    }
    BindingObject? element = ctx.getBindingObject(Pointer.fromAddress(targetId));

    if (element is Element) {
      ComputedStyle computedStyle = ComputedStyle(
        computedStyle: buildComputedStyle(element),
      );
      sendToFrontend(id, computedStyle);
    }
  }

  // Returns the styles defined inline (explicitly in the "style" attribute and
  // implicitly, using DOM attributes) for a DOM node identified by nodeId.
  void handleGetInlineStylesForNode(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    int? targetId = ctx.getTargetIdByNodeId(params['nodeId']);
    if (targetId == null) {
      sendToFrontend(id, null);
      return;
    }
    BindingObject? element = ctx.getBindingObject(Pointer.fromAddress(targetId));

    if (element is Element) {
      InlinedStyle inlinedStyle = InlinedStyle(
        inlineStyle: buildInlineStyle(element),
        attributesStyle: buildAttributesStyle(element.attributes),
      );
      sendToFrontend(id, inlinedStyle);
    }
  }

  void handleSetStyleTexts(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    List edits = params['edits'];
    List<CSSStyle?> styles = [];

    // Apply inline style edits by replacing the full inline style text of the target.
    for (Map<String, dynamic> edit in edits) {
      // Use styleSheetId to identify element (handles inline:<nodeId> or numeric).
      final dynamic rawStyleSheetId = edit['styleSheetId'];
      int? nodeId;
      int? frontendNodeId;
      if (rawStyleSheetId is int) {
        frontendNodeId = rawStyleSheetId;
        nodeId = ctx.getTargetIdByNodeId(rawStyleSheetId);
      } else if (rawStyleSheetId is String) {
        String sid = rawStyleSheetId;
        if (sid.startsWith('inline:')) {
          final String rest = sid.substring('inline:'.length);
          final int? nid = int.tryParse(rest);
          if (nid != null) {
            frontendNodeId = nid;
            nodeId = ctx.getTargetIdByNodeId(nid);
          }
        } else {
          final int? nid = int.tryParse(sid);
          if (nid != null) {
            frontendNodeId = nid;
            nodeId = ctx.getTargetIdByNodeId(nid);
          }
        }
      }
      String text = (edit['text'] ?? '').toString();
      if (nodeId == null) {
        styles.add(null);
        continue;
      }
      BindingObject? element = ctx.getBindingObject(Pointer.fromAddress(nodeId));
      if (element is Element) {
        // Replace full inline style with the provided text.
        _applyInlineStyleText(element, text);
        styles.add(buildInlineStyle(element));
        if (frontendNodeId != null) {
          _trackNodeComputedUpdate(frontendNodeId);
        }
      } else {
        styles.add(null);
      }
    }

    if (DebugFlags.enableDevToolsProtocolLogs) {
      try {
        final appliedCount = styles.where((s) => s != null).fold<int>(0, (acc, s) => acc + (s!.cssProperties.length));
        devToolsProtocolLogger.finer('[DevTools] CSS.setStyleTexts edits=${edits.length} appliedProps=$appliedCount');
      } catch (_) {}
    }
    sendToFrontend(
        id,
        JSONEncodableMap({
          'styles': styles,
        }));
  }

  void handleSetStyleSheetText(int? id, Map<String, dynamic> params) {
    // DevTools may call this for inline styles too (styleSheetId: "inline:<nodeId>")
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final dynamic rawStyleSheetId = params['styleSheetId'];
    final String text = (params['text'] ?? '').toString();

    int? nodeId;
    int? frontendNodeId;
    if (rawStyleSheetId is int) {
      frontendNodeId = rawStyleSheetId;
      nodeId = ctx.getTargetIdByNodeId(rawStyleSheetId);
    } else if (rawStyleSheetId is String) {
      String sid = rawStyleSheetId;
      if (sid.startsWith('inline:')) {
        final String rest = sid.substring('inline:'.length);
        final int? nid = int.tryParse(rest);
        if (nid != null) {
          frontendNodeId = nid;
          nodeId = ctx.getTargetIdByNodeId(nid);
        }
      } else {
        final int? nid = int.tryParse(sid);
        if (nid != null) {
          frontendNodeId = nid;
          nodeId = ctx.getTargetIdByNodeId(nid);
        }
      }
    }

    if (nodeId != null) {
      BindingObject? element = ctx.getBindingObject(Pointer.fromAddress(nodeId));
      if (element is Element) {
        _applyInlineStyleText(element, text);
      }
    }

    if (DebugFlags.enableDevToolsProtocolLogs) {
      devToolsProtocolLogger.finer('[DevTools] CSS.setStyleSheetText styleSheetId=$rawStyleSheetId len=${text.length}');
    }
    sendToFrontend(id, JSONEncodableMap({}));
    if (frontendNodeId != null) {
      _trackNodeComputedUpdate(frontendNodeId);
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/CSS/#method-createStyleSheet
  /// Creates a new via-inspector stylesheet and attaches it to the document (preferably `<head>`).
  /// Returns a StyleSheetId which we encode as `inline:<frontendNodeId>` for the created `<style>` element.
  void handleCreateStyleSheet(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, JSONEncodableMap({}));
      return;
    }

    final controller = ctx.getController() ?? devtoolsService.controller;
    final doc = document;
    if (controller == null || doc == null || doc.documentElement == null) {
      sendToFrontend(id, JSONEncodableMap({}));
      return;
    }

    // Create a new <style> element via the bridge so DevTools incremental events can flow if needed
    final ptr = allocateNewBindingObject();
    controller.view.createElement(ptr, 'style');
    final Element? styleEl = ctx.getBindingObject(ptr) as Element?;
    if (styleEl == null) {
      sendToFrontend(id, JSONEncodableMap({}));
      return;
    }

    // Attach to <head> if present; otherwise append to <html>
    Element attachTarget = (doc.documentElement?.querySelector(['head']) as Element?) ?? doc.documentElement!;
    try {
      controller.view.insertAdjacentNode(attachTarget.pointer!, 'beforeend', ptr);
    } catch (_) {
      // Fallback direct append (no incremental events)
      attachTarget.appendChild(styleEl);
    }

    // Build a StyleSheetId consistent with our inline handling
    final frontendNodeId = ctx.forDevtoolsNodeId(styleEl);
    final styleSheetId = 'inline:$frontendNodeId';
    if (DebugFlags.enableDevToolsProtocolLogs) {
      devToolsProtocolLogger.finer('[DevTools] CSS.createStyleSheet id=$styleSheetId');
    }
    sendToFrontend(id, JSONEncodableMap({'styleSheetId': styleSheetId}));
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/CSS/#method-forcePseudoState
  /// Enables or disables forcing certain pseudo classes for the given node.
  /// Params: `{ nodeId: <frontendNodeId>, forcedPseudoClasses: [ 'hover', 'active', ... ] }`
  void handleForcePseudoState(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, JSONEncodableMap({}));
      return;
    }

    final int? frontendNodeId = params['nodeId'] as int?;
    final List<dynamic>? forced = params['forcedPseudoClasses'] as List<dynamic>?;
    if (frontendNodeId == null || forced == null) {
      sendToFrontend(id, JSONEncodableMap({}));
      return;
    }

    final states = <String>{};
    for (final v in forced) {
      if (v is String && v.isNotEmpty) states.add(v.toLowerCase());
    }
    _forcedPseudoStates[frontendNodeId] = states;

    // If element exists, request style recalculation to reflect potential pseudo state effects
    try {
      final targetId = ctx.getTargetIdByNodeId(frontendNodeId);
      if (targetId != null && targetId != 0) {
        final BindingObject? obj = ctx.getBindingObject(Pointer.fromAddress(targetId));
        if (obj is Element) {
          obj.ownerDocument.markElementStyleDirty(obj);
          obj.ownerDocument.updateStyleIfNeeded();
        }
      }
    } catch (_) {}

    // Signal computed style subscribers
    _trackNodeComputedUpdate(frontendNodeId);

    if (DebugFlags.enableDevToolsProtocolLogs) {
      devToolsProtocolLogger
          .finer('[DevTools] CSS.forcePseudoState node=$frontendNodeId states=${states.join(',')}');
    }
    sendToFrontend(id, JSONEncodableMap({}));
  }

  /// Resolves a list of CSS property values in the context of a node's render style.
  /// Params:
  ///   - nodeId: frontend node id
  ///   - declarations: [{ name: 'width', value: '50%' }, ...] OR
  ///   - text: 'width:50%; height: 10px;'
  /// Returns: { resolved: [{ name: 'width', value: '160px' }, ...] }
  void handleResolveValues(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, JSONEncodableMap({'results': [], 'resolved': []}));
      return;
    }

    final int? frontendNodeId = params['nodeId'] as int?;
    if (frontendNodeId == null) {
      sendToFrontend(id, JSONEncodableMap({'results': [], 'resolved': []}));
      return;
    }

    final targetId = ctx.getTargetIdByNodeId(frontendNodeId);
    final BindingObject? obj = targetId != null && targetId != 0
        ? ctx.getBindingObject(Pointer.fromAddress(targetId))
        : null;
    final Element? element = obj is Element ? obj : null;
    if (element == null) {
      sendToFrontend(id, JSONEncodableMap({'results': [], 'resolved': []}));
      return;
    }

    // Spec path: values + optional propertyName
    if (params['values'] is List) {
      final List<dynamic> values = params['values'] as List<dynamic>;
      final String? propNameRaw = params['propertyName'] as String?;
      final String? propName =
          (propNameRaw != null && propNameRaw.isNotEmpty) ? camelize(propNameRaw) : null;
      final results = <String>[];
      for (final v0 in values) {
        final input = v0?.toString() ?? '';
        String out = input;
        try {
          dynamic resolved;
          if (propName != null) {
            resolved = element.renderStyle
                .resolveValue(propName, input, baseHref: element.ownerDocument.controller.url);
          } else {
            // Combined syntax fallback not fully supported; leave as-is.
            resolved = null;
          }
          if (resolved is CSSLengthValue) {
            out = resolved.cssText();
          } else if (resolved != null) {
            out = resolved.toString();
          }
        } catch (_) {}
        results.add(out);
      }
      sendToFrontend(id, JSONEncodableMap({'results': results}));
      return;
    }

    // Backward-compat path: declarations/text (non-standard)
    List<Map<String, String>> pairs = [];
    final decls = params['declarations'];
    if (decls is List) {
      for (final d in decls) {
        if (d is Map && d['name'] is String && d['value'] is String) {
          pairs.add({'name': d['name'] as String, 'value': d['value'] as String});
        }
      }
    } else {
      final text = params['text'];
      if (text is String && text.trim().isNotEmpty) {
        final parts = _splitDeclarations(text);
        for (final decl in parts) {
          final int colon = decl.indexOf(':');
          if (colon <= 0) continue;
          final name = decl.substring(0, colon).trim();
          final value = decl.substring(colon + 1).trim();
          if (name.isEmpty) continue;
          pairs.add({'name': name, 'value': value});
        }
      }
    }

    List<Map<String, String>> resolved = [];
    for (final p in pairs) {
      final origName = p['name']!;
      final camel = camelize(origName);
      final value = p['value']!;
      try {
        final v = element.renderStyle.resolveValue(camel, value, baseHref: element.ownerDocument.controller.url);
        String text;
        if (v is CSSLengthValue) {
          text = v.cssText();
        } else {
          text = v?.toString() ?? value;
        }
        resolved.add({'name': origName, 'value': text});
      } catch (_) {
        resolved.add({'name': origName, 'value': value});
      }
    }

    if (DebugFlags.enableDevToolsProtocolLogs) {
      try {
        devToolsProtocolLogger.finer('[DevTools] CSS.resolveValues node=$frontendNodeId count=${resolved.length}');
      } catch (_) {}
    }
    sendToFrontend(id, JSONEncodableMap({'results': resolved.map((e) => e['value']).toList(), 'resolved': resolved}));
  }

  // Adds a CSS rule to a stylesheet. We support only inline stylesheets on <style> elements.
  // Expected params: { styleSheetId: 'inline:<nodeId>' | <nodeId>, ruleText: 'selector { props }', location?: {...} }
  void handleAddRule(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final dynamic rawStyleSheetId = params['styleSheetId'];
    final String ruleText = (params['ruleText'] ?? '').toString();

    if (ruleText.trim().isEmpty) {
      sendToFrontend(id, JSONEncodableMap({'rule': {}}));
      return;
    }

    int? nodeId;
    if (rawStyleSheetId is int) {
      nodeId = ctx.getTargetIdByNodeId(rawStyleSheetId);
    } else if (rawStyleSheetId is String) {
      String sid = rawStyleSheetId;
      if (sid.startsWith('inline:')) {
        final String rest = sid.substring('inline:'.length);
        final int? nid = int.tryParse(rest);
        if (nid != null) {
          nodeId = ctx.getTargetIdByNodeId(nid);
        }
      } else {
        final int? nid = int.tryParse(sid);
        if (nid != null) {
          nodeId = ctx.getTargetIdByNodeId(nid);
        }
      }
    }

    if (nodeId == null) {
      sendToFrontend(id, JSONEncodableMap({'rule': {}}));
      return;
    }
    final BindingObject? obj = ctx.getBindingObject(Pointer.fromAddress(nodeId));
    if (obj is Element && obj is StyleElementMixin) {
      // Append text node with the rule; StyleElementMixin reacts and recalculates styles
      final Element styleEl = obj;
      final Document doc = styleEl.ownerDocument;
      final textNode = doc.createTextNode('\n$ruleText\n',
          BindingContext(doc.controller.view, doc.controller.view.contextId, allocateNewBindingObject()));
      styleEl.appendChild(textNode);
      // Respond with a minimal rule object
      sendToFrontend(id, JSONEncodableMap({'rule': {}}));
      return;
    }

    // Fallback: unsupported stylesheet target; no-op success
    sendToFrontend(id, JSONEncodableMap({'rule': {}}));
  }

  // Replace inline style with declarations parsed from text
  void _applyInlineStyleText(Element element, String text) {
    // Clear all existing inline styles
    element.clearInlineStyle();
    if (text.trim().isEmpty) return;

    // Naive split on semicolons not inside parentheses or quotes
    // Accept simple cases used by inline style editing
    final List<String> decls = _splitDeclarations(text);
    for (String decl in decls) {
      final int colon = decl.indexOf(':');
      if (colon <= 0) continue;
      final String name = decl.substring(0, colon).trim();
      String value = decl.substring(colon + 1).trim();
      // Drop optional trailing !important marker – inline styles already have highest priority
      if (value.endsWith('!important')) {
        value = value.substring(0, value.length - '!important'.length).trim();
      }
      if (name.isEmpty) continue;
      element.setInlineStyle(camelize(name), value);
      element.recalculateStyle();
    }
  }

  List<String> _splitDeclarations(String text) {
    final List<String> out = <String>[];
    final StringBuffer buf = StringBuffer();
    int depth = 0; // parentheses depth
    String? quote; // ' or "
    for (int i = 0; i < text.length; i++) {
      final String ch = text[i];
      if (quote != null) {
        buf.write(ch);
        if (ch == quote) quote = null;
        continue;
      }
      if (ch == '"' || ch == '\'') {
        quote = ch;
        buf.write(ch);
        continue;
      }
      if (ch == '(') {
        depth++;
        buf.write(ch);
        continue;
      }
      if (ch == ')') {
        if (depth > 0) depth--;
        buf.write(ch);
        continue;
      }
      if (ch == ';' && depth == 0) {
        final String part = buf.toString().trim();
        if (part.isNotEmpty) out.add(part);
        buf.clear();
        continue;
      }
      buf.write(ch);
    }
    final String tail = buf.toString().trim();
    if (tail.isNotEmpty) out.add(tail);
    return out;
  }

  static CSSStyle? buildMatchedStyle(Element element) {
    List<CSSProperty> cssProperties = [];
    String cssText = '';
    for (MapEntry<String, CSSPropertyValue> entry in element.style) {
      String kebabName = kebabize(entry.key);
      String propertyValue = entry.value.toString();
      String cssText0 = '$kebabName: $propertyValue';
      CSSProperty cssProperty = CSSProperty(
        name: kebabName,
        value: entry.value.value,
        range: SourceRange(
          startLine: 0,
          startColumn: cssText.length,
          endLine: 0,
          endColumn: cssText.length + cssText0.length + 1,
        ),
      );
      cssText += '$cssText0; ';
      cssProperties.add(cssProperty);
    }

    return CSSStyle(
        // For inline style, provide a string StyleSheetId per CDP expectations.
        styleSheetId: 'inline:${element.ownerView.forDevtoolsNodeId(element)}',
        cssProperties: cssProperties,
        shorthandEntries: <ShorthandEntry>[],
        cssText: cssText,
        range: SourceRange(startLine: 0, startColumn: 0, endLine: 0, endColumn: cssText.length));
  }

  static CSSStyle? buildInlineStyle(Element element) {
    List<CSSProperty> cssProperties = [];
    String cssText = '';
    element.inlineStyle.forEach((key, value) {
      String kebabName = kebabize(key);
      String propertyValue = value.toString();
      String cssText0 = '$kebabName: $propertyValue';
      CSSProperty cssProperty = CSSProperty(
        name: kebabName,
        value: value,
        range: SourceRange(
          startLine: 0,
          startColumn: cssText.length,
          endLine: 0,
          endColumn: cssText.length + cssText0.length + 1,
        ),
      );
      cssText += '$cssText0; ';
      cssProperties.add(cssProperty);
    });

    return CSSStyle(
        // For inline style, provide a string StyleSheetId per CDP expectations.
        styleSheetId: 'inline:${element.ownerView.forDevtoolsNodeId(element)}',
        cssProperties: cssProperties,
        shorthandEntries: <ShorthandEntry>[],
        cssText: cssText,
        range: SourceRange(startLine: 0, startColumn: 0, endLine: 0, endColumn: cssText.length));
  }

  static List<CSSComputedStyleProperty> buildComputedStyle(Element element) {
    List<CSSComputedStyleProperty> computedStyle = [];
    Map<CSSPropertyID, String> reverse(Map map) => {for (var e in map.entries) e.value: e.key};
    final propertyMap = reverse(CSSPropertyNameMap);
    ComputedCSSStyleDeclaration computedStyleDeclaration = ComputedCSSStyleDeclaration(
        BindingContext(element.ownerView, element.ownerView.contextId, allocateNewBindingObject()), element, null);
    for (CSSPropertyID id in ComputedProperties) {
      final propertyName = propertyMap[id];
      if (propertyName != null) {
        final value = computedStyleDeclaration.getPropertyValue(propertyName);
        if (value.isEmpty) {
          continue;
        }
        computedStyle.add(CSSComputedStyleProperty(name: propertyName, value: value));
        if (id == CSSPropertyID.Top) {
          computedStyle.add(CSSComputedStyleProperty(name: 'y', value: value));
        } else if (id == CSSPropertyID.Left) {
          computedStyle.add(CSSComputedStyleProperty(name: 'x', value: value));
        }
      }
    }
    return computedStyle;
  }

  // Kraken not supports attribute style for now.
  static CSSStyle? buildAttributesStyle(Map<String, dynamic> properties) {
    return null;
  }

  void handleGetBackgroundColors(int? id, Map<String, dynamic> params) {
    // For now, return empty background colors
    // This could be enhanced to actually compute background colors from the render tree
    sendToFrontend(
        id,
        JSONEncodableMap({
          'backgroundColors': [],
        }));
  }

  void handleSetEffectivePropertyValueForNode(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final int? frontendNodeIdParam = params['nodeId'] as int?;
    int? nodeId = frontendNodeIdParam != null ? ctx.getTargetIdByNodeId(frontendNodeIdParam) : null;
    String? propertyName = params['propertyName'];
    String? value = params['value'];

    if (nodeId != null && propertyName != null && value != null) {
      BindingObject? element = ctx.getBindingObject(Pointer.fromAddress(nodeId));
      if (element is Element) {
        element.setInlineStyle(camelize(propertyName), value);
      }
    }

    sendToFrontend(id, null);
    if (frontendNodeIdParam != null) {
      _trackNodeComputedUpdate(frontendNodeIdParam);
    }
  }

  // Returns all class names from the specified stylesheet.
  // We support only inline stylesheets targeted by styleSheetId: 'inline:<nodeId>' or numeric nodeId.
  void handleCollectClassNames(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final dynamic rawStyleSheetId = params['styleSheetId'];
    int? nodeId;
    if (rawStyleSheetId is int) {
      nodeId = ctx.getTargetIdByNodeId(rawStyleSheetId);
    } else if (rawStyleSheetId is String) {
      String sid = rawStyleSheetId;
      if (sid.startsWith('inline:')) {
        final String rest = sid.substring('inline:'.length);
        final int? nid = int.tryParse(rest);
        if (nid != null) nodeId = ctx.getTargetIdByNodeId(nid);
      } else {
        final int? nid = int.tryParse(sid);
        if (nid != null) nodeId = ctx.getTargetIdByNodeId(nid);
      }
    }

    final Set<String> classNames = <String>{};
    if (nodeId != null) {
      final BindingObject? obj = ctx.getBindingObject(Pointer.fromAddress(nodeId));
      if (obj is Element && obj is StyleElementMixin) {
        CSSStyleSheet? sheet = (obj).styleSheet;
        // If sheet not parsed yet, parse from text content
        if (sheet == null) {
          final String? text = obj.collectElementChildText();
          if (text != null) {
            sheet = CSSParser(text).parse(
                windowWidth: obj.windowWidth,
                windowHeight: obj.windowHeight,
                isDarkMode: obj.ownerView.rootController.isDarkMode);
          }
        }
        if (sheet != null) {
          _collectClassesFromRules(sheet.cssRules, classNames);
        }
      }
    }

    sendToFrontend(id, JSONEncodableMap({'classNames': classNames.toList()}));
  }

  void _collectClassesFromRules(List<CSSRule>? rules, Set<String> out) {
    if (rules == null) return;
    for (final CSSRule rule in rules) {
      if (rule is CSSStyleRule) {
        for (final selector in rule.selectorGroup.selectors) {
          for (final seq in selector.simpleSelectorSequences) {
            final simple = seq.simpleSelector;
            if (simple is ClassSelector) {
              // simple.name returns class name string
              out.add(simple.name);
            }
          }
        }
      } else if (rule is CSSMediaDirective) {
        _collectClassesFromRules(rule.getValidMediaRules(null, null, false), out);
      }
    }
  }
}

class MatchedStyles extends JSONEncodable {
  MatchedStyles({
    this.inlineStyle,
    this.attributesStyle,
    this.matchedCSSRules,
    this.pseudoElements,
    this.inherited,
    this.cssKeyframesRules,
  });

  CSSStyle? inlineStyle;
  CSSStyle? attributesStyle;
  List<RuleMatch>? matchedCSSRules;
  List<PseudoElementMatches>? pseudoElements;
  List<InheritedStyleEntry>? inherited;
  List<CSSKeyframesRule>? cssKeyframesRules;

  @override
  Map toJson() {
    return {
      if (inlineStyle != null) 'inlineStyle': inlineStyle,
      if (attributesStyle != null) 'attributesStyle': attributesStyle,
      if (matchedCSSRules != null) 'matchedCSSRules': matchedCSSRules,
      if (pseudoElements != null) 'pseudoElements': pseudoElements,
      if (inherited != null) 'inherited': inherited,
      if (cssKeyframesRules != null) 'cssKeyframesRules': cssKeyframesRules,
    };
  }
}

class CSSStyle extends JSONEncodable {
  // CDP StyleSheetId is a string. For inline styles, we encode as "inline:<nodeId>".
  String? styleSheetId;
  List<CSSProperty> cssProperties;
  List<ShorthandEntry> shorthandEntries;
  String? cssText;
  SourceRange? range;

  CSSStyle({
    this.styleSheetId,
    required this.cssProperties,
    required this.shorthandEntries,
    this.cssText,
    this.range,
  });

  @override
  Map toJson() {
    return {
      if (styleSheetId != null) 'styleSheetId': styleSheetId,
      'cssProperties': cssProperties,
      'shorthandEntries': shorthandEntries,
      if (cssText != null) 'cssText': cssText,
      if (range != null) 'range': range,
    };
  }
}

class RuleMatch extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class PseudoElementMatches extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class InheritedStyleEntry extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class CSSKeyframesRule extends JSONEncodable {
  @override
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class CSSProperty extends JSONEncodable {
  String name;
  String value;
  bool important;
  bool implicit;
  String? text;
  bool parsedOk;
  bool? disabled;
  SourceRange? range;

  CSSProperty({
    required this.name,
    required this.value,
    this.important = false,
    this.implicit = false,
    this.text,
    this.parsedOk = true,
    this.disabled,
    this.range,
  });

  @override
  Map toJson() {
    return {
      'name': name,
      'value': value,
      'important': important,
      'implicit': implicit,
      'text': text,
      'parsedOk': parsedOk,
      if (disabled != null) 'disabled': disabled,
      if (range != null) 'range': range,
    };
  }
}

class SourceRange extends JSONEncodable {
  int startLine;
  int startColumn;
  int endLine;
  int endColumn;

  SourceRange({
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  @override
  Map toJson() {
    return {
      'startLine': startLine,
      'startColumn': startColumn,
      'endLine': endLine,
      'endColumn': endColumn,
    };
  }
}

class ShorthandEntry extends JSONEncodable {
  String name;
  String value;
  bool important;

  ShorthandEntry({
    required this.name,
    required this.value,
    this.important = false,
  });

  @override
  Map toJson() {
    return {
      'name': name,
      'value': value,
      'important': important,
    };
  }
}

/// https://chromedevtools.github.io/devtools-protocol/tot/CSS/#method-getComputedStyleForNode
class ComputedStyle extends JSONEncodable {
  List<CSSComputedStyleProperty> computedStyle;

  ComputedStyle({required this.computedStyle});

  @override
  Map toJson() {
    return {
      'computedStyle': computedStyle,
    };
  }
}

/// https://chromedevtools.github.io/devtools-protocol/tot/CSS/#type-CSSComputedStyleProperty
class CSSComputedStyleProperty extends JSONEncodable {
  String name;
  String value;

  CSSComputedStyleProperty({required this.name, required this.value});

  @override
  Map toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class InlinedStyle extends JSONEncodable {
  CSSStyle? inlineStyle;
  CSSStyle? attributesStyle;

  InlinedStyle({this.inlineStyle, this.attributesStyle});

  @override
  Map toJson() {
    return {
      if (inlineStyle != null) 'inlineStyle': inlineStyle,
      if (attributesStyle != null) 'attributesStyle': attributesStyle,
    };
  }
}
