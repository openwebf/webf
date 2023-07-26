/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/css/query_selector.dart';

bool kShowUnavailableCSSProperties = false;

class ElementRuleCollector {
  bool matchedAnyRule(RuleSet ruleSet, Element element) {
    return matchedRules(ruleSet, element).isNotEmpty;
  }

  List<CSSStyleRule> matchedPseudoRules(RuleSet ruleSet, Element element) {
    if (ruleSet.pseudoRules.isEmpty) {
      return [];
    }
    List<CSSRule> rules = _collectMatchingRulesForList(ruleSet.pseudoRules, element);
    return rules.map((e) => e as CSSStyleRule).toList();
  }

  List<CSSRule> matchedRules(RuleSet ruleSet, Element element) {
    List<CSSRule> matchedRules = [];

    if (ruleSet.isEmpty) {
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
    final rules = matchedRules(ruleSet, element);
    CSSStyleDeclaration declaration = CSSStyleDeclaration();
    if (rules.isEmpty) {
      return declaration;
    }

    // sort selector
    rules.sort((leftRule, rightRule) {
      if (leftRule is! CSSStyleRule || rightRule is! CSSStyleRule) {
        return 0;
      }
      int isCompare = leftRule.selectorGroup.matchSpecificity.compareTo(rightRule.selectorGroup.matchSpecificity);
      if (isCompare == 0) {
        return leftRule.position.compareTo(rightRule.position);
      }
      return isCompare;
    });

    // Merge all the rules
    for (CSSRule rule in rules) {
      if (rule is CSSStyleRule) {
        declaration.union(rule.declaration);
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
        if (kShowUnavailableCSSProperties) {
          print('selector evaluator error: $error');
        }
      }
    }
    return matchedRules;
  }
}
