// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_INTERPOLATION_VALUE_H_
#define WEBF_CORE_ANIMATION_INTERPOLATION_VALUE_H_

#include <memory>
#include "core/animation/interpolable_value.h"
#include "core/animation/non_interpolable_value.h"

namespace webf {

// Represents a (non-strict) subset of a PropertySpecificKeyframe's value broken
// down into interpolable and non-interpolable parts. InterpolationValues can be
// composed together to represent a whole PropertySpecificKeyframe value.
struct InterpolationValue {
  WEBF_DISALLOW_NEW();

  explicit InterpolationValue(std::shared_ptr<InterpolableValue> interpolable_value,
                              std::shared_ptr<const NonInterpolableValue> non_interpolable_value = nullptr)
      : interpolable_value(interpolable_value), non_interpolable_value(std::move(non_interpolable_value)) {}

  InterpolationValue(std::nullptr_t) {}

  InterpolationValue(InterpolationValue&& other)
      : interpolable_value(std::move(other.interpolable_value)),
        non_interpolable_value(std::move(other.non_interpolable_value)) {}

  void operator=(InterpolationValue&& other) {
    interpolable_value = std::move(other.interpolable_value);
    non_interpolable_value = std::move(other.non_interpolable_value);
  }

  operator bool() const { return interpolable_value.get(); }

  InterpolationValue Clone() const {
    return InterpolationValue(interpolable_value ? interpolable_value->Clone() : nullptr, non_interpolable_value);
  }

  void Clear() {
    interpolable_value == nullptr;
    non_interpolable_value = nullptr;
  }

  // void Trace(GCVisitor* v) const { v->Trace(interpolable_value); }

  std::shared_ptr<InterpolableValue> interpolable_value;
  std::shared_ptr<const NonInterpolableValue> non_interpolable_value;
};

// Wrapper to be used with MakeGarbageCollected<>.
class InterpolationValueGCed {
 public:
  explicit InterpolationValueGCed(const InterpolationValue& underlying) : underlying_(underlying.Clone()) {}

  // void Trace(GCVisitor* v) const { v->Trace(underlying_); }

  InterpolationValue& underlying() { return underlying_; }
  const InterpolationValue& underlying() const { return underlying_; }

 private:
  InterpolationValue underlying_;
};

}  // namespace webf

// WTF_ALLOW_CLEAR_UNUSED_SLOTS_WITH_MEM_FUNCTIONS(blink::InterpolationValue)

#endif  // WEBF_CORE_ANIMATION_INTERPOLATION_VALUE_H_
