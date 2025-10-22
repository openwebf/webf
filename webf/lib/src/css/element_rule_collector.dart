/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/src/foundation/logger.dart';
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
    final bool perf = DebugFlags.enableCssPerf;
    final Stopwatch? sw = perf ? (Stopwatch()..start()) : null;
    List<CSSRule> rules = _collectMatchingRulesForList(ruleSet.pseudoRules, element);
    final list = rules.map((e) => e as CSSStyleRule).toList();
    if (perf && sw != null) {
      CSSPerf.recordPseudoMatch(durationMs: sw.elapsedMilliseconds, matchedCount: list.length);
    }
    if (kDebugMode && DebugFlags.enableCssLogs && list.isNotEmpty) {
      final examples = list.take(2).map((r) => r.selectorGroup.selectorText).toList();
      cssLogger.fine('[match] <' + element.tagName + '> pseudo matched=' + list.length.toString() +
          (examples.isNotEmpty ? ' e.g. ' + examples.join(', ') : ''));
    }
    return list;
  }

  List<CSSRule> matchedRules(RuleSet ruleSet, Element element) {
    List<CSSRule> matchedRules = [];
    final bool perf = DebugFlags.enableCssPerf;
    final Stopwatch? sw = perf ? (Stopwatch()..start()) : null;
    int candidateCount = 0;

    if (ruleSet.isEmpty) {
      return matchedRules;
    }

    // #id
    String? id = element.id;
    if (id != null) {
      final list = ruleSet.idRules[id];
      candidateCount += (list?.length ?? 0);
      matchedRules.addAll(_collectMatchingRulesForList(list, element));
    }

    // .class
    for (String className in element.classList) {
      final list = ruleSet.classRules[className];
      candidateCount += (list?.length ?? 0);
      matchedRules.addAll(_collectMatchingRulesForList(list, element));
    }

    // attribute selector
    for (String attribute in element.attributes.keys) {
      final list = ruleSet.attributeRules[attribute.toUpperCase()];
      candidateCount += (list?.length ?? 0);
      matchedRules.addAll(_collectMatchingRulesForList(list, element));
    }

    // tag selectors are stored uppercase; normalize element tag for lookup.
    final String tagLookup = element.tagName.toUpperCase();
    final listTag = ruleSet.tagRules[tagLookup];
    candidateCount += (listTag?.length ?? 0);
    matchedRules.addAll(_collectMatchingRulesForList(listTag, element));

    // universal
    candidateCount += ruleSet.universalRules.length;
    matchedRules.addAll(_collectMatchingRulesForList(ruleSet.universalRules, element));

    if (perf && sw != null) {
      CSSPerf.recordMatch(durationMs: sw.elapsedMilliseconds, candidateCount: candidateCount, matchedCount: matchedRules.length);
    }

    return matchedRules;
  }

  CSSStyleDeclaration collectionFromRuleSet(RuleSet ruleSet, Element element) {
    final rules = matchedRules(ruleSet, element);
    CSSStyleDeclaration declaration = CSSStyleDeclaration();
    if (rules.isEmpty) {
      return declaration;
    }

    if (kDebugMode && DebugFlags.enableCssLogs) {
      final examples = rules.whereType<CSSStyleRule>()
          .take(3)
          .map((r) => r.selectorGroup.selectorText)
          .toList();
      cssLogger.fine('[match] <' + element.tagName + '> matched rules=' + rules.length.toString() +
          (examples.isNotEmpty ? ' e.g. ' + examples.join(', ') : ''));
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
