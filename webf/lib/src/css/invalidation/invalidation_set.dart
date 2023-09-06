/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:webf/dom.dart';

import 'invalidate_flags.dart';

enum InvalidationType {
  invalidateDescendants,
  invalidateSiblings,
  invalidateNthSiblings,
}

class InvalidationLists {
  List<InvalidationSet> descendants = [];
  List<InvalidationSet> siblings = [];
}

class NodeInvalidationSets {
  List<InvalidationSet> descendants = [];
  List<InvalidationSet> siblings = [];
}

// Tracks data to determine which descendants in a DOM subtree, or
// siblings and their descendants, need to have style recalculated.
//
// Some example invalidation sets:
//
// .z {}
//   For class z we will have a DescendantInvalidationSet with invalidatesSelf
//   (the element itself is invalidated).
//
// .y .z {}
//   For class y we will have a DescendantInvalidationSet containing class z.
//
// .x ~ .z {}
//   For class x we will have a SiblingInvalidationSet containing class z, with
//   invalidatesSelf (the sibling itself is invalidated).
//
// .w ~ .y .z {}
//   For class w we will have a SiblingInvalidationSet containing class y, with
//   the SiblingInvalidationSet havings siblingDescendants containing class z.
//
// .v * {}
//   For class v we will have a DescendantInvalidationSet with
//   wholeSubtreeInvalid.
//
// .u ~ * {}
//   For class u we will have a SiblingInvalidationSet with wholeSubtreeInvalid
//   and invalidatesSelf (for all siblings, the sibling itself is invalidated).
//
// .t .v, .t ~ .z {}
//   For class t we will have a SiblingInvalidationSet containing class z, with
//   the SiblingInvalidationSet also holding descendants containing class v.
class InvalidationSet {
  InvalidationType type;

  InvalidationFlags invalidationFlags = InvalidationFlags();

  bool invalidatesSelf = false;
  bool invalidatesNth = false;
  bool isAlive = true;

  Set<String> classes = {};
  Set<String> ids = {};
  Set<String> tagNames = {};
  Set<String> attributes = {};

  InvalidationSet(this.type);

  @override
  bool operator ==(Object other) {
    if (other is! InvalidationSet) return false;
    InvalidationSet otherSet = other;

    if (type != otherSet.type) return false;

    if (type == InvalidationType.invalidateSiblings) {
      SiblingInvalidationSet thisSibling = this as SiblingInvalidationSet;
      SiblingInvalidationSet otherSibling = otherSet as SiblingInvalidationSet;

      if (thisSibling.maxDirectAdjacentSelectors != otherSibling.maxDirectAdjacentSelectors ||
          !(thisSibling.descendants == otherSibling.descendants) ||
          !(thisSibling.siblingDescendants == otherSibling.siblingDescendants)) {
        return false;
      }
    }

    if (invalidationFlags != otherSet.invalidationFlags) return false;
    if (invalidatesSelf != otherSet.invalidatesSelf) return false;

    return setEquals(classes, otherSet.classes) &&
        setEquals(ids, otherSet.ids) &&
        setEquals(tagNames, otherSet.tagNames) &&
        setEquals(attributes, otherSet.attributes);
  }

  bool get isDescendantInvalidationSet => type == InvalidationType.invalidateDescendants;

  bool get isSiblingInvalidationSet => type != InvalidationType.invalidateDescendants;

  bool get isNthSiblingInvalidationSet => type == InvalidationType.invalidateNthSiblings;

  bool invalidatesElement(Element element) {
    if (invalidationFlags.wholeSubtreeInvalid) {
      return true;
    }

    if (hasTagNames() && hasTagName(element.tagName)) {
      return true;
    }

    if (element.id != null && hasIds() && hasId(element.id!)) {
      return true;
    }

    if (element.classList.isNotEmpty && hasClasses()) {
      List<String> classLists = element.classList;
      for (int i = 0; i < classLists.length; i++) {
        if (classes.contains(classLists[i])) return true;
      }
    }

    if (element.attributes.isNotEmpty && hasAttributes()) {
      if (attributes.length == 1) {
        return element.hasAttribute(attributes.first);
      }
      for (String attr in attributes) {
        if (element.hasAttribute(attr)) return true;
      }
    }

    return false;
  }

  bool invalidatesTagName(Element element) {
    if (hasTagNames() && hasTagName(element.tagName)) {
      return true;
    }
    return false;
  }

