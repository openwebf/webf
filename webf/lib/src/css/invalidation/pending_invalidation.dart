/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// Performs deferred style invalidation for DOM subtrees.
//
// Suppose we have a large DOM tree with the style rules
// .a .b { ... }
// ...
// and user script adds or removes class 'a' from an element.
//
// The cached computed styles for any of the element's
// descendants that have class b are now outdated.
//
// The user script might subsequently make many more DOM
// changes, so we don't immediately traverse the element's
// descendants for class b.
//
// Instead, we record the need for this traversal by
// calling scheduleInvalidationSetsForNode with
// InvalidationLists obtained from RuleFeatureSet.
//
// When we next read computed styles, for example from
// user script or to render a frame,
// StyleInvalidator.invalidate(Document document) is called to
// traverse the DOM and perform all the pending style
// invalidations.
//
// If an element is removed from the DOM tree, we call
// ClearInvalidation(ContainerNode).
//
// When there are sibling rules and elements are added
// or removed from the tree, we call
// scheduleSiblingInvalidationsAsDescendants for the
// potentially affected siblings.
//
// When there are pending invalidations for an element's
// siblings, and the element is being removed, we call
// RescheduleSiblingInvalidationsAsDescendants to
// reshedule the invalidations as descendant invalidations
// on the element's parent.
//
// See https://goo.gl/3ane6s and https://goo.gl/z0Z9gn
// for more detailed overviews of style invalidation.

import 'package:webf/dom.dart';
import 'invalidation_set.dart';

class PendingInvalidations {
  final Map<ContainerNode, NodeInvalidationSets> pendingInvalidationMap = {};

  void scheduleInvalidationSetsForNode(InvalidationLists invalidationLists, ContainerNode node) {
    assert(!node.ownerDocument.styleEngine.isInRecalcStyle);
    var requiresDescendantInvalidation = false;

    if (node.styleChangeType.index < StyleChangeType.subtreeStyleChange.index) {
      for (var invalidationSet in invalidationLists.descendants) {
        if (invalidationSet.wholeSubtreeInvalid()) {
          node.setNeedsStyleRecalc(StyleChangeType.subtreeStyleChange);
          requiresDescendantInvalidation = false;
          break;
        }

        if (invalidationSet.invalidatesSelf && node.isElementNode()) {
          node.setNeedsStyleRecalc(StyleChangeType.localStyleChange);
        }

        if (invalidationSet.invalidatesNth) {
          node.ownerDocument.styleEngine.possiblyScheduleNthPseudoInvalidations(node);
        }

        if (!invalidationSet.isEmpty()) {
          requiresDescendantInvalidation = true;
        }
      }
      // No need to schedule descendant invalidations on display:none elements.
      if (requiresDescendantInvalidation && !node.isRendererAttached) {
        requiresDescendantInvalidation = false;
      }
    }

    if (!requiresDescendantInvalidation && invalidationLists.siblings.isEmpty) {
      return;
    }

    // For SiblingInvalidationSets we can skip scheduling if there is no
    // nextSibling() to invalidate, but NthInvalidationSets are scheduled on the
    // parent node which may not have a sibling.
    var nthOnly = node.nextSibling == null;
    var requiresSiblingInvalidation = false;
    var pendingInvalidations = ensurePendingInvalidations(node);
    for (var invalidationSet in invalidationLists.siblings) {
      if (nthOnly && !invalidationSet.isNthSiblingInvalidationSet) {
        continue;
      }
      if (pendingInvalidations.siblings.contains(invalidationSet)) {
        continue;
      }
      if (invalidationSet.invalidatesNth) {
        node.ownerDocument.styleEngine.possiblyScheduleNthPseudoInvalidations(node);
      }
      pendingInvalidations.siblings.add(invalidationSet);
      requiresSiblingInvalidation = true;
    }

    if (requiresSiblingInvalidation || requiresDescendantInvalidation) {
      node.setNeedsStyleInvalidation();
    }

    if (!requiresDescendantInvalidation) {
      return;
    }

    for (var invalidationSet in invalidationLists.descendants) {
      assert(!invalidationSet.wholeSubtreeInvalid());
      if (invalidationSet.isEmpty()) {
        continue;
      }
      if (pendingInvalidations.descendants.contains(invalidationSet)) {
        continue;
      }
      pendingInvalidations.descendants.add(invalidationSet);
    }
  }

  void scheduleSiblingInvalidationsAsDescendants(InvalidationLists invalidationLists, ContainerNode schedulingParent) {
    assert(invalidationLists.descendants.isEmpty);

    if (invalidationLists.siblings.isEmpty) {
      return;
    }

    NodeInvalidationSets pendingInvalidations = ensurePendingInvalidations(schedulingParent);

    schedulingParent.setNeedsStyleInvalidation();

    Element? subtreeRoot = schedulingParent as Element?;

    for (var invalidationSet in invalidationLists.siblings) {
      DescendantInvalidationSet? descendants = (invalidationSet as SiblingInvalidationSet).siblingDescendants();
      if (invalidationSet.wholeSubtreeInvalid() || (descendants != null && descendants.wholeSubtreeInvalid())) {
        subtreeRoot!.setNeedsStyleRecalc(StyleChangeType.subtreeStyleChange);
        return;
      }

      if (invalidationSet.invalidatesSelf && !pendingInvalidations.descendants.contains(invalidationSet)) {
        pendingInvalidations.descendants.add(invalidationSet);
      }

      if (descendants != null && !pendingInvalidations.descendants.contains(descendants)) {
        pendingInvalidations.descendants.add(descendants);
      }
    }
  }

  void rescheduleSiblingInvalidationsAsDescendants(Element element) {
    ContainerNode? parent = element.parentNode;
    assert(parent != null);
    if (parent is Document) {
      return;
    }

    var pendingInvalidationsIterator = pendingInvalidationMap[element];
    if (pendingInvalidationsIterator == null || pendingInvalidationsIterator.siblings.isEmpty) {
      return;
    }

    NodeInvalidationSets pendingInvalidations = pendingInvalidationsIterator;

    InvalidationLists invalidationLists = InvalidationLists();
    for (var invalidationSet in pendingInvalidations.siblings) {
      invalidationLists.descendants.add(invalidationSet);
      DescendantInvalidationSet? descendants = (invalidationSet as SiblingInvalidationSet).siblingDescendants();
      if (descendants != null) {
        invalidationLists.descendants.add(descendants);
      }
    }
    scheduleInvalidationSetsForNode(invalidationLists, parent!);
  }

  void clearInvalidation(ContainerNode node) {
    assert(node.needsStyleInvalidation);
    pendingInvalidationMap.remove(node);
    node.clearNeedsStyleInvalidation();
  }

  NodeInvalidationSets ensurePendingInvalidations(ContainerNode node) {
    if (pendingInvalidationMap.containsKey(node)) {
      return pendingInvalidationMap[node]!;
    }
    final result = NodeInvalidationSets();
    pendingInvalidationMap[node] = result;
    return result;
  }
}
