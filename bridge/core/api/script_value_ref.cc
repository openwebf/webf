/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/script_value_ref.h"
#include "core/api/exception_state.h"
#include "core/native/script_value_ref.h"

namespace webf {

const char* ScriptValueRefPublicMethods::ToString(webf::ScriptValueRef* script_value_ref,
                                                  webf::SharedExceptionState* shared_exception_state) {
  if (script_value_ref->script_value.IsString()) {
    auto value = script_value_ref->script_value.ToString(script_value_ref->context->ctx());
    return value.ToStringView().Characters8();
  }
  shared_exception_state->exception_state.ThrowException(script_value_ref->context->ctx(), webf::ErrorType::TypeError,
                                                         "Value is not a string.");
  return nullptr;
}

void ScriptValueRefPublicMethods::SetAsString(webf::ScriptValueRef* script_value_ref,
                                              const char* value,
                                              webf::SharedExceptionState* shared_exception_state) {
  webf::AtomicString value_atomic = webf::AtomicString(script_value_ref->context->ctx(), value);
  script_value_ref->script_value = webf::ScriptValue(script_value_ref->context->ctx(), value_atomic);
}

void ScriptValueRefPublicMethods::Release(webf::ScriptValueRef* script_value_ref) {
  delete script_value_ref;
}

}  // namespace webf
