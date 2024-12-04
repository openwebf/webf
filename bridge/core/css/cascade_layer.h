// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CASCADE_LAYER_H
#define WEBF_CASCADE_LAYER_H

#include "core/css/style_rule.h"

namespace webf {

class CascadeLayer;

struct CascadeLayerKeyHasher {
  std::size_t operator()(const std::shared_ptr<const CascadeLayer>& k) const {
    return std::hash<const CascadeLayer*>()(k.get());
  }
};

struct CascadeLayerKeyEqual {
  bool operator()(const std::shared_ptr<const CascadeLayer>& lhs,
                  const std::shared_ptr<const CascadeLayer>& rhs) const {
    return lhs.get() == rhs.get();
  }
};

// Mapping from one layer to another (obviously). This is used in two places:
//
//  - When building superrulesets, we merge the RuleSets' layers
//    to new CascadeLayer objects in the superruleset. Normally,
//    we also map values in the RuleSet::Intervals, but occasionally,
//    we need to look up @page rule etc. in the original RuleSets
//    (which are not mapped), so we need to also be able to look up
//    by the old layers, so we store and use the mapping.
//
//  - When building CascadeLayerMap (cascade_layer_map.h), we similarly combine
//    layers from all active RuleSets (the superruleset's layers
//    will be used in place of the layers of all RuleSets it is
//    subsuming), into one grouping so give them a canonical numbering.
//    For clarity, we use the typedef CanonicalLayerMap there.
using LayerMap = std::unordered_map<std::shared_ptr<const CascadeLayer>,
                                    std::shared_ptr<CascadeLayer>,
                                    CascadeLayerKeyHasher,
                                    CascadeLayerKeyEqual>;

// A CascadeLayer object represents a node in the ordered tree of cascade layers
// in the sorted layer ordering.
// https://www.w3.org/TR/css-cascade-5/#layer-ordering
class CascadeLayer final {
 public:
  explicit CascadeLayer(const std::string& name = "") : name_(name) {}
  ~CascadeLayer() = default;

  const std::string& GetName() const { return name_; }
  const std::vector<std::shared_ptr<CascadeLayer>>& GetDirectSubLayers() const { return direct_sub_layers_; }

  // Getting or setting the order of a layer is only valid for canonical cascade
  // layers i.e. the unique layer representation for a particular tree scope.
  const std::optional<unsigned> GetOrder() const { return order_; }
  void SetOrder(unsigned order) { order_ = order; }

  std::shared_ptr<CascadeLayer> GetOrAddSubLayer(const StyleRuleBase::LayerName& name);

  // Recursive merge, used during creation of superrulesets.
  // The hash set gets filled/appended with a map from the old to the new
  // layers, where applicable (no sub-CascadeLayer objects from “other”
  // are ever reused, so that they are unchanged even after future merges).
  //
  // This merges only the sub-layer structure and creates the mapping;
  // it does not touch order_, which is updated during creation of the
  // CascadeLayerMap.
  void Merge(const CascadeLayer& other, LayerMap& mapping);

  void Trace(GCVisitor*) const;

 private:
  friend class CascadeLayerTest;
  friend class RuleSetCascadeLayerTest;

  std::string ToStringForTesting() const;
  void ToStringInternal(StringBuilder&, const std::string&) const;

  std::shared_ptr<CascadeLayer> FindDirectSubLayer(const std::string&) const;

  std::optional<unsigned> order_;
  std::string name_;
  std::vector<std::shared_ptr<CascadeLayer>> direct_sub_layers_;
};

}  // namespace webf

#endif  // WEBF_CASCADE_LAYER_H
