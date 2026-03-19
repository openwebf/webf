/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/src/foundation/logger.dart';

bool cssRuleListsStructurallyEqual(List<CSSRule> left, List<CSSRule> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index++) {
    if (!cssRulesStructurallyEqual(left[index], right[index])) {
      return false;
    }
  }
  return true;
}

int cssRuleListStructuralHash(Iterable<CSSRule> rules) {
  return Object.hashAll(rules.map(cssRuleStructuralHash));
}

bool cssRulesStructurallyEqual(CSSRule? left, CSSRule? right) {
  if (identical(left, right)) return true;
  if (left == null || right == null) return left == right;
  if (left.runtimeType != right.runtimeType) return false;

  if (left is CSSStyleRule && right is CSSStyleRule) {
    return left.selectorGroup.structurallyEquals(right.selectorGroup) &&
        left.layerPath.length == right.layerPath.length &&
        _stringListsEqual(left.layerPath, right.layerPath) &&
        left.declaration.structurallyEquals(right.declaration);
  }

  if (left is CSSLayerStatementRule && right is CSSLayerStatementRule) {
    return _layerNamePathsEqual(left.layerNamePaths, right.layerNamePaths);
  }

  if (left is CSSLayerBlockRule && right is CSSLayerBlockRule) {
    return left.name == right.name &&
        _stringListsEqual(left.layerNamePath, right.layerNamePath) &&
        cssRuleListsStructurallyEqual(left.cssRules, right.cssRules);
  }

  if (left is CSSImportRule && right is CSSImportRule) {
    return left.href == right.href && left.media == right.media;
  }

  if (left is CSSKeyframesRule && right is CSSKeyframesRule) {
    return left.name == right.name &&
        _keyframesEqual(left.keyframes, right.keyframes);
  }

  if (left is CSSFontFaceRule && right is CSSFontFaceRule) {
    return left.declarations.structurallyEquals(right.declarations);
  }

  if (left is CSSMediaDirective && right is CSSMediaDirective) {
    return _mediaQueriesEqual(left.cssMediaQuery, right.cssMediaQuery) &&
        cssRuleListsStructurallyEqual(
            left.rules ?? const <CSSRule>[], right.rules ?? const <CSSRule>[]);
  }

  return left.cssText == right.cssText;
}

int cssRuleStructuralHash(CSSRule rule) {
  if (rule is CSSStyleRule) {
    return Object.hash(
      rule.type,
      rule.selectorGroup.structuralHashCode,
      Object.hashAll(rule.layerPath),
      rule.declaration.structuralHashCode,
    );
  }

  if (rule is CSSLayerStatementRule) {
    return Object.hash(
      rule.type,
      Object.hashAll(rule.layerNamePaths.map((path) => Object.hashAll(path))),
    );
  }

  if (rule is CSSLayerBlockRule) {
    return Object.hash(
      rule.type,
      rule.name,
      Object.hashAll(rule.layerNamePath),
      cssRuleListStructuralHash(rule.cssRules),
    );
  }

  if (rule is CSSImportRule) {
    return Object.hash(rule.type, rule.href, rule.media);
  }

  if (rule is CSSKeyframesRule) {
    return Object.hash(
      rule.type,
      rule.name,
      Object.hashAll(rule.keyframes.map((keyframe) => Object.hash(
            keyframe.property,
            keyframe.value,
            keyframe.offset,
            keyframe.easing,
          ))),
    );
  }

  if (rule is CSSFontFaceRule) {
    return Object.hash(rule.type, rule.declarations.structuralHashCode);
  }

  if (rule is CSSMediaDirective) {
    return Object.hash(
      rule.type,
      _mediaQueryStructuralHash(rule.cssMediaQuery),
      cssRuleListStructuralHash(rule.rules ?? const <CSSRule>[]),
    );
  }

  return Object.hash(rule.type, rule.cssText);
}

bool _layerNamePathsEqual(List<List<String>> left, List<List<String>> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index++) {
    if (!_stringListsEqual(left[index], right[index])) return false;
  }
  return true;
}

bool _stringListsEqual(List<String> left, List<String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _keyframesEqual(List<Keyframe> left, List<Keyframe> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index++) {
    final Keyframe leftKeyframe = left[index];
    final Keyframe rightKeyframe = right[index];
    if (leftKeyframe.property != rightKeyframe.property ||
        leftKeyframe.value != rightKeyframe.value ||
        leftKeyframe.offset != rightKeyframe.offset ||
        leftKeyframe.easing != rightKeyframe.easing) {
      return false;
    }
  }
  return true;
}

