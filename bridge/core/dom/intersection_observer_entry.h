// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_ENTRY_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_ENTRY_H_

#include <cstdint>

#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/script_wrappable.h"

namespace webf {

class BoundingClientRect;
class Element;

struct NativeIntersectionObserverEntry : public DartReadable {
  int8_t is_intersecting;
  double intersectionRatio;
  NativeBindingObject* target;
  NativeBindingObject* boundingClientRect;
  NativeBindingObject* rootBounds;
  NativeBindingObject* intersectionRect;
};

struct NativeIntersectionObserverEntryList : public DartReadable {
  NativeIntersectionObserverEntry* entries;
  int32_t length;
};

class IntersectionObserverEntry final : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = IntersectionObserverEntry*;
  IntersectionObserverEntry() = delete;
  explicit IntersectionObserverEntry(ExecutingContext* context,
                                     bool isIntersecting,
                                     double intersectionRatio,
                                     Element* target,
                                     BoundingClientRect* bounding_client_rect,
                                     BoundingClientRect* root_bounds,
                                     BoundingClientRect* intersection_rect);

  // TODO(pengfei12.guo): not supported
  // IDL interface
  int64_t time() const { return time_; }
  BoundingClientRect* rootBounds() const { return root_bounds_.Get(); }
  BoundingClientRect* boundingClientRect() const { return bounding_client_rect_.Get(); }
  BoundingClientRect* intersectionRect() const { return intersection_rect_.Get(); }
  double intersectionRatio() const { return intersectionRatio_; }
  // DOMRectReadOnly* boundingClientRect() const;
  // DOMRectReadOnly* rootBounds() const;
  // DOMRectReadOnly* intersectionRect() const;
  // bool isVisible() const {
  // return geometry_.IsVisible();
  //}

  bool isIntersecting() const { return isIntersecting_; }

  Element* target() const { return target_.Get(); }

  // TODO(pengfei12.guo): IntersectionGeometry not supported
  // blink-internal interface
  // const IntersectionGeometry& GetGeometry() const { return geometry_; }
  void Trace(GCVisitor*) const override;

 private:
  // IntersectionGeometry geometry_;
  double intersectionRatio_;
  bool isIntersecting_;
  int64_t time_;
  Member<BoundingClientRect> bounding_client_rect_;
  Member<BoundingClientRect> root_bounds_;
  Member<BoundingClientRect> intersection_rect_;
  Member<Element> target_;
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_ENTRY_H_
