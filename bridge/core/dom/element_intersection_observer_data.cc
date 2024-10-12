// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#include "core/dom/element_intersection_observer_data.h"

#include "core/dom/document.h"
#include "core/dom/intersection_observation.h"
#include "core/dom/intersection_observer.h"
#include "core/dom/intersection_observer_controller.h"

namespace webf {

std::shared_ptr<IntersectionObservation> ElementIntersectionObserverData::GetObservationFor(
    IntersectionObserver& observer) {
  auto i = observations_.find(&observer);
  if (i == observations_.end())
    return nullptr;
  return i->second;
}

void ElementIntersectionObserverData::AddObservation(IntersectionObservation& observation) {
  assert(observation.Observer());
  observations_.insert({observation.Observer(), std::make_shared<IntersectionObservation>(observation)});
}

void ElementIntersectionObserverData::AddObserver(IntersectionObserver& observer) {
  observers_.insert(&observer);
}

void ElementIntersectionObserverData::RemoveObservation(IntersectionObservation& observation) {
  observations_.erase(observation.Observer());
}

void ElementIntersectionObserverData::RemoveObserver(IntersectionObserver& observer) {
  observers_.erase(&observer);
}

void ElementIntersectionObserverData::TrackWithController(IntersectionObserverController& controller) {
  for (auto& entry : observations_)
    controller.AddTrackedObservation(*entry.second);
  for (auto& observer : observers_)
    controller.AddTrackedObserver(*observer);
}

void ElementIntersectionObserverData::StopTrackingWithController(IntersectionObserverController& controller) {
  for (auto& entry : observations_)
    controller.RemoveTrackedObservation(*entry.second);
  for (auto& observer : observers_)
    controller.RemoveTrackedObserver(*observer);
}

/*
// TODO(pengfei12.guo): not supported
void ElementIntersectionObserverData::ComputeIntersectionsForTarget() {
  ComputeIntersectionsContext context;
  for (auto& [observer, observation] : observations_) {
    observation->ComputeIntersectionImmediately(context);
  }
}

bool ElementIntersectionObserverData::NeedsOcclusionTracking() const {
  for (auto& entry : observations_) {
    if (entry.key->trackVisibility())
      return true;
  }
  return false;
}

void ElementIntersectionObserverData::InvalidateCachedRects() {
  if (!RuntimeEnabledFeatures::IntersectionOptimizationEnabled()) {
    for (auto& observer : observers_) {
      observer->InvalidateCachedRects();
    }
  }
  for (auto& entry : observations_) {
    entry.value->InvalidateCachedRects();
  }
}
 */

void ElementIntersectionObserverData::Trace(GCVisitor* visitor) const {
  for (const auto& pair : observations_) {
    const Member<IntersectionObserver>& observerMember = pair.first;
    visitor->TraceMember(observerMember);
  }

  for (const auto& observerMember : observers_) {
    visitor->TraceMember(observerMember);
  }
}

}  // namespace webf
