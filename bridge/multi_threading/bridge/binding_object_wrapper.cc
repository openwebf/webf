/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "binding_object_wrapper.h"
#include "core/binding_object.h"
#include "core/dart_isolate_context.h"
#include "dart_method_wrapper.h"

namespace webf {

namespace multi_threading {

void HandleCallFromDartSideWrapper(NativeBindingObject* binding_object,
                                   NativeValue* return_value,
                                   NativeValue* method,
                                   int32_t argc,
                                   NativeValue* argv,
                                   Dart_Handle dart_object) {
  binding_object->binding_target_->GetDispatcher()->PostToJsSync(
      webf::NativeBindingObject::HandleCallFromDartSide, binding_object, return_value, method, argc, argv, dart_object);
}

void BindingObjectWrapper::HandleAnonymousAsyncCalledFromDartWrapper(void* ptr,
                                                                     NativeValue* native_value,
                                                                     int32_t contextId,
                                                                     const char* errmsg) {
  auto* promise_context = static_cast<BindingObjectPromiseContext*>(ptr);
  promise_context->context->dartIsolateContext()->dispatcher()->PostToJs(
      webf::BindingObject::HandleAnonymousAsyncCalledFromDart, promise_context, native_value, contextId, errmsg);
}

ScriptValue BindingObjectWrapper::AnonymousFunctionCallbackWrapper(JSContext* ctx,
                                                                   const ScriptValue& this_val,
                                                                   uint32_t argc,
                                                                   const ScriptValue* argv,
                                                                   void* private_data) {
  return ScriptValue(ctx, nullptr);
}

}  // namespace multi_threading

}  // namespace webf