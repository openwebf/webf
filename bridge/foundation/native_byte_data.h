/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#ifndef WEBF_FOUNDATION_NATIVE_BYTE_DATA_H_
#define WEBF_FOUNDATION_NATIVE_BYTE_DATA_H_

#include "native_value.h"

namespace webf {

class DartIsolateContext;
class ExecutingContext;

struct NativeByteDataFinalizerContext {
  DartIsolateContext* dart_isolate_context;
  ExecutingContext* context;
  JSValue value;
};

using FreeNativeByteData = void (*)(void* ptr);

struct NativeByteData : public DartReadable {
  static NativeByteData* Create(uint8_t* bytes,
                                int32_t length,
                                FreeNativeByteData on_free,
                                NativeByteDataFinalizerContext* context);
  uint8_t* bytes;
  int32_t length;
  FreeNativeByteData free_native_byte_data_;
  NativeByteDataFinalizerContext* context;
};

}  // namespace webf

#endif  // WEBF_FOUNDATION_NATIVE_BYTE_DATA_H_
