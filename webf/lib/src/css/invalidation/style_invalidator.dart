/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'invalidation_set.dart';
import 'invalidate_flags.dart';

class Entry {
  final SiblingInvalidationSet invalidationSet;
  final int invalidationLimit;

  Entry(this.invalidationSet, this.invalidationLimit);
}

class SiblingData {
  final List<Entry> invalidationEntries = [];
  int elementIndex = 0;

  SiblingData();

  void pushInvalidationSet(SiblingInvalidationSet invalidationSet) {
    int invalidationLimit;
    if (invalidationSet.maxDirectAdjacentSelectors == (1 << 32) - 1) {
      // Equivalent of UINT_MAX for 32-bit
      invalidationLimit = (1 << 32) - 1;
    } else {
      invalidationLimit = elementIndex + invalidationSet.maxDirectAdjacentSelectors;
    }
    invalidationEntries.add(Entry(invalidationSet, invalidationLimit));
  }

  bool matchCurrentInvalidationSets(Element element, StyleInvalidator styleInvalidator) {
    bool thisElementNeedsStyleRecalc = false;
    assert(!styleInvalidator.wholeSubtreeInvalid());

    int index = 0;
    while (index < invalidationEntries.length) {
      if (elementIndex > invalidationEntries[index].invalidationLimit) {
        invalidationEntries[index] = invalidationEntries.last;
        invalidationEntries.removeLast();
        continue;
      }

      final SiblingInvalidationSet invalidationSet = invalidationEntries[index].invalidationSet;
      index++;
      if (!invalidationSet.invalidatesElement(element)) {
        continue;
      }

      if (invalidationSet.invalidatesSelf) {
        thisElementNeedsStyleRecalc = true;
      }

      final DescendantInvalidationSet? descendants = invalidationSet.siblingDescendants();
      if (descendants != null) {
        if (descendants.wholeSubtreeInvalid()) {
          element.setNeedsStyleRecalc(StyleChangeType.subtreeStyleChange);
          return true;
        }

        if (!descendants.isEmpty()) {
          styleInvalidator.pushInvalidationSet(descendants);
        }
      }
    }
    return thisElementNeedsStyleRecalc;
  }

  bool get isEmpty => invalidationEntries.isEmpty;

  void advance() {
    elementIndex++;
  }
}

/// Applies deferred style invalidation for DOM subtrees.
///
/// See [https://goo.gl/3ane6s] and [https://goo.gl/z0Z9gn]
/// for more detailed overviews of style invalidation.
class StyleInvalidator {
  final Map<ContainerNode, NodeInvalidationSets> pendingInvalidationMap;
  final List<InvalidationSet> invalidationSets = [];
  final List<NthSiblingInvalidationSet?> pendingNthSets = [];
  InvalidationFlags invalidationFlags = InvalidationFlags();

  StyleInvalidator(this.pendingInvalidationMap);

  void _runInvalidate(Function fn) {
    InvalidationFlags previousInvalidationFlags = invalidationFlags;
    fn();
    invalidationFlags = previousInvalidationFlags;
  }

  void invalidateRootElement(Document document, Element? rootElement) {
    var siblingData = SiblingData();

    if (document.needsStyleInvalidation) {
      assert(rootElement == document.documentElement);
      pushInvalidationSetsForContainerNode(document, siblingData);
      document.clearNeedsStyleInvalidation();
      assert(siblingData.isEmpty);
    }

    if (rootElement != null) {
      invalidate(rootElement, siblingData);
      if (!siblingData.isEmpty) {
        Element? nextSibling = rootElement.nextSiblingElement;
        while (nextSibling != null) {
          invalidate(nextSibling, siblingData);
          nextSibling = nextSibling.nextSiblingElement;
        }
      }
      for (Element? ancestor = rootElement; ancestor != null; ancestor = ancestor.parentElement) {
        ancestor.clearChildNeedsStyleInvalidation();
      }
    }
    document.clearChildNeedsStyleInvalidation();
    pendingInvalidationMap.clear();
    pendingNthSets.clear();
  }

  void invalidate(Element element, SiblingData siblingData) {
    siblingData.advance();

    _runInvalidate(() {
      if (!wholeSubtreeInvalid()) {
        if (element.styleChangeType == StyleChangeType.subtreeStyleChange) {
          setWholeSubtreeInvalid();
        } else if (checkInvalidationSetsAgainstElement(element, siblingData)) {
          element.setNeedsStyleRecalc(StyleChangeType.localStyleChange);
        }
        if (element.needsStyleInvalidation) {
          pushInvalidationSetsForContainerNode(element, siblingData);
        }
      }

      if ((!wholeSubtreeInvalid() && hasInvalidationSets() && element.isRendererAttached) ||
          element.childNeedsStyleInvalidation) {
        invalidateChildren(element);
      } else {
        clearPendingNthSiblingInvalidationSets();
      }

      element.clearChildNeedsStyleInvalidation();
      element.clearNeedsStyleInvalidation();
    });
  }

