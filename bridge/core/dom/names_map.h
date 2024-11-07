// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_DOM_NAMES_MAP_H_
#define WEBF_CORE_DOM_NAMES_MAP_H_

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/dom/space_split_string.h"

namespace webf {

// Parses and stores mappings from part name to ordered set of part names as in
// http://drafts.csswg.org/css-shadow-parts/.
// TODO(crbug/805271): Deduplicate identical maps as SpaceSplitString does so
// that elements with identical exportparts attributes share instances.
class NamesMap {
 public:
  NamesMap() = default;
  NamesMap(const NamesMap&) = delete;
  NamesMap& operator=(const NamesMap&) = delete;
  explicit NamesMap(const AtomicString& string);

  // Clears any existing mapping, parses the string and sets the mapping from
  // that.
  void Set(const AtomicString&);
  void Clear() { data_.clear(); }
  // Inserts value into the ordered set under key.
  void Add(const AtomicString& key, const AtomicString& value);
  SpaceSplitString* Get(const AtomicString& key) const;

  size_t size() const { return data_.size(); }

  void Trace(GCVisitor* visitor) const { }

 private:
  template <typename CharacterType>
  void Set(const AtomicString&, const CharacterType*);

  std::unordered_map<AtomicString, std::shared_ptr<SpaceSplitString>, AtomicString::KeyHasher> data_;
};

}

#endif  // WEBF_CORE_DOM_NAMES_MAP_H_
