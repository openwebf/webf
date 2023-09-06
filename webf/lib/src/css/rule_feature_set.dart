/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

import 'invalidation/invalidate_flags.dart';
import 'invalidation/invalidation_set.dart';
import 'package:serializable_bloom_filter/serializable_bloom_filter.dart';

enum PositionType { subject, ancestor }

enum FeatureInvalidationType { normalInvalidation, requiresSubtreeInvalidation }

class FeatureMetadata {
  bool usesFirstLineRules = false;
  bool usesWindowInactiveSelector = false;
  bool needsFullRecalcForRuleSetInvalidation = false;
  int maxDirectAdjacentSelectors = 0;
  bool invalidatesParts = false;
  bool usesHasInsideNth = false;

  void merge(FeatureMetadata other) {
    // Implement the merge logic here.
  }

  void clear() {
    // Reset all properties to their default values.
    usesFirstLineRules = false;
    usesWindowInactiveSelector = false;
    needsFullRecalcForRuleSetInvalidation = false;
    maxDirectAdjacentSelectors = 0;
    invalidatesParts = false;
    usesHasInsideNth = false;
  }

  bool equals(FeatureMetadata other) {
    // Implement equality logic here.
    return usesFirstLineRules == other.usesFirstLineRules &&
        usesWindowInactiveSelector == other.usesWindowInactiveSelector &&
        needsFullRecalcForRuleSetInvalidation == other.needsFullRecalcForRuleSetInvalidation &&
        maxDirectAdjacentSelectors == other.maxDirectAdjacentSelectors &&
        invalidatesParts == other.invalidatesParts &&
        usesHasInsideNth == other.usesHasInsideNth;
  }

  bool notEquals(FeatureMetadata other) {
    return !equals(other);
  }
}

class InvalidationSetFeatures {
  List<String> classes = [];
  List<String> attributes = [];
  List<String> ids = [];
  List<String> tagNames = [];
  List<String> emittedTagNames = [];
  int maxDirectAdjacentSelectors = 0;
  int descendantFeaturesDepth = 0;
  InvalidationFlags invalidationFlags =
      InvalidationFlags(); // Assuming that InvalidationFlags is a class you have defined.
  bool contentPseudoCrossing = false;
  bool hasNthPseudo = false;
  bool hasFeaturesForRuleSetInvalidation = false;

  void merge(InvalidationSetFeatures other) {
    // Implement the merge logic here.
  }

  bool hasFeatures() {
    // Implement the logic to check for features.
    return false;
  }

  bool hasIdClassOrAttribute() {
    // Implement the logic to check for ID, Class or Attribute.
    return false;
  }

  void narrowToClass(String className) {
    if (size() == 1 && (ids.isNotEmpty || classes.isNotEmpty)) {
      return;
    }
    clearFeatures();
    classes.add(className);
  }

  void narrowToAttribute(String attribute) {
    if (size() == 1 && (ids.isNotEmpty || classes.isNotEmpty || attributes.isNotEmpty)) {
      return;
    }
    clearFeatures();
    attributes.add(attribute);
  }

  void narrowToId(String id) {
    if (size() == 1 && ids.isNotEmpty) {
      return;
    }
    clearFeatures();
    ids.add(id);
  }

  void narrowToTag(String tagName) {
    if (size() == 1) {
      return;
    }
    clearFeatures();
    tagNames.add(tagName);
  }

  void narrowToFeatures(InvalidationSetFeatures other) {
    // Implement this method.
  }

  void clearFeatures() {
    classes.clear();
    attributes.clear();
    ids.clear();
    tagNames.clear();
    emittedTagNames.clear();
  }

  int size() {
    return classes.length + attributes.length + ids.length + tagNames.length + emittedTagNames.length;
  }
}

enum SelectorPreMatch { selectorNeverMatches, selectorMayMatch }

class RuleFeatureSet {
  RuleFeatureSet();

  // Metadata and other private data
  final FeatureMetadata _metadata = FeatureMetadata();

  final Map<String, InvalidationSet> _classInvalidationSets = {};
  final Map<String, InvalidationSet> _attributeInvalidationSets = {};
  final Map<String, InvalidationSet> _idInvalidationSets = {};
  final Map<PseudoType, InvalidationSet> _pseudoInvalidationSets = {};

