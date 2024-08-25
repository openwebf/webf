/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_BINDINGS_V8_CONVERTER_IMPL_H_
#define BRIDGE_BINDINGS_V8_CONVERTER_IMPL_H_

#include "bindings/v8/idl_type.h"
#include "bindings/v8/exception_state.h"

namespace webf {

template <>
struct Converter<IDLCallback> : public ConverterBase<IDLCallback> {
  static ImplType FromValue(v8::Isolate* isolate, v8::Local<v8::Value> arg, ExceptionState& exception_state) {
    if (!arg->IsFunction()) {
      return v8::MaybeLocal<v8::Function>();
    }

    return v8::Local<v8::Function>::Cast(arg);
  }
};

};  // namespace webf

#endif  // BRIDGE_BINDINGS_V8_CONVERTER_IMPL_H_
