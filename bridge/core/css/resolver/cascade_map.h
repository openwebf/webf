/*
 * Copyright (C) 2020 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WEBF_CORE_CSS_RESOLVER_CASCADE_MAP_H_
#define WEBF_CORE_CSS_RESOLVER_CASCADE_MAP_H_

#include <unordered_map>
#include <vector>
#include "foundation/macros.h"
#include "core/css/css_property_name.h"
#include "core/css/properties/css_bitset.h"
#include "core/css/resolver/cascade_priority.h"

namespace webf {

// Optimized map from CSSPropertyNames to CascadePriority.
//
// Because using a HashMap for everything is quite expensive in terms of
// performance, this class stores standard (non-custom) properties in a fixed-
// size array, and only custom properties are stored in a HashMap.
class CascadeMap {
  WEBF_STACK_ALLOCATED();

 public:
  class CascadePriorityList;

  // Get the CascadePriority for the given CSSPropertyName. If there is no
  // entry for the given name, CascadePriority() is returned.
  CascadePriority At(const CSSPropertyName&) const;
  // Find the CascadePriority location for a given name, if present. If there
  // is no entry for the given name, nullptr is returned. If a CascadeOrigin
  // is provided, returns the CascadePriority for that origin.
  //
  // Note that the returned pointer may accessed to change the stored value.
  //
  // Note also that calling Add() invalidates the pointer.
  CascadePriority* Find(const CSSPropertyName&);
  const CascadePriority* Find(const CSSPropertyName&) const;
  const CascadePriority* Find(const CSSPropertyName&, StyleCascadeOrigin) const;
  CascadePriority* FindKnownToExist(const CSSPropertyID id) {
    DCHECK(native_properties_.Bits().Has(id));
    return &native_properties_.Buffer()[static_cast<size_t>(id)].Top(
            backing_vector_);
  }
  const CascadePriority* FindKnownToExist(const CSSPropertyID id) const {
    DCHECK(native_properties_.Bits().Has(id));
    return &native_properties_.Buffer()[static_cast<size_t>(id)].Top(
            backing_vector_);
  }
  // Similar to Find(name, origin), but returns the CascadePriority from cascade
  // layers below the given priority. The uint64_t is presumed to come from
  // CascadePriority::ForLayerComparison().
  const CascadePriority* FindRevertLayer(const CSSPropertyName&,
                                         uint64_t) const;
  // Similar to Find(), if you already have the right CascadePriorityList.
  CascadePriority& Top(CascadePriorityList&);
  // Adds an entry to the map if the incoming priority is greater than or equal
  // to the current priority for the same name. Entries must be added in non-
  // decreasing lexicographical order of (origin, tree scope, layer).
  void Add(const AtomicString& custom_property_name, CascadePriority);
  void Add(CSSPropertyID, CascadePriority);
  // Added properties with CSSPropertyPriority::kHighPropertyPriority cause the
  // corresponding high_priority_-bit to be set. This provides a fast way to
  // check which high-priority properties have been added (if any).
  uint64_t HighPriorityBits() const {
    return native_properties_.Bits().HighPriorityBits();
  }
  // True if any important declaration has been added.
  bool HasImportant() const { return has_important_; }
  // True if any inline style declaration lost the cascade to something
  // else. This is rare, but if it happens, we need to turn off incremental
  // style calculation (see CanApplyInlineStyleIncrementally() and related
  // functions). This information is propagated up to ComputedStyle after
  // the cascade and stored there.
  bool InlineStyleLost() const { return inline_style_lost_; }
  const CSSBitset& NativeBitset() const { return native_properties_.Bits(); }
  // Remove all properties (both native and custom) from the CascadeMap.
  void Reset();

  // A list storing the highest CascadePriority from each cascade layer that has
  // a higher-priority declaration than all the previous layers. The entries are
  // in the ascending lexicographical order of (origin, tree scope, layer).
  // To avoid constructor and destructor calls on a large number of lists, the
  // list is implemented as a linked stack where nodes are backed by a vector.
  class CascadePriorityList {
    WEBF_DISALLOW_NEW();

    struct Node {
      WEBF_DISALLOW_NEW();
      Node(CascadePriority priority, size_t next_index)
          : priority(priority), next_index(next_index) {}

      CascadePriority priority;
      // 0 for null; Otherwise, next_index - 1 is index in the backing vector.
      size_t next_index;
    };

    // The inline size is set to avoid re-allocations in common cases. The
    // following allows a UA and author declaration on every property without
    // re-allocation.
    using BackingVector = std::vector<Node>;

   public:
    CascadePriorityList() = default;
    inline CascadePriorityList(BackingVector& backing_vector,
                               CascadePriority priority)
        : head_index_(backing_vector.size() + 1) {
      backing_vector.emplace_back(priority, 0);
    }

    class Iterator {
      WEBF_STACK_ALLOCATED();

     public:
      inline Iterator(const BackingVector*, const Node*);
      inline bool operator!=(const Iterator&) const;
      inline const CascadePriority& operator*() const;
      inline const CascadePriority* operator->() const;
      inline Iterator& operator++();
      Iterator& operator++(int) = delete;

     private:
      using BackingVector = CascadePriorityList::BackingVector;
      using Node = CascadePriorityList::Node;

      const BackingVector* backing_vector_;
      const Node* backing_node_;
    };

    inline bool IsEmpty() const;

    // For performance reasons, we don't store the BackingVector reference in
    // each list, but pass it as a parameter.
    inline Iterator Begin(const BackingVector&) const;
    inline Iterator End(const BackingVector&) const;
    inline const CascadePriority& Top(const BackingVector&) const;
    inline CascadePriority& Top(BackingVector&);
    inline void Push(BackingVector&, CascadePriority priority);

   private:
    friend class Iterator;

    size_t head_index_ = 0;
  };

  class NativeMap {
    WEBF_STACK_ALLOCATED();

   public:
    CSSBitset& Bits() { return bits_; }
    const CSSBitset& Bits() const { return bits_; }

    CascadePriorityList* Buffer() {
      return reinterpret_cast<CascadePriorityList*>(properties_);
    }
    const CascadePriorityList* Buffer() const {
      return reinterpret_cast<const CascadePriorityList*>(properties_);
    }

   private:
    // For performance reasons, a char-array is used to prevent construction of
    // CascadePriorityList objects. A companion bitset keeps track of which
    // properties are initialized.
    CSSBitset bits_;
    alignas(CascadePriorityList) char properties_[kNumCSSProperties *
                                                  sizeof(CascadePriorityList)];
  };

  using CustomMap = std::unordered_map<AtomicString, CascadePriorityList, AtomicString::KeyHasher>;

  const CustomMap& GetCustomMap() const { return custom_properties_; }
  CustomMap& GetCustomMap() { return custom_properties_; }

 private:
  ALWAYS_INLINE void Add(CascadePriorityList* list, CascadePriority);

  bool has_important_ = false;
  bool inline_style_lost_ = false;
  NativeMap native_properties_;
  CustomMap custom_properties_;
  CascadePriorityList::BackingVector backing_vector_;
};

// CascadePriorityList implementation is inlined for performance reasons.

inline CascadeMap::CascadePriorityList::Iterator::Iterator(
    const BackingVector* backing_vector,
    const Node* node)
    : backing_vector_(backing_vector), backing_node_(node) {}

inline const CascadePriority&
CascadeMap::CascadePriorityList::Iterator::operator*() const {
  return backing_node_->priority;
}

inline const CascadePriority*
CascadeMap::CascadePriorityList::Iterator::operator->() const {
  return &backing_node_->priority;
}

inline CascadeMap::CascadePriorityList::Iterator&
CascadeMap::CascadePriorityList::Iterator::operator++() {
  if (!backing_node_->next_index) {
    backing_node_ = nullptr;
  } else {
    backing_node_ = &backing_vector_->at(backing_node_->next_index - 1);
  }
  return *this;
}

inline bool CascadeMap::CascadePriorityList::Iterator::operator!=(
    const Iterator& other) const {
  // We should never compare two iterators backed by different vectors.
  DCHECK_EQ(backing_vector_, other.backing_vector_);
  return backing_node_ != other.backing_node_;
}

inline CascadeMap::CascadePriorityList::Iterator
CascadeMap::CascadePriorityList ::Begin(
    const BackingVector& backing_vector) const {
  if (!head_index_) {
    return Iterator(&backing_vector, nullptr);
  }
  return Iterator(&backing_vector, &backing_vector[head_index_ - 1]);
}

inline CascadeMap::CascadePriorityList::Iterator
CascadeMap::CascadePriorityList::End(
    const BackingVector& backing_vector) const {
  return Iterator(&backing_vector, nullptr);
}

inline const CascadePriority& CascadeMap::CascadePriorityList::Top(
    const BackingVector& backing_vector) const {
  DCHECK(!IsEmpty());
  return *Begin(backing_vector);
}

inline CascadePriority& CascadeMap::CascadePriorityList::Top(
    BackingVector& backing_vector) {
  DCHECK(!IsEmpty());
  return const_cast<CascadePriority&>(*Begin(backing_vector));
}

inline void CascadeMap::CascadePriorityList::Push(BackingVector& backing_vector,
                                                  CascadePriority priority) {
  backing_vector.push_back(Node(priority, head_index_));
  head_index_ = backing_vector.size();
}

inline bool CascadeMap::CascadePriorityList::IsEmpty() const {
  return !head_index_;
}

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_CASCADE_MAP_H_