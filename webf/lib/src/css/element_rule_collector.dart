/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/css/selector_evaluator.dart';

class ElementRuleCollector {
  bool matchedAnyRule(RuleSet ruleSet, Element element) {
    return _matchedRules(ruleSet, element).isNotEmpty;
  }

  List<CSSRule> _matchedRules(RuleSet ruleSet, Element element) {
    List<CSSRule> matchedRules = [];

    if (ruleSet.rules.isEmpty) {
      return matchedRules;
    }

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
      matchedRules.addAll(_collectMatchingRulesForList(ruleSet.attributeRules[attribute.toUpperCase()], element));
    }

    // tag
    matchedRules.addAll(_collectMatchingRulesForList(ruleSet.tagRules[element.tagName], element));

    // universal
    matchedRules.addAll(_collectMatchingRulesForList(ruleSet.universalRules, element));

    return matchedRules;
  }

  CSSStyleDeclaration collectionFromRuleSet(RuleSet ruleSet, Element element) {
    final matchedRules = _matchedRules(ruleSet, element);
    CSSStyleDeclaration declaration = CSSStyleDeclaration();
    if (matchedRules.isEmpty) {
      return declaration;
    }

    // sort selector
    matchedRules.sort((leftRule, rightRule) {
      if (leftRule is! CSSStyleRule || rightRule is! CSSStyleRule) {
        return 0;
      }
      int isCompare = leftRule.selectorGroup.specificity.compareTo(rightRule.selectorGroup.specificity);
      if (isCompare == 0) {
        return ruleSet.rules.indexOf(leftRule).compareTo(ruleSet.rules.indexOf(rightRule));
      }
      return isCompare;
    });

    // Merge all the rules
    for (CSSRule rule in matchedRules) {
      if (rule is CSSStyleRule) {
        declaration.merge(rule.declaration);
      }
    }
    return declaration;
  }

  List<CSSRule> _collectMatchingRulesForList(List<CSSRule>? rules, Element element) {
    if (rules == null || rules.isEmpty) {
      return [];
    }
    List<CSSRule> matchedRules = [];
    SelectorEvaluator evaluator = SelectorEvaluator();
    for (CSSRule rule in rules) {
      if (rule is! CSSStyleRule) {
        continue;
      }
      try {
        if (evaluator.matchSelector(rule.selectorGroup, element)) {
          matchedRules.add(rule);
        }
      } catch (error) {
        print('selector evaluator error: $error');
      }
    }
    return matchedRules;
  }
}
