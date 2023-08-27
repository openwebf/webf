/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:webf/dom.dart';
import 'invalidation/style_invalidator.dart';
import 'invalidation/invalidation_set.dart';
import 'invalidation/pending_invalidation.dart';
import 'style_invalidation_root.dart';

// The StyleEngine class manages style-related state for the document. There is
// a 1-1 relationship of Document to StyleEngine. The document calls the
// StyleEngine when the document is updated in a way that impacts styles.
class StyleEngine {
  Document document;
  StyleNodeManager get styleNodeManager => _styleNodeManager;
  late StyleNodeManager _styleNodeManager;

  bool inDOMRemoval = false;

  Set<Element> styleDirtyElements = {};
  PendingInvalidations pendingInvalidations = PendingInvalidations();

  StyleInvalidationRoot styleInvalidationRoot = StyleInvalidationRoot();

  StyleEngine(this.document) {
    _styleNodeManager = StyleNodeManager(document);
  }

  void childrenRemoved(ContainerNode parent) {
    if (!parent.isConnected) {
      return;
    }
    if (parent == parent.ownerDocument) {
      parent.ownerDocument.styleEngine.markElementNeedsStyleUpdate(parent.ownerDocument.documentElement!);
    } else {
      parent.ownerDocument.styleEngine.markElementNeedsStyleUpdate(parent as Element);
    }
  }

  void nodeWillBeRemoved(Node node) {
    if (node is Element) {

    }
  }

  void flushStyleSheetsStyleIfNeeded() {
    if (!styleNodeManager.hasPendingStyleSheet && !styleNodeManager.isStyleSheetCandidateNodeChanged) {
      return;
    }
    if (document.styleSheets.isEmpty && styleNodeManager.hasPendingStyleSheet) {
      flushStyleSheetStyle(rebuild: true);
      return;
    }
    flushStyleSheetStyle();
  }

  void markElementNeedsStyleUpdate(Element element) {
    styleDirtyElements.add(element);
    document.scheduleStyleNeedsUpdate();
  }

  void flushStyleSheetStyle({bool rebuild = false}) {
    if (styleDirtyElements.isEmpty) {
      return;
    }
    if (!styleNodeManager.updateActiveStyleSheets(rebuild: rebuild)) {
      styleDirtyElements.clear();
      return;
    }
    recalcStyle();
  }

  bool _isInRecalcStyle = false;
  bool get isInRecalcStyle => _isInRecalcStyle;

  void recalcStyle({bool rebuild = false}) {
    if (!kReleaseMode) {
      Timeline.startSync(
        'STYLE',
      );
    }

    _isInRecalcStyle = true;

    document.documentElement?.recalculateStyle(rebuildNested: true);
    if (!kReleaseMode) {
      Timeline.finishSync();
    }
    // if (styleDirtyElements.any((element) {
    //   return element is HeadElement || element is HTMLElement;
    // }) ||
    //     rebuild) {
    //   document.documentElement?.recalculateStyle(rebuildNested: true);
    // } else {
    //   List<Element> removedElements = [];
    //   for (Element element in styleDirtyElements) {
    //     bool success = element.recalculateStyle();
    //     if (success) {
    //       removedElements.add(element);
    //     }
    //   }
    //   styleDirtyElements.removeAll(removedElements);
    // }
    _isInRecalcStyle = false;
  }

  void possiblyScheduleNthPseudoInvalidations(Node node) {
    if (!node.isElementNode()) {
      return;
    }
    ContainerNode? parent = node.parentNode;
    if (parent == null) {
      return;
    }

    if ((parent.childrenAffectedByForwardPositionalRules() &&
        node.nextSibling != null) ||
        (parent.childrenAffectedByBackwardPositionalRules() &&
            node.previousSibling != null)) {
      node.ownerDocument.styleEngine.scheduleNthPseudoInvalidations(parent);
    }
  }

  void scheduleNthPseudoInvalidations(ContainerNode nthParent) {
    InvalidationLists invalidationLists = InvalidationLists();
    // getRuleFeatureSet().collectNthInvalidationSet(invalidationLists);
    pendingInvalidations.scheduleInvalidationSetsForNode(invalidationLists, nthParent);
  }

  void invalidateStyle() {
    var styleInvalidator = StyleInvalidator(pendingInvalidations.pendingInvalidationMap);
    styleInvalidator.invalidateRootElement(document, styleInvalidationRoot.rootElement());
    styleInvalidationRoot.clear();
  }
}
