/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_NTH_INDEX_CACHE_H_
#define WEBF_CORE_DOM_NTH_INDEX_CACHE_H_

#include "foundation/macros.h"

namespace webf {

class Element;
class CSSSelectorList;
class SelectorChecker;

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
