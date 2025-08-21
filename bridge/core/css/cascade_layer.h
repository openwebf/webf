/*
 * Copyright (C) 2021 Google Inc. All rights reserved.
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

#ifndef WEBF_CORE_CSS_CASCADE_LAYER_H_
#define WEBF_CORE_CSS_CASCADE_LAYER_H_

#include <optional>
#include <unordered_map>
#include <vector>
#include "../../foundation/string/atomic_string.h"
#include "core/css/style_rule.h"
#include "foundation/macros.h"

namespace webf {

// Forward declaration to avoid circular dependency
class CascadeLayer;

// Mapping from one layer to another. This is used when building
// CascadeLayerMap to combine layers from all active RuleSets
// into one grouping to give them a canonical numbering.
using LayerMap = std::unordered_map<const CascadeLayer*, std::shared_ptr<CascadeLayer>>;

// A CascadeLayer object represents a node in the ordered tree of cascade layers
// in the sorted layer ordering.
// https://www.w3.org/TR/css-cascade-5/#layer-ordering
class CascadeLayer final : public std::enable_shared_from_this<CascadeLayer> {
 public:
  explicit CascadeLayer(const AtomicString& name = AtomicString::Empty())
      : name_(name) {}
  ~CascadeLayer() = default;

  const AtomicString& GetName() const { return name_; }
  const std::vector<std::shared_ptr<CascadeLayer>>& GetDirectSubLayers() const {
    return direct_sub_layers_;
  }

  // Getting or setting the order of a layer is only valid for canonical cascade
  // layers i.e. the unique layer representation for a particular tree scope.
  const std::optional<uint16_t> GetOrder() const { return order_; }
  void SetOrder(uint16_t order) { order_ = order; }

  CascadeLayer* GetOrAddSubLayer(const std::vector<AtomicString>& name);

  // Recursive merge, used during creation of CascadeLayerMap.
  // The hash map gets filled/appended with a map from the old to the new
  // layers, where applicable (no sub-CascadeLayer objects from "other"
  // are ever reused, so that they are unchanged even after future merges).
  //
  // This merges only the sub-layer structure and creates the mapping;
  // it does not touch order_, which is updated during creation of the
  // CascadeLayerMap.
  void Merge(const CascadeLayer& other, LayerMap& mapping);


 private:
  friend class CascadeLayerTest;
  friend class RuleSetCascadeLayerTest;

  String ToStringForTesting() const;
  void ToStringInternal(String& result, const String& prefix) const;

  CascadeLayer* FindDirectSubLayer(const AtomicString& name) const;
  void ComputeLayerOrderInternal(unsigned* next);

  std::optional<uint16_t> order_;
  AtomicString name_;
  std::vector<std::shared_ptr<CascadeLayer>> direct_sub_layers_;
  
  CascadeLayer(const CascadeLayer&) = delete;
  CascadeLayer& operator=(const CascadeLayer&) = delete;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CASCADE_LAYER_H_
