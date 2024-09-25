/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BASE_MEMORY_SHARED_PTR_H_
#define BASE_MEMORY_SHARED_PTR_H_

#include <memory>

namespace std {

// Patch for NDK 22.1.7171670
#if ANDROID
template <typename T, typename U>
std::shared_ptr<T> reinterpret_pointer_cast(const std::shared_ptr<U>& r) noexcept {
  auto p = reinterpret_cast<typename std::shared_ptr<T>::element_type*>(r.get());
  return std::shared_ptr<T>(r, p);
}

#endif

}

#endif