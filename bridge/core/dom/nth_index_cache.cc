/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/dom/nth_index_cache.h"

#include <unordered_map>

#include "core/dom/container_node.h"
#include "core/dom/element.h"
#include "core/dom/element_traversal.h"
#include "core/dom/qualified_name.h"
#include "core/css/css_selector_list.h"
#include "core/css/selector_checker.h"
#include "foundation/string/atomic_string.h"

namespace webf {

namespace {

thread_local NthIndexCachePerfStats g_nth_index_cache_perf_stats;
thread_local bool g_nth_index_cache_enabled = false;

struct TypeIndexCache {
  unsigned total = 0;
  std::unordered_map<const Element*, unsigned> index;
};

struct ParentIndexCache {
  unsigned total_element_children = 0;
  bool child_index_built = false;
  std::unordered_map<const Element*, unsigned> child_index;
  std::unordered_map<AtomicString, TypeIndexCache, AtomicString::KeyHasher> type_caches;
};

thread_local std::unordered_map<const ContainerNode*, ParentIndexCache> g_parent_index_caches;

ParentIndexCache& GetParentCache(const ContainerNode& parent) {
  return g_parent_index_caches[&parent];
}

void EnsureChildIndexBuilt(ParentIndexCache& cache, const ContainerNode& parent) {
  if (cache.child_index_built) {
    return;
  }
  ++g_nth_index_cache_perf_stats.parent_cache_builds;
  unsigned index = 0;
  for (Element* child = ElementTraversal::FirstChild(parent); child; child = ElementTraversal::NextSibling(*child)) {
    ++index;
    cache.child_index.emplace(child, index);
    ++g_nth_index_cache_perf_stats.parent_cache_build_steps;
  }
  cache.total_element_children = index;
  cache.child_index_built = true;
}

TypeIndexCache& EnsureTypeIndexBuilt(ParentIndexCache& cache,
                                     const ContainerNode& parent,
                                     const AtomicString& local_name) {
  auto it = cache.type_caches.find(local_name);
  if (it != cache.type_caches.end()) {
    return it->second;
  }

  ++g_nth_index_cache_perf_stats.type_cache_builds;
  auto [insert_it, inserted] = cache.type_caches.emplace(local_name, TypeIndexCache{});
  TypeIndexCache& type_cache = insert_it->second;

  unsigned index = 0;
  for (Element* child = ElementTraversal::FirstChild(parent); child; child = ElementTraversal::NextSibling(*child)) {
    ++g_nth_index_cache_perf_stats.type_cache_build_steps;
    if (!child->HasTagName(local_name)) {
      continue;
    }
    ++index;
    type_cache.index.emplace(child, index);
  }
  type_cache.total = index;
  return type_cache;
}

}  // namespace

void ResetNthIndexCachePerfStats() {
  g_nth_index_cache_perf_stats = NthIndexCachePerfStats{};
}

NthIndexCachePerfStats TakeNthIndexCachePerfStats() {
  NthIndexCachePerfStats out = g_nth_index_cache_perf_stats;
  g_nth_index_cache_perf_stats = NthIndexCachePerfStats{};
  return out;
}

NthIndexCacheScope::NthIndexCacheScope() : previous_enabled_(g_nth_index_cache_enabled) {
  if (!previous_enabled_) {
    g_nth_index_cache_enabled = true;
    g_parent_index_caches.clear();
  }
}

NthIndexCacheScope::~NthIndexCacheScope() {
  if (!previous_enabled_) {
    g_parent_index_caches.clear();
    g_nth_index_cache_enabled = false;
  }
}


// Helper that mirrors Blink's logic for checking selector filters
// in :nth-child(... of <selector>) and :nth-last-child(... of <selector>).
bool NthIndexCache::MatchesFilter(Element* element,
                                  const CSSSelectorList* selector_list,
                                  const SelectorChecker* checker,
                                  const void* context) {
  ++g_nth_index_cache_perf_stats.of_filter_checks;
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
    ++g_nth_index_cache_perf_stats.of_filter_match_selector_calls;
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
  ++g_nth_index_cache_perf_stats.nth_child_calls;

  if (selector_list || !g_nth_index_cache_enabled) {
  // Count previous siblings that match the optional filter.
  unsigned count = 1;
  for (Element* sibling = ElementTraversal::PreviousSibling(element); sibling;
       sibling = ElementTraversal::PreviousSibling(*sibling)) {
    ++g_nth_index_cache_perf_stats.nth_child_steps;
    if (MatchesFilter(sibling, selector_list, checker, context)) {
      ++count;
    }
  }
  return count;
  }

  ContainerNode* parent = element.ParentElementOrDocumentFragment();
  if (!parent) {
    return 1;
  }
  ParentIndexCache& cache = GetParentCache(*parent);
  EnsureChildIndexBuilt(cache, *parent);
  auto it = cache.child_index.find(&element);
  if (it == cache.child_index.end()) {
    return 1;
  }
  return it->second;
}

unsigned NthIndexCache::NthOfTypeIndex(const Element& element) {
  ++g_nth_index_cache_perf_stats.nth_of_type_calls;

  if (!g_nth_index_cache_enabled) {
  // Count previous siblings of the same type
  unsigned count = 1;
  const QualifiedName& type = element.TagQName();
  
  for (Element* sibling = ElementTraversal::PreviousSibling(element, HasTagName(type.LocalName()));
       sibling; sibling = ElementTraversal::PreviousSibling(*sibling, HasTagName(type.LocalName()))) {
    ++g_nth_index_cache_perf_stats.nth_of_type_steps;
    ++count;
  }
  return count;
  }

  ContainerNode* parent = element.ParentElementOrDocumentFragment();
  if (!parent) {
    return 1;
  }
  const AtomicString& local_name = element.TagQName().LocalName();
  ParentIndexCache& parent_cache = GetParentCache(*parent);
  TypeIndexCache& type_cache = EnsureTypeIndexBuilt(parent_cache, *parent, local_name);
  auto it = type_cache.index.find(&element);
  if (it == type_cache.index.end()) {
    return 1;
  }
  return it->second;
}

unsigned NthIndexCache::NthLastChildIndex(const Element& element,
                                          const CSSSelectorList* selector_list,
                                          const SelectorChecker* checker,
                                          const void* context) {
  ++g_nth_index_cache_perf_stats.nth_last_child_calls;

  if (selector_list || !g_nth_index_cache_enabled) {
  // Count following siblings that match the optional filter.
  unsigned count = 1;
  for (Element* sibling = ElementTraversal::NextSibling(element); sibling;
       sibling = ElementTraversal::NextSibling(*sibling)) {
    ++g_nth_index_cache_perf_stats.nth_last_child_steps;
    if (MatchesFilter(sibling, selector_list, checker, context)) {
      ++count;
    }
  }
  return count;
  }

  ContainerNode* parent = element.ParentElementOrDocumentFragment();
  if (!parent) {
    return 1;
  }
  ParentIndexCache& cache = GetParentCache(*parent);
  EnsureChildIndexBuilt(cache, *parent);
  auto it = cache.child_index.find(&element);
  if (it == cache.child_index.end() || cache.total_element_children == 0) {
    return 1;
  }
  return cache.total_element_children - it->second + 1;
}

unsigned NthIndexCache::NthLastOfTypeIndex(const Element& element) {
  ++g_nth_index_cache_perf_stats.nth_last_of_type_calls;

  if (!g_nth_index_cache_enabled) {
  // Count following siblings of the same type
  unsigned count = 1;
  const QualifiedName& type = element.TagQName();
  
  for (Element* sibling = ElementTraversal::NextSibling(element, HasTagName(type.LocalName()));
       sibling; sibling = ElementTraversal::NextSibling(*sibling, HasTagName(type.LocalName()))) {
    ++g_nth_index_cache_perf_stats.nth_last_of_type_steps;
    ++count;
  }
  return count;
  }

  ContainerNode* parent = element.ParentElementOrDocumentFragment();
  if (!parent) {
    return 1;
  }
  const AtomicString& local_name = element.TagQName().LocalName();
  ParentIndexCache& parent_cache = GetParentCache(*parent);
  TypeIndexCache& type_cache = EnsureTypeIndexBuilt(parent_cache, *parent, local_name);
  auto it = type_cache.index.find(&element);
  if (it == type_cache.index.end() || type_cache.total == 0) {
    return 1;
  }
  return type_cache.total - it->second + 1;
}

}  // namespace webf