  void addClass(String className) {
    classes.add(className);
  }

  void addId(String id) {
    ids.add(id);
  }

  void addTagName(String tagName) {
    tagNames.add(tagName);
  }

  void addAttribute(String attributeName) {
    attributes.add(attributeName);
  }

  bool hasClasses() => classes.isNotEmpty;

  bool hasIds() => ids.isNotEmpty;

  bool hasTagNames() => tagNames.isNotEmpty;

  bool hasAttributes() => attributes.isNotEmpty;

  bool hasId(String key) {
    return ids.contains(key);
  }

  bool hasTagName(String key) {
    return tagNames.contains(key);
  }

  // Format the InvalidationSet for debugging purposes.
  //
  // Examples:
  //
  //         { .a } - Invalidates class |a|.
  //         { #a } - Invalidates id |a|.
  //      { .a #a } - Invalidates class |a| and id |a|.
  //        { div } - Invalidates tag name |div|.
  //     { :hover } - Invalidates pseudo-class :hover.
  //  { .a [name] } - Invalidates class |a| and attribute |name|.
  //          { $ } - Invalidates self.
  //       { .a $ } - Invalidates class |a| and self.
  //       { .b 4 } - Invalidates class |b|. Max direct siblings = 4.
  //   { .a .b $4 } - Combination of the two previous examples.
  //          { W } - Whole subtree invalid.
  //
  // Flags (omitted if false):
  //
  //  $ - Invalidates self.
  //  W - Whole subtree invalid.
  //  C - Invalidates custom pseudo.
  //  T - Tree boundary crossing.
  //  I - Insertion point crossing.
  //  S - Invalidates slotted.
  //  P - Invalidates parts.
  //  ~ - Max direct siblings is kDirectAdjacentMax.
  //  <integer> - Max direct siblings is specified number (omitted if 1).
  @override
  String toString() {
    String formatSet(Set<String> range, String prefix, String suffix) {
      List<String> names = [];
      for (var str in range) {
        names.add(str);
      }
      names.sort((a, b) => a.compareTo(b));

      return names.map((name) => '$prefix$name$suffix').join(' ');
    }

    var features = StringBuffer();

    if (hasIds()) {
      features.write(formatSet(ids, '#', ''));
    }
    if (hasClasses()) {
      if (features.isNotEmpty) features.write(' ');
      features.write(formatSet(classes, '.', ''));
    }
    if (hasTagNames()) {
      if (features.isNotEmpty) features.write(' ');
      features.write(formatSet(tagNames, '', ''));
    }
    if (hasAttributes()) {
      if (features.isNotEmpty) features.write(' ');
      features.write(formatSet(attributes, '[', ']'));
    }

    String formatMaxDirectAdjacent(InvalidationSet set) {
      var sibling = set as SiblingInvalidationSet?; // Using safe cast
      if (sibling == null) {
        return '';
      }
      var max = sibling.maxDirectAdjacentSelectors;
      if (max == SiblingInvalidationSet.directAdjacentMax) {
        return '~';
      }
      if (max != 1) {
        return max.toString();
      }
      return '';
    }

    var metadata = StringBuffer()
      ..write(invalidatesSelf ? '\$' : '')
      ..write(invalidationFlags.wholeSubtreeInvalid ? 'W' : '')
      ..write(invalidationFlags.invalidateCustomPseudo ? 'C' : '')
      // ... Repeat for all flags
      ..write(formatMaxDirectAdjacent(this));

    return '{ ${features} ${metadata} }';
  }

  void combine(InvalidationSet other) {
    classes.addAll(other.classes);
    ids.addAll(other.ids);
    tagNames.addAll(other.tagNames);
    attributes.addAll(other.attributes);
  }

  static InvalidationSet selfInvalidationSet() {
    InvalidationSet invalidationSet = InvalidationSet(InvalidationType.invalidateDescendants);
    invalidationSet.invalidatesSelf = true;
    return invalidationSet;
  }

  @override
  int get hashCode => super.hashCode;

  void setWholeSubtreeInvalid() {
    if (invalidationFlags.wholeSubtreeInvalid) return;

    invalidationFlags.wholeSubtreeInvalid = true;
    invalidationFlags.invalidateCustomPseudo = false;
    invalidationFlags.treeBoundaryCrossing = false;
    invalidationFlags.insertionPointCrossing = false;
    invalidationFlags.invalidatesSlotted = false;
    invalidationFlags.invalidatesParts = false;
  }

