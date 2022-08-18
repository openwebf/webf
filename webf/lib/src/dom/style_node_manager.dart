/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:collection/collection.dart';

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

/*
  Handling element style updates
  1. log all style element
  2.
 */
class StyleNodeManager {
  final List<Node> _styleSheetCandidateNodes = [];

  final Document document;

  StyleNodeManager(this.document);

  void addStyleSheetCandidateNode(Node node) {
    if (!node.isConnected) {
      return;
    }
    if (_styleSheetCandidateNodes.isEmpty) {
      _styleSheetCandidateNodes.add(node);
      return;
    }

    // Determine an appropriate insertion point.
    for (int i = _styleSheetCandidateNodes.length - 1; i >= 0; i--) {
      DocumentPosition position = _styleSheetCandidateNodes[i].compareDocumentPosition(node);
      if (position == DocumentPosition.FOLLOWING) {
        _styleSheetCandidateNodes.insert(i + 1, node);
        return;
      }
    }

    _styleSheetCandidateNodes.insert(0, node);
  }

  void removeStyleSheetCandidateNode(Node node) {
    _styleSheetCandidateNodes.remove(node);
  }

  void updateActiveStyleSheets() {
    List<CSSStyleSheet> newSheets = _collectActiveStyleSheets();
    if (newSheets.isEmpty) {
      return;
    }
    newSheets = _collectActiveStyleSheets().where((element) => element.cssRules.isNotEmpty).toList();
    RuleSet changedRuleSet = analyzeStyleSheetChangeRuleSet(document.styleSheets, newSheets);
    invalidateElementStyle(changedRuleSet);
    document.handleStyleSheets(newSheets);
  }

  List<CSSStyleSheet> _collectActiveStyleSheets() {
    List<CSSStyleSheet> styleSheetsForStyleSheetsList = [];
    for (Node node in _styleSheetCandidateNodes) {
      if (node is LinkElement && !node.disabled && !node.loading && node.styleSheet != null) {
        styleSheetsForStyleSheetsList.add(node.styleSheet!);
      } else if (node is StyleElement && node.styleSheet != null) {
        styleSheetsForStyleSheetsList.add(node.styleSheet!);
      }
    }
    return styleSheetsForStyleSheetsList;
  }

  void invalidateElementStyle(RuleSet changedRuleSet) {
    ElementRuleCollector collector = ElementRuleCollector();
    document.visitChild((node) {
      if (node.childNodes.where((node) => node.needsStyleRecalculate).isNotEmpty) {
        node.needsStyleRecalculate = true;
      } else if (node is Element && node.isConnected) {
        if (collector.matchedAnyRule(changedRuleSet, node)) {
          node.needsStyleRecalculate = true;
        }
      }
    });
  }

  RuleSet analyzeStyleSheetChangeRuleSet(List<CSSStyleSheet> oldSheets, List<CSSStyleSheet> newSheets) {
    RuleSet ruleSet = RuleSet();

    final oldSheetsCount = oldSheets.length;
    final newSheetsCount = newSheets.length;

    final minCount = math.min(oldSheetsCount, newSheetsCount);

    Function equals = ListEquality().equals;

    int index = 0;
    for (; index < minCount && oldSheets[index] == newSheets[index]; index++) {
      if (equals(oldSheets[index].cssRules, newSheets[index].cssRules)) {
        continue;
      }
      ruleSet.addRules(newSheets[index].cssRules);
      ruleSet.addRules(oldSheets[index].cssRules);
    }

    if (index == oldSheetsCount) {
      for (; index < newSheetsCount; index++) {
        ruleSet.addRules(newSheets[index].cssRules);
      }
      return ruleSet;
    }

    if (index == newSheetsCount) {
      for (; index < oldSheetsCount; index++) {
        ruleSet.addRules(oldSheets[index].cssRules);
      }
      return ruleSet;
    }

    List<CSSStyleSheet> mergeSorted = [];
    mergeSorted.addAll(oldSheets.sublist(index));
    mergeSorted.addAll(newSheets.sublist(index));
    mergeSorted.sort();

    for (int index = 0; index < mergeSorted.length; index++) {
      CSSStyleSheet sheet = mergeSorted[index];
      CSSStyleSheet sheet1 = mergeSorted[++index];
      if (index == mergeSorted.length || sheet != sheet1) {
        ruleSet.addRules(sheet1.cssRules);
        continue;
      }

      CSSStyleSheet sheet2 = mergeSorted[++index];
      if (equals(sheet1.cssRules, sheet2.cssRules)) {
        continue;
      }

      ruleSet.addRules(sheet1.cssRules);
      ruleSet.addRules(sheet2.cssRules);
    }

    return ruleSet;
  }
}
