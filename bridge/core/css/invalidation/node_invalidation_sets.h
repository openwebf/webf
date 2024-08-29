// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_INVALIDATION_NODE_INVALIDATION_SETS_H_
#define WEBF_CORE_CSS_INVALIDATION_NODE_INVALIDATION_SETS_H_

#include "core/css/invalidation/invalidation_set.h"

namespace webf {

class NodeInvalidationSets final {
 public:
  NodeInvalidationSets() = default;
  NodeInvalidationSets(NodeInvalidationSets&&) = default;
  NodeInvalidationSets& operator=(NodeInvalidationSets&&) = default;
  NodeInvalidationSets(const NodeInvalidationSets&) = delete;
  NodeInvalidationSets& operator=(const NodeInvalidationSets&) = delete;

  InvalidationSetVector& Descendants() { return descendants_; }
  const InvalidationSetVector& Descendants() const { return descendants_; }
  InvalidationSetVector& Siblings() { return siblings_; }
  const InvalidationSetVector& Siblings() const { return siblings_; }

  // add by guopengfei
  bool Contains(const InvalidationSetVector& vec, const std::shared_ptr<InvalidationSet>& value) {
    return std::find(vec.begin(), vec.end(), value) != vec.end();
  }

 private:
  InvalidationSetVector descendants_;
  InvalidationSetVector siblings_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_INVALIDATION_NODE_INVALIDATION_SETS_H_
