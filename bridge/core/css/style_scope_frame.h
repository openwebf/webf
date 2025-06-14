// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_STYLE_SCOPE_FRAME_H_
#define WEBF_CORE_CSS_STYLE_SCOPE_FRAME_H_

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/css/match_flags.h"
#include "foundation/macros.h"

namespace webf {

class ContainerNode;
class Element;
class StyleScope;
class SelectorChecker;

// The *activations* for a given StyleScope/node, is a list of active
// scopes found in the ancestor chain, their roots (ContainerNode*), and the
// proximities to those roots.
//
// The idea is that, if we're matching a selector ':scope' within some
// StyleScope, we look up the activations for that StyleScope, and
// and check if the current element (`SelectorCheckingContext.element`)
// matches any of the activation roots.
struct StyleScopeActivation {
  WEBF_DISALLOW_NEW();

 public:
  void Trace(GCVisitor*) const;

  // The root is the node when the activation happened. In other words,
  // the node that matched <scope-start>. The root is always an Element for
  // activations produced by @scope, however, it may be a non-element for
  // the "default activation" (see SelectorChecker::EnsureActivations).
  //
  // https://drafts.csswg.org/css-cascade-6/#typedef-scope-start
  Member<const ContainerNode> root;
  // The distance to the root, in terms of number of inclusive ancestors
  // between some subject element and the root.
  unsigned proximity = 0;
};

struct StyleScopeActivations {
 public:
  void Trace(GCVisitor*) const;

  std::vector<StyleScopeActivation> vector;

  // Even if `vector` is empty, `match_flags` can be set. For example:
  //
  //  @scope (p:hover) {
  //    :scope { ... }
  //  }
  //
  // When matching :scope against 'p', even if 'p' is not currently hovered,
  // (and therefore won't produce a StyleScopeActivation in the vector),
  // `match_flags` will contain kAffectedByHover. This allows us to propagate
  // the flags when matching :scope, also when the selector does not match.
  MatchFlags match_flags = 0;
};

// Stores the current @scope activations for a given subject element.
//
// See `StyleScopeActivation` for more information about activations.
//
// StyleScopeFrames are placed on the stack in `Element::RecalcStyle`, and
// serve as a cache of all @scope activations until that point in the tree.
// The actual contents of a StyleScopeFrame is populated lazily during
// `SelectorChecker::CheckPseudoScope`.
//
// StyleScopeFrames may contain a pointer to a parent frame, in which case
// `SelectorChecker::CheckPseudoScope` will store data applicable to the parent
// element in that frame.
class StyleScopeFrame {
  WEBF_STACK_ALLOCATED();

 public:
  explicit StyleScopeFrame(Element& element) : element_(element) {}

  explicit StyleScopeFrame(Element& element, StyleScopeFrame* parent) : element_(element), parent_(parent) {}

  StyleScopeFrame* GetParentFrameOrNull(Element& parent_element);
  StyleScopeFrame& GetParentFrameOrThis(Element& parent_element);

  // A StyleScope has been "seen" if `element_` or any of the elements
  // in element_'s ancestor chain is a scoping root.
  //
  // Note that a StyleScope being "seen" does not mean that it's currently
  // "in scope" [1], because the scope may be limited [2]. However, if a
  // StyleScope has *not* been seen, it's definitely not in scope.
  //
  // This function is only valid for implicit StyleScopes (IsImplicit()==true).
  //
  // [1] https://drafts.csswg.org/css-cascade-6/#in-scope
  // [2] https://drafts.csswg.org/css-cascade-6/#scoping-limit
  bool HasSeenImplicitScope(std::shared_ptr<const StyleScope>&);

 private:
  friend class SelectorChecker;

  using ScopeSet = std::unordered_set<std::shared_ptr<const StyleScope>>;

  std::shared_ptr<ScopeSet> CalculateSeenImplicitScopes();

  Element& element_;
  StyleScopeFrame* parent_ = nullptr;
  std::unordered_map<std::shared_ptr<const StyleScope>, std::shared_ptr<const StyleScopeActivations>> data_;
  std::shared_ptr<ScopeSet> seen_implicit_scopes_ = nullptr;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_SCOPE_FRAME_H_
