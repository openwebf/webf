/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_MATCHED_PROPERTIES_CACHE_H
#define WEBF_CSS_RESOLVER_MATCHED_PROPERTIES_CACHE_H

#include <memory>
#include <unordered_map>
#include "core/css/match_result.h"
#include "core/style/computed_style.h"
#include "foundation/macros.h"

namespace webf {

class Element;
class StyleResolverState;

// Cache for matched properties to avoid redundant style resolution
class MatchedPropertiesCache {

 public:
  MatchedPropertiesCache();
  ~MatchedPropertiesCache();

  // Cache key for looking up cached styles
  struct Key {
    // Hash of matched properties
    unsigned matched_properties_hash = 0;
    
    // Parent style hash
    unsigned parent_style_hash = 0;
    
    // Element characteristics
    bool is_link = false;
    bool is_visited_link = false;
    
    bool operator==(const Key& other) const {
      return matched_properties_hash == other.matched_properties_hash &&
             parent_style_hash == other.parent_style_hash &&
             is_link == other.is_link &&
             is_visited_link == other.is_visited_link;
    }
  };
  
  struct KeyHash {
    size_t operator()(const Key& key) const {
      size_t hash = key.matched_properties_hash;
      hash = (hash << 5) ^ key.parent_style_hash;
      if (key.is_link) hash ^= 1;
      if (key.is_visited_link) hash ^= 2;
      return hash;
    }
  };

  // Cache entry containing computed style
  struct CacheEntry {
    std::shared_ptr<const ComputedStyle> computed_style;
    std::shared_ptr<const ComputedStyle> parent_computed_style;
  };

  // Try to find a cached style
  const CacheEntry* Find(const Key&, const StyleResolverState&);

  // Add a style to the cache
  void Add(const Key&, 
           std::shared_ptr<const ComputedStyle>,
           std::shared_ptr<const ComputedStyle> parent);

  // Clear the cache
  void Clear();

  // Check if caching is enabled
  bool IsEnabled() const { return is_enabled_; }
  void SetEnabled(bool enabled) { is_enabled_ = enabled; }

 private:
  // Verify that a cached entry is still valid
  bool IsValid(const CacheEntry&, const StyleResolverState&) const;

  // Compute hash for matched properties
  static unsigned ComputeMatchedPropertiesHash(const MatchResult&);

  std::unordered_map<Key, CacheEntry, KeyHash> cache_;
  bool is_enabled_ = true;
  
  // Cache statistics
  mutable unsigned hit_count_ = 0;
  mutable unsigned miss_count_ = 0;
  mutable unsigned add_count_ = 0;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_MATCHED_PROPERTIES_CACHE_H