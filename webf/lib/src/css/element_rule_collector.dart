/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/css/selector_checker.dart';

class ElementRuleCollector {

  CSSStyleDeclaration collectionFromRuleSet(RuleSet ruleSet, Element element) {

    List<CSSRule> matchedRules = [];

    // #id
    String? id = element.id;
    if (id != null) {
       matchedRules.addAll(_collectMatchingRulesForList(ruleSet.idRules[id], element));
    }

    // .class
    for (String className in element.classList) {
      matchedRules.addAll(_collectMatchingRulesForList(ruleSet.classRules[className], element));
    }

    // attribute selector
    for (String attribute in element.attributes.keys) {
      matchedRules.addAll(_collectMatchingRulesForList(ruleSet.attributeRules[attribute], element));
    }

    // tag
    matchedRules.addAll(_collectMatchingRulesForList(ruleSet.tagRules[element.tagName], element));

    // universal
    matchedRules.addAll(_collectMatchingRulesForList(ruleSet.universalRules, element));

    matchedRules.sort((leftRule, rightRule) {
      if (leftRule is! CSSStyleRule || rightRule is! CSSStyleRule) {
        return 0;
      }
      return leftRule.selectorGroup.specificity.compareTo(rightRule.selectorGroup.specificity);
    });

    CSSStyleDeclaration declaration = CSSStyleDeclaration();
    for (CSSRule rule in matchedRules.reversed) {
      if (rule is CSSStyleRule) {
        declaration.merge(rule.declaration);
      }
    }
    return declaration;
  }

  List<CSSRule> _collectMatchingRulesForList(List<CSSRule>? rules, Element element) {
    if (rules == null) {
      return [];
    }
    List<CSSRule> matchedRules = [];
    SelectorEvaluator evaluator = SelectorEvaluator();
    for (CSSRule rule in rules) {
      if (rule is! CSSStyleRule) {
        continue;
      }
      if (evaluator.matchSelector(rule.selectorGroup, element)) {
        matchedRules.add(rule);
      }
    }
    return matchedRules;
  }
}
