// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_NON_INTERPOLABLE_VALUE_H_
#define WEBF_CORE_ANIMATION_NON_INTERPOLABLE_VALUE_H_


namespace webf {

// Represents components of a PropertySpecificKeyframe's value that either do
// not change or 50% flip when interpolating with an adjacent value.
class NonInterpolableValue {
 public:
  virtual ~NonInterpolableValue() = default;

  typedef const void* Type;
  virtual Type GetType() const = 0;
};

// These macros provide safe downcasts of NonInterpolableValue subclasses with
// debug assertions.
// See CSSDefaultInterpolationType.cpp for example usage.
#define DECLARE_NON_INTERPOLABLE_VALUE_TYPE()         \
  Type GetType() const final { return static_type_; } \
  static Type static_type_

#define DEFINE_NON_INTERPOLABLE_VALUE_TYPE(T) \
  NonInterpolableValue::Type T::static_type_ = &T::static_type_

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_NON_INTERPOLABLE_VALUE_H_
