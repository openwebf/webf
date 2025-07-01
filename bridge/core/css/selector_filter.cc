/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "selector_filter.h"

#include "core/css/css_selector.h"
#include "core/dom/element.h"

namespace webf {

SelectorFilter::SelectorFilter() {
  // Start with one filter on the stack
  filter_stack_.emplace_back();
  current_filter_ = &filter_stack_.back();
}

SelectorFilter::~SelectorFilter() = default;

void SelectorFilter::PushElement(const Element& element) {
  // Create new filter entry
  filter_stack_.emplace_back();
  current_filter_ = &filter_stack_.back();
  
  // Collect identifiers from element
  std::vector<AtomicString> identifiers;
  CollectElementIdentifiers(element, identifiers);
  
  // Add identifiers to bloom filter
  for (const auto& identifier : identifiers) {
    AddToBloomFilter(identifier);
    current_filter_->identifiers.push_back(identifier);
  }
}

void SelectorFilter::PopElement(const Element& element) {
  if (filter_stack_.size() > 1) {
    filter_stack_.pop_back();
    current_filter_ = &filter_stack_.back();
  }
}

bool SelectorFilter::MightMatch(const CSSSelector& selector) const {
  if (!current_filter_) {
    return true;
  }
  
  // Check each simple selector in the compound
  for (const CSSSelector* current = &selector; current; 
       current = current->NextSimpleSelector()) {
    
    // Check tag name
    if (current->Match() == CSSSelector::kTag) {
      const AtomicString& tag_name = current->TagQName().LocalName();
      if (!tag_name.IsNull() && !MayContain(tag_name)) {
        return false;
      }
    }
    
    // Check ID
    if (current->Match() == CSSSelector::kId) {
      const AtomicString& id = current->Value();
      if (!id.IsNull() && !MayContain(id)) {
        return false;
      }
    }
    
    // Check class
    if (current->Match() == CSSSelector::kClass) {
      const AtomicString& class_name = current->Value();
      if (!class_name.IsNull() && !MayContain(class_name)) {
        return false;
      }
    }
    
    // Check attribute name
    if (current->IsAttributeSelector()) {
      const QualifiedName& attr = current->Attribute();
      if (!MayContain(attr.LocalName())) {
        return false;
      }
    }
  }
  
  return true;
}

void SelectorFilter::Clear() {
  filter_stack_.clear();
  filter_stack_.emplace_back();
  current_filter_ = &filter_stack_.back();
}

unsigned SelectorFilter::Hash1(const AtomicString& string) {
  // Simple hash function 1
  unsigned hash = 0;
  const auto& impl = string.Impl();
  if (impl) {
    for (size_t i = 0; i < impl->length(); ++i) {
      hash = (hash << 5) + hash + (*impl)[i];
    }
  }
  return hash & kBloomFilterMask;
}

unsigned SelectorFilter::Hash2(const AtomicString& string) {
  // Simple hash function 2
  unsigned hash = 0;
  const auto& impl = string.Impl();
  if (impl) {
    for (size_t i = 0; i < impl->length(); ++i) {
      hash = (hash << 3) + hash + (*impl)[i];
    }
  }
  return (hash >> 3) & kBloomFilterMask;
}

void SelectorFilter::AddToBloomFilter(const AtomicString& identifier) {
  if (!current_filter_ || identifier.IsNull()) {
    return;
  }
  
  unsigned hash1 = Hash1(identifier);
  unsigned hash2 = Hash2(identifier);
  
  current_filter_->bloom_filter[hash1] = true;
  current_filter_->bloom_filter[hash2] = true;
}

bool SelectorFilter::MayContain(const AtomicString& identifier) const {
  if (!current_filter_ || identifier.IsNull()) {
    return true;
  }
  
  unsigned hash1 = Hash1(identifier);
  unsigned hash2 = Hash2(identifier);
  
  return current_filter_->bloom_filter[hash1] && 
         current_filter_->bloom_filter[hash2];
}

void SelectorFilter::CollectElementIdentifiers(
    const Element& element,
    std::vector<AtomicString>& identifiers) {
  
  // Add tag name
  identifiers.push_back(element.TagQName().LocalName());
  
  // Add ID
  if (element.HasID()) {
    identifiers.push_back(element.id());
  }
  
  // Add classes
  if (element.HasClass()) {
    for (const auto& class_name : element.ClassNames()) {
      identifiers.push_back(class_name);
    }
  }
  
  // Add attribute names
  if (element.hasAttributes()) {
    for (const auto& attribute : element.Attributes()) {
      identifiers.push_back(attribute.GetName().LocalName());
    }
  }
}

}  // namespace webf