  bool wholeSubtreeInvalid() {
    return invalidationFlags.wholeSubtreeInvalid;
  }

  bool isEmpty() {
    return classes.isEmpty && ids.isEmpty && tagNames.isEmpty && attributes.isEmpty &&
        !invalidationFlags.invalidateCustomPseudo && !invalidationFlags.insertionPointCrossing ||
        invalidationFlags.invalidatesSlotted || invalidationFlags.invalidatesParts;
  }

  void setTreeBoundaryCrossing() {
    invalidationFlags.treeBoundaryCrossing = true;
  }
  bool treeBoundaryCrossing() {
    return invalidationFlags.treeBoundaryCrossing;
  }

  void setInsertionPointCrossing() {
    invalidationFlags.insertionPointCrossing = true;
  }

  bool insertionPointCrossing() {
    return invalidationFlags.insertionPointCrossing;
  }

  void setCustomPseudoInvalid() {
    invalidationFlags.invalidateCustomPseudo = true;
  }

  bool customPseudoInvalid() {
    return invalidationFlags.invalidateCustomPseudo;
  }

  void setInvalidatesSlotted() {
    invalidationFlags.invalidatesSlotted = true;
  }

  bool invalidatesSlotted() {
    return invalidationFlags.invalidatesSlotted;
  }

  InvalidationFlags getInvalidationFlags() {
    return invalidationFlags;
  }

  void setInvalidatesParts() {
    invalidationFlags.invalidatesParts = true;
  }

  bool invalidatesParts() {
    return invalidationFlags.invalidatesParts;
  }

}

class DescendantInvalidationSet extends InvalidationSet {
  // Private constructor
  DescendantInvalidationSet() : super(InvalidationType.invalidateDescendants);
}

class SiblingInvalidationSet extends InvalidationSet {
  static const int directAdjacentMax = 0xFFFFFFFF;

  int maxDirectAdjacentSelectors;

  DescendantInvalidationSet? siblingDescendantInvalidationSet;
  DescendantInvalidationSet? descendantInvalidationSet;

  SiblingInvalidationSet.fromDescendants(DescendantInvalidationSet descendants)
      : maxDirectAdjacentSelectors = 1,
        descendantInvalidationSet = descendants,
        super(InvalidationType.invalidateSiblings);

  SiblingInvalidationSet()
      : maxDirectAdjacentSelectors = directAdjacentMax,
        super(InvalidationType.invalidateSiblings);

  int getMaxDirectAdjacentSelectors() {
    return maxDirectAdjacentSelectors;
  }

  void updateMaxDirectAdjacentSelectors(int value) {
    maxDirectAdjacentSelectors = math.max(value, maxDirectAdjacentSelectors);
  }

  DescendantInvalidationSet? siblingDescendants() {
    return siblingDescendantInvalidationSet;
  }

  DescendantInvalidationSet ensureSiblingDescendants() {
    siblingDescendantInvalidationSet ??= DescendantInvalidationSet();
    return siblingDescendantInvalidationSet!;
  }

  DescendantInvalidationSet? descendants() {
    return descendantInvalidationSet;
  }

  DescendantInvalidationSet ensureDescendants() {
    descendantInvalidationSet ??= DescendantInvalidationSet();
    return descendantInvalidationSet!;
  }
}

// For invalidation of :nth-* selectors on dom mutations we use a sibling
// invalidation set which is scheduled on the parent node of the DOM mutation
// affected by the :nth-* selectors.
//
// During invalidation, the set is pushed into the SiblingData used for
// invalidating the direct children.
//
// Features are collected into this set as if the selectors were preceded by a
// universal selector with an indirect adjacent combinator.
//
// Example: If you have the following selector:
//
// :nth-of-type(2n+1) .x {}
//
// we need to invalidate descendants of class 'x' of an arbitrary number of
// siblings when one of the siblings are added or removed. We then collect
// features to the NthSiblingInvalidationSet as if we had a selector:
//
// * ~ :nth-of-type(2n+1) .x {}
//
// Pushing that set into SiblingData before invalidating the siblings will then
// invalidate descendants with class 'x'.
class NthSiblingInvalidationSet extends SiblingInvalidationSet {
  NthSiblingInvalidationSet();
}