  SiblingInvalidationSet universalSiblingInvalidationSet = SiblingInvalidationSet();
  DescendantInvalidationSet typeRuleInvalidationSet = DescendantInvalidationSet();
  NthSiblingInvalidationSet? nthInvalidationSet;

  // We don't create the Bloom filter right away; there may be so few of
  // them that we don't really bother. This number counts the times we've
  // inserted something that could go in there; once it reaches 50
  // (for this style sheet), we create the Bloom filter and start
  // inserting there instead. Note that we don't _remove_ any of the sets,
  // though; they will remain. This also means that when merging the
  // RuleFeatureSets into the global one, we can go over 50 such entries
  // in total.
  int _numCandidatesForNamesBloomFilter = 0;
  final BloomFilter _namesWithSelfInvalidation = BloomFilter(falsePositiveProbability: 0.01, numItems: 1 << 14);

  // Merge function
  void merge(RuleFeatureSet other) {
    // Merge logic here
  }

  void clear() {
    // Clear logic here
  }

  SelectorPreMatch collectFeaturesFromSelector(CSSSelector selector, int selectorIndex, CSSRule rule) {
    FeatureMetadata metadata = FeatureMetadata();
    final int maxDirectAdjacentSelectors = 0;
    if (collectMetadataFromSelector(selector, maxDirectAdjacentSelectors, metadata) ==
        SelectorPreMatch.selectorNeverMatches) {
      return SelectorPreMatch.selectorNeverMatches;
    }

    _metadata.merge(metadata);

    updateInvalidationSets(selector, selectorIndex, rule as CSSStyleRule);

    return SelectorPreMatch.selectorMayMatch;
  }

  // The CollectMetadataFromSelector method
  SelectorPreMatch collectMetadataFromSelector(
    CSSSelector selector,
    int maxDirectAdjacentSelectors,
    FeatureMetadata metadata,
  ) {
    // RelationType relation = RelationType.descendant;
    //
    // int index = 0;
    // for (var current in selector.simpleSelectorSequences) {
    //   SimpleSelector simpleSelector = current.simpleSelector;
    //
    //   if (simpleSelector is PseudoSelector) {
    //     switch (simpleSelector.pseudoType) {
    //       case PseudoType.firstLine:
    //         metadata.usesFirstLineRules = true;
    //         break;
    //       default:
    //         break;
    //     }
    //   }
    //
    //   relation = current.combinator;
    //
    //   if (relation == RelationType.directAdjacent) {
    //     maxDirectAdjacentSelectors++;
    //   } else if (maxDirectAdjacentSelectors > 0 &&
    //       (relation != RelationType.subSelector || index + 1 == selector.simpleSelectorSequences.length)) {
    //     if (maxDirectAdjacentSelectors > metadata.maxDirectAdjacentSelectors) {
    //       metadata.maxDirectAdjacentSelectors = maxDirectAdjacentSelectors;
    //     }
    //     maxDirectAdjacentSelectors = 0;
    //   }
    //   index++;
    // }
    //
    // assert(maxDirectAdjacentSelectors == 0);

    return SelectorPreMatch.selectorMayMatch;
  }

  // Update all invalidation sets for a given selector (potentially in the
  // given @scope). See UpdateInvalidationSetsForComplex() for details.
  void updateInvalidationSets(CSSSelector selector, int selectorIndex, CSSStyleRule rule) {
    final features = InvalidationSetFeatures();

    final featureInvalidationType = updateInvalidationSetsForComplex(
        selector,
        selectorIndex,
        rule,
        false,
        // inNthChild
        features,
        PositionType.subject,
        PseudoType.unknown);

    if (featureInvalidationType == FeatureInvalidationType.requiresSubtreeInvalidation) {
      features.invalidationFlags.wholeSubtreeInvalid = true;
    }

    updateRuleSetInvalidation(features);
  }

  void updateRuleSetInvalidation(InvalidationSetFeatures features) {
    if (features.hasFeaturesForRuleSetInvalidation) {
      return;
    }

    if (features.invalidationFlags.wholeSubtreeInvalid ||
        (!features.invalidationFlags.invalidateCustomPseudo && features.tagNames.isEmpty)) {
      _metadata.needsFullRecalcForRuleSetInvalidation = true;
      return;
    }

    if (features.invalidationFlags.invalidateCustomPseudo) {
      typeRuleInvalidationSet.setCustomPseudoInvalid();
      typeRuleInvalidationSet.setTreeBoundaryCrossing();
    }

    for (var tagName in features.tagNames) {
      typeRuleInvalidationSet.addTagName(tagName);
    }
  }

