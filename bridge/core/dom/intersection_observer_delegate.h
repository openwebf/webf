// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_DELEGATE_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_DELEGATE_H_

#include "core/dom/intersection_observer.h"
#include "bindings/qjs/heap_vector.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class ExecutionContext;
class IntersectionObserver;
class IntersectionObserverEntry;

class IntersectionObserverDelegate {
 public:
  ~IntersectionObserverDelegate() = default;

  virtual IntersectionObserver::DeliveryBehavior GetDeliveryBehavior()
      const = 0;

  // The IntersectionObserver spec requires that at least one observation be
  // recorded after observe() is called, even if the target is detached.
  virtual bool NeedsInitialObservationWithDetachedTarget() const = 0;

  virtual void Deliver(const std::vector<Member<IntersectionObserverEntry>>&,
                       IntersectionObserver&) = 0;
  virtual ExecutionContext* GetExecutionContext() const = 0;
  //virtual void Trace(GCVisitor* visitor) const {}

  //const char* NameInHeapSnapshot() const override {
  //  return "IntersectionObserverDelegate";
  //}
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_DELEGATE_H_
