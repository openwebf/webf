/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/css/query_selector.dart';

bool kShowUnavailableCSSProperties = false;

class ElementRuleCollector {
  bool matchedAnyRule(RuleSet ruleSet, Element element) {
    return matchedRules(ruleSet, element).isNotEmpty;
  }

  List<CSSStyleRule> matchedPseudoRules(RuleSet ruleSet, Element element) {

    final SelectorEvaluator evaluator = SelectorEvaluator();

    // Collect candidates from all indexed buckets because many pseudo-element
    // selectors (e.g., ".foo div::before") are indexed under tag/class/id
    // buckets for matching efficiency.
    final List<CSSRule> candidates = [];

    // #id
    String? id = element.id;
    if (id != null) {
      candidates.addAll(_collectMatchingRulesForList(
        ruleSet.idRules[id],
        element,
        evaluator: evaluator,
        includePseudo: true,
        enableAncestryFastPath: false,
      ));
    }

    // .class
    for (final String className in element.classList) {
      candidates.addAll(_collectMatchingRulesForList(
        ruleSet.classRules[className],
        element,
        evaluator: evaluator,
        includePseudo: true,
        enableAncestryFastPath: false,
      ));
    }

    // [attr]
    for (final String attribute in element.attributes.keys) {
      candidates.addAll(_collectMatchingRulesForList(
        ruleSet.attributeRules[attribute.toUpperCase()],
        element,
        evaluator: evaluator,
        includePseudo: true,
        enableAncestryFastPath: false,
      ));
    }

    // tag
    final String tagLookup = element.tagName.toUpperCase();
    candidates.addAll(_collectMatchingRulesForList(
      ruleSet.tagRules[tagLookup],
      element,
      evaluator: evaluator,
      includePseudo: true,
      enableAncestryFastPath: false,
    ));

    // universal
    candidates.addAll(_collectMatchingRulesForList(
      ruleSet.universalRules,
      element,
      evaluator: evaluator,
      includePseudo: true,
      enableAncestryFastPath: false,
    ));

    // legacy pseudo bucket (for selectors without a better rightmost key)
    candidates.addAll(_collectMatchingRulesForList(
      ruleSet.pseudoRules,
      element,
      evaluator: evaluator,
      includePseudo: true,
      enableAncestryFastPath: false,
    ));

    // Deduplicate while preserving order.
    final List<CSSStyleRule> list = [];
    final Set<CSSStyleRule> seen = {};
    for (final CSSRule r in candidates) {
      if (r is CSSStyleRule && !seen.contains(r)) {
        seen.add(r);
        list.add(r);
      }
    }


    return list;
  }

  List<CSSRule> matchedRules(RuleSet ruleSet, Element element) {
    List<CSSRule> matchedRules = [];

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
    matchedRules.addAll(_collectMatchingRulesForList(
      listTag,
      element,
      evaluator: evaluator,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: ancestorTokens,
    ));

    // universal
    matchedRules.addAll(_collectMatchingRulesForList(
      ruleSet.universalRules,
      element,
      evaluator: evaluator,
      enableAncestryFastPath: DebugFlags.enableCssAncestryFastPath,
      ancestorTokens: ancestorTokens,
    ));



    return matchedRules;
  }

  // Variant used by stylesheet invalidation fallback. Allows skipping certain
  // categories (e.g., universal/tag) and capping universal evaluations to help
  // diagnose hotspots when many rules change at once.
  List<CSSRule> matchedRulesForInvalidate(RuleSet ruleSet, Element element) {
    List<CSSRule> matchedRules = [];
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
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules);
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
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules);
    }

    // Legacy pseudo rules (e.g., ::before/::after)
    if (ruleSet.pseudoRules.isNotEmpty) {
      matchedRules.addAll(_collectMatchingRulesForList(
        ruleSet.pseudoRules,
        element,
        evaluator: evaluator,
        enableAncestryFastPath: false,
        ancestorTokens: null,
        includePseudo: true,
      ));
      if (matchedRules.isNotEmpty) gotoReturn(matchedRules);
    }


    return matchedRules;
  }

  void gotoReturn(List<CSSRule> matchedRules) {

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

  List<CSSRule> _collectMatchingRulesForList(
    List<CSSRule>? rules,
    Element element, {
      required SelectorEvaluator evaluator,
      bool enableAncestryFastPath = true,
      _AncestorTokenSet? ancestorTokens,
      bool includePseudo = false,
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
          final bool hasPseudo = _selectorGroupHasPseudoElement(rule.selectorGroup);
          final bool hasNonPseudo = _selectorGroupHasNonPseudoElement(rule.selectorGroup);
          if (includePseudo) {
            if (hasPseudo) matchedRules.add(rule);
          } else {
            // For normal elements, only include the rule if there exists at least
            // one non-pseudo selector in the group that matches the element on its
            // own. This avoids accidentally including pseudo-element selectors like
            // ".angle::before" for the base element when the evaluator treats legacy
            // pseudos as matching.
            bool matchedByNonPseudo = false;
            if (hasNonPseudo) {
              for (final Selector sel in rule.selectorGroup.selectors) {
                final bool selHasPseudo = _selectorHasPseudoElement(sel);
                if (!selHasPseudo) {
                  final SelectorGroup single = SelectorGroup(<Selector>[sel]);
                  if (evaluator.matchSelector(single, element)) {
                    matchedByNonPseudo = true;
                    break;
                  }
                }
              }
            }
            if (matchedByNonPseudo) {
              matchedRules.add(rule);
            } else {
              if (DebugFlags.enableCssTrace) {
                final selText = rule.selectorGroup.selectorText;
                cssLogger.finer('[CSS/Match] skip non-pseudo include for ${element.tagName} due to only-pseudo match: "$selText"');
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
    return matchedRules;
  }

  bool _selectorGroupHasPseudoElement(SelectorGroup selectorGroup) {
    for (final Selector selector in selectorGroup.selectors) {
      for (final SimpleSelectorSequence seq in selector.simpleSelectorSequences) {
        final simple = seq.simpleSelector;
        if (simple is PseudoElementSelector || simple is PseudoElementFunctionSelector) {
          return true;
        }
      }
    }
    return false;
  }

  bool _selectorGroupHasNonPseudoElement(SelectorGroup selectorGroup) {
    for (final Selector selector in selectorGroup.selectors) {
      for (final SimpleSelectorSequence seq in selector.simpleSelectorSequences) {
        final simple = seq.simpleSelector;
        // Any non-pseudo simple selector (including universal '*', tag, class, id, attribute)
        // indicates the group targets normal elements as well.
        if (simple is! PseudoElementSelector && simple is! PseudoElementFunctionSelector) {
          return true;
        }
      }
    }
    return false;
  }

  bool _selectorHasPseudoElement(Selector selector) {
    for (final SimpleSelectorSequence seq in selector.simpleSelectorSequences) {
      final simple = seq.simpleSelector;
      if (simple is PseudoElementSelector || simple is PseudoElementFunctionSelector) {
        return true;
      }
    }
    return false;
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
