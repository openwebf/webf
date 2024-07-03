/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_WEBF_API_WEBF_VALUE_H_
#define WEBF_CORE_WEBF_API_WEBF_VALUE_H_

namespace webf {

template <typename T, typename U>
/// Simple struct value both contains the value returned to external native plugin and related C function pointers.
struct WebFValue {
  T* value;
  U* method_pointer;
};

// Memory aligned and readable from external C/C++/Rust side.
// Only C type member can be included in this class, any C++ type and classes can is not allowed to use here.
struct WebFPublicMethods {};

template <typename T, typename U>
WebFValue<T, U> ToWebFValue(void* value, void* method_pointer) {
  return {.value = value, .method_pointer = method_pointer};
}

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_WEBF_VALUE_H_
