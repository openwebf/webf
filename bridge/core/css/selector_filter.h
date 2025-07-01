/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_SELECTOR_FILTER_H
#define WEBF_CSS_SELECTOR_FILTER_H

#include <memory>
#include <unordered_set>
#include <vector>
#include "core/css/css_selector.h"
#include "foundation/macros.h"

namespace webf {

class Element;

// Bloom filter for fast selector matching
class SelectorFilter {
  WEBF_DISALLOW_NEW();

 public:
  SelectorFilter();
  ~SelectorFilter();

  // Push element information to the filter
  void PushElement(const Element&);
  
  // Pop element information from the filter
  void PopElement(const Element&);
  
  // Check if a selector might match
  bool MightMatch(const CSSSelector&) const;
  
  // Clear the filter
  void Clear();

 private:
  // Bloom filter implementation
  static constexpr size_t kBloomFilterSize = 1024;
  static constexpr size_t kBloomFilterMask = kBloomFilterSize - 1;
  
  // Hash functions for bloom filter
  static unsigned Hash1(const AtomicString&);
  static unsigned Hash2(const AtomicString&);
  
  // Add to bloom filter
  void AddToBloomFilter(const AtomicString&);
  
  // Check bloom filter
  bool MayContain(const AtomicString&) const;
  
  // Collect identifiers from element
  void CollectElementIdentifiers(const Element&, std::vector<AtomicString>&);
  
  // Stack of bloom filters for nested elements
  struct FilterEntry {
    std::vector<bool> bloom_filter;
    std::vector<AtomicString> identifiers;
    
    FilterEntry() : bloom_filter(kBloomFilterSize, false) {}
  };
  
  std::vector<FilterEntry> filter_stack_;
  
  // Current filter (top of stack)
  FilterEntry* current_filter_ = nullptr;
};

}  // namespace webf

#endif  // WEBF_CSS_SELECTOR_FILTER_H