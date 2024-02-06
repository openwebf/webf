/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_RUST_API_RUST_VALUE_H_
#define WEBF_CORE_RUST_API_RUST_VALUE_H_

namespace webf {

template<typename T, typename U>
/// Simple struct value both contains the value returned to rust and related C function pointers.
struct RustValue {
  T* value;
  U* method_pointer;
};

// Memory aligned and readable from Rust side.
// Only C type member can be included in this class, any C++ type and classes can is not allowed to use here.
struct RustMethods {};

template<typename T, typename U>
RustValue<T, U> ToRustValue(void* value, void* method_pointer) {
  return {.value = value, .method_pointer = method_pointer};
}

}

#endif  // WEBF_CORE_RUST_API_RUST_VALUE_H_
