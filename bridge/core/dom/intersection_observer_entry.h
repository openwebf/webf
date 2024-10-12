// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_ENTRY_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_ENTRY_H_

#include "bindings/qjs/cppgc/member.h"
#include "core/binding_object.h"

namespace webf {

class Element;

class IntersectionObserverEntry final : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = IntersectionObserverEntry*;

  IntersectionObserverEntry(ExecutingContext* context, bool isIntersecting, Element* target);
  // TODO(pengfei12.guo): not supported
  // IDL interface
  // double time() const { return time_; }
  // double intersectionRatio() const {
  // return geometry_.IntersectionRatio();
  //}
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

  bool IsIntersectionObserverEntry() const override { return true; };

 private:
  // IntersectionGeometry geometry_;
  bool isIntersecting_;
  // DOMHighResTimeStamp time_;
  Member<Element> target_;
};

template <>
struct DowncastTraits<IntersectionObserverEntry> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsIntersectionObserverEntry(); }
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_ENTRY_H_