bool _mediaQueriesEqual(CSSMediaQuery? left, CSSMediaQuery? right) {
  if (identical(left, right)) return true;
  if (left == null || right == null) return left == right;
  if (left._mediaUnary != right._mediaUnary) return false;
  if (left._mediaType?.name != right._mediaType?.name) return false;
  if (left.expressions.length != right.expressions.length) return false;
  for (int index = 0; index < left.expressions.length; index++) {
    final CSSMediaExpression leftExpression = left.expressions[index];
    final CSSMediaExpression rightExpression = right.expressions[index];
    if (leftExpression.op != rightExpression.op) return false;
    final Map<String, String>? leftStyle = leftExpression.mediaStyle;
    final Map<String, String>? rightStyle = rightExpression.mediaStyle;
    if (leftStyle == null || rightStyle == null) {
      if (leftStyle != rightStyle) return false;
      continue;
    }
    if (leftStyle.length != rightStyle.length) return false;
    final List<String> keys = leftStyle.keys.toList(growable: false)..sort();
    final List<String> otherKeys = rightStyle.keys.toList(growable: false)
      ..sort();
    if (!_stringListsEqual(keys, otherKeys)) return false;
    for (final String key in keys) {
      if (leftStyle[key] != rightStyle[key]) return false;
    }
  }
  return true;
}

int _mediaQueryStructuralHash(CSSMediaQuery? mediaQuery) {
  if (mediaQuery == null) return 0;
  return Object.hash(
    mediaQuery._mediaUnary,
    mediaQuery._mediaType?.name,
    Object.hashAll(mediaQuery.expressions.map((expression) {
      final Map<String, String>? mediaStyle = expression.mediaStyle;
      if (mediaStyle == null) {
        return Object.hash(expression.op, null);
      }
      final List<String> keys = mediaStyle.keys.toList(growable: false)..sort();
      return Object.hash(
        expression.op,
        Object.hashAll(keys.map((key) => Object.hash(key, mediaStyle[key]))),
      );
    })),
  );
}

/// https://drafts.csswg.org/cssom/#the-cssstylerule-interface
class CSSStyleRule extends CSSRule {
  @override
  String get cssText =>
      '${selectorGroup.selectorText} {${declaration.cssText}}';

  @override
  int get type => CSSRule.STYLE_RULE;

  final SelectorGroup selectorGroup;
  final CSSStyleDeclaration declaration;

  CSSStyleRule(this.selectorGroup, this.declaration) : super();

  int get structuralHashCode => cssRuleStructuralHash(this);

  bool structurallyEquals(CSSStyleRule other) {
    return cssRulesStructurallyEqual(this, other);
  }
}

/// https://drafts.csswg.org/cssom/#the-cssimportrule-interface
class CSSImportRule extends CSSRule {
  final String href;
  final String? media;

  CSSImportRule(this.href, {this.media});

  @override
  int get type => CSSRule.IMPORT_RULE;
}

/// Represents a CSS Cascade Layer ordering statement: `@layer a, b;`.
///
/// WebF flattens layer blocks into normal rules and emits a statement rule to
/// ensure empty layers still participate in ordering.
class CSSLayerStatementRule extends CSSRule {
  /// A list of layer name paths (each path is dot-separated in CSS).
  /// Example: `@layer a.b, c;` becomes `[['a','b'], ['c']]`.
  final List<List<String>> layerNamePaths;

  CSSLayerStatementRule(this.layerNamePaths);

  @override
  int get type => CSSRule.LAYER_STATEMENT_RULE;
}

/// Represents a CSS Cascade Layer block: `@layer name { ... }`.
///
/// This is a grouping rule in the CSSOM and supports insertRule/deleteRule.
class CSSLayerBlockRule extends CSSRule {
  /// The layer name as written, using dot notation for nested names.
  /// For anonymous layers, this is the empty string.
  final String name;

  /// Resolved full layer name path segments in the cascade layer tree.
  /// This includes any parent layer context.
  final List<String> layerNamePath;

  /// Child rules within this layer block.
  final List<CSSRule> cssRules;

  CSSLayerBlockRule({
    required this.name,
    required this.layerNamePath,
    required List<CSSRule> cssRules,
  }) : cssRules = cssRules;