  // Update all invalidation sets for a given CSS selector; this is usually
  // called for the entire selector at top level, but can also end up calling
  // itself recursively if any of the selectors contain selector lists
  FeatureInvalidationType updateInvalidationSetsForComplex(
    CSSSelector selector,
    int selectorIndex,
    CSSStyleRule rule,
    bool inNthChild,
    InvalidationSetFeatures features,
    PositionType position,
    PseudoType pseudoType,
  ) {
    // Given a rule, update the descendant invalidation sets for the features
    // found in its selector. The first step is to extract the features from the
    // rightmost compound selector (ExtractInvalidationSetFeaturesFromCompound).
    // Secondly, add those features to the invalidation sets for the features
    // found in the other compound selectors (AddFeaturesToInvalidationSets).
    // If we find a feature in the right-most compound selector that requires a
    // subtree recalc, next_compound will be the rightmost compound and we will
    // AddFeaturesToInvalidationSets for that one as well.
    InvalidationSetFeatures? siblingFeatures = null;

    // Step 1. Note that this also, in passing, inserts self-invalidation
    // and nth-child InvalidationSets for the rightmost compound selector.
    // This probably isn't the prettiest, but it's how the structure is
    // at this point.
    CSSSelector? lastInCompound =
        extractInvalidationSetFeaturesFromCompound(selector, features, position, false, inNthChild);

    bool wasWholeSubtreeInvalid = features.invalidationFlags.wholeSubtreeInvalid;

    if (features.invalidationFlags.wholeSubtreeInvalid) {
      features.hasFeaturesForRuleSetInvalidation = false;
    } else if (!features.hasFeatures()) {
      features.invalidationFlags.wholeSubtreeInvalid = true;
    }

    // Only check for has_nth_pseudo if this is the top-level complex selector.
    if (pseudoType == PseudoType.unknown && features.hasNthPseudo) {
      // The rightmost compound contains an :nth-* selector.
      // Add the compound features to the NthSiblingInvalidationSet. That is, for
      // '#id:nth-child(even)', add #id to the invalidation set and make sure we
      // invalidate elements matching those features (SetInvalidateSelf()).
      NthSiblingInvalidationSet nthSet = ensureNthInvalidationSet();
      addFeaturesToInvalidationSet(nthSet, features);
      nthSet.invalidatesSelf = true;
    }

    // Step 2.
    CSSSelector? nextCompound = lastInCompound != null
        ? selectorIndex < rule.selectorGroup.selectors.length - 1
            ? rule.selectorGroup.selectors[selectorIndex + 1]
            : null
        : selector;

    if (nextCompound != null) {
      if (lastInCompound != null) {

      }
    }

    return FeatureInvalidationType.requiresSubtreeInvalidation;
  }

  InvalidationSetFeatures? updateFeaturesFromCombinator(
      RelationType combinator,
      CSSSelector? lastCompoundInAdjacentChain,
      InvalidationSetFeatures lastCompoundInAdjacentChainFeatures,
      InvalidationSetFeatures descendantFeatures,
      bool forLogicalCombinationInHas,
      bool inNthChild) {

  }

  void addFeaturesToInvalidationSet(InvalidationSet invalidationSet, InvalidationSetFeatures features) {
    if (features.invalidationFlags.treeBoundaryCrossing) {
      invalidationSet.setTreeBoundaryCrossing();
    }
    if (features.invalidationFlags.insertionPointCrossing) {
      invalidationSet.setInsertionPointCrossing();
    }
    if (features.invalidationFlags.invalidatesSlotted) {
      invalidationSet.setInvalidatesSlotted();
    }
    if (features.invalidationFlags.wholeSubtreeInvalid) {
      invalidationSet.setWholeSubtreeInvalid();
    }
    if (features.invalidationFlags.invalidatesParts) {
      invalidationSet.setInvalidatesParts();
    }
    if (features.contentPseudoCrossing || features.invalidationFlags.wholeSubtreeInvalid) {
      return;
    }

    for (var id in features.ids) {
      invalidationSet.addId(id);
    }

    for (var tagName in features.tagNames) {
      invalidationSet.addTagName(tagName);
    }

    for (var emittedTagName in features.emittedTagNames) {
      invalidationSet.addTagName(emittedTagName);
    }

    for (var className in features.classes) {
      invalidationSet.addClass(className);
    }

    for (var attribute in features.attributes) {
      invalidationSet.addAttribute(attribute);
    }

    if (features.invalidationFlags.invalidateCustomPseudo) {
      invalidationSet.setCustomPseudoInvalid();
    }
  }

