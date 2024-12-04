// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "container_query.h"
#include "core/css/css_markup.h"

namespace webf {

ContainerQuery::ContainerQuery(ContainerSelector selector, std::shared_ptr<const MediaQueryExpNode> query)
    : selector_(std::move(selector)), query_(query) {}

ContainerQuery::ContainerQuery(const ContainerQuery& other) : selector_(other.selector_), query_(other.query_) {}

std::string ContainerQuery::ToString() const {
  StringBuilder result;
  std::string name = selector_.Name();
  if (!name.empty()) {
    SerializeIdentifier(name, result);
    result.Append(' ');
  }
  result.Append(query_->Serialize());
  return result.ReleaseString();
}

std::shared_ptr<ContainerQuery> ContainerQuery::CopyWithParent(std::shared_ptr<const ContainerQuery> parent) const {
  auto copy = std::make_shared<ContainerQuery>(*this);
  copy->parent_ = std::move(parent);
  return copy;
}

}  // namespace webf