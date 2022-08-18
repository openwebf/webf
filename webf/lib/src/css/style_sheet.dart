/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';

abstract class StyleSheet {}

const String _CSSStyleSheetType = 'text/css';

// https://drafts.csswg.org/cssom-1/#cssstylesheet
class CSSStyleSheet implements StyleSheet, Comparable {
  String type = _CSSStyleSheetType;

  /// A Boolean indicating whether the stylesheet is disabled. False by default.
  bool disabled = false;

  /// A string containing the baseURL used to resolve relative URLs in the stylesheet.
  String? href;

  final String content;

  List<CSSRule> get cssRules => _cssRules;
  late List<CSSRule> _cssRules;

  CSSStyleSheet(this.content, this._cssRules, {this.disabled = false, this.href});

  CSSStyleSheet.from(this.content, {this.disabled = false, this.href}) {
    _cssRules = CSSParser(content).parseRules();
  }

  insertRule(String text, int index) {
    List<CSSRule> rules = CSSParser(text).parseRules();
    cssRules.addAll(rules);
  }

  /// Removes a rule from the stylesheet object.
  deleteRule(int index) {
    cssRules.removeAt(index);
  }

  /// Synchronously replaces the content of the stylesheet with the content passed into it.
  replaceSync(String text) {
    cssRules.clear();
    List<CSSRule> rules = CSSParser(text).parseRules();
    cssRules.addAll(rules);
  }

  Future replace(String text) async {
    return Future(() {
      replaceSync(text);
    });
  }

  @override
  bool operator ==(Object other) {
    return other is CSSStyleSheet && other.content == content;
  }

  @override
  int get hashCode => content.hashCode;

  CSSStyleSheet clone() {
    CSSStyleSheet sheet = CSSStyleSheet(content, List.from(cssRules), disabled: disabled, href: href);
    return sheet;
  }

  @override
  int compareTo(other) {
    if (other is! CSSStyleSheet) {
      return 0;
    }
    return hashCode.compareTo(other.hashCode);
  }
}