  static bool supportsInvalidation(PseudoType pseudoType) {
    switch (pseudoType) {
      case PseudoType.after:
      case PseudoType.before:
      case PseudoType.empty:
      case PseudoType.firstChild:
      case PseudoType.firstLine:
      case PseudoType.firstOfType:
      case PseudoType.lastChild:
      case PseudoType.lastOfType:
      case PseudoType.nthChild:
      case PseudoType.nthLastChild:
      case PseudoType.nthLastOfType:
      case PseudoType.nthOfType:
      case PseudoType.onlyChild:
      case PseudoType.onlyOfType:
      case PseudoType.root:
        return true;
      case PseudoType.unknown:
        return false;
    }
  }

  static bool requiresSubtreeInvalidation(SimpleSelector selector) {
    if (selector is! PseudoClassSelector && selector is! PseudoElementSelector) {
      return false;
    }

    if (selector is PseudoSelector) {
      switch (selector.pseudoType) {
        case PseudoType.firstLine:
          return true;
        default:
          assert(supportsInvalidation(selector.pseudoType));
          return false;
      }
    }

    return false;
  }

  void extractInvalidationSetFeaturesFromSimpleSelector(SimpleSelector selector, InvalidationSetFeatures features) {
    features.hasFeaturesForRuleSetInvalidation |=
        selector is IdSelector || selector is ClassSelector || selector is AttributeSelector; // simplified example

    if (selector is ElementSelector) {
      features.narrowToTag(selector.name);
      return;
    }
    if (selector is IdSelector) {
      features.narrowToId(selector.name);
      return;
    }
    if (selector is ClassSelector) {
      features.narrowToClass(selector.name);
      return;
    }
    if (selector is AttributeSelector) {
      features.narrowToAttribute(selector.name);
      return;
    }
  }

  bool insertIntoSelfInvalidationBloomFilter(String value) {
    if (_numCandidatesForNamesBloomFilter++ < 50) {
      return false;
    }
    _namesWithSelfInvalidation.add(value);
    return true;
  }

  InvalidationSet ensureMutableInvalidationSet(
      InvalidationType type, PositionType position, InvalidationSet? invalidationSet) {
    if (invalidationSet == null) {
      if (type == InvalidationType.invalidateDescendants) {
        if (position == PositionType.subject) {
          invalidationSet = InvalidationSet.selfInvalidationSet();
        } else {
          invalidationSet = DescendantInvalidationSet();
        }
      } else {
        invalidationSet = SiblingInvalidationSet();
      }
      return invalidationSet;
    }

    if (invalidationSet.invalidatesSelf &&
        type == InvalidationType.invalidateDescendants &&
        position == PositionType.subject) {
      // NOTE: This is fairly dodgy; we're returning the singleton
      // self-invalidation set (which is very much immutable) from a
      // function promising to return something mutable. We pretty much
      // rely on the caller to do the right thing and not mutate the
      // self-invalidation set if asking for it (ie., giving this
      // combination of type/position).
      return invalidationSet;
    }

    // @TODO: should consider exist invalidation sets.
    assert(false);
    return invalidationSet;
  }

  InvalidationSet ensureInvalidationSet(
      Map<String, InvalidationSet> map, String key, InvalidationType type, PositionType position) {
    InvalidationSet set = ensureMutableInvalidationSet(type, position, null);
    map[key] = set;
    return set;
  }

  InvalidationSet ensureClassInvalidationSet(String className, InvalidationType type, PositionType position) {
    return ensureInvalidationSet(_classInvalidationSets, className, type, position);
  }

  InvalidationSet ensureAttributeInvalidationSet(String attrName, InvalidationType type, PositionType position) {
    return ensureInvalidationSet(_attributeInvalidationSets, attrName, type, position);
  }

