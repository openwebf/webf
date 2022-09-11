/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_FOUNDATION_NATIVE_VALUE_CONVERTER_H_
#define BRIDGE_FOUNDATION_NATIVE_VALUE_CONVERTER_H_

#include "core/binding_object.h"
#include "native_type.h"
#include "native_value.h"

namespace webf {

// NativeValueConverter converts types back and forth from C++ types to NativeValue. The template
// parameter |T| determines what kind of type conversion to perform.
template <typename T, typename SFINAEHelper = void>
struct NativeValueConverter {
  using ImplType = T;
};

template <typename T>
struct NativeValueConverterBase {
  using ImplType = typename T::ImplType;
};

template <>
struct NativeValueConverter<NativeTypeNull> : public NativeValueConverterBase<NativeTypeNull> {
  static NativeValue ToNativeValue() { return Native_NewNull(); }

  static ImplType FromNativeValue(JSContext* ctx) { return ScriptValue::Empty(ctx); }
};

template <>
struct NativeValueConverter<NativeTypeString> : public NativeValueConverterBase<NativeTypeString> {
  static NativeValue ToNativeValue(const ImplType& value) { return Native_NewString(value.ToNativeString().release()); }

  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) {
    return AtomicString(ctx, static_cast<NativeString*>(value.u.ptr));
    ;
  }
};

template <>
struct NativeValueConverter<NativeTypeBool> : public NativeValueConverterBase<NativeTypeBool> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewBool(value); }

  static ImplType FromNativeValue(NativeValue value) { return value.u.int64 == 1; }
};

template <>
struct NativeValueConverter<NativeTypeInt64> : public NativeValueConverterBase<NativeTypeInt64> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewInt64(value); }

  static ImplType FromNativeValue(NativeValue value) { return value.u.int64; }
};

template <>
struct NativeValueConverter<NativeTypeDouble> : public NativeValueConverterBase<NativeTypeDouble> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewFloat64(value); }

  static ImplType FromNativeValue(NativeValue value) {
    double result;
    memcpy(&result, reinterpret_cast<void*>(&value.u.int64), sizeof(double));
    return result;
  }
};

template <>
struct NativeValueConverter<NativeTypeJSON> : public NativeValueConverterBase<NativeTypeJSON> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewJSON(value); }
  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) {
    auto* str = static_cast<const char*>(value.u.ptr);
    return ScriptValue::CreateJsonObject(ctx, str, strlen(str));
  }
};

class BindingObject;
struct NativeBindingObject;

template <typename T>
struct NativeValueConverter<NativeTypePointer<T>> : public NativeValueConverterBase<NativeTypePointer<T>> {
  static NativeValue ToNativeValue(T* value) { return Native_NewPtr(JSPointerType::Others, value); }
  static NativeValue ToNativeValue(BindingObject* value) {
    return Native_NewPtr(JSPointerType::Others, value->bindingObject());
  }
  static T* FromNativeValue(NativeValue value) { return static_cast<T*>(value.u.ptr); }
};

template <>
struct NativeValueConverter<NativeTypeFunction> : public NativeValueConverterBase<NativeTypeFunction> {
  static NativeValue ToNativeValue(ImplType value) {
    // Not supported.
    assert(false);
  }

  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) {
    return QJSFunction::Create(ctx, BindingObject::AnonymousFunctionCallback, 4, value.u.ptr);
  };
};

template <>
struct NativeValueConverter<NativeTypeAsyncFunction> : public NativeValueConverterBase<NativeTypeAsyncFunction> {
  static NativeValue ToNativeValue(ImplType value) {
    // Not supported.
    assert(false);
  }

  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) {
    return QJSFunction::Create(ctx, BindingObject::AnonymousAsyncFunctionCallback, 4, value.u.ptr);
  }
};

template<typename T>
struct NativeValueConverter<NativeTypeArray<T>> : public NativeValueConverterBase<NativeTypeArray<T>> {
  using ImplType = typename NativeTypeArray<typename NativeValueConverter<T>::ImplType>::ImplType;
  static NativeValue ToNativeValue(ImplType value) {
    auto* ptr = new NativeValue[value.size()];
    for(int i = 0; i < value.size(); i ++) {
      ptr[i] = NativeValueConverter<T>::ToNativeValue(value[i]);
    }
    return Native_NewList(value.size(), ptr);
  }

  static ImplType FromNativeValue(JSContext* ctx, NativeValue native_value) {
    size_t length = native_value.uint32;
    auto* arr = static_cast<NativeValue*>(native_value.u.ptr);
    std::vector<typename T::ImplType> vec;
    vec.reserve(length);
    for(int i = 0; i < length; i ++) {
      vec[i] = NativeValueConverter<T>::FromNativeValue(ctx, arr[i]);
    }
    return vec;
  }
};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_NATIVE_VALUE_CONVERTER_H_
