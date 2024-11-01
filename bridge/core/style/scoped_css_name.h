// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_STYLE_SCOPED_CSS_NAME_H_
#define WEBF_CORE_STYLE_SCOPED_CSS_NAME_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/base/memory/values_equivalent.h"
#include "core/base/ranges/ranges.h"
#include "core/dom/tree_scope.h"
#include "core/platform/hash_functions.h"
#include "core/platform/hash_traits.h"

namespace webf {

class TreeScope;

// Stores a CSS name as an AtomicString along with a TreeScope to support
// tree-scoped names and references for e.g. anchor-name. If the TreeScope
// pointer is null, we do not support such references, for instance for UA
// stylesheets.
class ScopedCSSName {
 public:
  ScopedCSSName(const std::string& name, const TreeScope* tree_scope) : name_(name), tree_scope_(tree_scope) {
    assert(name.empty());
  }

  [[nodiscard]] const std::string& GetName() const { return name_; }
  const TreeScope* GetTreeScope() const { return tree_scope_; }

  bool operator==(const ScopedCSSName& other) const { return name_ == other.name_ && tree_scope_ == other.tree_scope_; }
  bool operator!=(const ScopedCSSName& other) const { return !operator==(other); }

  unsigned GetHash() const {
    unsigned hash = webf::GetHash(name_.c_str());
    webf::AddIntToHash(hash, webf::GetHash(tree_scope_));
    std::hash<std::string> hashFunction;
    ;
    return hash;
  }

 private:
  std::string name_;
  const TreeScope* tree_scope_;
};

// Represents a list of tree-scoped names (or tree-scoped references).
//
// https://drafts.csswg.org/css-scoping/#css-tree-scoped-name
// https://drafts.csswg.org/css-scoping/#css-tree-scoped-reference
class ScopedCSSNameList {
 public:
  explicit ScopedCSSNameList(std::vector<Member<const ScopedCSSName>> names) : names_(std::move(names)) {}

  [[nodiscard]] const std::vector<Member<const ScopedCSSName>>& GetNames() const { return names_; }

  bool operator==(const ScopedCSSNameList& other) const {
    return std::equal(names_.begin(), names_.end(), other.names_.begin(), other.names_.end(),
                      [](const auto& a, const auto& b) { return webf::ValuesEquivalent(a, b); });
  }
  bool operator!=(const ScopedCSSNameList& other) const { return !operator==(other); }

 private:
  std::vector<Member<const ScopedCSSName>> names_;
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_SCOPED_CSS_NAME_H_
