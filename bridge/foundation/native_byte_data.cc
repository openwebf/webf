/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#include "native_byte_data.h"
#include "core/executing_context.h"

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

void NativeByteData::HandleNativeByteDataFinalizer(void* raw_finalizer_ptr) {
  auto* finalizer_context = static_cast<NativeByteDataFinalizerContext*>(raw_finalizer_ptr);

  // Check if the JS context is alive.
  if (!finalizer_context->context->IsContextValid() || !finalizer_context->context->IsCtxValid()) {
    return;
  }

  auto* context = finalizer_context->context;
  bool is_dedicated = context->isDedicated();
  finalizer_context->dart_isolate_context->dispatcher()->PostToJs(
      is_dedicated, context->contextId(),
      [](NativeByteDataFinalizerContext* finalizer_context) {
        // The context or ctx may be finalized during the thread switch
        if (!finalizer_context->context->IsContextValid() || !finalizer_context->context->IsCtxValid()) {
          return;
        }
        // Free the JSValue reference when the JS heap and context is alive.
        JS_FreeValue(finalizer_context->context->ctx(), finalizer_context->value);
        finalizer_context->context->UnRegisterActiveNativeByteData(finalizer_context);
      },
      finalizer_context);
}

}  // namespace webf