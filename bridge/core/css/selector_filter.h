/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_SELECTOR_FILTER_H
#define WEBF_CSS_SELECTOR_FILTER_H

#include <array>
#include <bitset>
#include <cstdint>
#include <memory>
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

  // Precompute identifier hashes for a selector's ancestor requirements.
  // The resulting hashes are used by FastRejectSelector() for a cheap
  // bit-test based rejection.
  static void CollectIdentifierHashes(const CSSSelector&, std::vector<uint32_t>& hashes);

  // Fast reject using precomputed identifier hashes.
  bool FastRejectSelector(const std::vector<uint32_t>& identifier_hashes) const;
  
  // Check if a selector might match
  bool MightMatch(const CSSSelector&) const;
  
  // Clear the filter
 void Clear();

 private:
  // Similar to Blink's SelectorFilter: a small bloom filter for ancestor
  // identifiers to quickly reject rules with impossible ancestor requirements.
  static constexpr unsigned kFilterSize = 8192;
  static constexpr unsigned kFilterMask = kFilterSize - 1;

  enum Salt : unsigned {
    kTagSalt = 1,
    kIdSalt = 3,
    kClassSalt = 5,
    kAttributeSalt = 7,
  };

  void PushMark();
  void PopToLastMark();

  void AddHash(unsigned hash);
  bool MayContainHash(unsigned hash) const;
  void AddIdentifier(const AtomicString&, unsigned salt);
  bool MayContainIdentifier(const AtomicString&, unsigned salt) const;

  static bool IsExcludedAttribute(const AtomicString& local_name);

  bool FastRejectDescendantSelectors(const CSSSelector&) const;
  bool FastRejectDescendantCompoundSelectorIdentifierHashes(const CSSSelector* selector,
                                                            CSSSelector::RelationType relation) const;
  bool FastRejectForSimpleSelector(const CSSSelector&) const;

  std::bitset<kFilterSize> ancestor_filter_;
  std::vector<uint16_t> set_bits_;
  std::vector<size_t> marks_;
};

}  // namespace webf

#endif  // WEBF_CSS_SELECTOR_FILTER_H
