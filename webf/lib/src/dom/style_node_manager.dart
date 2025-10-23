/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] skip add candidate: ${node.runtimeType} (not connected)');
      }
      return;
    }
    if (_styleSheetCandidateNodes.contains(node)) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] candidate already tracked: ${node.runtimeType}');
      }
      return;
    }
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] add candidate node: ' + node.runtimeType.toString());
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
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] remove candidate node: ' + node.runtimeType.toString());
    }
    _isStyleSheetCandidateNodeChanged = true;
  }

  void appendPendingStyleSheet(CSSStyleSheet styleSheet) {
    if (_pendingStyleSheets.contains(styleSheet)) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] append pending sheet skipped (already pending) hash=${styleSheet.hashCode}');
      }
      return;
    }
    _pendingStyleSheets.add(styleSheet);
    if (DebugFlags.enableCssPerf) {
      CSSPerf.recordStyleAdded();
    }
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] append pending sheet: total=${_pendingStyleSheets.length} hash=${styleSheet.hashCode} rules=${styleSheet.cssRules.length}');
    }
    if (DebugFlags.enableCssMultiStyleTrace) {
      cssLogger.info('[trace][multi-style][add] pending=${_pendingStyleSheets.length} candidates=${_styleSheetCandidateNodes.length} ' +
          'hash=${styleSheet.hashCode}');
    }
  }

  void removePendingStyleSheet(CSSStyleSheet styleSheet) {
    _pendingStyleSheets.removeWhere((element) => element == styleSheet);
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] remove pending sheet: remaining=${_pendingStyleSheets.length}');
    }
  }

  // TODO(jiangzhou): cache stylesheet
  bool updateActiveStyleSheets({bool rebuild = false}) {
    List<CSSStyleSheet> newSheets = _collectActiveStyleSheets();
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] updateActiveStyleSheets: candidates=${_styleSheetCandidateNodes.length} -> newSheets=${newSheets.length} '
          '(rebuild=$rebuild pending=${_pendingStyleSheets.length})');
    }
    if (DebugFlags.enableCssMultiStyleTrace) {
      cssLogger.info('[trace][multi-style][update] pending=${_pendingStyleSheets.length} candidates=${_styleSheetCandidateNodes.length} rebuild=$rebuild');
    }
    newSheets = newSheets.where((element) => element.cssRules.isNotEmpty).toList();
    if (rebuild == false) {
      RuleSet changedRuleSet = analyzeStyleSheetChangeRuleSet(document.styleSheets, newSheets);
      final bool shouldForceHtml = !changedRuleSet.tagRules.containsKey('HTML') && _sheetsContainTagDifference(document.styleSheets, newSheets, 'HTML');
      final bool shouldForceBody = !changedRuleSet.tagRules.containsKey('BODY') && _sheetsContainTagDifference(document.styleSheets, newSheets, 'BODY');
      if (changedRuleSet.isEmpty) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[style] updateActiveStyleSheets: no rule changes detected');
        }
        _pendingStyleSheets.clear();
        _isStyleSheetCandidateNodeChanged = false;
        return false;
      }
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] updateActiveStyleSheets: changed rules ' +
            'id=${changedRuleSet.idRules.length} class=${changedRuleSet.classRules.length} attr=${changedRuleSet.attributeRules.length} '
            'tag=${changedRuleSet.tagRules.length} universal=${changedRuleSet.universalRules.length} pseudo=${changedRuleSet.pseudoRules.length}');
      }
      invalidateElementStyle(changedRuleSet);
      if (shouldForceHtml) {
        final HTMLElement? root = document.documentElement;
        if (root != null) {
          document.markElementStyleDirty(root, reason: 'tag-detect:HTML');
          if (DebugFlags.enableCssTrace) {
            cssLogger.info('[trace][invalidate] tag-detect forcing root dirty (HTML)');
          }
        }
      }
      if (shouldForceBody) {
        final BodyElement? body = document.bodyElement;
        if (body != null) {
          document.markElementStyleDirty(body, reason: 'tag-detect:BODY');
          if (DebugFlags.enableCssTrace) {
            cssLogger.info('[trace][invalidate] tag-detect forcing body dirty (BODY)');
          }
        }
      }
    } else {
      final root = document.documentElement;
      if (root != null) {
        document.markElementStyleDirty(root);
      }
    }
    document.handleStyleSheets(newSheets);
    if (kDebugMode && DebugFlags.enableCssLogs) {
      final hashes = newSheets.map((s) => s.hashCode).toList();
      cssLogger.fine('[style] updateActiveStyleSheets: applied sheets hashes=$hashes');
    }
    _pendingStyleSheets.clear();
    _isStyleSheetCandidateNodeChanged = false;
    return true;
  }

  List<CSSStyleSheet> _collectActiveStyleSheets() {
    List<CSSStyleSheet> styleSheetsForStyleSheetsList = [];
    for (Node node in _styleSheetCandidateNodes) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[style] inspect candidate: ${node.runtimeType} connected=${node.isConnected} hasSheet=${node is StyleElementMixin ? node.styleSheet != null : node is LinkElement ? node.styleSheet != null : false}');
      }
      if (node is LinkElement && !node.disabled && !node.loading && node.styleSheet != null) {
        styleSheetsForStyleSheetsList.add(node.styleSheet!);
      } else if (node is StyleElementMixin && node.styleSheet != null) {
        styleSheetsForStyleSheetsList.add(node.styleSheet!);
      }
    }
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[style] _collectActiveStyleSheets: ' + styleSheetsForStyleSheetsList.length.toString());
    }
    return styleSheetsForStyleSheetsList;
  }

  void invalidateElementStyle(RuleSet changedRuleSet) {
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
    int fallbackMatched = 0;
    final bool hasTagRules = changedRuleSet.tagRules.isNotEmpty;
    if (DebugFlags.enableCssTrace) {
      cssLogger.info('[trace][invalidate] changed tags=${changedRuleSet.tagRules.keys.join(',')} universals=${changedRuleSet.universalRules.length} pseudo=${changedRuleSet.pseudoRules.length}');
    }
    if (hasTagRules ||
        changedRuleSet.universalRules.isNotEmpty ||
        changedRuleSet.pseudoRules.isNotEmpty) {
      final ElementRuleCollector collector = ElementRuleCollector();
      final List<Node> stack = <Node>[document];
      while (stack.isNotEmpty) {
        final Node node = stack.removeLast();
        if (node is Element) {
          fallbackVisited++;
          final rules = collector.matchedRules(changedRuleSet, node);
          if (rules.isNotEmpty) {
            fallbackMatched++;
            if (DebugFlags.enableCssTrace) {
              cssLogger.info('[trace][invalidate][fallback-match] ${node.tagName}#${node.hashCode}');
            }
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
        if (DebugFlags.enableCssTrace) {
          cssLogger.info('[trace][invalidate] forcing root dirty for tag ${root.tagName}');
        }
        addReason(root, 'tag:${root.tagName}');
      }
      final BodyElement? body = document.bodyElement;
      if (body != null && changedRuleSet.tagRules.containsKey('BODY')) {
        if (DebugFlags.enableCssTrace) {
          cssLogger.info('[trace][invalidate] forcing body dirty for tag BODY');
        }
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

    if (DebugFlags.enableCssTrace) {
      cssLogger.info('[trace][invalidate] ids=${changedRuleSet.idRules.length} classes=${changedRuleSet.classRules.length} attrs=${changedRuleSet.attributeRules.length} tags=${changedRuleSet.tagRules.length} universals=${changedRuleSet.universalRules.length} pseudo=${changedRuleSet.pseudoRules.length} ' +
          'dirty=${dirty.length} fallbackVisited=$fallbackVisited fallbackMatched=$fallbackMatched');
    }
    for (final el in dirty) {
      document.markElementStyleDirty(el, reason: reasons[el]?.join('|'));
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

    if (DebugFlags.enableCssTrace) {
      cssLogger.info('[trace][sheets][diff] totals: id=${ruleSet.idRules.length} class=${ruleSet.classRules.length} attr=${ruleSet.attributeRules.length} tag=${ruleSet.tagRules.length} universal=${ruleSet.universalRules.length} pseudo=${ruleSet.pseudoRules.length}');
      if (ruleSet.tagRules.isNotEmpty) {
        cssLogger.info('[trace][sheets][diff] tag keys: ${ruleSet.tagRules.keys.join(',')}');
      }
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
