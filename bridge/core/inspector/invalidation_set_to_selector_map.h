// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INSPECTOR_INVALIDATION_SET_TO_SELECTOR_MAP_H_
#define WEBF_CORE_INSPECTOR_INVALIDATION_SET_TO_SELECTOR_MAP_H_

#include "core/css/style_rule.h"

namespace webf {

class InvalidationSet;
class StyleRule;

// Implements a back-mapping from InvalidationSet entries to the selectors that
// placed them there, for use in diagnostic traces.
// Only active while the appropriate tracing configuration is enabled.
class InvalidationSetToSelectorMap {
 public:
  // A small helper to bundle together a StyleRule plus an index into its
  // selector list.
  class IndexedSelector {
   public:
    IndexedSelector(StyleRule* style_rule, unsigned selector_index);
    //void Trace(GCVisitor*) const;
    std::shared_ptr<StyleRule> GetStyleRule() const;
    unsigned GetSelectorIndex() const;
    std::string GetSelectorText() const;

    // TODO(guopengfei)：简单实现，解决编译问题
    struct KeyHasher {
      std::size_t operator()(const IndexedSelector& k) const { return k.selector_index_; }
    };

   private:
    std::shared_ptr<StyleRule> style_rule_;
    unsigned selector_index_;
  };
  using IndexedSelectorList = std::unordered_set<std::shared_ptr<IndexedSelector>>;

  enum class SelectorFeatureType {
    kUnknown,
    kClass,
    kId,
    kTagName,
    kAttribute,
    kWholeSubtree
  };

  // Instantiates a new mapping if a diagnostic tracing session with the
  // appropriate configuration has started, or deletes an existing mapping if
  // tracing is no longer enabled.
  static void StartOrStopTrackingIfNeeded();

  // Call at the start and end of indexing features for a given selector.
  static void BeginSelector(StyleRule* style_rule, unsigned selector_index);
  static void EndSelector();

  // Helper object for a Begin/EndSelector pair.
  class SelectorScope {
   public:
    SelectorScope(StyleRule* style_rule, unsigned selector_index);
    ~SelectorScope();
  };

  // Call for each feature recorded to an invalidation set.
  static void RecordInvalidationSetEntry(
      const InvalidationSet* invalidation_set,
      SelectorFeatureType type,
      const AtomicString& value);

  // Call at the start and end of an invalidation set combine operation.
  static void BeginInvalidationSetCombine(const InvalidationSet* target,
                                          const InvalidationSet* source);
  static void EndInvalidationSetCombine();

  // Helper object for a Begin/EndInvalidationSetCombine pair.
  class CombineScope {
   public:
    CombineScope(const InvalidationSet* target, const InvalidationSet* source);
    ~CombineScope();
  };

  // Given an invalidation set and a selector feature representing an entry in
  // that invalidation set, returns a list of selectors that contributed to that
  // entry existing in that invalidation set.
  static const IndexedSelectorList* Lookup(
      const InvalidationSet* invalidation_set,
      SelectorFeatureType type,
      const AtomicString& value);

  InvalidationSetToSelectorMap();
  void Trace(GCVisitor*) const;

 protected:
  friend class InvalidationSetToSelectorMapTest;
  static std::shared_ptr<InvalidationSetToSelectorMap>& GetInstanceReference();

 private:
  // The back-map is stored in two levels: first from an invalidation set
  // pointer to a map of entries, then from each entry to a list of selectors.
  // We don't retain a strong pointer to the InvalidationSet because we don't
  // need it for any purpose other than as a lookup key.

  struct KeyHasher {
    std::size_t operator()(const std::pair<SelectorFeatureType, AtomicString>& p) const noexcept {
      std::size_t h1 = std::hash<SelectorFeatureType>{}(p.first);
      std::size_t h2 = AtomicString::KeyHasher{}(p.second);
      return h1 ^ (h2 << 1); // 或者使用其他合适的哈希组合方式
    }
  };

  using InvalidationSetEntry = std::pair<SelectorFeatureType, AtomicString>;
  using InvalidationSetEntryMap =
      std::unordered_map<InvalidationSetEntry, std::shared_ptr<IndexedSelectorList>, KeyHasher>;
  using InvalidationSetMap =
      std::unordered_map<const InvalidationSet*, std::shared_ptr<InvalidationSetEntryMap>>;

  std::shared_ptr<InvalidationSetMap> invalidation_set_map_;
  std::shared_ptr<IndexedSelector> current_selector_;
  unsigned combine_recursion_depth_ = 0;
};

// static
std::shared_ptr<InvalidationSetToSelectorMap>&
InvalidationSetToSelectorMap::GetInstanceReference() {
  thread_local static std::shared_ptr<InvalidationSetToSelectorMap> instance = std::make_shared<InvalidationSetToSelectorMap>();
  return instance;
}

}  // namespace webf

#endif  // WEBF_CORE_INSPECTOR_INVALIDATION_SET_TO_SELECTOR_MAP_H_
