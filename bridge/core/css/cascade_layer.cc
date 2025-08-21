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

#include "core/css/cascade_layer.h"
#include <sstream>

namespace webf {

CascadeLayer* CascadeLayer::FindDirectSubLayer(const AtomicString& name) const {
  // Anonymous layers are all distinct.
  if (name == AtomicString::Empty()) {
    return nullptr;
  }
  for (const auto& sub_layer : direct_sub_layers_) {
    if (sub_layer->GetName() == name) {
      return sub_layer.get();
    }
  }
  return nullptr;
}

CascadeLayer* CascadeLayer::GetOrAddSubLayer(
    const std::vector<AtomicString>& name) {
  CascadeLayer* layer = this;
  for (const AtomicString& name_part : name) {
    CascadeLayer* direct_sub_layer = layer->FindDirectSubLayer(name_part);
    if (!direct_sub_layer) {
      auto new_layer = std::make_shared<CascadeLayer>(name_part);
      layer->direct_sub_layers_.push_back(new_layer);
      direct_sub_layer = new_layer.get();
    }
    layer = direct_sub_layer;
  }
  return layer;
}

String CascadeLayer::ToStringForTesting() const {
  String result;
  ToStringInternal(result, ""_s);
  return result;
}

void CascadeLayer::ToStringInternal(String& result,
                                   const String& prefix) const {
  for (const auto& sub_layer : direct_sub_layers_) {
    String name = sub_layer->name_.IsNull() ? "(anonymous)"_s : sub_layer->name_.GetString();
    if (!result.IsEmpty()) {
      result = result + ","_s;
    }
    result = result + prefix;
    result = result + name;
    sub_layer->ToStringInternal(result, prefix + name + "."_s);
  }
}

void CascadeLayer::Merge(const CascadeLayer& other, LayerMap& mapping) {
  // Can't use shared_from_this in non-shared_ptr context
  // This would need to be refactored if we need this functionality
  // mapping.insert({&other, shared_from_this()});
  for (const auto& sub_layer : other.direct_sub_layers_) {
    GetOrAddSubLayer({sub_layer->GetName()})->Merge(*sub_layer, mapping);
  }
}

}  // namespace webf
