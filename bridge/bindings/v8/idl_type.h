/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_BINDINGS_V8_CONVERTER_TS_TYPE_H_
#define BRIDGE_BINDINGS_V8_CONVERTER_TS_TYPE_H_

#include <vector>
#include "bindings/qjs/converter.h"
#include <v8/v8.h>

namespace webf {

template <typename T>
struct IDLTypeBaseHelper {
  using ImplType = T;
};

// Function callback
struct IDLCallback : public IDLTypeBaseHelper<v8::MaybeLocal<v8::Function>> {
  using ImplType = typename Converter<v8::MaybeLocal<v8::Function>>::ImplType;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_V8_CONVERTER_TS_TYPE_H_
