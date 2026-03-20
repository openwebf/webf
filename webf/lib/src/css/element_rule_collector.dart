/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:collection';

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/css/query_selector.dart';

bool kShowUnavailableCSSProperties = false;

class SelectorAncestorTokenSet {
  final Element? _element;
  Set<String>? _ids;
  Set<String>? _classes;
  Set<String>? _tags;

  SelectorAncestorTokenSet._(
      this._element, this._ids, this._classes, this._tags);

  factory SelectorAncestorTokenSet.lazy(Element element) {
    return SelectorAncestorTokenSet._(element, null, null, null);
  }

  factory SelectorAncestorTokenSet.eager(
      {required Set<String> ids,
      required Set<String> classes,
      required Set<String> tags}) {
    return SelectorAncestorTokenSet._(null, ids, classes, tags);
  }

  Set<String> get ids {
    _ensureBuilt();
    return _ids!;
  }

  Set<String> get classes {
    _ensureBuilt();
    return _classes!;
  }

  Set<String> get tags {
    _ensureBuilt();
    return _tags!;
  }

  void _ensureBuilt() {
    if (_ids != null && _classes != null && _tags != null) {
      return;
    }

    final Set<String> ids = <String>{};
    final Set<String> classes = <String>{};
    final Set<String> tags = <String>{};
    Element? cursor = _element?.parentElement;
    while (cursor != null) {
      final String? cursorId = cursor.id;
      if (cursorId != null && cursorId.isNotEmpty) {
        ids.add(cursorId);
      }
      if (cursor.classList.isNotEmpty) {
        classes.addAll(cursor.classList);
      }
      tags.add(cursor.tagName.toUpperCase());
      cursor = cursor.parentElement;
    }

    _ids = ids;
    _classes = classes;
    _tags = tags;
  }
}

class ElementRuleCollector {
  SelectorAncestorTokenSet buildAncestorTokens(Element element) {
    return _buildAncestorTokens(element);
  }

  bool matchedAnyRule(RuleSet ruleSet, Element element) {
    return matchedRules(ruleSet, element).isNotEmpty;
  }

  bool canActivatePseudoClassOnTarget(
      RuleSet ruleSet, Element element, String pseudoClassName) {
    if (ruleSet.isEmpty) return false;

    final SelectorEvaluator evaluator = SelectorEvaluator();
    final String normalizedPseudo = pseudoClassName.toLowerCase();

    bool matchRules(List<CSSRule>? rules) {
      if (rules == null || rules.isEmpty) return false;
      for (final CSSRule rule in rules) {
        if (rule is! CSSStyleRule) continue;
        if (!selectorGroupHasRightmostPseudoClass(
            rule.selectorGroup, normalizedPseudo)) {
          continue;
        }
        if (evaluator.matchSelectorWithForcedPseudoClass(
          rule.selectorGroup,
          element,
          forcedElement: element,
          pseudoClass: normalizedPseudo,
        )) {
          return true;
        }
      }
      return false;
    }

    final String? id = element.id;
    if (id != null && matchRules(ruleSet.idRules[id])) {
      return true;
    }

    for (final String className in element.classList) {
      if (matchRules(ruleSet.classRules[className])) {
        return true;
      }
    }

    for (final String attribute in element.attributes.keys) {
      if (matchRules(ruleSet.attributeRules[attribute.toUpperCase()])) {
        return true;
      }
    }

    if (matchRules(ruleSet.tagRules[element.tagName.toUpperCase()])) {
      return true;
    }

    return matchRules(ruleSet.universalRules) ||
        matchRules(ruleSet.pseudoRules);
  }

