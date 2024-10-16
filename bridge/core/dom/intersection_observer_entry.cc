// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#include "core/dom/intersection_observer_entry.h"
#include "core/dom/element.h"

namespace webf {

IntersectionObserverEntry::IntersectionObserverEntry(ExecutingContext* context, bool isIntersecting, Element* target)
    : BindingObject(context->ctx()), isIntersecting_(isIntersecting), target_(target) {}

// DOMRectReadOnly* IntersectionObserverEntry::boundingClientRect() const {
//   return DOMRectReadOnly::FromRectF(gfx::RectF(geometry_.TargetRect()));
// }
//
// DOMRectReadOnly* IntersectionObserverEntry::rootBounds() const {
//   if (geometry_.ShouldReportRootBounds())
//     return DOMRectReadOnly::FromRectF(gfx::RectF(geometry_.RootRect()));
//   return nullptr;
// }
//
// DOMRectReadOnly* IntersectionObserverEntry::intersectionRect() const {
//   return DOMRectReadOnly::FromRectF(gfx::RectF(geometry_.IntersectionRect()));
// }

void IntersectionObserverEntry::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(target_);
}

}  // namespace webf
