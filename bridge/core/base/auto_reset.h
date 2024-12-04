// Copyright 2011 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_AUTO_RESET_H
#define WEBF_AUTO_RESET_H

#include <utility>

namespace webf {

template <typename T>
class [[maybe_unused, nodiscard]] AutoReset {
 public:
  template <typename U>
  AutoReset(T * scoped_variable, U && new_value)
      : scoped_variable_(scoped_variable),
        original_value_(std::exchange(*scoped_variable_, std::forward<U>(new_value))) {}

  // A constructor that's useful for asserting the old value of
  // `scoped_variable`, especially when it's inconvenient to check this before
  // constructing the AutoReset object (e.g. in a class member initializer
  // list).
  template <typename U>
  AutoReset(T * scoped_variable, U && new_value, const T& expected_old_value) : AutoReset(scoped_variable, new_value) {
    DCHECK_EQ(original_value_, expected_old_value);
  }

  AutoReset(AutoReset && other)
      : scoped_variable_(std::exchange(other.scoped_variable_, nullptr)),
        original_value_(std::move(other.original_value_)) {}

  AutoReset& operator=(AutoReset&& rhs) {
    scoped_variable_ = std::exchange(rhs.scoped_variable_, nullptr);
    original_value_ = std::move(rhs.original_value_);
    return *this;
  }

  ~AutoReset() {
    if (scoped_variable_)
      *scoped_variable_ = std::move(original_value_);
  }

 private:
  T* scoped_variable_;

  T original_value_;
};

}  // namespace webf

#endif  // WEBF_AUTO_RESET_H