  void pushInvalidationSetsForContainerNode(ContainerNode containerNode, SiblingData siblingData) {
    var pendingInvalidationsIterator = pendingInvalidationMap[containerNode];
    if (pendingInvalidationsIterator == null) {
      // In Dart, we typically use asserts for such checks
      assert(
          false,
          'We should strictly not have marked an element for '
          'invalidation without any pending invalidations.');
      return;
    }
    var pendingInvalidations = pendingInvalidationsIterator;

    assert(pendingNthSets.isEmpty);

    for (var invalidationSet in pendingInvalidations.siblings) {
      assert(invalidationSet.isAlive);
      if (invalidationSet.isNthSiblingInvalidationSet) {
        addPendingNthSiblingInvalidationSet(invalidationSet as NthSiblingInvalidationSet);
      } else {
        siblingData.pushInvalidationSet(invalidationSet as SiblingInvalidationSet);
      }
    }

    if (containerNode.styleChangeType == StyleChangeType.subtreeStyleChange) {
      return;
    }

    if (pendingInvalidations.descendants.isNotEmpty) {
      for (var invalidationSet in pendingInvalidations.descendants) {
        assert(invalidationSet.isAlive);
        pushInvalidationSet(invalidationSet);
      }
    }
  }

  void pushInvalidationSet(InvalidationSet invalidationSet) {
    assert(!invalidationFlags.wholeSubtreeInvalid);
    assert(!invalidationSet.wholeSubtreeInvalid());
    assert(!invalidationSet.isEmpty());
    if (invalidationSet.customPseudoInvalid()) {
      invalidationFlags.invalidateCustomPseudo = true;
    }
    if (invalidationSet.treeBoundaryCrossing()) {
      invalidationFlags.treeBoundaryCrossing = true;
    }
    if (invalidationSet.insertionPointCrossing()) {
      invalidationFlags.insertionPointCrossing = true;
    }
    if (invalidationSet.invalidatesSlotted()) {
      invalidationFlags.invalidatesSlotted = true;
    }
    if (invalidationSet.invalidatesParts()) {
      invalidationFlags.invalidatesParts = true;
    }
    invalidationSets.add(invalidationSet);
  }

  bool wholeSubtreeInvalid() => invalidationFlags.wholeSubtreeInvalid;

  void invalidateChildren(Element element) {
    SiblingData siblingData = SiblingData();
    pushNthSiblingInvalidationSets(siblingData);

    Element? child = element.firstElementChild;
    while (child != null) {
      invalidate(child, siblingData);
      child = child.nextElementSibling;
    }
  }

  bool checkInvalidationSetsAgainstElement(Element element, SiblingData siblingData) {
    // We need to call both because the sibling data may invalidate the whole
    // subtree at which point we can stop recursing.
    bool matchesCurrent = matchesCurrentInvalidationSets(element);
    bool matchesSibling = !siblingData.isEmpty && siblingData.matchCurrentInvalidationSets(element, this);
    return matchesCurrent || matchesSibling;
  }

  bool matchesCurrentInvalidationSets(Element element) {
    for (var invalidationSet in invalidationSets) {
      if (invalidationSet.invalidatesElement(element)) {
        return true;
      }
    }

    return false;
  }

  bool matchesCurrentInvalidationSetsAsSlotted(Element element) {
    assert(invalidationFlags.invalidatesSlotted);

    for (var invalidationSet in invalidationSets) {
      if (!invalidationSet.invalidatesSlotted()) {
        continue;
      }
      if (invalidationSet.invalidatesElement(element)) {
        return true;
      }
    }
    return false;
  }

  bool matchesCurrentInvalidationSetsAsParts(Element element) {
    assert(invalidationFlags.invalidatesParts);

    for (var invalidationSet in invalidationSets) {
      if (!invalidationSet.invalidatesParts()) {
        continue;
      }
      if (invalidationSet.invalidatesElement(element)) {
        return true;
      }
    }
    return false;
  }

  bool hasInvalidationSets() {
    return !wholeSubtreeInvalid() && (invalidationSets.isNotEmpty || pendingNthSets.isNotEmpty);
  }

  void setWholeSubtreeInvalid() {
    invalidationFlags.wholeSubtreeInvalid = true;
  }

  bool treeBoundaryCrossing() => invalidationFlags.treeBoundaryCrossing;

  bool insertionPointCrossing() => invalidationFlags.insertionPointCrossing;

  bool invalidatesSlotted() => invalidationFlags.invalidatesSlotted;

  bool invalidatesParts() => invalidationFlags.invalidatesParts;

  void addPendingNthSiblingInvalidationSet(NthSiblingInvalidationSet nthSet) {
    pendingNthSets.add(nthSet);
  }

  void pushNthSiblingInvalidationSets(SiblingData siblingData) {
    for (var invalidationSet in pendingNthSets) {
      siblingData.pushInvalidationSet(invalidationSet!);
    }
    clearPendingNthSiblingInvalidationSets();
  }

  void clearPendingNthSiblingInvalidationSets() {
    pendingNthSets.clear();
  }
}