  InvalidationSet ensureIdInvalidationSet(String id, InvalidationType type, PositionType position) {
    return ensureInvalidationSet(_idInvalidationSets, id, type, position);
  }

  InvalidationSet ensurePseudoInvalidationSet(PseudoType pseudoType, InvalidationType type, PositionType position) {
    assert(pseudoType != PseudoType.unknown);
    InvalidationSet set = ensureMutableInvalidationSet(type, position, null);
    _pseudoInvalidationSets[pseudoType] = set;
    return set;
  }

  NthSiblingInvalidationSet ensureNthInvalidationSet() {
    nthInvalidationSet ??= NthSiblingInvalidationSet();
    return nthInvalidationSet!;
  }

  InvalidationSet? invalidationSetForSimpleSelector(
      SimpleSelector selector, InvalidationType type, PositionType position) {
    if (selector is ClassSelector) {
      if (type == InvalidationType.invalidateDescendants &&
          position == PositionType.subject &&
          insertIntoSelfInvalidationBloomFilter(selector.name)) {
        return null;
      }
      return ensureClassInvalidationSet(selector.name, type, position);
    }

    if (selector is AttributeSelector) {
      return ensureAttributeInvalidationSet(selector.name, type, position);
    }

    if (selector is IdSelector) {
      if (type == InvalidationType.invalidateDescendants &&
          position == PositionType.subject &&
          insertIntoSelfInvalidationBloomFilter(selector.name)) {
        return null;
      }
      return ensureIdInvalidationSet(selector.name, type, position);
    }

    if (selector is PseudoSelector) {
      switch (selector.pseudoType) {
        case PseudoType.firstOfType:
        case PseudoType.lastOfType:
        case PseudoType.onlyOfType:
        case PseudoType.nthChild:
        case PseudoType.nthOfType:
        case PseudoType.nthLastOfType:
        case PseudoType.nthLastChild:
          return ensureNthInvalidationSet();
        case PseudoType.empty:
        case PseudoType.firstChild:
        case PseudoType.firstLine:
        case PseudoType.lastChild:
        case PseudoType.onlyChild:
          return ensurePseudoInvalidationSet(selector.pseudoType, type, position);
        default:
          break;
      }
    }

    return null;
  }

  CSSSelector? extractInvalidationSetFeaturesFromCompound(
    CSSSelector compound,
    InvalidationSetFeatures features,
    PositionType position,
    bool forLogicalCombinationInHas,
    bool inNthChild,
  ) {
    int index = 0;
    // NOTE: Due to the check at the bottom of the loop, this loop stops
    // once we are at the end of the compound, ie., we see a relation that
    // is not a sub-selector. So for e.g. .a .b.c#d, we will see #d, .c, .b
    // and then stop, returning to .b.
    for (var selector in compound.simpleSelectorSequences) {
      // Fall back to use subtree invalidations, even for features in the
      // rightmost compound selector. Returning nullptr here will make
      // addFeaturesToInvalidationSets start marking invalidation sets for
      // subtree recalc for features in the rightmost compound selector.
      if (requiresSubtreeInvalidation(selector.simpleSelector)) {
        features.invalidationFlags.wholeSubtreeInvalid = true;
        return null;
      }

      extractInvalidationSetFeaturesFromSimpleSelector(selector.simpleSelector, features);

      // Initialize the entry in the invalidation set map for self-
      // invalidation, if supported.
      InvalidationSet? invalidationSet =
          invalidationSetForSimpleSelector(selector.simpleSelector, InvalidationType.invalidateDescendants, position);
      if (invalidationSet != null) {
        if (invalidationSet == nthInvalidationSet) {
          features.hasNthPseudo = true;
        } else if (position == PositionType.subject) {
          invalidationSet.invalidatesSelf = true;

          // If we are within :nth-child(), it means we'll need nth-child
          // invalidation for anything within this subject;
          if (inNthChild) {
            invalidationSet.invalidatesNth = true;
          }
        }
      }

      if (features.invalidationFlags.invalidatesParts) {
        _metadata.invalidatesParts = true;
      }

      if (index + 1 == compound.simpleSelectorSequences.length || (selector.combinator != RelationType.subSelector)) {
        // return selector;
        return null;
      }
      index++;
    }
    return null;
  }
}
