/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "matched_properties_cache.h"

#include "core/css/css_property_value_set.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/dom/element.h"
#include "core/style/computed_style.h"

namespace webf {

MatchedPropertiesCache::MatchedPropertiesCache() = default;

MatchedPropertiesCache::~MatchedPropertiesCache() = default;

const MatchedPropertiesCache::CacheEntry* MatchedPropertiesCache::Find(
    const Key& key,
    const StyleResolverState& state) {
  
  if (!is_enabled_) {
    return nullptr;
  }
  
  auto it = cache_.find(key);
  if (it == cache_.end()) {
    ++miss_count_;
    return nullptr;
  }
  
  const CacheEntry& entry = it->second;
  
  // Verify the cached entry is still valid
  if (!IsValid(entry, state)) {
    // Remove invalid entry
    cache_.erase(it);
    ++miss_count_;
    return nullptr;
  }
  
  ++hit_count_;
  return &entry;
}

void MatchedPropertiesCache::Add(
    const Key& key,
    std::shared_ptr<const ComputedStyle> style,
    std::shared_ptr<const ComputedStyle> parent_style) {
  
  if (!is_enabled_ || !style) {
    return;
  }
  
  // Limit cache size to prevent unbounded growth
  static const size_t kMaxCacheSize = 1000;
  if (cache_.size() >= kMaxCacheSize) {
    // Simple eviction: clear the entire cache
    // TODO: Implement LRU or other eviction strategy
    Clear();
  }
  
  CacheEntry entry;
  entry.computed_style = style;
  entry.parent_computed_style = parent_style;
  
  cache_[key] = entry;
  ++add_count_;
}

void MatchedPropertiesCache::Clear() {
  cache_.clear();
  hit_count_ = 0;
  miss_count_ = 0;
  add_count_ = 0;
}

bool MatchedPropertiesCache::IsValid(
    const CacheEntry& entry,
    const StyleResolverState& state) const {
  
  if (!entry.computed_style) {
    return false;
  }
  
  // Check if parent style matches
  const ComputedStyle* current_parent = state.ParentStyle();
  const ComputedStyle* cached_parent = entry.parent_computed_style.get();
  
  if (current_parent != cached_parent) {
    // Parent style has changed
    return false;
  }
  
  // TODO: Add more validation checks:
  // - Font size changes that affect em/rem units
  // - Viewport size changes that affect viewport units
  // - Custom property changes
  // - Container query changes
  
  return true;
}

unsigned MatchedPropertiesCache::ComputeMatchedPropertiesHash(
    const MatchResult& result) {
  
  unsigned hash = 0;
  
  for (const auto& entry : result.GetMatchedProperties()) {
    if (!entry.properties) {
      continue;
    }
    
    // Simple hash combining property count and first few properties
    hash = (hash << 5) ^ entry.properties->PropertyCount();
    
    // Hash first few properties
    for (unsigned i = 0; i < std::min(3u, entry.properties->PropertyCount()); ++i) {
      const auto property = entry.properties->PropertyAt(i);
      hash = (hash << 3) ^ static_cast<unsigned>(property.Id());
      hash = (hash << 1) ^ (property.IsImportant() ? 1 : 0);
    }
    
    // Include origin and layer in hash
    hash = (hash << 2) ^ static_cast<unsigned>(entry.origin);
    hash = (hash << 4) ^ entry.layer_level;
  }
  
  return hash;
}

}  // namespace webf