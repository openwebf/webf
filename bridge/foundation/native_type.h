/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_FOUNDATION_NATIVE_TYPE_H_
#define BRIDGE_FOUNDATION_NATIVE_TYPE_H_

#include <type_traits>
#include <vector>
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/script_value.h"
#include "foundation/native_string.h"

namespace webf {

void* dart_malloc(std::size_t size);
void dart_free(void* ptr);

// Shared C struct which can be read by dart through Dart FFI.
struct DartReadable {
  // Dart FFI use ole32 as it's allocator, we need to override the default allocator to compact with Dart FFI.
  static void* operator new(std::size_t size);
  static void operator delete(void* memory) noexcept;
};

struct NativeTypeBase {
  using ImplType = void;
};

template <typename T>
struct NativeTypeBaseHelper {
  using ImplType = T;
};

// Null
struct NativeTypeNull final : public NativeTypeBaseHelper<ScriptValue> {};

// Bool
struct NativeTypeBool final : public NativeTypeBaseHelper<bool> {};

// String
struct NativeTypeString final : public NativeTypeBaseHelper<AtomicString> {};

// Int64
struct NativeTypeInt64 final : public NativeTypeBaseHelper<int64_t> {};

// Double
struct NativeTypeDouble final : public NativeTypeBaseHelper<double> {};

// JSON
struct NativeTypeJSON final : public NativeTypeBaseHelper<ScriptValue> {};

// Array
template <typename T>
struct NativeTypeArray final : public NativeTypeBase {
  using ImplType = typename std::vector<T>;
};

// Pointer
template <typename T>
struct NativeTypePointer final : public NativeTypeBaseHelper<T*> {};

// Sync function
struct NativeTypeFunction final : public NativeTypeBaseHelper<std::shared_ptr<QJSFunction>> {};

// Async function
struct NativeTypeAsyncFunction final : public NativeTypeBaseHelper<std::shared_ptr<QJSFunction>> {};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_NATIVE_TYPE_H_
