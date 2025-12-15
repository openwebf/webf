// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_H_

#include <unordered_set>
#include <vector>
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/exception_state.h"
#include "core/binding_object.h"
#include "qjs_intersection_observer_init.h"

namespace webf {

class Element;
class ExceptionState;
class IntersectionObserverEntry;
class Node;
class ScriptState;

class IntersectionObserver final : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static IntersectionObserver* Create(ExecutingContext* context,
                                      const std::shared_ptr<QJSFunction>& function,
                                      ExceptionState& exception_state);

  static IntersectionObserver* Create(ExecutingContext* context,
                                      const std::shared_ptr<QJSFunction>& function,
                                      const std::shared_ptr<IntersectionObserverInit>& observer_init,
                                      ExceptionState& exception_state);

  IntersectionObserver(ExecutingContext* context, const std::shared_ptr<QJSFunction>& function);
  IntersectionObserver(ExecutingContext* context,
                       const std::shared_ptr<QJSFunction>& function,
                       const std::shared_ptr<IntersectionObserverInit>& observer_init);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

  // API methods.
  void observe(Element*, ExceptionState&);
  void unobserve(Element*, ExceptionState&);
  void disconnect(ExceptionState&);
  std::vector<IntersectionObserverEntry*> takeRecords(ExceptionState&);

  // API attributes.
  [[nodiscard]] Node* root() const { return root_; }
  [[nodiscard]] AtomicString rootMargin() const { return root_margin_; }
  [[nodiscard]] AtomicString scrollMargin() const { return scroll_margin_; }
  [[nodiscard]] const std::vector<double>& thresholds() const { return thresholds_; }
  [[nodiscard]] double delay() const { return delay_; }
  [[nodiscard]] bool trackVisibility() const { return track_visibility_; }

  // An observer can either track intersections with an explicit root Node,
  // or with the the top-level frame's viewport (the "implicit root").  When
  // tracking the implicit root, root_ will be null, but because root_ is a
  // weak pointer, we cannot surmise that this observer tracks the implicit
  // root just because root_ is null.  Hence root_is_implicit_.
  [[nodiscard]] bool RootIsImplicit() const {
    // return root_is_implicit_;
    // If the root option is not specified, the viewport is used as the root element by default.
    return root_ == nullptr;
  }

  // Returns false if this observer has an explicit root node which has been
  // deleted; true otherwise.
  bool RootIsValid() const;

  void Trace(GCVisitor*) const override;

 private:
  // We use UntracedMember<> here to do custom weak processing.
  Node* root_ = nullptr;
  AtomicString root_margin_ = AtomicString::CreateFromUTF8("0px 0px 0px 0px");
  AtomicString scroll_margin_ = AtomicString::CreateFromUTF8("0px 0px 0px 0px");
  std::vector<double> thresholds_ = {0.0};
  double delay_ = 0.0;
  bool track_visibility_ = false;
  // Track active observation targets to keep this JS observer alive while it
  // has observations. Targets are stored by their NativeBindingObject pointer
  // address so we can avoid holding strong references to DOM Elements.
  std::unordered_set<const NativeBindingObject*> observed_targets_;
  bool keep_alive_ = false;

  std::shared_ptr<QJSFunction> function_;
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_H_
