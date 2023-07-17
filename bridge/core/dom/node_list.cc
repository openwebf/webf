/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "node_list.h"

namespace webf {

void NodeList::InvalidateCache() {
  for (auto& cache : tag_collection_cache_)
    cache.second->InvalidateCache();
}

void NodeList::Trace(webf::GCVisitor* visitor) const {
  for (auto& item : tag_collection_cache_) {
    visitor->TraceMember(item.second);
  }
}

}  // namespace webf