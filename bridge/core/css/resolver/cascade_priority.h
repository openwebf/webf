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

#ifndef WEBF_CORE_CSS_RESOLVER_CASCADE_PRIORITY_H_
#define WEBF_CORE_CSS_RESOLVER_CASCADE_PRIORITY_H_

#include <cstdint>
#include <limits>
#include "core/css/resolver/cascade_origin.h"

namespace webf {

// CascadePriority encodes cascade criteria according to:
// https://drafts.csswg.org/css-cascade/#cascade-sort
//
// The cascade priority is represented as a 96-bit value, with higher bits
// representing higher priority. The encoding is designed to allow direct
// comparison using operator< and operator>.
//
// Bit layout (from low to high):
// - Bits 0-3: Generation (for resolving order of appearance)
// - Bits 4-35: Position (index within style source)
// - Bits 36-51: Layer order (for cascade layers)
// - Bit 52: Is inline style
// - Bit 53: Is try style
// - Bit 54: Is try tactics style
// - Bits 64-79: Tree order (for shadow DOM scoping)
// - Bits 80-84: Origin and importance
class CascadePriority {
 public:
  CascadePriority() : priority_(0), high_(0) {}

  // Constructor for regular style rules
  CascadePriority(StyleCascadeOrigin origin,
                  bool is_inline_style,
                  uint16_t layer_order,
                  uint32_t position,
                  uint16_t tree_order = 0)
      : priority_(0), high_(0) {
    // For non-important origins, lower tree/layer order means higher priority.
    // For important origins, this is inverted via ToImportantOrigin().
    uint64_t inverted_tree_order = tree_order;
    uint64_t inverted_layer_order = layer_order;
    
    if (IsImportantOrigin(origin)) {
      inverted_tree_order = std::numeric_limits<uint16_t>::max() - tree_order;
      inverted_layer_order = std::numeric_limits<uint16_t>::max() - layer_order;
    }

    priority_ = (static_cast<uint64_t>(position) << 4) |
                (inverted_layer_order << 36) |
                (static_cast<uint64_t>(is_inline_style) << 52);
    
    high_ = (inverted_tree_order) |
            (static_cast<uint32_t>(origin) << 16);
  }

  // For animations (which don't have position)
  static CascadePriority ForAnimation(uint16_t tree_order = 0) {
    CascadePriority priority;
    priority.high_ = (static_cast<uint32_t>(tree_order)) |
                     (static_cast<uint32_t>(StyleCascadeOrigin::kAnimation) << 16);
    return priority;
  }

  // For transitions (highest priority)
  static CascadePriority ForTransition() {
    CascadePriority priority;
    priority.high_ = static_cast<uint32_t>(StyleCascadeOrigin::kTransition) << 16;
    return priority;
  }

  bool operator<(const CascadePriority& other) const {
    if (high_ != other.high_)
      return high_ < other.high_;
    return priority_ < other.priority_;
  }

  bool operator>(const CascadePriority& other) const {
    return other < *this;
  }

  bool operator==(const CascadePriority& other) const {
    return priority_ == other.priority_ && high_ == other.high_;
  }

  bool operator!=(const CascadePriority& other) const {
    return !(*this == other);
  }

  bool operator<=(const CascadePriority& other) const {
    return !(other < *this);
  }

  bool operator>=(const CascadePriority& other) const {
    return !(*this < other);
  }

  StyleCascadeOrigin GetOrigin() const {
    return static_cast<StyleCascadeOrigin>((high_ >> 16) & 0x1F);
  }

  bool IsInlineStyle() const {
    return (priority_ >> 52) & 1;
  }

  uint16_t GetLayerOrder() const {
    uint16_t inverted = (priority_ >> 36) & 0xFFFF;
    if (IsImportantOrigin(GetOrigin())) {
      return std::numeric_limits<uint16_t>::max() - inverted;
    }
    return inverted;
  }

  uint32_t GetPosition() const {
    return (priority_ >> 4) & 0xFFFFFFFF;
  }

  uint16_t GetTreeOrder() const {
    uint16_t inverted = high_ & 0xFFFF;
    if (IsImportantOrigin(GetOrigin())) {
      return std::numeric_limits<uint16_t>::max() - inverted;
    }
    return inverted;
  }

  uint8_t GetGeneration() const {
    return priority_ & 0xF;
  }

  void SetGeneration(uint8_t generation) {
    priority_ = (priority_ & ~0xFULL) | (generation & 0xF);
  }

  bool HasOrigin() const {
    return GetOrigin() != StyleCascadeOrigin::kNone;
  }

  bool IsImportant() const {
    return IsImportantOrigin(GetOrigin());
  }

  // Returns a value that compares like CascadePriority, except that it
  // ignores the importance and all sorting criteria below layer order,
  // which allows us to compare if two CascadePriorities belong
  // to the same cascade layer.
  uint64_t ForLayerComparison() const {
    // Our value to compare is essentially 96 bits. Get the uppermost 64 bits
    // (we don't care about generation and position).
    uint64_t bits = (priority_ >> 32) | (static_cast<uint64_t>(high_) << 32);

    // NOTE: This branch will get converted into a conditional move by the
    // compiler.
    if (high_ & (1u << 19)) {  // importance bit
      // Remove importance, which means; we need to clear the importance bit.
      // But if set, it has previously flipped some other interesting bits
      // (origin/importance, tree order and layer order), so we need to flip
      // them back before returning.
      bits ^= 0xFull << 48;  // origin/importance mask
      bits ^= 0xFFFFull << 32;  // tree order mask
      bits ^= 0xFFFFull << 4;  // layer order mask
    }

    bits >>= 4;  // Remove everything below layer_order.
    return bits;
  }

 private:
  uint64_t priority_;  // Low 64 bits
  uint32_t high_;      // High 32 bits
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_CASCADE_PRIORITY_H_