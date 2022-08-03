/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

abstract class StyleSheet {}

const String _CSSStyleSheetType = 'text/css';

// https://drafts.csswg.org/cssom-1/#cssstylesheet
class CSSStyleSheet implements StyleSheet {
  String type = _CSSStyleSheetType;

  /// A Boolean indicating whether the stylesheet is disabled. False by default.
  bool disabled = false;

  /// A string containing the baseURL used to resolve relative URLs in the stylesheet.
  String? herf;

  final RuleSet ruleSet;

  CSSStyleSheet(this.ruleSet, {this.disabled = false, this.herf});

  insertRule(String text, int index) {
    List<CSSRule> rules = CSSParser(text).parseRules();
    for (CSSRule rule in rules) {
      ruleSet.addRule(rule);
    }
  }

  /// Removes a rule from the stylesheet object.
  deleteRule(int index) {
    ruleSet.deleteRule(index);
  }

  /// Synchronously replaces the content of the stylesheet with the content passed into it.
  replaceSync(String text) {
    ruleSet.reset();
    List<CSSRule> rules = CSSParser(text).parseRules();
    for (CSSRule rule in rules) {
      ruleSet.addRule(rule);
    }
  }

  replace(String text) {
    // TODO: put in next frame and return a future
    replaceSync(text);
  }
}
