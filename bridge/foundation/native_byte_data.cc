/*
* Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
* Licensed under GNU AGPL with Enterprise exception.
*/

#include "native_byte_data.h"

namespace webf {

NativeByteData* NativeByteData::Create(uint8_t* bytes, int32_t length, FreeNativeByteData on_free, void* ptr) {
  auto* native_byte_data = new NativeByteData();
  native_byte_data->bytes = bytes;
  native_byte_data->length = length;
  native_byte_data->free_native_byte_data_ = on_free;
  native_byte_data->ptr = ptr;
  return native_byte_data;
}

}