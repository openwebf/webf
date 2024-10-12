// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Design doc for IntersectionObserver implementation:
//   https://docs.google.com/a/google.com/document/d/1hLK0eyT5_BzyNS4OkjsnoqqFQDYCbKfyBinj94OnLiQ

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_CONTROLLER_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_CONTROLLER_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/heap_hashmap.h"
#include "core/dom/intersection_observer.h"

namespace webf {

class ExecutionContext;
// class LocalFrameView;
/*
class ComputeIntersectionsContext {
  WEBF_STACK_ALLOCATED();

 public:
  ~ComputeIntersectionsContext() {
    // GetAndResetNextRunDelay() must have been called.
    CHECK_EQ(next_run_delay_, base::TimeDelta::Max());
  }

  //base::TimeTicks GetMonotonicTime();
  DOMHighResTimeStamp GetTimeStamp(const IntersectionObserver& observer);
  std::optional<IntersectionGeometry::RootGeometry>& GetRootGeometry(
      const IntersectionObserver& observer,
      unsigned flags);
  void UpdateNextRunDelay(base::TimeDelta delay);
  base::TimeDelta GetAndResetNextRunDelay();

 private:
  base::TimeTicks monotonic_time_;
  ExecutionContext* explicit_root_execution_context_ = nullptr;
  DOMHighResTimeStamp explicit_root_timestamp_ = -1;
  ExecutionContext* implicit_root_execution_context_ = nullptr;
  DOMHighResTimeStamp implicit_root_timestamp_ = -1;

  const IntersectionObserver* explicit_root_geometry_observer_ = nullptr;
  std::optional<IntersectionGeometry::RootGeometry> explicit_root_geometry_;
  const IntersectionObserver* implicit_root_geometry_observer_ = nullptr;
  std::optional<IntersectionGeometry::RootGeometry> implicit_root_geometry_;

  base::TimeDelta next_run_delay_ = base::TimeDelta::Max();
};
*/

class IntersectionObserverController : public GarbageCollectedMixin {
 public:
  explicit IntersectionObserverController() = default;
  ~IntersectionObserverController() = default;

  void ScheduleIntersectionObserverForDelivery(IntersectionObserver&);

  // Immediately deliver all notifications for all observers for which
  // (observer->GetDeliveryBehavior() == behavior).
  // void DeliverNotifications(IntersectionObserver::DeliveryBehavior behavior);

  // The flags argument is composed of values from
  // IntersectionObservation::ComputeFlags. They are dirty bits that control
  // whether an IntersectionObserver needs to do any work. The return value
  // communicates whether observer->trackVisibility() is true for any tracked
  // observer.
  // TODO(pengfei12.guo): not supported
  // bool ComputeIntersections(unsigned flags,
  //                           LocalFrameView&,
  //                           gfx::Vector2dF accumulated_scroll_delta_since_last_update,
  //                           ComputeIntersectionsContext&);

  void AddTrackedObserver(IntersectionObserver&);
  void AddTrackedObservation(IntersectionObservation&);
  void RemoveTrackedObserver(IntersectionObserver&);
  void RemoveTrackedObservation(IntersectionObservation&);

  bool NeedsOcclusionTracking() const { return needs_occlusion_tracking_; }

  void Trace(GCVisitor*) const override;

  // TODO(pengfei12.guo): not supported
  // const char* NameInHeapSnapshot() const override {
  //  return "IntersectionObserverController";
  //}

  // TODO(pengfei12.guo): not supported
  // wtf_size_t GetTrackedObserverCountForTesting() const {
  //  return tracked_explicit_root_observers_.size();
  //}

  // TODO(pengfei12.guo): not supported
  // wtf_size_t GetTrackedObservationCountForTesting() const;

 private:
  void PostTaskToDeliverNotifications();

  // IntersectionObserver's with a connected explicit root in this document.
  std::unordered_set<Member<IntersectionObserver>, Member<IntersectionObserver>::KeyHasher>
      tracked_explicit_root_observers_;
  // IntersectionObservations with an implicit root and connected target in this
  // document, grouped by IntersectionObservers.
  std::unordered_map<Member<IntersectionObserver>,
                     std::unordered_set<std::shared_ptr<IntersectionObservation>>,
                     Member<IntersectionObserver>::KeyHasher>
      tracked_implicit_root_observations_;
  // IntersectionObservers for which this is the execution context of the
  // callback, and with unsent notifications.
  std::unordered_set<Member<IntersectionObserver>, Member<IntersectionObserver>::KeyHasher>
      pending_intersection_observers_;
  // This is 'true' if any tracked node is the target of an observer for
  // which observer->trackVisibility() is true.
  bool needs_occlusion_tracking_;
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_CONTROLLER_H_
