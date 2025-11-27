/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/inspector/invalidation_set_to_selector_map.h"
#include "core/css/invalidation/invalidation_set.h"

namespace webf {

InvalidationSetToSelectorMap::IndexedSelector::IndexedSelector(StyleRule* style_rule, unsigned selector_index)
    : style_rule_(style_rule), selector_index_(selector_index) {}

// void InvalidationSetToSelectorMap::IndexedSelector::Trace(
//    Visitor* visitor) const {
//  visitor->Trace(style_rule_);
//}

std::shared_ptr<StyleRule> InvalidationSetToSelectorMap::IndexedSelector::GetStyleRule() const {
  return style_rule_;
}

unsigned InvalidationSetToSelectorMap::IndexedSelector::GetSelectorIndex() const {
  return selector_index_;
}

std::string InvalidationSetToSelectorMap::IndexedSelector::GetSelectorText() const {
  return style_rule_->SelectorAt(selector_index_).SelectorText().ToUTF8String();
}

// static
void InvalidationSetToSelectorMap::StartOrStopTrackingIfNeeded() {
  // WebF currently does not toggle invalidation-set tracing dynamically.
  // Keep the singleton instance managed by GetInstanceReference() and do
  // nothing here.
}

// static
void InvalidationSetToSelectorMap::BeginSelector(StyleRule* style_rule, unsigned selector_index) {
  InvalidationSetToSelectorMap* instance = GetInstanceReference().get();
  if (instance == nullptr) {
    return;
  }

  assert(instance->current_selector_ == nullptr);
  instance->current_selector_ = std::make_shared<IndexedSelector>(style_rule, selector_index);
}

// static
void InvalidationSetToSelectorMap::EndSelector() {
  InvalidationSetToSelectorMap* instance = GetInstanceReference().get();
  if (instance == nullptr) {
    return;
  }

  assert(instance->current_selector_ != nullptr);
  instance->current_selector_.reset();
}

InvalidationSetToSelectorMap::SelectorScope::SelectorScope(StyleRule* style_rule, unsigned selector_index) {
  InvalidationSetToSelectorMap::BeginSelector(style_rule, selector_index);
}
InvalidationSetToSelectorMap::SelectorScope::~SelectorScope() {
  InvalidationSetToSelectorMap::EndSelector();
}

// static
// static
void InvalidationSetToSelectorMap::RecordInvalidationSetEntry(const InvalidationSet* invalidation_set,
                                                              SelectorFeatureType type,
                                                              const AtomicString& value) {
  InvalidationSetToSelectorMap* instance = GetInstanceReference().get();
  if (instance == nullptr) {
    return;
  }

  // Ignore entries that get added during a combine operation. Those get
  // handled when the combine operation begins.
  if (instance->combine_recursion_depth_ > 0) {
    return;
  }

  // Mapping is only valid when we have an active selector context. In normal
  // WebF builds we never enable invalidation tracing, so simply skip if no
  // current selector has been set, instead of asserting.
  if (!instance->current_selector_) {
    return;
  }
  auto result =
      instance->invalidation_set_map_->insert({invalidation_set, std::make_shared<InvalidationSetEntryMap>()});
  InvalidationSetEntryMap* entry_map = result.first->second.get();

  auto insert_result = entry_map->insert({InvalidationSetEntry(type, value), std::make_shared<IndexedSelectorList>()});
  IndexedSelectorList* indexed_selector_list = insert_result.first->second.get();

  indexed_selector_list->insert(instance->current_selector_);
}

// static
void InvalidationSetToSelectorMap::BeginInvalidationSetCombine(const InvalidationSet* target,
                                                               const InvalidationSet* source) {
  InvalidationSetToSelectorMap* instance = GetInstanceReference().get();
  if (instance == nullptr) {
    return;
  }
  instance->combine_recursion_depth_++;

  // `source` may not be in the map if it contains only information that is not
  // tracked such as self-invalidation, or if it was created before tracking
  // started.
  // TODO(crbug.com/337076014): Re-visit rule sets that already existed when
  // tracking started so that invalidation sets for them can be included.
  auto source_entry_it = instance->invalidation_set_map_->find(source);
  if (source_entry_it != instance->invalidation_set_map_->end()) {
    auto target_entry_map_it =
        instance->invalidation_set_map_->insert({target, std::make_shared<InvalidationSetEntryMap>()});
    InvalidationSetEntryMap* target_entry_map = target_entry_map_it.first->second.get();

    for (const auto& source_selector_list_it : *(source_entry_it->second)) {
      auto target_selector_list_it =
          target_entry_map->insert({source_selector_list_it.first, std::make_shared<IndexedSelectorList>()});
      IndexedSelectorList* target_selector_list = target_selector_list_it.first->second.get();

      for (const auto& source_selector : *(source_selector_list_it.second)) {
        target_selector_list->insert(source_selector);
      }
    }
  }
}

// static
void InvalidationSetToSelectorMap::EndInvalidationSetCombine() {
  InvalidationSetToSelectorMap* instance = GetInstanceReference().get();
  if (instance == nullptr) {
    return;
  }

  assert(instance->combine_recursion_depth_ > 0u);
  instance->combine_recursion_depth_--;
}

InvalidationSetToSelectorMap::CombineScope::CombineScope(const InvalidationSet* target, const InvalidationSet* source) {
  InvalidationSetToSelectorMap::BeginInvalidationSetCombine(target, source);
}

InvalidationSetToSelectorMap::CombineScope::~CombineScope() {
  InvalidationSetToSelectorMap::EndInvalidationSetCombine();
}

// static
const InvalidationSetToSelectorMap::IndexedSelectorList* InvalidationSetToSelectorMap::Lookup(
    const InvalidationSet* invalidation_set,
    SelectorFeatureType type,
    const AtomicString& value) {
  const InvalidationSetToSelectorMap* instance = GetInstanceReference().get();
  if (instance == nullptr) {
    return nullptr;
  }

  auto entry_it = instance->invalidation_set_map_->find(invalidation_set);
  if (entry_it != instance->invalidation_set_map_->end()) {
    auto selector_list_it = entry_it->second->find(InvalidationSetEntry(type, value));
    if (selector_list_it != entry_it->second->end()) {
      return selector_list_it->second.get();
    }
  }

  return nullptr;
}

InvalidationSetToSelectorMap::InvalidationSetToSelectorMap() {
  invalidation_set_map_ = std::make_shared<InvalidationSetMap>();
}

void InvalidationSetToSelectorMap::Trace(GCVisitor* visitor) const {
  // visitor->Trace(invalidation_set_map_);
  // visitor->Trace(current_selector_);
}

// static
std::shared_ptr<InvalidationSetToSelectorMap>& InvalidationSetToSelectorMap::GetInstanceReference() {
  thread_local static std::shared_ptr<InvalidationSetToSelectorMap> instance =
      std::make_shared<InvalidationSetToSelectorMap>();
  return instance;
}

}  // namespace webf
