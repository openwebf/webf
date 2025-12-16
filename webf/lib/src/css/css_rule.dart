/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:quiver/core.dart';
import 'package:webf/css.dart';
import 'package:webf/src/foundation/logger.dart';

/// https://drafts.csswg.org/cssom/#the-cssstylerule-interface
class CSSStyleRule extends CSSRule {
  @override
  String get cssText => declaration.cssText;

  @override
  int get type => CSSRule.STYLE_RULE;

  final SelectorGroup selectorGroup;
  final CSSStyleDeclaration declaration;

  CSSStyleRule(this.selectorGroup, this.declaration) : super();

  @override
  int get hashCode => hash2(selectorGroup, declaration);

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
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
        keyframes.add(Keyframe(property, entry.value.value, offset ?? 0, easingForThisKeyframe));
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

  CSSFontFaceRule(this.declarations): super();

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

  List<CSSRule>? getValidMediaRules(double? windowWidth, double? windowHeight, bool isDarkMode) {
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
    if (mediaType != null && mediaType != MediaType.SCREEN && mediaType != MediaType.ALL) {
      return mediaRules;
    }
    List<bool> conditions = [];
    List<bool> ops = [];
    for (CSSMediaExpression expression in cssMediaQuery!.expressions) {
      // [max-width: 1800px, min-width: 450px]
      if (expression.mediaStyle != null) {
        dynamic maxAspectRatio = expression.mediaStyle!['max-aspect-ratio'];
        if (maxAspectRatio != null && windowWidth != null && windowHeight != null) {
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
        if (minAspectRatio != null && windowWidth != null && windowHeight != null) {
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
          double maxWidthValue = CSSLength.parseLength(maxWidth, null).value ?? -1;
          bool condition = windowWidth < maxWidthValue;
          conditions.add(condition);
          ops.add(expression.op == MediaOperator.AND);
        }
        dynamic minWidth = expression.mediaStyle!['min-width'];
        if (windowWidth != null && minWidth != null) {
          double minWidthValue = CSSLength.parseLength(minWidth, null).value ?? -1;
          bool condition = windowWidth > minWidthValue;
          conditions.add(condition);
          ops.add(expression.op == MediaOperator.AND);
        }
        dynamic prefersColorScheme = expression.mediaStyle!['prefers-color-scheme'];
        if (prefersColorScheme != null) {
          bool isMediaDarkMode = prefersColorScheme == 'dark';
          bool condition = isMediaDarkMode == isDarkMode;
          conditions.add(condition);
          ops.add(expression.op == MediaOperator.AND);
        }
      }
    }
    bool isValid = true;
    for (int i = 0; i < conditions.length; i ++) {
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
      if (str.contains('/')) { // 8/5
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

  CSSMediaQuery(
      this._mediaUnary, this._mediaType, this.expressions)
      : super();

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
