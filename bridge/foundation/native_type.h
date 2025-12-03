/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_FOUNDATION_NATIVE_TYPE_H_
#define BRIDGE_FOUNDATION_NATIVE_TYPE_H_

#include <type_traits>
#include <vector>
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/script_value.h"
#include "foundation/native_string.h"
#include "foundation/dart_readable.h"

namespace webf {

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

// ----------------------------------------------------------------------------
// FFI structs for Dart bridge interop
// Keep layout in sync with ../webf/lib/src/bridge/native_types.dart
// ----------------------------------------------------------------------------

// Key-Value pair where both key and value are SharedNativeString*.
// Memory for the pointers (key/value) is owned externally and freed via
// freeNativeString on the Dart side after conversion.
struct NativePair : public DartReadable {
  SharedNativeString* key{nullptr};
  SharedNativeString* value{nullptr};
};

// Array of NativePair items with a 32-bit length.
struct NativeMap : public DartReadable {
  NativePair* items{nullptr};
  uint32_t length{0};
};

// Combined style value + base href payload for UICommand::kSetStyle.
// - |value| holds the serialized CSS value (NativeString*).
// - |href| holds an optional base href (NativeString*), or nullptr if absent.
struct NativeStyleValueWithHref : public DartReadable {
  SharedNativeString* value{nullptr};
  SharedNativeString* href{nullptr};
};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_NATIVE_TYPE_H_
