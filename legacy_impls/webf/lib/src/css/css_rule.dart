/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:quiver/core.dart';
import 'package:webf/css.dart';

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
    double? offset;
    final keyText = block.blockSelectors[0];
    if (keyText == 'from') {
      offset = 0;
    } else if (keyText == 'to') {
      offset = 1;
    } else {
      offset = CSSPercentage.parsePercentage(keyText);
    }
    for (MapEntry<String, CSSPropertyValue> entry in block.declarations) {
      final property = camelize(entry.key);
      keyframes.add(Keyframe(property, entry.value.value, offset ?? 0, LINEAR));
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
