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

  void addRules(List<CSSRule> rules) {
    for (CSSRule rule in rules) {
      addRule(rule);
    }
  }

  void addRule(CSSRule rule) {
    rules.add(rule);
    if (rule is CSSStyleRule) {
      for (final selector in rule.selectorGroup.selectors) {
        findBestRuleSetAndAdd(selector, rule);
      }
    } else {
      assert(false, 'Unsupported rule type: ${rule.runtimeType}');
    }
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
  void findBestRuleSetAndAdd(Selector selector, CSSRule rule) {
    String? id, className, attributeName, tagName, pseudoName;

    for (final simpleSelectorSequence in selector.simpleSelectorSequences.reversed) {
      final simpleSelector = simpleSelectorSequence.simpleSelector;
      if (simpleSelector.runtimeType == IdSelector) {
        id = simpleSelector.name;
      } else if (simpleSelector.runtimeType == ClassSelector) {
        className = simpleSelector.name;
      } else if (simpleSelector.runtimeType == AttributeSelector) {
        attributeName = simpleSelector.name;
      } else if (simpleSelector.runtimeType == ElementSelector) {
        if (simpleSelector.isWildcard) {
          break;
        }
        tagName = simpleSelector.name;
      } else if (simpleSelector.runtimeType == PseudoClassSelector ||
          simpleSelector.runtimeType == PseudoElementSelector) {
        pseudoName = simpleSelector.name;
      }

      if (id != null || className != null || attributeName != null || tagName != null || pseudoName != null) {
        break;
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
      insertRule(attributeName.toUpperCase(), rule, attributeRules);
      return;
    }

    if (tagName != null && tagName.isNotEmpty == true) {
      insertRule(tagName.toUpperCase(), rule, tagRules);
      return;
    }

    universalRules.add(rule);
  }
}
