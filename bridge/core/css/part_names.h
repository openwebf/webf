// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PART_NAMES_H_
#define WEBF_CORE_CSS_PART_NAMES_H_

#include <core/dom/space_split_string.h>
#include <unordered_set>

namespace webf {

class NamesMap;
class SpaceSplitString;

// Represents a set of part names as we ascend through scopes and apply
// partmaps. A single partmap is applied by looking up each name in the map and
// taking the union of all of the values found (which are sets of names). This
// becomes the new set of names. Multiple partmaps are applied in succession.
class PartNames {
  WEBF_STACK_ALLOCATED();

 public:
  PartNames();
  explicit PartNames(const SpaceSplitString& names);
  ~PartNames() { pending_maps_.clear(); }
  PartNames(const PartNames&) = delete;
  PartNames& operator=(const PartNames&) = delete;
  // Adds a new map to be applied. It does that apply the map and update the set
  // of names immediately. That will only be done if actually needed.
  //
  // This captures a reference to names_map.
  void PushMap(std::shared_ptr<const NamesMap> names_map);
  // Returns true if name is included in the set. Applies any pending maps
  // before checking.
  bool Contains(const AtomicString& name);
  // Returns the number of part names in the set.
  size_t size();

 private:
  // Really updates the set as described in ApplyMap.
  void ApplyMap(const NamesMap& names_map);

  std::unordered_set<AtomicString, AtomicString::KeyHasher> names_;
  // A queue of maps that have been passed to ApplyMap but not yet
  // applied. These will be applied only if Contains is eventually called.
  std::vector<std::shared_ptr<const NamesMap>> pending_maps_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PART_NAMES_H_
