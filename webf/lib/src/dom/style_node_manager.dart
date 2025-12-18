/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/src/foundation/logger.dart';
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
  List<Node> get styleSheetCandidateNodes => _styleSheetCandidateNodes;
  final List<Node> _styleSheetCandidateNodes = [];

  final List<CSSStyleSheet> _pendingStyleSheets = [];

  bool get hasPendingStyleSheet => _pendingStyleSheets.isNotEmpty;
  int get pendingStyleSheetCount => _pendingStyleSheets.length;
  bool _isStyleSheetCandidateNodeChanged = false;
  bool get isStyleSheetCandidateNodeChanged => _isStyleSheetCandidateNodeChanged;

  final Document document;

  StyleNodeManager(this.document);

  void addStyleSheetCandidateNode(Node node) {
    if (!node.isConnected) {
      return;
    }
    if (_styleSheetCandidateNodes.contains(node)) {
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
    if (_pendingStyleSheets.contains(styleSheet)) {
      return;
    }
    _pendingStyleSheets.add(styleSheet);
    if (DebugFlags.enableCssMultiStyleTrace) {
      cssLogger.info('[trace][multi-style][add] pending=${_pendingStyleSheets.length} candidates=${_styleSheetCandidateNodes.length} ' 'hash=${styleSheet.hashCode}');
    }
  }

  void removePendingStyleSheet(CSSStyleSheet styleSheet) {
    _pendingStyleSheets.removeWhere((element) => element == styleSheet);

  }

  // TODO(jiangzhou): cache stylesheet
  bool updateActiveStyleSheets({bool rebuild = false}) {
    List<CSSStyleSheet> newSheets = _collectActiveStyleSheets();
    if (DebugFlags.enableCssMultiStyleTrace) {
      cssLogger.info('[trace][multi-style][update] pending=${_pendingStyleSheets.length} candidates=${_styleSheetCandidateNodes.length} rebuild=$rebuild');
    }
    newSheets = newSheets.where((element) => element.cssRules.isNotEmpty).toList();
    if (rebuild == false) {
      RuleSet changedRuleSet = analyzeStyleSheetChangeRuleSet(document.styleSheets, newSheets);
      final bool shouldForceHtml = !changedRuleSet.tagRules.containsKey('HTML') && _sheetsContainTagDifference(document.styleSheets, newSheets, 'HTML');
      final bool shouldForceBody = !changedRuleSet.tagRules.containsKey('BODY') && _sheetsContainTagDifference(document.styleSheets, newSheets, 'BODY');
      if (changedRuleSet.isEmpty) {
        _pendingStyleSheets.clear();
        _isStyleSheetCandidateNodeChanged = false;
        return false;
      }
      invalidateElementStyle(changedRuleSet);
      if (shouldForceHtml) {
        final HTMLElement? root = document.documentElement;
        if (root != null) {
          document.markElementStyleDirty(root, reason: 'tag-detect:HTML');
        }
      }
      if (shouldForceBody) {
        final BodyElement? body = document.bodyElement;
        if (body != null) {
          document.markElementStyleDirty(body, reason: 'tag-detect:BODY');
        }
      }
    } else {
      final root = document.documentElement;
      if (root != null) {
        document.markElementStyleDirty(root);
      }
    }
    document.handleStyleSheets(newSheets);
    _pendingStyleSheets.clear();
    _isStyleSheetCandidateNodeChanged = false;
    return true;
  }

  // Marks elements dirty based on the changed rules and returns the number of
  // unique elements marked during this call.
  int invalidateElementStyle(RuleSet changedRuleSet) {
    int marked = 0;
    // Targeted invalidation using fast indices on Document
    final Set<Element> dirty = <Element>{};
    final Map<Element, List<String>> reasons = <Element, List<String>>{};
    void addReason(Element el, String r) {
      dirty.add(el);
      final list = reasons.putIfAbsent(el, () => <String>[]);
      list.add(r);
    }

    // 1) ID-based rules
    if (changedRuleSet.idRules.isNotEmpty) {
      for (final id in changedRuleSet.idRules.keys) {
        final list = document.elementsByID[id];
        if (list != null && list.isNotEmpty) {
          for (final el in list) {
            addReason(el, 'id:$id');
          }
        }
      }
    }

    // 2) Class-based rules
    if (changedRuleSet.classRules.isNotEmpty) {
      for (final cls in changedRuleSet.classRules.keys) {
        final list = document.elementsByClass[cls];
        if (list != null && list.isNotEmpty) {
          for (final el in list) {
            addReason(el, 'class:$cls');
          }
        }
      }
    }

    // 3) Attribute presence-based rules (keys are uppercased in RuleSet)
    if (changedRuleSet.attributeRules.isNotEmpty) {
      for (final attr in changedRuleSet.attributeRules.keys) {
        final list = document.elementsByAttr[attr];
        if (list != null && list.isNotEmpty) {
          for (final el in list) {
            addReason(el, 'attr:$attr');
          }
        }
      }
    }

    // 4) Fallback cases: tag/universal/pseudo changes.
    // Prefer a bounded scan using the collector rather than forcing a root recalc.
    int fallbackVisited = 0;
    final bool hasTagRules = changedRuleSet.tagRules.isNotEmpty;
    if (hasTagRules ||
        changedRuleSet.universalRules.isNotEmpty ||
        changedRuleSet.pseudoRules.isNotEmpty) {
      final ElementRuleCollector collector = ElementRuleCollector();
      final List<Node> stack = <Node>[document];
      while (stack.isNotEmpty) {
        final Node node = stack.removeLast();
        if (node is Element) {
          fallbackVisited++;
          final rules = collector.matchedRulesForInvalidate(changedRuleSet, node);
          if (rules.isNotEmpty) {
            addReason(node, 'fallback');
          }
        }
        if (node.childNodes.isNotEmpty) {
          stack.addAll(node.childNodes);
        }
      }
    }

    // Ensure document root elements pick up tag-based changes immediately.
    if (hasTagRules) {
      final HTMLElement? root = document.documentElement;
      if (root != null && changedRuleSet.tagRules.containsKey(root.tagName.toUpperCase())) {
        addReason(root, 'tag:${root.tagName}');
      }
      final BodyElement? body = document.bodyElement;
      if (body != null && changedRuleSet.tagRules.containsKey('BODY')) {
        addReason(body, 'tag:BODY');
      }
    }

    if (fallbackVisited > 0) {
      final HTMLElement? root = document.documentElement;
      if (root != null) {
        addReason(root, 'fallback-root');
      }
      final BodyElement? body = document.bodyElement;
      if (body != null) {
        addReason(body, 'fallback-root');
      }
    }
    for (final el in dirty) {
      document.markElementStyleDirty(el, reason: reasons[el]?.join('|'));
    }
    marked = dirty.length;
    return marked;
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

bool _sheetsContainTagDifference(List<CSSStyleSheet> oldSheets, List<CSSStyleSheet> newSheets, String tag) {
  final bool before = _sheetsContainTagSelector(oldSheets, tag);
  final bool after = _sheetsContainTagSelector(newSheets, tag);
  return before != after;
}

bool _sheetsContainTagSelector(List<CSSStyleSheet> sheets, String tag) {
  if (sheets.isEmpty) return false;
  final String target = tag.toUpperCase();
  for (final CSSStyleSheet sheet in sheets) {
    for (final CSSRule rule in sheet.cssRules) {
      if (rule is! CSSStyleRule) continue;
      for (final Selector selector in rule.selectorGroup.selectors) {
        for (final SimpleSelectorSequence sequence in selector.simpleSelectorSequences) {
          final SimpleSelector simple = sequence.simpleSelector;
          if (simple is ElementSelector && !simple.isWildcard) {
            if (simple.name.toUpperCase() == target) {
              return true;
            }
          }
        }
      }
    }
  }
  return false;
}
