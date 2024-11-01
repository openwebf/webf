// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "cascade_layer.h"
#include "foundation/string_builder.h"

namespace webf {

std::shared_ptr<CascadeLayer> CascadeLayer::FindDirectSubLayer(const std::string& name) const {
  // Anonymous layers are all distinct.
  if (name.empty()) {
    return nullptr;
  }
  for (const auto& sub_layer : direct_sub_layers_) {
    if (sub_layer->GetName() == name) {
      return sub_layer;
    }
  }
  return nullptr;
}

std::shared_ptr<CascadeLayer> CascadeLayer::GetOrAddSubLayer(const StyleRuleBase::LayerName& name) {
  std::shared_ptr<CascadeLayer> layer = std::make_shared<CascadeLayer>(*this);
  for (const std::optional<std::string>& name_part : name) {
    std::shared_ptr<CascadeLayer> direct_sub_layer = layer->FindDirectSubLayer(name_part.value_or(""));
    if (!direct_sub_layer) {
      direct_sub_layer = std::make_shared<CascadeLayer>(name_part.value_or(""));
      layer->direct_sub_layers_.push_back(direct_sub_layer);
    }
    layer = direct_sub_layer;
  }
  return layer;
}

std::string CascadeLayer::ToStringForTesting() const {
  StringBuilder result;
  ToStringInternal(result, "");
  return result.ReleaseString();
}

void CascadeLayer::ToStringInternal(StringBuilder& result, const std::string& prefix) const {
  for (const auto& sub_layer : direct_sub_layers_) {
    std::string name = sub_layer->name_.length() ? sub_layer->name_ : "(anonymous)";
    if (result.length()) {
      result.Append(",");
    }
    result.Append(prefix);
    result.Append(name);
    sub_layer->ToStringInternal(result, prefix + name + ".");
  }
}

void CascadeLayer::Merge(const CascadeLayer& other, LayerMap& mapping) {
  mapping.insert({std::shared_ptr<const CascadeLayer>(&other), std::shared_ptr<CascadeLayer>(this)});
  for (std::shared_ptr<CascadeLayer> sub_layer : other.direct_sub_layers_) {
    GetOrAddSubLayer({sub_layer->GetName()})->Merge(*sub_layer, mapping);
  }
}

void CascadeLayer::Trace(GCVisitor* visitor) const {}
}  // namespace webf
