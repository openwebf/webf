/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_NATIVE_VECTOR_VALUE_REF_H_
#define WEBF_CORE_NATIVE_VECTOR_VALUE_REF_H_

#include "plugin_api/webf_value.h"

namespace webf {
struct VectorValueRef {
  int64_t size;
  void* data;

  VectorValueRef(void* data, int64_t size) : data(data), size(size){};
};
}  // namespace webf

#endif  // WEBF_CORE_NATIVE_VECTOR_VALUE_REF_H_
