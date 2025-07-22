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
#include "core/css/cascade_layer.h"
#include "core/css/rule_set.h"

namespace webf {
namespace {

// See layer_map.h.
using CanonicalLayerMap = LayerMap;

void ComputeLayerOrder(CascadeLayer& layer, uint16_t& next) {
  for (const auto& sub_layer : layer.GetDirectSubLayers()) {
    ComputeLayerOrder(*sub_layer, next);
  }
  layer.SetOrder(next++);
}

}  // namespace

CascadeLayerMap::CascadeLayerMap(const ActiveStyleSheetVector& sheets) {
  auto canonical_root_layer = std::make_shared<CascadeLayer>();

  // For now, just create a simple root layer with implicit outer layer order
  // TODO: Process cascade layers from stylesheets when RuleSet supports them
  canonical_root_layer->SetOrder(kImplicitOuterLayerOrder);
  canonical_root_layer_ = canonical_root_layer;
}

}  // namespace webf