// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/invalidation/pending_invalidations.h"
#include "core/css/invalidation/invalidation_set.h"
#include "core/css/invalidation/style_invalidator.h"
#include "core/css/style_change_reason.h"
#include "core/css/style_engine.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/element_traversal.h"
#include "core/dom/node_computed_style.h"
//#include "core/dom/shadow_root.h"
//#include "core/html/html_slot_element.h"
//#include "core/inspector/inspector_trace_events.h"

namespace webf {

void PendingInvalidations::ScheduleInvalidationSetsForNode(const InvalidationLists& invalidation_lists,
                                                           ContainerNode& node) {
  assert(node.InActiveDocument());
  assert(!node.GetDocument().InStyleRecalc());
  bool requires_descendant_invalidation = false;

  if (node.GetStyleChangeType() < kSubtreeStyleChange) {
    for (auto& invalidation_set : invalidation_lists.descendants) {
      if (invalidation_set->InvalidatesNth()) {
        PossiblyScheduleNthPseudoInvalidations(node);
      }

      if (invalidation_set->WholeSubtreeInvalid()) {
        // TODO(guopengfei)：暂不支持ShadowRoot，直接赋值&node
        // auto* shadow_root = DynamicTo<ShadowRoot>(node);
        // auto* subtree_root = shadow_root ? &shadow_root->host() : &node;
        auto* subtree_root = &node;
        /*if (subtree_root->IsElementNode()) {
          TRACE_STYLE_INVALIDATOR_INVALIDATION_SET(
              To<Element>(*subtree_root), kInvalidationSetInvalidatesSubtree,
              *invalidation_set);
        }*/
        subtree_root->SetNeedsStyleRecalc(kSubtreeStyleChange,
                                          StyleChangeReasonForTracing::Create(style_change_reason::kRelatedStyleRule));
        requires_descendant_invalidation = false;
        break;
      }

      if (invalidation_set->InvalidatesSelf() && node.IsElementNode()) {
        /*TRACE_STYLE_INVALIDATOR_INVALIDATION_SET(
            To<Element>(node), kInvalidationSetInvalidatesSelf,
            *invalidation_set);*/
        node.SetNeedsStyleRecalc(kLocalStyleChange,
                                 StyleChangeReasonForTracing::Create(style_change_reason::kRelatedStyleRule));
      }

      if (!invalidation_set->IsEmpty()) {
        requires_descendant_invalidation = true;
      }
    }
    /* // TODO(guopengfei)：暂不支持ComputedStyle
    // No need to schedule descendant invalidations on display:none elements.
    if (requires_descendant_invalidation && node.IsElementNode() &&
        !To<Element>(node).GetComputedStyle()) {
      requires_descendant_invalidation = false;
    }
     */
  }

  if (!requires_descendant_invalidation && invalidation_lists.siblings.empty()) {
    return;
  }

  // For SiblingInvalidationSets we can skip scheduling if there is no
  // nextSibling() to invalidate, but NthInvalidationSets are scheduled on the
  // parent node which may not have a sibling.
  bool nth_only = !node.nextSibling();
  bool requires_sibling_invalidation = false;
  NodeInvalidationSets& pending_invalidations = EnsurePendingInvalidations(node);
  for (auto& invalidation_set : invalidation_lists.siblings) {
    if (nth_only && !invalidation_set->IsNthSiblingInvalidationSet()) {
      continue;
    }
    if (pending_invalidations.Contains(pending_invalidations.Siblings(), invalidation_set)) {
      continue;
    }
    if (invalidation_set->InvalidatesNth()) {
      PossiblyScheduleNthPseudoInvalidations(node);
    }
    pending_invalidations.Siblings().push_back(invalidation_set);
    requires_sibling_invalidation = true;
  }

  if (requires_sibling_invalidation || requires_descendant_invalidation) {
    node.SetNeedsStyleInvalidation();
  }

  if (!requires_descendant_invalidation) {
    return;
  }

  for (auto& invalidation_set : invalidation_lists.descendants) {
    assert(!invalidation_set->WholeSubtreeInvalid());
    if (invalidation_set->IsEmpty()) {
      continue;
    }
    if (pending_invalidations.Contains(pending_invalidations.Descendants(), invalidation_set)) {
      continue;
    }
    pending_invalidations.Descendants().push_back(invalidation_set);
  }
}

void PendingInvalidations::ScheduleSiblingInvalidationsAsDescendants(const InvalidationLists& invalidation_lists,
                                                                     ContainerNode& scheduling_parent) {
  assert(invalidation_lists.descendants.empty());

  if (invalidation_lists.siblings.empty()) {
    return;
  }

  NodeInvalidationSets& pending_invalidations = EnsurePendingInvalidations(scheduling_parent);

  scheduling_parent.SetNeedsStyleInvalidation();

  Element* subtree_root = DynamicTo<Element>(scheduling_parent);
  if (!subtree_root) {
    // TODO(guopengfei)：暂不支持ShadowRoot，直接return
    // subtree_root = &To<ShadowRoot>(scheduling_parent).host();
    return;
  }

  for (auto& invalidation_set : invalidation_lists.siblings) {
    std::shared_ptr<DescendantInvalidationSet> descendants =
        std::shared_ptr<DescendantInvalidationSet>(To<SiblingInvalidationSet>(*invalidation_set).SiblingDescendants());
    bool whole_subtree_invalid = false;
    if (invalidation_set->WholeSubtreeInvalid()) {
      // TRACE_STYLE_INVALIDATOR_INVALIDATION_SET(
      //    *subtree_root, kInvalidationSetInvalidatesSubtree, *invalidation_set);
      whole_subtree_invalid = true;
    } else if (descendants && descendants->WholeSubtreeInvalid()) {
      // TRACE_STYLE_INVALIDATOR_INVALIDATION_SET(
      //    *subtree_root, kInvalidationSetInvalidatesSubtree, *descendants);
      whole_subtree_invalid = true;
    }
    if (whole_subtree_invalid) {
      subtree_root->SetNeedsStyleRecalc(kSubtreeStyleChange,
                                        StyleChangeReasonForTracing::Create(style_change_reason::kRelatedStyleRule));
      return;
    }

    if (invalidation_set->InvalidatesSelf() &&
        !pending_invalidations.Contains(pending_invalidations.Descendants(), invalidation_set)) {
      pending_invalidations.Descendants().push_back(invalidation_set);
    }

    if (descendants && !pending_invalidations.Contains(pending_invalidations.Descendants(), descendants)) {
      pending_invalidations.Descendants().push_back(descendants);
    }
  }
}

void PendingInvalidations::RescheduleSiblingInvalidationsAsDescendants(Element& element) {
  auto* parent = element.parentNode();
  assert(parent);
  if (parent->IsDocumentNode()) {
    return;
  }
  auto pending_invalidations_iterator = pending_invalidation_map_.find(&element);
  if (pending_invalidations_iterator == pending_invalidation_map_.end() ||
      pending_invalidations_iterator->second.Siblings().empty()) {
    return;
  }
  NodeInvalidationSets& pending_invalidations = pending_invalidations_iterator->second;

  InvalidationLists invalidation_lists;
  for (const auto& invalidation_set : pending_invalidations.Siblings()) {
    invalidation_lists.descendants.push_back(invalidation_set);
    if (std::shared_ptr<DescendantInvalidationSet> descendants =
            To<SiblingInvalidationSet>(*invalidation_set).SiblingDescendants()) {
      invalidation_lists.descendants.push_back(descendants);
    }
  }
  ScheduleInvalidationSetsForNode(invalidation_lists, *parent);
}

void PendingInvalidations::ClearInvalidation(ContainerNode& node) {
  assert(node.NeedsStyleInvalidation());
  pending_invalidation_map_.erase(&node);
  node.ClearNeedsStyleInvalidation();
}

NodeInvalidationSets& PendingInvalidations::EnsurePendingInvalidations(ContainerNode& node) {
  auto it = pending_invalidation_map_.find(&node);
  if (it != pending_invalidation_map_.end()) {
    return it->second;
  }
  auto add_result = pending_invalidation_map_.emplace(&node, NodeInvalidationSets());
  return add_result.first->second;
}

}  // namespace webf
