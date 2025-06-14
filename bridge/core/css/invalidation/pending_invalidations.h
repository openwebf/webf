// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_INVALIDATION_PENDING_INVALIDATIONS_H_
#define WEBF_CORE_CSS_INVALIDATION_PENDING_INVALIDATIONS_H_

#include <unordered_map>
#include "bindings/qjs/cppgc/member.h"
#include "core/css/invalidation/node_invalidation_sets.h"
#include "foundation/macros.h"

namespace webf {

class ContainerNode;
class Document;
class Element;
// TODO(guopengfei)：使用自定义hash：KeyHasher，比较对象内存
using PendingInvalidationMap =
    std::unordered_map<Member<ContainerNode>, NodeInvalidationSets, Member<ContainerNode>::KeyHasher>;

// Performs deferred style invalidation for DOM subtrees.
//
// Suppose we have a large DOM tree with the style rules
// .a .b { ... }
// ...
// and user script adds or removes class 'a' from an element.
//
// The cached computed styles for any of the element's
// descendants that have class b are now outdated.
//
// The user script might subsequently make many more DOM
// changes, so we don't immediately traverse the element's
// descendants for class b.
//
// Instead, we record the need for this traversal by
// calling ScheduleInvalidationSetsForNode with
// InvalidationLists obtained from RuleFeatureSet.
//
// When we next read computed styles, for example from
// user script or to render a frame,
// StyleInvalidator::Invalidate(Document&) is called to
// traverse the DOM and perform all the pending style
// invalidations.
//
// If an element is removed from the DOM tree, we call
// ClearInvalidation(ContainerNode&).
//
// When there are sibling rules and elements are added
// or removed from the tree, we call
// ScheduleSiblingInvalidationsAsDescendants for the
// potentially affected siblings.
//
// When there are pending invalidations for an element's
// siblings, and the element is being removed, we call
// RescheduleSiblingInvalidationsAsDescendants to
// reshedule the invalidations as descendant invalidations
// on the element's parent.
//
// See https://goo.gl/3ane6s and https://goo.gl/z0Z9gn
// for more detailed overviews of style invalidation.
// TODO: unify these documents into an .md file in the repo.

class PendingInvalidations {
  WEBF_DISALLOW_NEW();

 public:
  PendingInvalidations() = default;
  PendingInvalidations(const PendingInvalidations&) = delete;
  PendingInvalidations& operator=(const PendingInvalidations&) = delete;
  ~PendingInvalidations() {}
  // May immediately invalidate the node and/or add pending invalidation sets to
  // this node.
  void ScheduleInvalidationSetsForNode(const InvalidationLists&, ContainerNode&);
  void ScheduleSiblingInvalidationsAsDescendants(const InvalidationLists&, ContainerNode& scheduling_parent);
  void RescheduleSiblingInvalidationsAsDescendants(Element&);
  void ClearInvalidation(ContainerNode&);

  PendingInvalidationMap& GetPendingInvalidationMap() { return pending_invalidation_map_; }
  void Trace(GCVisitor* visitor) const {
    // TODO(guopengfei)：先注释
    // visitor->TraceMember(pending_invalidation_map_);
  }

 private:
  NodeInvalidationSets& EnsurePendingInvalidations(ContainerNode&);

  PendingInvalidationMap pending_invalidation_map_;
};
}  // namespace webf

#endif  // WEBF_CORE_CSS_INVALIDATION_PENDING_INVALIDATIONS_H_
