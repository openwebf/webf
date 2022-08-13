/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

abstract class StyleSheet {}

const String _CSSStyleSheetType = 'text/css';

// https://drafts.csswg.org/cssom-1/#cssstylesheet
class CSSStyleSheet implements StyleSheet {
  String type = _CSSStyleSheetType;

  /// A Boolean indicating whether the stylesheet is disabled. False by default.
  bool disabled = false;

  /// A string containing the baseURL used to resolve relative URLs in the stylesheet.
  String? herf;

  final RuleSet ruleSet;

  CSSStyleSheet(this.ruleSet, {this.disabled = false, this.herf});

  insertRule(String text, int index) {
    List<CSSRule> rules = CSSParser(text).parseRules();
    for (CSSRule rule in rules) {
      ruleSet.addRule(rule);
    }
  }

  /// Removes a rule from the stylesheet object.
  deleteRule(int index) {
    ruleSet.deleteRule(index);
  }

  /// Synchronously replaces the content of the stylesheet with the content passed into it.
  replaceSync(String text) {
    ruleSet.reset();
    List<CSSRule> rules = CSSParser(text).parseRules();
    for (CSSRule rule in rules) {
      ruleSet.addRule(rule);
    }
  }

  replace(String text) {
    // TODO: put in next frame and return a future
    replaceSync(text);
  }
}

/*
1. append 元素
2. Node::invalidateStyle 方法 将元素所有祖先都标记需要更新样式
3. Document updateStyleIfNeeded()
  3.1 flush pending sheet
      比对 style sheet， 得到 ActiveSheetsChange 和  ChangedRuleSet
      通过 ElementRuleCollector ElementRuleCollector::matchesAnyAuthorRules
      对比后将 element 标记为 invalid (Invalidator::invalidateIfNeeded)
  3.2 判断标记 needsStyleRecalc() ，执行 resolveStyle();
5. TreeResolver::resolveComposedTree
6. TreeResolver::resolveElement
  6.1 TreeResolver::styleForStyleable return CSSStyleDeclaration
    6.1.1 styleForElement
  6.2 Merge CSSStyleDeclaration
-----------------------







1. 对比 style sheet
enum ActiveSheetsChange {
  kNoActiveSheetsChanged,  // Nothing changed.
  kActiveSheetsChanged,    // Sheets were added and/or inserted.
  kActiveSheetsAppended    // Only additions, and all appended.
};
2.

SetNeedsStyleRecalc


 */
