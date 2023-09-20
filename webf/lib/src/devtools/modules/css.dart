/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart';
import 'package:webf/launcher.dart';

const int INLINED_STYLESHEET_ID = 1;
const String ZERO_PX = '0px';

class InspectCSSModule extends UIInspectorModule {
  Document get document => devtoolsService.controller!.view.document;

  WebFViewController get view => devtoolsService.controller!.view;

  InspectCSSModule(DevToolsService devtoolsService) : super(devtoolsService);

  @override
  String get name => 'CSS';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'getMatchedStylesForNode':
        handleGetMatchedStylesForNode(id, params!);
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
    }
  }

  void handleGetMatchedStylesForNode(int? id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    BindingObject? element = view.getBindingObject<BindingObject>(Pointer.fromAddress(nodeId));
    if (element is Element) {
      MatchedStyles matchedStyles = MatchedStyles(
        inlineStyle: buildMatchedStyle(element),
      );
      sendToFrontend(id, matchedStyles);
    }
  }

  void handleGetComputedStyleForNode(int? id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element? element = view.getBindingObject<Element>(Pointer.fromAddress(nodeId));

    if (element != null) {
      ComputedStyle computedStyle = ComputedStyle(
        computedStyle: buildComputedStyle(element),
      );
      sendToFrontend(id, computedStyle);
    }
  }

  // Returns the styles defined inline (explicitly in the "style" attribute and
  // implicitly, using DOM attributes) for a DOM node identified by nodeId.
  void handleGetInlineStylesForNode(int? id, Map<String, dynamic> params) {
    int nodeId = params['nodeId'];
    Element? element = view.getBindingObject<Element>(Pointer.fromAddress(nodeId));

    if (element != null) {
      InlinedStyle inlinedStyle = InlinedStyle(
        inlineStyle: buildInlineStyle(element),
        attributesStyle: buildAttributesStyle(element.attributes),
      );
      sendToFrontend(id, inlinedStyle);
    }
  }

  void handleSetStyleTexts(int? id, Map<String, dynamic> params) {
    List edits = params['edits'];
    List<CSSStyle?> styles = [];

    // @TODO: diff the inline style edits.
    // @TODO: support comments for inline style.
    for (Map<String, dynamic> edit in edits) {
      // Use styleSheetId to identity element.
      int nodeId = edit['styleSheetId'];
      String text = edit['text'] ?? '';
      List<String> texts = text.split(';');
      Element? element = document.controller.view.getBindingObject<Element>(Pointer.fromAddress(nodeId));
      if (element != null) {
        for (String kv in texts) {
          kv = kv.trim();
          List<String> _kv = kv.split(':');
          if (_kv.length == 2) {
            String name = _kv[0].trim();
            String value = _kv[1].trim();
            element.setInlineStyle(camelize(name), value);
          }
        }
        styles.add(buildInlineStyle(element));
      } else {
        styles.add(null);
      }
    }

    sendToFrontend(
        id,
        JSONEncodableMap({
          'styles': styles,
        }));
  }

  static CSSStyle? buildMatchedStyle(Element element) {
    List<CSSProperty> cssProperties = [];
    String cssText = '';
    for (MapEntry<String, CSSPropertyValue> entry in element.style) {
      String kebabName = kebabize(entry.key);
      String propertyValue = entry.value.toString();
      String _cssText = '$kebabName: $propertyValue';
      CSSProperty cssProperty = CSSProperty(
        name: kebabName,
        value: entry.value.value,
        range: SourceRange(
          startLine: 0,
          startColumn: cssText.length,
          endLine: 0,
          endColumn: cssText.length + _cssText.length + 1,
        ),
      );
      cssText += '$_cssText; ';
      cssProperties.add(cssProperty);
    }

    return CSSStyle(
        // Absent for user agent stylesheet and user-specified stylesheet rules.
        // Use hash code id to identity which element the rule belongs to.
        styleSheetId: element.pointer!.address,
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
      String _cssText = '$kebabName: $propertyValue';
      CSSProperty cssProperty = CSSProperty(
        name: kebabName,
        value: value,
        range: SourceRange(
          startLine: 0,
          startColumn: cssText.length,
          endLine: 0,
          endColumn: cssText.length + _cssText.length + 1,
        ),
      );
      cssText += '$_cssText; ';
      cssProperties.add(cssProperty);
    });

    return CSSStyle(
        // Absent for user agent stylesheet and user-specified stylesheet rules.
        // Use hash code id to identity which element the rule belongs to.
        styleSheetId: element.pointer!.address,
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
  int? styleSheetId;
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
