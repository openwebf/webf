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
    // A fresh evaluator per pseudo match set is fine; these are separate passes.
    final SelectorEvaluator evaluator = SelectorEvaluator();
    List<CSSRule> rules = _collectMatchingRulesForList(
      ruleSet.pseudoRules,
      element,
      evaluator: evaluator,
      enableAncestryFastPath: false, // Pseudo rules often don't benefit from ancestry prechecks.
    );
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
    // Reuse a single evaluator per matchedRules() to avoid repeated allocations.
    final SelectorEvaluator evaluator = SelectorEvaluator();
    // Build ancestor token sets once per call if fast-path is enabled, to avoid
    // repeatedly walking the ancestor chain for each candidate rule.
    final _AncestorTokenSet? ancestorTokens = DebugFlags.enableCssAncestryFastPath
        ? _buildAncestorTokens(element)
        : null;

    if (ruleSet.isEmpty) {
      return matchedRules;
    }

    // #id
    String? id = element.id;
    if (id != null) {
      final list = ruleSet.idRules[id];
      candidateCount += (list?.length ?? 0);
      matchedRules.addAll(_collectMatchingRulesForList(
        list,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: ancestorTokens,
      ));
    }

    // .class
    for (String className in element.classList) {
      final list = ruleSet.classRules[className];
      candidateCount += (list?.length ?? 0);
      matchedRules.addAll(_collectMatchingRulesForList(
        list,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: ancestorTokens,
      ));
    }

    // attribute selector
    for (String attribute in element.attributes.keys) {
      final list = ruleSet.attributeRules[attribute.toUpperCase()];
      candidateCount += (list?.length ?? 0);
      matchedRules.addAll(_collectMatchingRulesForList(
        list,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: ancestorTokens,
      ));
    }

    // tag selectors are stored uppercase; normalize element tag for lookup.
    final String tagLookup = element.tagName.toUpperCase();
    final listTag = ruleSet.tagRules[tagLookup];
    candidateCount += (listTag?.length ?? 0);
    matchedRules.addAll(_collectMatchingRulesForList(
      listTag,
      element,
      evaluator: evaluator,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: ancestorTokens,
    ));

    // universal
    candidateCount += ruleSet.universalRules.length;
    matchedRules.addAll(_collectMatchingRulesForList(
      ruleSet.universalRules,
      element,
      evaluator: evaluator,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: ancestorTokens,
    ));

    if (perf && sw != null) {
      CSSPerf.recordMatch(durationMs: sw.elapsedMilliseconds, candidateCount: candidateCount, matchedCount: matchedRules.length);
    }

    return matchedRules;
  }

  // Variant used by stylesheet invalidation fallback. Allows skipping certain
  // categories (e.g., universal/tag) and capping universal evaluations to help
  // diagnose hotspots when many rules change at once.
  List<CSSRule> matchedRulesForInvalidate(RuleSet ruleSet, Element element) {
    List<CSSRule> matchedRules = [];
    final bool perf = DebugFlags.enableCssPerf;
    final Stopwatch? sw = perf ? (Stopwatch()..start()) : null;
    // Reuse a single evaluator per call.
    final SelectorEvaluator evaluator = SelectorEvaluator();
    final _AncestorTokenSet? ancestorTokens = DebugFlags.enableCssAncestryFastPath
        ? _buildAncestorTokens(element)
        : null;

    if (ruleSet.isEmpty) return matchedRules;

    // NOTE: id/class/attribute selectors are handled via document indices in
    // StyleNodeManager.invalidateElementStyle(). Do not evaluate them here.

    // tag selectors (optional)
    if (!DebugFlags.enableCssInvalidateSkipTag) {
      final String tagLookup = element.tagName.toUpperCase();
      final listTag = ruleSet.tagRules[tagLookup];
      matchedRules.addAll(_collectMatchingRulesForList(
        listTag,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: ancestorTokens,
      ));
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules, sw);
    }

    // universal (optional + capped or heuristic skip)
    final bool skipUniversal = DebugFlags.enableCssInvalidateSkipUniversal ||
        (DebugFlags.enableCssInvalidateUniversalHeuristics &&
            ruleSet.universalRules.length > DebugFlags.cssInvalidateUniversalSkipThreshold);
    if (!skipUniversal) {
      final int cap = DebugFlags.cssInvalidateUniversalCap;
      if (cap > 0 && ruleSet.universalRules.length > cap) {
        matchedRules.addAll(_collectMatchingRulesForList(
          ruleSet.universalRules.take(cap).toList(),
          element,
          evaluator: evaluator,
          enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
          ancestorTokens: ancestorTokens,
        ));
      } else {
        matchedRules.addAll(_collectMatchingRulesForList(
          ruleSet.universalRules,
          element,
          evaluator: evaluator,
          enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
          ancestorTokens: ancestorTokens,
        ));
      }
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules, sw);
    }

    // Legacy pseudo rules (e.g., ::before/::after)
    if (ruleSet.pseudoRules.isNotEmpty) {
      matchedRules.addAll(_collectMatchingRulesForList(
        ruleSet.pseudoRules,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: false,
        ancestorTokens: null,
      ));
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules, sw);
    }

    if (sw != null) {
      // We do not record candidateCount breakdown here to keep overhead low.
      CSSPerf.recordMatch(durationMs: sw.elapsedMilliseconds, candidateCount: 0, matchedCount: matchedRules.length);
    }
    return matchedRules;
  }

  void gotoReturn(List<CSSRule> matchedRules, Stopwatch? sw) {
    if (sw != null) {
      CSSPerf.recordMatch(durationMs: sw.elapsedMilliseconds, candidateCount: 0, matchedCount: matchedRules.length);
    }
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

  List<CSSRule> _collectMatchingRulesForList(
    List<CSSRule>? rules,
    Element element, {
    required SelectorEvaluator evaluator,
    bool enableAncestryFastPath = true,
    _AncestorTokenSet? ancestorTokens,
  }) {
    if (rules == null || rules.isEmpty) {
      return [];
    }
    List<CSSRule> matchedRules = [];
    for (CSSRule rule in rules) {
      if (rule is! CSSStyleRule) {
        continue;
      }
      // Cheap ancestry key precheck for descendant combinators: if a selector
      // requires an ancestor ID/class/tag that's not present in the chain, skip
      // the expensive evaluator entirely.
      if (enableAncestryFastPath) {
        final _AncestorHints hints = _collectDescendantAncestorHints(rule.selectorGroup);
        if (!hints.isEmpty) {
          if (!_ancestorChainSatisfiesHints(element, hints, tokens: ancestorTokens)) {
            continue;
          }
        }
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

  // A minimal hint collector that gathers ancestor ID/class/tag tokens from
  // groups that are connected via DESCENDANT combinators. Used for an early
  // presence check along the ancestor chain.
  _AncestorHints _collectDescendantAncestorHints(SelectorGroup selectorGroup) {
    final hints = _AncestorHints();
    for (final Selector selector in selectorGroup.selectors) {
      // Build right-to-left groups as in SelectorEvaluator.
      final List<List<SimpleSelector>> groups = <List<SimpleSelector>>[];
      final List<int> groupCombinators = <int>[];
      List<SimpleSelector> current = <SimpleSelector>[];
      for (final seq in selector.simpleSelectorSequences.reversed) {
        current.add(seq.simpleSelector);
        if (seq.combinator != TokenKind.COMBINATOR_NONE) {
          groups.add(current);
          groupCombinators.add(seq.combinator);
          current = <SimpleSelector>[];
        }
      }
      if (current.isNotEmpty) {
        groups.add(current);
        groupCombinators.add(TokenKind.COMBINATOR_NONE);
      }

      // Walk combinators; when it’s a descendant combinator from the rightmost
      // to the next group, collect simple tokens from that ancestor group.
      for (int gi = 0; gi < groups.length - 1; gi++) {
        final int combinator = groupCombinators[gi];
        if (combinator == TokenKind.COMBINATOR_DESCENDANT) {
          final List<SimpleSelector> ancestorGroup = groups[gi + 1];
          for (final SimpleSelector s in ancestorGroup) {
            if (s is IdSelector) {
              hints.ids.add(s.name);
            } else if (s is ClassSelector) {
              hints.classes.add(s.name);
            } else if (s is ElementSelector && !s.isWildcard) {
              hints.tags.add(s.name.toUpperCase());
            }
          }
        }
      }
    }
    return hints;
  }

  bool _ancestorChainSatisfiesHints(Element element, _AncestorHints hints, { _AncestorTokenSet? tokens }) {
    if (hints.isEmpty) return true;
    final _AncestorTokenSet localTokens = tokens ?? _buildAncestorTokens(element);
    // All required tokens must be present somewhere in the chain.
    if (hints.ids.isNotEmpty && !localTokens.ids.containsAll(hints.ids)) return false;
    if (hints.classes.isNotEmpty && !localTokens.classes.containsAll(hints.classes)) return false;
    if (hints.tags.isNotEmpty && !localTokens.tags.containsAll(hints.tags)) return false;
    return true;
  }

  _AncestorTokenSet _buildAncestorTokens(Element element) {
    final Set<String> ids = {};
    final Set<String> classes = {};
    final Set<String> tags = {};
    Element? cursor = element.parentElement;
    while (cursor != null) {
      if (cursor.id != null && cursor.id!.isNotEmpty) ids.add(cursor.id!);
      if (cursor.classList.isNotEmpty) classes.addAll(cursor.classList);
      tags.add(cursor.tagName.toUpperCase());
      cursor = cursor.parentElement;
    }
    return _AncestorTokenSet(ids: ids, classes: classes, tags: tags);
  }
}

class _AncestorHints {
  final Set<String> ids = {};
  final Set<String> classes = {};
  final Set<String> tags = {};

  bool get isEmpty => ids.isEmpty && classes.isEmpty && tags.isEmpty;
}

class _AncestorTokenSet {
  final Set<String> ids;
  final Set<String> classes;
  final Set<String> tags;
  _AncestorTokenSet({required this.ids, required this.classes, required this.tags});
}
