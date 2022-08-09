/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#ifndef KRAKENBRIDGE_CORE_FILEAPI_ARRAY_BUFFER_DATA_H_
#define KRAKENBRIDGE_CORE_FILEAPI_ARRAY_BUFFER_DATA_H_

namespace kraken {

struct ArrayBufferData {
  uint8_t* buffer;
  int32_t length;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_FILEAPI_ARRAY_BUFFER_DATA_H_
