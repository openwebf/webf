/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_NTH_INDEX_CACHE_H_
#define WEBF_CORE_DOM_NTH_INDEX_CACHE_H_

#include <cstdint>
#include "foundation/macros.h"

namespace webf {

class Element;
class CSSSelectorList;
class SelectorChecker;

struct NthIndexCachePerfStats {
  uint64_t nth_child_calls = 0;
  uint64_t nth_child_steps = 0;
  uint64_t nth_last_child_calls = 0;
  uint64_t nth_last_child_steps = 0;
  uint64_t nth_of_type_calls = 0;
  uint64_t nth_of_type_steps = 0;
  uint64_t nth_last_of_type_calls = 0;
  uint64_t nth_last_of_type_steps = 0;

  uint64_t of_filter_checks = 0;
  uint64_t of_filter_match_selector_calls = 0;

  uint64_t parent_cache_builds = 0;
  uint64_t parent_cache_build_steps = 0;
  uint64_t type_cache_builds = 0;
  uint64_t type_cache_build_steps = 0;
};

void ResetNthIndexCachePerfStats();
NthIndexCachePerfStats TakeNthIndexCachePerfStats();

class NthIndexCacheScope {
  WEBF_STACK_ALLOCATED();

 public:
  NthIndexCacheScope();
  ~NthIndexCacheScope();

  NthIndexCacheScope(const NthIndexCacheScope&) = delete;
  NthIndexCacheScope& operator=(const NthIndexCacheScope&) = delete;

 private:
  bool previous_enabled_{false};
};

// Basic implementation of NthIndexCache for nth-child selectors
// TODO: Add actual caching for performance optimization
class NthIndexCache {
  WEBF_STACK_ALLOCATED();

 public:
  // Calculate the index of element among its siblings (1-based)
  static unsigned NthChildIndex(const Element& element,
                                const CSSSelectorList* selector_list,
                                const SelectorChecker* checker,
                                const void* context);
  
  // Calculate the index of element among siblings of the same type (1-based)
  static unsigned NthOfTypeIndex(const Element& element);
  
  // Calculate the index from the end among siblings (1-based)
  static unsigned NthLastChildIndex(const Element& element,
                                    const CSSSelectorList* selector_list,
                                    const SelectorChecker* checker,
                                    const void* context);
  
  // Calculate the index from the end among siblings of the same type (1-based)
  static unsigned NthLastOfTypeIndex(const Element& element);
 
 private:
  // Helper: when a selector list is provided for :nth-child(... of S),
  // only siblings matching that selector list are counted.
  static bool MatchesFilter(Element* element,
                            const CSSSelectorList* selector_list,
                            const SelectorChecker* checker,
                            const void* context);
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_NTH_INDEX_CACHE_H_
