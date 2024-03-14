/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

typedef CSSMap = HashMap<String, List<CSSRule>>;

class RuleSet {
  final Document ownerDocument;
  RuleSet(this.ownerDocument);

  bool get isEmpty =>
      keyframesRules.isEmpty;

  final Map<String, CSSKeyframesRule> keyframesRules = {};

  int _lastPosition = 0;

  void addRules(List<CSSRule> rules, { required String? baseHref }) {
    for (CSSRule rule in rules) {
      addRule(rule, baseHref: baseHref);
    }
  }

  void addRule(CSSRule rule, { required String? baseHref }) {
    rule.position = _lastPosition++;
    if (rule is CSSKeyframesRule) {
      keyframesRules[rule.name] = rule;
    } else if (rule is CSSFontFaceRule) {
      CSSFontFace.resolveFontFaceRules(rule, ownerDocument.contextId!, baseHref);
    } else {
      assert(false, 'Unsupported rule type: ${rule.runtimeType}');
    }
  }

  static bool _isLegacyPsuedoClass(String name) {
    // TODO: :first-letter/line match elements.
    switch (name) {
      case 'before':
      case 'after':
        return true;
      case 'first-line':
      case 'first-letter':
      default:
        return false;
    }
  }
}