  @override
  int get type => CSSRule.LAYER_BLOCK_RULE;

  int insertRule(CSSRule rule, int index) {
    if (index < 0 || index > cssRules.length) {
      throw RangeError.index(index, cssRules, 'index');
    }
    cssRules.insert(index, rule);
    return index;
  }

  void deleteRule(int index) {
    cssRules.removeAt(index);
  }
}

class KeyFrameBlock {
  final List<String> blockSelectors;
  final CSSStyleDeclaration declarations;

  KeyFrameBlock(this.blockSelectors, this.declarations);
}

class CSSKeyframesRule extends CSSRule {
  final int _keyframeName;
  final String name;
  final List<Keyframe> keyframes = [];

  @override
  int get type => CSSRule.KEYFRAMES_RULE;

  CSSKeyframesRule(this._keyframeName, this.name) : super();

  void add(KeyFrameBlock block) {
    // Support per-keyframe easing via `animation-timing-function` declared
    // inside the keyframe block. This easing applies to the segment starting
    // at this keyframe and ending at the next keyframe for the same property.
    // Default to linear if not specified.
    String easingForThisKeyframe = LINEAR;

    // First pass: detect block-level animation-timing-function if present.
    for (MapEntry<String, CSSPropertyValue> entry in block.declarations) {
      final propName = camelize(entry.key);
      if (propName == 'animationTimingFunction') {
        easingForThisKeyframe = entry.value.value;
        break;
      }
    }

    // For combined selectors like "0%, 100%", create keyframes for each.
    for (final String rawSel in block.blockSelectors) {
      final String keyText = rawSel.trim();
      double? offset;
      if (keyText == 'from') {
        offset = 0;
      } else if (keyText == 'to') {
        offset = 1;
      } else {
        offset = CSSPercentage.parsePercentage(keyText);
      }

      // Add keyframes for animatable properties, skipping the block-level timing function.
      for (MapEntry<String, CSSPropertyValue> entry in block.declarations) {
        final property = camelize(entry.key);
        if (property == 'animationTimingFunction') {
          continue; // already captured as easing
        }
        keyframes.add(Keyframe(
            property, entry.value.value, offset ?? 0, easingForThisKeyframe));
      }

      // (removed) verbose keyframe parse diagnostics
    }
  }

  String? get keyFrameName {
    switch (_keyframeName) {
      case TokenKind.DIRECTIVE_KEYFRAMES:
      case TokenKind.DIRECTIVE_MS_KEYFRAMES:
        return '@keyframes';
      case TokenKind.DIRECTIVE_WEB_KIT_KEYFRAMES:
        return '@-webkit-keyframes';
      case TokenKind.DIRECTIVE_MOZ_KEYFRAMES:
        return '@-moz-keyframes';
      case TokenKind.DIRECTIVE_O_KEYFRAMES:
        return '@-o-keyframes';
    }
    return null;
  }
}

class CSSFontFaceRule extends CSSRule {
  final CSSStyleDeclaration declarations;

  CSSFontFaceRule(this.declarations) : super();

  @override
  int get type => CSSRule.FONT_FACE_RULE;

  String? get keyFrameName {
    return '@font-face';
  }
}

class CSSMediaDirective extends CSSRule {
  final CSSMediaQuery? cssMediaQuery;
  final List<CSSRule>? rules;

  CSSMediaDirective(this.cssMediaQuery, this.rules) : super();

  set rules(List<CSSRule>? rules) {
    this.rules = rules;
  }

  @override
  int get type => CSSRule.MEDIA_RULE;

