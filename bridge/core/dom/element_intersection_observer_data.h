// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ELEMENT_INTERSECTION_OBSERVER_DATA_H_
#define WEBF_CORE_ELEMENT_INTERSECTION_OBSERVER_DATA_H_

#include <unordered_map>
#include <unordered_set>
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class IntersectionObservation;
class IntersectionObserver;
class IntersectionObserverController;

class ElementIntersectionObserverData final : public GarbageCollectedMixin {
 public:
  ElementIntersectionObserverData() = default;
  ~ElementIntersectionObserverData() = default;

  // If the argument observer is observing this Element, this method will return
  // the observation.
  std::shared_ptr<IntersectionObservation> GetObservationFor(IntersectionObserver&);

  // Add an implicit-root observation with this element as target.
  void AddObservation(IntersectionObservation&);
  // Add an explicit-root observer with this element as root.
  void AddObserver(IntersectionObserver&);
  void RemoveObservation(IntersectionObservation&);
  void RemoveObserver(IntersectionObserver&);
  [[nodiscard]] bool IsEmpty() const { return observations_.empty() && observers_.empty(); }
  void TrackWithController(IntersectionObserverController&);
  void StopTrackingWithController(IntersectionObserverController&);

  // TODO(pengfei12.guo): not supported
  // Run the IntersectionObserver algorithm for all observations for which this
  // element is target.
  // void ComputeIntersectionsForTarget();

  // TODO(pengfei12.guo): not supported
  // bool NeedsOcclusionTracking() const;

  // TODO(pengfei12.guo): not supported
  // Indicates that geometry information cached during the previous run of the
  // algorithm is invalid and must be recomputed.
  // void InvalidateCachedRects();

  void Trace(GCVisitor*) const;

  // TODO(pengfei12.guo): not supported
  // const char* NameInHeapSnapshot() const override {
  //  return "ElementIntersectionObserverData";
  //}

 private:
  // IntersectionObservations for which the Node owning this data is target.
  std::unordered_map<Member<IntersectionObserver>,
                     std::shared_ptr<IntersectionObservation>,
                     Member<IntersectionObserver>::KeyHasher>
      observations_;
  // IntersectionObservers for which the Node owning this data is root.
  // Weak because once an observer is unreachable from javascript and has no
  // active observations, it should be allowed to die.
  std::unordered_set<Member<IntersectionObserver>, Member<IntersectionObserver>::KeyHasher> observers_;
};

}  // namespace webf

#endif  // WEBF_CORE_ELEMENT_INTERSECTION_OBSERVER_DATA_H_