  List<CSSStyleRule> matchedPseudoRules(RuleSet ruleSet, Element element,
      {SelectorAncestorTokenSet? ancestorTokens,
      SelectorEvaluator? evaluator}) {
    final SelectorEvaluator resolvedEvaluator = evaluator ?? SelectorEvaluator();
    final SelectorAncestorTokenSet? resolvedAncestorTokens = ancestorTokens ??
        (DebugFlags.enableCssAncestryFastPath
            ? _buildAncestorTokens(element)
            : null);

    // Collect candidates from all indexed buckets because many pseudo-element
    // selectors (e.g., ".foo div::before") are indexed under tag/class/id
    // buckets for matching efficiency.
    final List<CSSStyleRule> candidates = [];

    // #id
    String? id = element.id;
    if (id != null) {
      _collectMatchingRulesForList(
        ruleSet.idRules[id],
        element,
        evaluator: resolvedEvaluator,
        includePseudo: true,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: resolvedAncestorTokens,
        matchedRules: candidates,
      );
    }

    // .class
    for (final String className in element.classList) {
      _collectMatchingRulesForList(
        ruleSet.classRules[className],
        element,
        evaluator: resolvedEvaluator,
        includePseudo: true,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: resolvedAncestorTokens,
        matchedRules: candidates,
      );
    }

    // [attr]
    for (final String attribute in element.attributes.keys) {
      _collectMatchingRulesForList(
        ruleSet.attributeRules[attribute.toUpperCase()],
        element,
        evaluator: resolvedEvaluator,
        includePseudo: true,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: resolvedAncestorTokens,
        matchedRules: candidates,
      );
    }

    // tag
    final String tagLookup = element.tagName.toUpperCase();
    _collectMatchingRulesForList(
      ruleSet.tagRules[tagLookup],
      element,
      evaluator: resolvedEvaluator,
      includePseudo: true,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: resolvedAncestorTokens,
      matchedRules: candidates,
    );

    // universal
    _collectMatchingRulesForList(
      ruleSet.universalRules,
      element,
      evaluator: resolvedEvaluator,
      includePseudo: true,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: resolvedAncestorTokens,
      matchedRules: candidates,
    );

    // legacy pseudo bucket (for selectors without a better rightmost key)
    _collectMatchingRulesForList(
      ruleSet.pseudoRules,
      element,
      evaluator: resolvedEvaluator,
      includePseudo: true,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: resolvedAncestorTokens,
      matchedRules: candidates,
    );

    // Deduplicate while preserving order.
    final List<CSSStyleRule> list = [];
    final Set<CSSStyleRule> seen = LinkedHashSet<CSSStyleRule>.identity();
    for (final CSSStyleRule rule in candidates) {
      if (seen.add(rule)) {
        list.add(rule);
      }
    }

    return list;
  }

  List<CSSStyleRule> matchedRules(RuleSet ruleSet, Element element,
      {SelectorAncestorTokenSet? ancestorTokens,
      SelectorEvaluator? evaluator}) {
    final List<CSSStyleRule> matchedRules = <CSSStyleRule>[];

    // Reuse a single evaluator per matchedRules() to avoid repeated allocations.
    final SelectorEvaluator resolvedEvaluator = evaluator ?? SelectorEvaluator();
    // Share one lazily materialized ancestor token set across all candidate
    // checks in this match pass so we only walk the ancestor chain on demand.
    final SelectorAncestorTokenSet? resolvedAncestorTokens = ancestorTokens ??
        (DebugFlags.enableCssAncestryFastPath
            ? _buildAncestorTokens(element)
            : null);

    if (ruleSet.isEmpty) {
      return matchedRules;
    }

    // #id
    String? id = element.id;
    if (id != null) {
      final list = ruleSet.idRules[id];
      _collectMatchingRulesForList(
        list,
        element,
        evaluator: resolvedEvaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: resolvedAncestorTokens,
        matchedRules: matchedRules,
      );
    }

    // .class
    for (String className in element.classList) {
      final list = ruleSet.classRules[className];
      _collectMatchingRulesForList(
        list,
        element,
        evaluator: resolvedEvaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: resolvedAncestorTokens,
        matchedRules: matchedRules,
      );
    }

    // attribute selector
    for (String attribute in element.attributes.keys) {
      final list = ruleSet.attributeRules[attribute.toUpperCase()];
      _collectMatchingRulesForList(
        list,
        element,
        evaluator: resolvedEvaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: resolvedAncestorTokens,
        matchedRules: matchedRules,
      );
    }

    // tag selectors are stored uppercase; normalize element tag for lookup.
    final String tagLookup = element.tagName.toUpperCase();
    final listTag = ruleSet.tagRules[tagLookup];
    _collectMatchingRulesForList(
      listTag,
      element,
      evaluator: resolvedEvaluator,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: resolvedAncestorTokens,
      matchedRules: matchedRules,
    );

    // universal
    _collectMatchingRulesForList(
      ruleSet.universalRules,
      element,
      evaluator: resolvedEvaluator,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: resolvedAncestorTokens,
      matchedRules: matchedRules,
    );

    return matchedRules;
  }

