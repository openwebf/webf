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


// Helper that mirrors Blink's logic for checking selector filters
// in :nth-child(... of <selector>) and :nth-last-child(... of <selector>).
bool NthIndexCache::MatchesFilter(Element* element,
                                  const CSSSelectorList* selector_list,
                                  const SelectorChecker* checker,
                                  const void* context) {
  if (!selector_list) {
    return true;  // No filter => all elements count
  }
  // Build a sub-context based on the caller's context, as Blink does.
  const auto* original = static_cast<const SelectorChecker::SelectorCheckingContext*>(context);
  if (!original) {
    return false;
  }

  SelectorChecker::SelectorCheckingContext sub_context(*original);
  sub_context.element = element;
  sub_context.is_sub_selector = true;
  sub_context.in_nested_complex_selector = true;
  sub_context.pseudo_id = kPseudoIdNone;

  for (sub_context.selector = selector_list->First(); sub_context.selector;
       sub_context.selector = CSSSelectorList::Next(*sub_context.selector)) {
    SelectorChecker::MatchResult dummy_result;
    // As in Blink, use MatchSelector to avoid propagating flags.
    if (checker->MatchSelector(sub_context, dummy_result) == SelectorChecker::kSelectorMatches) {
      return true;
    }
  }
  return false;
}

unsigned NthIndexCache::NthChildIndex(const Element& element,
                                      const CSSSelectorList* selector_list,
                                      const SelectorChecker* checker,
                                      const void* context) {
  // Count previous siblings that match the optional filter.
  unsigned count = 1;
  for (Element* sibling = ElementTraversal::PreviousSibling(element); sibling;
       sibling = ElementTraversal::PreviousSibling(*sibling)) {
    if (MatchesFilter(sibling, selector_list, checker, context)) {
      ++count;
    }
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
  // Count following siblings that match the optional filter.
  unsigned count = 1;
  for (Element* sibling = ElementTraversal::NextSibling(element); sibling;
       sibling = ElementTraversal::NextSibling(*sibling)) {
    if (MatchesFilter(sibling, selector_list, checker, context)) {
      ++count;
    }
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
