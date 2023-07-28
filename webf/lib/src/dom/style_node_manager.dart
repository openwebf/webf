/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:collection/collection.dart';

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';

/*
  Handling element style updates
  1. log all style element
  2. collect stylesheets
  3. calculate changed rule set
  4. invalidated element
 */
class StyleNodeManager {
  final List<Node> _styleSheetCandidateNodes = [];

  final List<CSSStyleSheet> _pendingStyleSheets = [];

  bool get hasPendingStyleSheet => _pendingStyleSheets.isNotEmpty;
  bool _isStyleSheetCandidateNodeChanged = false;
  bool get isStyleSheetCandidateNodeChanged => _isStyleSheetCandidateNodeChanged;

  final Document document;

  StyleNodeManager(this.document);

  void addStyleSheetCandidateNode(Node node) {
    if (!node.isConnected) {
      return;
    }
    if (_styleSheetCandidateNodes.isEmpty) {
      _styleSheetCandidateNodes.add(node);
      _isStyleSheetCandidateNodeChanged = true;
      return;
    }

    // Determine an appropriate insertion point.
    for (int i = _styleSheetCandidateNodes.length - 1; i >= 0; i--) {
      DocumentPosition position = _styleSheetCandidateNodes[i].compareDocumentPosition(node);
      if (position == DocumentPosition.FOLLOWING) {
        _styleSheetCandidateNodes.insert(i + 1, node);
        _isStyleSheetCandidateNodeChanged = true;
        return;
      }
    }

    _styleSheetCandidateNodes.insert(0, node);
    _isStyleSheetCandidateNodeChanged = true;
  }

  void removeStyleSheetCandidateNode(Node node) {
    _styleSheetCandidateNodes.remove(node);
    _isStyleSheetCandidateNodeChanged = true;
  }

  void appendPendingStyleSheet(CSSStyleSheet styleSheet) {
    _pendingStyleSheets.add(styleSheet);
  }

  void removePendingStyleSheet(CSSStyleSheet styleSheet) {
    _pendingStyleSheets.removeWhere((element) => element == styleSheet);
  }

  // TODO(jiangzhou): cache stylesheet
  bool updateActiveStyleSheets({bool rebuild = false}) {
    List<CSSStyleSheet> newSheets = _collectActiveStyleSheets();
    if (newSheets.isEmpty) {
      return false;
    }
    newSheets = newSheets.where((element) => element.cssRules.isNotEmpty).toList();
    if (rebuild == false) {
      RuleSet changedRuleSet = analyzeStyleSheetChangeRuleSet(document.styleSheets, newSheets);
      if (changedRuleSet.isEmpty) {
        return false;
      }
      invalidateElementStyle(changedRuleSet);
    } else {
      final root = document.documentElement;
      if (root != null) {
        document.styleDirtyElements.add(root);
      }
    }
    document.handleStyleSheets(newSheets);
    _pendingStyleSheets.clear();
    _isStyleSheetCandidateNodeChanged = false;
    return true;
  }

  List<CSSStyleSheet> _collectActiveStyleSheets() {
    List<CSSStyleSheet> styleSheetsForStyleSheetsList = [];
    for (Node node in _styleSheetCandidateNodes) {
      if (node is LinkElement && !node.disabled && !node.loading && node.styleSheet != null) {
        styleSheetsForStyleSheetsList.add(node.styleSheet!);
      } else if (node is StyleElementMixin && node.styleSheet != null) {
        styleSheetsForStyleSheetsList.add(node.styleSheet!);
      }
    }
    return styleSheetsForStyleSheetsList;
  }

  void invalidateElementStyle(RuleSet changedRuleSet) {
    ElementRuleCollector collector = ElementRuleCollector();
    List<Node> stack = [document];
    while (stack.isNotEmpty) {
      Node node = stack.removeLast();
      if (node is! Element) {
        continue;
      }
      final rules = collector.matchedRules(changedRuleSet, node);
      if (rules.isNotEmpty) {
        document.styleDirtyElements.add(node);
      }
      if (node.childNodes.isNotEmpty) {
        stack.addAll(node.childNodes);
      }
    }
  }

  RuleSet analyzeStyleSheetChangeRuleSet(List<CSSStyleSheet> oldSheets, List<CSSStyleSheet> newSheets) {
    RuleSet ruleSet = RuleSet(document);

    final oldSheetsCount = oldSheets.length;
    final newSheetsCount = newSheets.length;

    final minCount = math.min(oldSheetsCount, newSheetsCount);

    Function equals = ListEquality().equals;

    int index = 0;
    for (; index < minCount && oldSheets[index] == newSheets[index]; index++) {
      if (equals(oldSheets[index].cssRules, newSheets[index].cssRules)) {
        continue;
      }
      ruleSet.addRules(newSheets[index].cssRules, baseHref: newSheets[index].href);
      ruleSet.addRules(oldSheets[index].cssRules, baseHref: oldSheets[index].href);
    }

    if (index == oldSheetsCount) {
      for (; index < newSheetsCount; index++) {
        ruleSet.addRules(newSheets[index].cssRules, baseHref: newSheets[index].href);
      }
      return ruleSet;
    }

    if (index == newSheetsCount) {
      for (; index < oldSheetsCount; index++) {
        ruleSet.addRules(oldSheets[index].cssRules, baseHref: oldSheets[index].href);
      }
      return ruleSet;
    }

    List<CSSStyleSheet> mergeSorted = [];
    mergeSorted.addAll(oldSheets.sublist(index));
    mergeSorted.addAll(newSheets.sublist(index));
    mergeSorted.sort();

    for (int index = 0; index < mergeSorted.length; index++) {
      CSSStyleSheet sheet = mergeSorted[index];
      if (index + 1 < mergeSorted.length) {
        ++index;
      }
      CSSStyleSheet sheet1 = mergeSorted[index];
      if (index == mergeSorted.length - 1 || sheet != sheet1) {
        ruleSet.addRules(sheet1.cssRules, baseHref: sheet1.href);
        continue;
      }

      if (index + 1 < mergeSorted.length) {
        ++index;
      }
      CSSStyleSheet sheet2 = mergeSorted[index];
      if (equals(sheet1.cssRules, sheet2.cssRules)) {
        continue;
      }

      ruleSet.addRules(sheet1.cssRules, baseHref: sheet1.href);
      ruleSet.addRules(sheet2.cssRules, baseHref: sheet2.href);
    }

    return ruleSet;
  }
}
