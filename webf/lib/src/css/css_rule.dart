/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

/// https://drafts.csswg.org/cssom/#the-cssstylerule-interface
class CSSStyleRule extends CSSRule {
  final SelectorTextVisitor _selectorTextVisitor = SelectorTextVisitor();

  String get selectorText {
    _selectorTextVisitor.visitSelectorGroup(selectorGroup);
    return _selectorTextVisitor.toString();
  }

  @override
  String get cssText => declaration.cssText;

  @override
  int get type => CSSRule.STYLE_RULE;

  final SelectorGroup selectorGroup;
  final CSSStyleDeclaration declaration;

  CSSStyleRule(this.selectorGroup, this.declaration) : super();

  SimpleSelector? get lastSimpleSelector {
    return selectorGroup.selectors.last.simpleSelectorSequences.last.simpleSelector;
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
  final List<KeyFrameBlock> blocks = [];

  @override
  int get type => CSSRule.KEYFRAMES_RULE;

  CSSKeyframesRule(this._keyframeName, this.name) : super();

  void add(KeyFrameBlock block) {
    blocks.add(block);
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