  // Variant used by stylesheet invalidation fallback. Allows skipping certain
  // categories (e.g., universal/tag) and capping universal evaluations to help
  // diagnose hotspots when many rules change at once.
  List<CSSRule> matchedRulesForInvalidate(RuleSet ruleSet, Element element) {
    final List<CSSStyleRule> matchedRules = <CSSStyleRule>[];
    // Reuse a single evaluator per call.
    final SelectorEvaluator evaluator = SelectorEvaluator();
    final SelectorAncestorTokenSet? ancestorTokens =
        DebugFlags.enableCssAncestryFastPath
            ? _buildAncestorTokens(element)
            : null;

    if (ruleSet.isEmpty) return matchedRules;

    // NOTE: id/class/attribute selectors are handled via document indices in
    // StyleNodeManager.invalidateElementStyle(). Do not evaluate them here.

    // tag selectors (optional)
    if (!DebugFlags.enableCssInvalidateSkipTag) {
      final String tagLookup = element.tagName.toUpperCase();
      final listTag = ruleSet.tagRules[tagLookup];
      _collectMatchingRulesForList(
        listTag,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: ancestorTokens,
        matchedRules: matchedRules,
      );
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules);
    }

    // universal (optional + capped or heuristic skip)
    final bool skipUniversal = DebugFlags.enableCssInvalidateSkipUniversal ||
        (DebugFlags.enableCssInvalidateUniversalHeuristics &&
            ruleSet.universalRules.length >
                DebugFlags.cssInvalidateUniversalSkipThreshold);
    if (!skipUniversal) {
      final int cap = DebugFlags.cssInvalidateUniversalCap;
      if (cap > 0 && ruleSet.universalRules.length > cap) {
        _collectMatchingRulesForList(
          ruleSet.universalRules.take(cap).toList(),
          element,
          evaluator: evaluator,
          enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
          ancestorTokens: ancestorTokens,
          matchedRules: matchedRules,
        );
      } else {
        _collectMatchingRulesForList(
          ruleSet.universalRules,
          element,
          evaluator: evaluator,
          enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
          ancestorTokens: ancestorTokens,
          matchedRules: matchedRules,
        );
      }
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules);
    }

    // Legacy pseudo rules (e.g., ::before/::after)
    if (ruleSet.pseudoRules.isNotEmpty) {
      _collectMatchingRulesForList(
        ruleSet.pseudoRules,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
        ancestorTokens: ancestorTokens,
        includePseudo: true,
        matchedRules: matchedRules,
      );
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules);
    }

    return matchedRules.cast<CSSRule>();
  }

  void gotoReturn(List<CSSStyleRule> matchedRules) {}

  CSSStyleDeclaration collectionFromRuleSet(RuleSet ruleSet, Element element,
      {SelectorAncestorTokenSet? ancestorTokens, SelectorEvaluator? evaluator}) {
    return cascadeMatchedStyleRules(
        matchedRules(ruleSet, element,
            ancestorTokens: ancestorTokens, evaluator: evaluator),
        cacheVersion: ruleSet.ownerDocument.ruleSetVersion);
  }

  void _collectMatchingRulesForList(
    List<CSSRule>? rules,
    Element element, {
    required SelectorEvaluator evaluator,
    bool enableAncestryFastPath = true,
    SelectorAncestorTokenSet? ancestorTokens,
    bool includePseudo = false,
    required List<CSSStyleRule> matchedRules,
  }) {
    if (rules == null || rules.isEmpty) {
      return;
    }
    for (CSSRule rule in rules) {
      if (rule is! CSSStyleRule) {
        continue;
      }
      final SelectorGroup selectorGroup = rule.selectorGroup;
      final List<Selector> normalSelectors =
          selectorGroup.selectorsWithoutPseudoElement;
      if (!includePseudo && normalSelectors.isEmpty) {
        continue;
      }
      // Cheap ancestry key precheck for descendant combinators: if a selector
      // requires an ancestor ID/class/tag that's not present in the chain, skip
      // the expensive evaluator entirely.
      if (enableAncestryFastPath) {
        final Iterable<Selector> selectorsForHintCheck =
            includePseudo ? selectorGroup.selectors : normalSelectors;
        if (!_selectorsMayMatchAncestorHints(selectorsForHintCheck, element,
            tokens: ancestorTokens)) {
          continue;
        }
      }
      try {
        if (evaluator.matchSelector(selectorGroup, element)) {
          if (includePseudo) {
            if (selectorGroup.hasPseudoElement) {
              matchedRules.add(rule);
            }
          } else {
            final bool matchedByNonPseudo = !selectorGroup.hasPseudoElement ||
                _matchesAnySelectorWithoutSpecificity(
                    evaluator, normalSelectors, element);
            if (matchedByNonPseudo) {
              matchedRules.add(rule);
            } else {
              if (DebugFlags.enableCssTrace) {
                final selText = rule.selectorGroup.selectorText;
                cssLogger.finer(
                    '[CSS/Match] skip non-pseudo include for ${element.tagName} due to only-pseudo match: "$selText"');
              }
            }
          }
        }
      } catch (error) {
        if (kShowUnavailableCSSProperties) {
          cssLogger.warning('selector evaluator error: $error');
        }
      }
    }
  }

  bool _matchesAnySelectorWithoutSpecificity(
      SelectorEvaluator evaluator, List<Selector> selectors, Element element) {
    for (final Selector selector in selectors) {
      if (evaluator.matchSingleSelectorWithoutSpecificity(selector, element)) {
        return true;
      }
    }
    return false;
  }

  bool _selectorsMayMatchAncestorHints(
      Iterable<Selector> selectors, Element element,
      {SelectorAncestorTokenSet? tokens}) {
    SelectorAncestorTokenSet? localTokens = tokens;
    for (final Selector selector in selectors) {
      final SelectorAncestorHints hints = selector.descendantAncestorHints;
      if (hints.isEmpty) {
        return true;
      }
      localTokens ??= _buildAncestorTokens(element);
      if (_ancestorChainSatisfiesHints(localTokens, hints)) {
        return true;
      }
    }
    return false;
  }

  bool _ancestorChainSatisfiesHints(
      SelectorAncestorTokenSet tokens, SelectorAncestorHints hints) {
    if (hints.isEmpty) return true;
    // All required tokens must be present somewhere in the chain.
    if (hints.ids.isNotEmpty && !tokens.ids.containsAll(hints.ids))
      return false;
    if (hints.classes.isNotEmpty && !tokens.classes.containsAll(hints.classes))
      return false;
    if (hints.tags.isNotEmpty && !tokens.tags.containsAll(hints.tags))
      return false;
    return true;
  }

  SelectorAncestorTokenSet _buildAncestorTokens(Element element) {
    return SelectorAncestorTokenSet.lazy(element);
  }
}
