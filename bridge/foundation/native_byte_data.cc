/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#include "native_byte_data.h"
#include <cstdio>  // For printf

namespace webf {

NativeByteData* NativeByteData::Create(uint8_t* bytes,
                                       int32_t length,
                                       FreeNativeByteData on_free,
                                       NativeByteDataFinalizerContext* context) {
  auto* native_byte_data = new NativeByteData();
  native_byte_data->bytes = bytes;
  native_byte_data->length = length;
  native_byte_data->free_native_byte_data_ = on_free;
  native_byte_data->context = context;
  return native_byte_data;
}

}  // namespace webf