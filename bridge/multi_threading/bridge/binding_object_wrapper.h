/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/**
 * @brief dart call c++ method wrapper, for supporting multi-threading.
 * it's call on the dart isolate thread.
 */
#ifndef MULTI_THREADING_BINDING_OBJECT_WRAPPER_H
#define MULTI_THREADING_BINDING_OBJECT_WRAPPER_H

#include <cstdint>

#include "bindings/qjs/script_wrappable.h"
#include "foundation/native_type.h"
#include "foundation/native_value.h"

namespace webf {

struct NativeBindingObject;

namespace multi_threading {

void HandleCallFromDartSideWrapper(NativeBindingObject* binding_object,
                                   NativeValue* return_value,
                                   NativeValue* method,
                                   int32_t argc,
                                   NativeValue* argv,
                                   Dart_Handle dart_object);

class BindingObjectWrapper {
 public:
  static void HandleAnonymousAsyncCalledFromDartWrapper(void* ptr,
                                                        NativeValue* native_value,
                                                        int32_t contextId,
                                                        const char* errmsg);

  // This function were called when the anonymous function returned to the JS code has been called by users.
  static ScriptValue AnonymousFunctionCallbackWrapper(JSContext* ctx,
                                                      const ScriptValue& this_val,
                                                      uint32_t argc,
                                                      const ScriptValue* argv,
                                                      void* private_data);

};  // class BindingObjectWrapper

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_BINDING_OBJECT_WRAPPER_H