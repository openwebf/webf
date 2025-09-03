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

#ifndef WEBF_CORE_CSS_CASCADE_LAYER_MAP_H_
#define WEBF_CORE_CSS_CASCADE_LAYER_MAP_H_

#include <limits>
#include <unordered_map>
#include <cassert>
#include <cstdint>
#include <memory>
#include <vector>
#include "foundation/macros.h"

namespace webf {

class CascadeLayer;
class RuleSet;
class CSSStyleSheet;

// Manages cascade layers from all style sheets in a tree scope.
// Sorts cascade layers according to the CSS cascade layer spec:
// https://www.w3.org/TR/css-cascade-5/#cascade-layers
class CascadeLayerMap {
 public:
  // The order of the implicit outer layer
  static constexpr uint16_t kImplicitOuterLayerOrder = std::numeric_limits<uint16_t>::max();

  // ActiveStyleSheet represents a pair of CSSStyleSheet and RuleSet
  using ActiveStyleSheet = std::pair<std::shared_ptr<CSSStyleSheet>, std::shared_ptr<RuleSet>>;
  using ActiveStyleSheetVector = std::vector<ActiveStyleSheet>;

  explicit CascadeLayerMap(const ActiveStyleSheetVector& active_style_sheets);

  // Returns the layer order of the given layer. For the implicit outer layer,
  // pass nullptr.
  uint16_t GetLayerOrder(const CascadeLayer* layer) const {
    if (!layer)
      return kImplicitOuterLayerOrder;
    
    auto it = layer_order_map_.find(layer);
    if (it != layer_order_map_.end())
      return it->second;
    
    // This shouldn't happen for well-formed cascade layers
    assert(false);
    return kImplicitOuterLayerOrder;
  }

  // Returns -1 if layer1 < layer2 in the layer order
  // Returns 0 if layer1 == layer2
  // Returns 1 if layer1 > layer2
  int CompareLayerOrder(const CascadeLayer* layer1, const CascadeLayer* layer2) const {
    uint16_t order1 = GetLayerOrder(layer1);
    uint16_t order2 = GetLayerOrder(layer2);
    
    if (order1 < order2)
      return -1;
    else if (order1 > order2)
      return 1;
    else
      return 0;
  }

  const CascadeLayer* GetRootLayer() const { return canonical_root_layer_.get(); }

 private:
  std::shared_ptr<CascadeLayer> canonical_root_layer_;
  
  // Maps each CascadeLayer to its computed order number.
  std::unordered_map<const CascadeLayer*, uint16_t> layer_order_map_;
  
  CascadeLayerMap(const CascadeLayerMap&) = delete;
  CascadeLayerMap& operator=(const CascadeLayerMap&) = delete;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CASCADE_LAYER_MAP_H_