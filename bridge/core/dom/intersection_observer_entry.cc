// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#include "core/dom/intersection_observer_entry.h"

#include <chrono>
#include <cmath>

#include "core/executing_context.h"
#include "core/dom/element.h"
#include "core/dom/legacy/bounding_client_rect.h"

namespace webf {

namespace {

int64_t NowInMilliseconds(ExecutingContext* context) {
  using namespace std::chrono;
  auto now = system_clock::now();
  auto duration = duration_cast<microseconds>(now - context->timeOrigin());
  auto reduced_duration = std::floor(duration / 1000us) * 1000us;
  return duration_cast<milliseconds>(reduced_duration).count();
}

}  // namespace

IntersectionObserverEntry::IntersectionObserverEntry(ExecutingContext* context,
                                                     bool isIntersecting,
                                                     bool isVisible,
                                                     double intersectionRatio,
                                                     Element* target,
                                                     BoundingClientRect* bounding_client_rect,
                                                     BoundingClientRect* root_bounds,
                                                     BoundingClientRect* intersection_rect)
    : ScriptWrappable(context->ctx()),
      intersectionRatio_(intersectionRatio),
      isIntersecting_(isIntersecting),
      is_visible_(isVisible),
      time_(NowInMilliseconds(context)),
      bounding_client_rect_(bounding_client_rect),
      root_bounds_(root_bounds),
      intersection_rect_(intersection_rect),
      target_(target) {}

void IntersectionObserverEntry::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(bounding_client_rect_);
  visitor->TraceMember(root_bounds_);
  visitor->TraceMember(intersection_rect_);
  visitor->TraceMember(target_);
}

}  // namespace webf
