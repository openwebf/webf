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

#include "core/css/cascade_layer_map.h"

#include <algorithm>
#include <functional>
#include <string>

#include "core/css/cascade_layer.h"
#include "core/css/rule_set.h"
#include "foundation/logging.h"

namespace webf {
namespace {

void ComputeLayerOrder(CascadeLayer& layer, uint16_t& next) {
  for (const auto& sub_layer : layer.GetDirectSubLayers()) {
    ComputeLayerOrder(*sub_layer, next);
  }
  layer.SetOrder(next++);
}

}  // namespace

CascadeLayerMap::CascadeLayerMap(const ActiveRuleSetVector& active_rule_sets) {
  canonical_root_layer_ = std::make_shared<CascadeLayer>();

  LayerMap mapping;
  mapping.reserve(active_rule_sets.size() * 8);

  for (const auto& rule_set : active_rule_sets) {
    if (!rule_set) {
      continue;
    }
    const CascadeLayer* root = rule_set->GetCascadeLayerRoot();
    if (!root) {
      continue;
    }
    canonical_root_layer_->Merge(*root, mapping);
  }

  // Compute deterministic depth-first postorder indices for canonical layers.
  uint16_t next = 0;
  for (const auto& sub_layer : canonical_root_layer_->GetDirectSubLayers()) {
    ComputeLayerOrder(*sub_layer, next);
  }

  // Unlayered rules belong to the implicit outer layer, which always wins for
  // non-important declarations. Represent it with the max order.
  canonical_root_layer_->SetOrder(kImplicitOuterLayerOrder);

  // Populate lookup for all original layers seen during merging.
  layer_order_map_.reserve(mapping.size());
  for (const auto& entry : mapping) {
    const CascadeLayer* original = entry.first;
    const std::shared_ptr<CascadeLayer>& canonical = entry.second;
    if (!original || !canonical) {
      continue;
    }
    const std::optional<uint16_t> order = canonical->GetOrder();
    layer_order_map_[original] = order.has_value() ? order.value() : kImplicitOuterLayerOrder;
  }

#if WEBF_LOG_CASCADE_IF
  struct LayerDebugEntry {
    uint16_t order;
    std::string name;
    const CascadeLayer* layer;
  };

  std::vector<LayerDebugEntry> debug_entries;
  debug_entries.reserve(layer_order_map_.size());

  std::function<void(const CascadeLayer&, const std::string&)> visit =
      [&](const CascadeLayer& layer, const std::string& prefix) {
        String part_str = layer.GetName().GetString();
        std::string part = part_str.IsEmpty() ? "<anonymous>" : part_str.ToUTF8String();
        std::string full = prefix.empty() ? part : prefix + "." + part;

        std::optional<uint16_t> order = layer.GetOrder();
        if (order.has_value()) {
          debug_entries.push_back({order.value(), full, &layer});
        }

        for (const auto& child : layer.GetDirectSubLayers()) {
          if (child) {
            visit(*child, full);
          }
        }
      };

  for (const auto& child : canonical_root_layer_->GetDirectSubLayers()) {
    if (child) {
      visit(*child, "");
    }
  }
  debug_entries.push_back({kImplicitOuterLayerOrder, "<unlayered>", nullptr});

  std::sort(debug_entries.begin(), debug_entries.end(),
            [](const LayerDebugEntry& a, const LayerDebugEntry& b) { return a.order < b.order; });

  WEBF_LAZY_STREAM(WEBF_LOG_STREAM(VERBOSE), WEBF_LOG_CASCADE_IF)
      << "CascadeLayerMap: computed order (" << debug_entries.size() << ")";
  for (const auto& e : debug_entries) {
    WEBF_LAZY_STREAM(WEBF_LOG_STREAM(VERBOSE), WEBF_LOG_CASCADE_IF)
        << "  order=" << e.order << " name=" << e.name << " layer=" << e.layer;
  }
#endif
}

}  // namespace webf
