/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

/// https://drafts.csswg.org/cssom/#the-cssstylerule-interface
class CSSStyleRule extends CSSRule {
  @override
  String get cssText => declaration.cssText;

  final SelectorGroup selectorGroup;
  final CSSStyleDeclaration declaration;

  CSSStyleRule(this.selectorGroup, this.declaration) : super();

  SimpleSelector? get lastSimpleSelector {
    return selectorGroup.selectors.last.simpleSelectorSequences.last.simpleSelector;
  }

  String get selectorText {
    var sb = StringBuffer();
    selectorGroup.selectors.forEach((selector) {
      sb.write(selector.simpleSelectorSequences.map((ss) => ss.simpleSelector.name).join(' '));
    });
    return sb.toString();
  }
}
