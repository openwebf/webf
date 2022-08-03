/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';

import 'package:webf/css.dart';

typedef CSSMap = HashMap<String, List<CSSRule>>;

class RuleSet {
  final List<CSSRule> rules = [];

  final CSSMap idRules = HashMap();
  final CSSMap classRules = HashMap();
  final CSSMap attributeRules = HashMap();
  final CSSMap tagRules = HashMap();
  final List<CSSRule> universalRules = [];

  void addRule(CSSRule rule) {
    rules.add(rule);
    if (rule is CSSStyleRule) {
      findBestRuleSetAndAdd(rule);
    } else {
      assert(false, 'Unsupported rule type: ${rule.runtimeType}');
    }
  }

  void deleteRule(int index) {
    CSSRule rule = rules.removeAt(index);
    // if (rule is CSSStyleRule) {
    //   // findBestRuleSetAndRemove(rule);
    // }
  }

  void reset() {
    rules.clear();
    idRules.clear();
    classRules.clear();
    attributeRules.clear();
    tagRules.clear();
    universalRules.clear();
  }

  // indexed by selectorText
  void findBestRuleSetAndAdd(CSSStyleRule rule) {
    String? id, className, attributeName, tagName, pseudoElementName, pseudoFunctionName;

    for (final selector in rule.selectorGroup.selectors) {
      for (final simpleSelectorSequence in selector.simpleSelectorSequences) {
        final simpleSelector = simpleSelectorSequence.simpleSelector;
        switch (simpleSelector.runtimeType) {
          case IdSelector:
            id = simpleSelector.name;
            break;
          case ClassSelector:
            className = simpleSelector.name;
            break;
          case AttributeSelector:
            attributeName = simpleSelector.name;
            break;
          case ElementSelector:
            tagName = simpleSelector.name;
            break;
        }
      }
    }

    void insertRule(String key, CSSRule rule, CSSMap map) {
      List<CSSRule>? rules = map[key] ?? [];
      rules.add(rule);
      map[key] = rules;
    }

    if (id != null && id.isNotEmpty == true) {
      insertRule(id, rule, idRules);
      return;
    }

    if (className != null && className.isNotEmpty == true) {
      insertRule(className, rule, classRules);
      return;
    }

    if (attributeName != null && attributeName.isNotEmpty == true) {
      insertRule(attributeName, rule, attributeRules);
      return;
    }

    if (tagName != null && tagName.isNotEmpty == true) {
      insertRule(tagName, rule, tagRules);
      return;
    }
    universalRules.add(rule);
  }
}
