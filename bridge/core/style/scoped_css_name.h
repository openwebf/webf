// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_STYLE_SCOPED_CSS_NAME_H_
#define WEBF_CORE_STYLE_SCOPED_CSS_NAME_H_

#include "core/base/memory/values_equivalent.h"
#include "core/base/ranges/algorithm.h"
#include "core/base/ranges/ranges.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/dom/tree_scope.h"
#include "core/platform/hash_functions.h"
#include "core/platform/hash_traits.h"

namespace webf {

class TreeScope;

// TODO(guopengfei): 取消继承GarbageCollected
// Stores a CSS name as an AtomicString along with a TreeScope to support
// tree-scoped names and references for e.g. anchor-name. If the TreeScope
// pointer is null, we do not support such references, for instance for UA
// stylesheets.
class ScopedCSSName {
 public:
  ScopedCSSName(const std::string& name, const TreeScope* tree_scope)
      : name_(name), tree_scope_(tree_scope) {
    assert(name.empty());
  }

  const std::string& GetName() const { return name_; }
  std::shared_ptr<const TreeScope> GetTreeScope() const { return tree_scope_; }

  bool operator==(const ScopedCSSName& other) const {
    return name_ == other.name_ && tree_scope_ == other.tree_scope_;
  }
  bool operator!=(const ScopedCSSName& other) const {
    return !operator==(other);
  }

  unsigned GetHash() const {
    //unsigned hash = WTF::GetHash(name_);
    std::hash<std::string> hash_fn;
    unsigned hash = hash_fn(name_);
    WTF::AddIntToHash(hash, WTF::GetHash(tree_scope_.get()));
    return hash;
  }
  // TODO(guopengfei): 取消继承GarbageCollected
  //void Trace(GCVisitor* visitor) const;

 private:
  //AtomicString name_;
  std::string name_;

  // Weak reference to break ref cycle with both GC-ed and ref-counted objects:
  // Document -> ComputedStyle -> ScopedCSSName -> TreeScope(Document)
  std::shared_ptr<const TreeScope> tree_scope_;
};

// Represents a list of tree-scoped names (or tree-scoped references).
//
// https://drafts.csswg.org/css-scoping/#css-tree-scoped-name
// https://drafts.csswg.org/css-scoping/#css-tree-scoped-reference
class ScopedCSSNameList
    : public GarbageCollected<ScopedCSSNameList> {
 public:
  explicit ScopedCSSNameList(std::vector<Member<const ScopedCSSName>> names)
      : names_(std::move(names)) {
  }

  const std::vector<Member<const ScopedCSSName>>& GetNames() const {
    return names_;
  }

  bool operator==(const ScopedCSSNameList& other) const {
    return webf::ranges::equal(names_, other.names_,
                               [](const auto& a, const auto& b) {
                                 return webf::ValuesEquivalent(a, b);
                               });
  }
  bool operator!=(const ScopedCSSNameList& other) const {
    return !operator==(other);
  }
  // TODO(guopengfei): 取消继承GarbageCollected
  //void Trace(GCVisitor* visitor) const;

 private:
  std::vector<Member<const ScopedCSSName>> names_;
};

}  // namespace webf

namespace WTF {
// TODO(guopengfei): 取消继承MemberHashTraits<ScopedCSSNameWrapperType>
/*
// Allows creating a hash table of ScopedCSSName in wrapper pointers (e.g.,
// HeapHashSet<Member<ScopedCSSName>>) that hashes the ScopedCSSNames directly
// instead of the wrapper pointers.

template <typename ScopedCSSNameWrapperType>
struct ScopedCSSNameWrapperPtrHashTraits
    : MemberHashTraits<ScopedCSSNameWrapperType> {
  using TraitType =
      typename MemberHashTraits<ScopedCSSNameWrapperType>::TraitType;
  static unsigned GetHash(const TraitType& name) { return name->GetHash(); }
  static bool Equal(const TraitType& a, const TraitType& b) {
    return webf::ValuesEquivalent(a, b);
  }
  // Set this flag to 'false', otherwise Equal above will see gibberish values
  // that aren't safe to call ValuesEquivalent on.
  static constexpr bool kSafeToCompareToEmptyOrDeleted = false;
};

template <>
struct HashTraits<webf::Member<webf::ScopedCSSName>>
    : ScopedCSSNameWrapperPtrHashTraits<webf::ScopedCSSName> {};
template <>
struct HashTraits<webf::Member<const webf::ScopedCSSName>>
    : ScopedCSSNameWrapperPtrHashTraits<const webf::ScopedCSSName> {};
*/
}  // namespace WTF

#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_STYLE_SCOPED_CSS_NAME_H_
