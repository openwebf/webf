/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/dom/nth_index_cache.h"
#include "core/dom/element.h"
#include "core/dom/element_traversal.h"
#include "core/dom/qualified_name.h"
#include "core/css/css_selector_list.h"
#include "core/css/selector_checker.h"

namespace webf {

unsigned NthIndexCache::NthChildIndex(const Element& element,
                                      const CSSSelectorList* selector_list,
                                      const SelectorChecker* checker,
                                      const void* context) {
  // Count previous siblings
  unsigned count = 1;
  for (Element* sibling = ElementTraversal::PreviousSibling(element);
       sibling; sibling = ElementTraversal::PreviousSibling(*sibling)) {
    // If selector_list is provided, only count elements that match
    // For now, we count all siblings (simplified implementation)
    // TODO: Implement selector matching for nth-child(An+B of selector)
    ++count;
  }
  return count;
}

unsigned NthIndexCache::NthOfTypeIndex(const Element& element) {
  // Count previous siblings of the same type
  unsigned count = 1;
  const QualifiedName& type = element.TagQName();
  
  for (Element* sibling = ElementTraversal::PreviousSibling(element, HasTagName(type.LocalName()));
       sibling; sibling = ElementTraversal::PreviousSibling(*sibling, HasTagName(type.LocalName()))) {
    ++count;
  }
  return count;
}

unsigned NthIndexCache::NthLastChildIndex(const Element& element,
                                          const CSSSelectorList* selector_list,
                                          const SelectorChecker* checker,
                                          const void* context) {
  // Count following siblings
  unsigned count = 1;
  for (Element* sibling = ElementTraversal::NextSibling(element);
       sibling; sibling = ElementTraversal::NextSibling(*sibling)) {
    // If selector_list is provided, only count elements that match
    // For now, we count all siblings (simplified implementation)
    // TODO: Implement selector matching for nth-last-child(An+B of selector)
    ++count;
  }
  return count;
}

unsigned NthIndexCache::NthLastOfTypeIndex(const Element& element) {
  // Count following siblings of the same type
  unsigned count = 1;
  const QualifiedName& type = element.TagQName();
  
  for (Element* sibling = ElementTraversal::NextSibling(element, HasTagName(type.LocalName()));
       sibling; sibling = ElementTraversal::NextSibling(*sibling, HasTagName(type.LocalName()))) {
    ++count;
  }
  return count;
}

}  // namespace webf