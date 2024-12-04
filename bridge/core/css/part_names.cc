// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "part_names.h"
#include "core/dom/names_map.h"

namespace webf {

namespace {
// Adds the names to the set.
static void AddToSet(const SpaceSplitString& strings, std::unordered_set<AtomicString, AtomicString::KeyHasher>* set) {
  for (size_t i = 0; i < strings.size(); i++) {
    set->emplace(strings[i]);
  }
}
}  // namespace

PartNames::PartNames(const SpaceSplitString& names) {
  AddToSet(names, &names_);
}

void PartNames::PushMap(std::shared_ptr<const NamesMap> names_map) {
  pending_maps_.push_back(names_map);
}

void PartNames::ApplyMap(const NamesMap& names_map) {
  std::unordered_set<AtomicString, AtomicString::KeyHasher> new_names;
  for (const AtomicString& name : names_) {
    if (SpaceSplitString* mapped_names = names_map.Get(name)) {
      AddToSet(*mapped_names, &new_names);
    }
  }
  std::swap(names_, new_names);
}

bool PartNames::Contains(const AtomicString& name) {
  // If we have any, apply all pending maps and clear the queue.
  if (pending_maps_.size()) {
    for (std::shared_ptr<const NamesMap>& pending_map : pending_maps_) {
      ApplyMap(*pending_map);
    }
    pending_maps_.clear();
  }
  return names_.contains(name);
}

size_t PartNames::size() {
  return names_.size();
}

}  // namespace webf
