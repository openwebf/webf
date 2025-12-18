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

typedef CSSMap = HashMap<String, List<CSSRule>>;

class RuleSet {
  final Document ownerDocument;
  RuleSet(this.ownerDocument);

  bool get isEmpty =>
      idRules.isEmpty &&
      classRules.isEmpty &&
      attributeRules.isEmpty &&
      tagRules.isEmpty &&
      universalRules.isEmpty &&
      pseudoRules.isEmpty &&
      keyframesRules.isEmpty;

  final CSSMap idRules = HashMap();
  final CSSMap classRules = HashMap();
  final CSSMap attributeRules = HashMap();
  final CSSMap tagRules = HashMap();
  final List<CSSRule> universalRules = [];
  final List<CSSRule> pseudoRules = [];

  final Map<String, CSSKeyframesRule> keyframesRules = {};

  int _lastPosition = 0;

  void addRules(List<CSSRule> rules, { required String? baseHref }) {
    for (CSSRule rule in rules) {
      addRule(rule, baseHref: baseHref);
    }
  }

  void addRule(CSSRule rule, { required String? baseHref }) {
    rule.position = _lastPosition++;
    if (rule is CSSStyleRule) {
      for (final selector in rule.selectorGroup.selectors) {
        findBestRuleSetAndAdd(selector, rule);
      }
    } else if (rule is CSSKeyframesRule) {
      keyframesRules[rule.name] = rule;
    } else if (rule is CSSFontFaceRule) {
      CSSFontFace.resolveFontFaceRules(rule, ownerDocument.contextId!, baseHref);
    } else if (rule is CSSMediaDirective) {
      // doNothing
    } else if (rule is CSSImportRule) {
      // @import rules are resolved and flattened during stylesheet load.
      // Ignore any leftover import rules.
    } else {
      assert(false, 'Unsupported rule type: ${rule.runtimeType}');
    }
  }

  void reset() {
    idRules.clear();
    classRules.clear();
    attributeRules.clear();
    tagRules.clear();
    universalRules.clear();
    pseudoRules.clear();
  }

  // indexed by selectorText
  void findBestRuleSetAndAdd(Selector selector, CSSRule rule) {
    // Enforce CSS rule: a pseudo-element must be the last simple selector
    // in a compound selector. If any simple selector appears after a
    // pseudo-element, the selector is invalid and must not match.
    final List<SimpleSelectorSequence> seqs = selector.simpleSelectorSequences;
    for (int i = 0; i < seqs.length; i++) {
      final s = seqs[i].simpleSelector;
      if (s is PseudoElementSelector || s is PseudoElementFunctionSelector) {
        if (i != seqs.length - 1) {
          // Invalid selector like `P:first-line.three`; drop this rule.
          return;
        }
        break;
      }
    }

    // Choose the best indexing key from the RIGHTMOST COMPOUND only, with
    // priority: id > class > attribute > tag > legacy pseudo > universal.
    // Build the rightmost compound by walking from the end until a combinator
    // boundary.
    final List<SimpleSelector> rightmost = <SimpleSelector>[];
    for (final seq in seqs.reversed) {
      rightmost.add(seq.simpleSelector);
      if (seq.combinator != TokenKind.COMBINATOR_NONE) break;
    }

    String? id;
    String? className;
    String? attributeName;
    String? tagName;
    String? legacyPseudo;

    // Scan for best key across the compound (no early break on pseudo).
    for (final simple in rightmost) {
      if (simple is IdSelector) {
        id ??= simple.name;
      } else if (simple is ClassSelector) {
        className ??= simple.name;
      } else if (simple is AttributeSelector) {
        attributeName ??= simple.name;
      } else if (simple is ElementSelector && !simple.isWildcard) {
        tagName ??= simple.name;
      } else if (simple is PseudoClassSelector || simple is PseudoElementSelector) {
        final name = (simple as dynamic).name as String; // both have name
        if (_isLegacyPsuedoClass(name)) legacyPseudo ??= name;
      } else if (simple is PseudoClassFunctionSelector) {
        // ignore function pseudos for bucketing
      } else if (simple is NegationSelector) {
        // ignore :not() for bucketing; prefer other keys if present
      }
    }

    void insertRule(String key, CSSRule rule, CSSMap map) {
      List<CSSRule>? rules = map[key] ?? [];
      rules.add(rule);
      map[key] = rules;
    }

    if (id != null && id.isNotEmpty) {
      insertRule(id, rule, idRules);
      return;
    }

    if (className != null && className.isNotEmpty) {
      insertRule(className, rule, classRules);
      return;
    }

    if (attributeName != null && attributeName.isNotEmpty) {
      insertRule(attributeName.toUpperCase(), rule, attributeRules);
      return;
    }

    if (tagName != null && tagName.isNotEmpty) {
      insertRule(tagName.toUpperCase(), rule, tagRules);
      return;
    }

    if (legacyPseudo != null) {
      pseudoRules.add(rule);
      return;
    }

    universalRules.add(rule);
  }

  static bool _isLegacyPsuedoClass(String name) {
    // TODO: :first-letter/line match elements.
    switch (name) {
      case 'before':
      case 'after':
      case 'first-letter':
      case 'first-line':
        return true;
      default:
        return false;
    }
  }
}
