// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef BASE_MEMORY_PTR_UTIL_H_
#define BASE_MEMORY_PTR_UTIL_H_

#include <memory>
#include <type_traits>

namespace base {

// Helper to transfer ownership of a raw pointer to a std::unique_ptr<T>.
// Note that std::unique_ptr<T> has very different semantics from
// std::unique_ptr<T[]>: do not use this helper for array allocations.
template <typename T>
typename std::enable_if<std::is_object<T>::value && !std::is_array<T>::value, std::unique_ptr<T>>::type WrapUnique(
    T* ptr) {
  return std::unique_ptr<T>(ptr);
}

}  // namespace base

#endif  // BASE_MEMORY_PTR_UTIL_H_