  List<CSSRule>? getValidMediaRules(
      double? windowWidth, double? windowHeight, bool isDarkMode) {
    List<CSSRule>? mediaRules = [];
    if (rules == null) {
      return mediaRules;
    }
    if (cssMediaQuery == null) {
      return rules;
    }
    // bool isMediaTypeNotOp = cssMediaQuery._mediaUnary == TokenKind.MEDIA_OP_ONLY;
    //w3c has media type screen/print/speech/all, but webf only work on screen and all
    String? mediaType = cssMediaQuery!._mediaType?.name;
    if (mediaType != null &&
        mediaType != MediaType.SCREEN &&
        mediaType != MediaType.ALL) {
      return mediaRules;
    }
    List<bool> conditions = [];
    List<bool> ops = [];
    for (CSSMediaExpression expression in cssMediaQuery!.expressions) {
      // [max-width: 1800px, min-width: 450px]
      if (expression.mediaStyle != null) {
        dynamic maxAspectRatio = expression.mediaStyle!['max-aspect-ratio'];
        if (maxAspectRatio != null &&
            windowWidth != null &&
            windowHeight != null) {
          double? maxAPS;
          if (maxAspectRatio is String) {
            maxAPS = parseStringToDouble(maxAspectRatio);
          } else if (maxAspectRatio is double) {
            maxAPS = maxAspectRatio;
          }
          if (maxAPS != null) {
            bool condition = windowWidth / windowHeight <= maxAPS;
            conditions.add(condition);
            ops.add(expression.op == MediaOperator.AND);
          }
        }
        dynamic minAspectRatio = expression.mediaStyle!['min-aspect-ratio'];
        if (minAspectRatio != null &&
            windowWidth != null &&
            windowHeight != null) {
          double? minAPS;
          if (minAspectRatio is String) {
            minAPS = parseStringToDouble(minAspectRatio);
          } else if (minAspectRatio is double) {
            minAPS = minAspectRatio;
          }
          if (minAPS != null) {
            bool condition = windowWidth / windowHeight >= minAPS;
            conditions.add(condition);
            ops.add(expression.op == MediaOperator.AND);
          }
        }
        dynamic maxWidth = expression.mediaStyle!['max-width'];
        if (windowWidth != null && maxWidth != null) {
          double maxWidthValue =
              CSSLength.parseLength(maxWidth, null).value ?? -1;
          // Media Queries: `max-width` matches when width <= value.
          bool condition = windowWidth <= maxWidthValue;
          conditions.add(condition);
          ops.add(expression.op == MediaOperator.AND);
        }
        dynamic minWidth = expression.mediaStyle!['min-width'];
        if (windowWidth != null && minWidth != null) {
          double minWidthValue =
              CSSLength.parseLength(minWidth, null).value ?? -1;
          // Media Queries: `min-width` matches when width >= value.
          bool condition = windowWidth >= minWidthValue;
          conditions.add(condition);
          ops.add(expression.op == MediaOperator.AND);
        }
        dynamic prefersColorScheme =
            expression.mediaStyle!['prefers-color-scheme'];
        if (prefersColorScheme != null) {
          bool isMediaDarkMode = prefersColorScheme == 'dark';
          bool condition = isMediaDarkMode == isDarkMode;
          conditions.add(condition);
          ops.add(expression.op == MediaOperator.AND);
        }
      }
    }
    bool isValid = true;
    for (int i = 0; i < conditions.length; i++) {
      bool con = conditions[i];
      bool isAnd = ops[i];
      if (isAnd) {
        isValid = isValid && con;
      } else {
        isValid = isValid || con;
      }
    }
    if (isValid) {
      mediaRules = rules;
    }
    return mediaRules;
  }

  double? parseStringToDouble(String str) {
    try {
      if (str.contains('/')) {
        // 8/5
        List<String> parts = str.split('/');
        double num1 = double.parse(parts[0]);
        double num2 = double.parse(parts[1]);
        return num1 / num2;
      }
      return double.parse(str);
    } catch (e) {
      cssLogger.fine('parseStringToDouble error: $e');
    }
    return null;
  }
}

/// MediaQuery grammar:
///
///      : [ONLY | NOT]? S* media_type S* [ AND S* media_expression ]*
///      | media_expression [ AND S* media_expression ]*
///     media_type
///      : IDENT
///     media_expression
///      : '(' S* media_feature S* [ ':' S* expr ]? ')' S*
///     media_feature
///      : IDENT
class CSSMediaQuery extends TreeNode {
  /// not, only or no operator.
  final int _mediaUnary;
  final Identifier? _mediaType;
  final List<CSSMediaExpression> expressions;

  CSSMediaQuery(this._mediaUnary, this._mediaType, this.expressions) : super();

  bool get hasMediaType => _mediaType != null;
  String get mediaType => _mediaType!.name;

  bool get hasUnary => _mediaUnary != -1;
  String get unary =>
      TokenKind.idToValue(TokenKind.MEDIA_OPERATORS, _mediaUnary)!
          .toUpperCase();
}

/// MediaExpression grammar:
///
///     '(' S* media_feature S* [ ':' S* expr ]? ')' S*
class CSSMediaExpression extends TreeNode {
  final String op;
  final Map<String, String>? mediaStyle;

  CSSMediaExpression(this.op, this.mediaStyle) : super();
}
