// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVATION_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVATION_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/dom/intersection_observer_entry.h"

namespace webf {

//class ComputeIntersectionsContext;
class Element;
class IntersectionObserver;
//class IntersectionObserverEntry;

// IntersectionObservation represents the result of calling
// IntersectionObserver::observe(target) for some target element; it tracks the
// intersection between a single target element and the IntersectionObserver's
// root.  It is an implementation-internal class without any exposed interface.
class IntersectionObservation final : public GarbageCollectedMixin {
 public:
  // Flags that drive the behavior of the ComputeIntersections() method. For an
  // explanation of implicit vs. explicit root, see intersection_observer.h.
  enum ComputeFlags {
    // If this bit is set, and observer_->RootIsImplicit() is true, then the
    // root bounds (i.e., size of the top document's viewport) should be
    // included in any IntersectionObserverEntry objects created by Compute().
    kReportImplicitRootBounds = 1 << 0,
    // If this bit is set, and observer_->RootIsImplicit() is false, then
    // Compute() should update the observation.
    kExplicitRootObserversNeedUpdate = 1 << 1,
    // If this bit is set, and observer_->RootIsImplicit() is true, then
    // Compute() should update the observation.
    kImplicitRootObserversNeedUpdate = 1 << 2,
    // If this bit is set, it indicates that at least one LocalFrameView
    // ancestor is detached from the LayoutObject tree of its parent. Usually,
    // this is unnecessary -- if an ancestor FrameView is detached, then all
    // descendant frames are detached. There is, however, at least one exception
    // to this rule; see crbug.com/749737 for details.
    kAncestorFrameIsDetachedFromLayout = 1 << 3,
    // If this bit is set, then the observer.delay parameter is ignored; i.e.,
    // the computation will run even if the previous run happened within the
    // delay parameter.
    kIgnoreDelay = 1 << 4,
    // If this bit is set, we can skip tracking the sticky frame during
    // UpdateViewportIntersectionsForSubtree.
    kCanSkipStickyFrameTracking = 1 << 5,
    // If this bit is set, we only process intersection observations that
    // require post-layout delivery.
    kPostLayoutDeliveryOnly = 1 << 6,
    // Corresponding to LocalFrameView::kScrollAndVisibilityOnly.
    kScrollAndVisibilityOnly = 1 << 7,
  };

  IntersectionObservation(IntersectionObserver&, Element&);

  IntersectionObserver* Observer() const { return observer_.Get(); }
  Element* Target() const { return target_.Get(); }
  /*
  // TODO(pengfei12.guo@vipshop.com):geometry not support
  // Returns 1 if the geometry was recalculated, otherwise 0. This could be a
  // bool, but int64_t matches IntersectionObserver::ComputeIntersections().
  int64_t ComputeIntersection(
      unsigned flags,
      gfx::Vector2dF accumulated_scroll_delta_since_last_update,
      ComputeIntersectionsContext&);
  void ComputeIntersectionImmediately(ComputeIntersectionsContext&);
  gfx::Vector2dF MinScrollDeltaToUpdate() const;
   */
  void TakeRecords(std::vector<Member<IntersectionObserverEntry>>&);
  void Disconnect();
  // TODO(pengfei12.guo@vipshop.com):not support
  // void InvalidateCachedRects() { cached_rects_.valid = false; }

  void Trace(GCVisitor*) const override;

  // TODO(pengfei12.guo@vipshop.com):not support
  // bool CanUseCachedRectsForTesting(bool scroll_and_visibility_only) const;

 private:
  // TODO(pengfei12.guo@vipshop.com):not support
  // bool ShouldCompute(unsigned flags) const;
  // bool MaybeDelayAndReschedule(unsigned flags, ComputeIntersectionsContext&);
  // unsigned GetIntersectionGeometryFlags(unsigned compute_flags) const;
  // Inspect the geometry to see if there has been a transition event; if so,
  // generate a notification and schedule it for delivery.
  // TODO(pengfei12.guo@vipshop.com):not support geometry
  // void ProcessIntersectionGeometry(const IntersectionGeometry& geometry,
  //                                 ComputeIntersectionsContext&);

  Member<IntersectionObserver> observer_;
  Member<Element> target_;
  std::vector<Member<IntersectionObserverEntry>> entries_;
  // TODO(pengfei12.guo@vipshop.com):not support
  // base::TimeTicks last_run_time_;

  // TODO(pengfei12.guo@vipshop.com):not support
  // IntersectionGeometry::CachedRects cached_rects_;

  uint32_t last_threshold_index_ = UINT_MAX;
  bool last_is_visible_ = false;

  // Ensures update even if kExplicitRootObserversNeedUpdate or
  // kImplicitRootObserversNeedUpdate is not specified in flags.
  // It ensures the initial update, and if a needed update is skipped for some
  // reason, the flag will be true until the update is done.
  bool needs_update_ = true;
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVATION_H_
