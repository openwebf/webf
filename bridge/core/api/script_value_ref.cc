/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/script_value_ref.h"
#include "core/api/exception_state.h"
#include "core/native/script_value_ref.h"

#include "string/wtf_string.h"

namespace webf {

// TODO(CGQAQ): this need allocate memory
const UTF8Char* ScriptValueRefPublicMethods::ToString(webf::ScriptValueRef* script_value_ref,
                                                      webf::SharedExceptionState* shared_exception_state) {
  if (script_value_ref->script_value.IsString()) {
    auto value = script_value_ref->script_value.ToAtomicString(script_value_ref->context->ctx());
    // TODO(CGQAQ): this is not right at all, UAF
    auto str =value.ToUTF8String();
    auto* leak = new UTF8Char[str.size()];
    memcpy(leak, str.c_str(), str.size() + 1);
    return leak;
  }
  shared_exception_state->exception_state.ThrowException(script_value_ref->context->ctx(), webf::ErrorType::TypeError,
                                                         "Value is not a string.");
  return nullptr;
}

void ScriptValueRefPublicMethods::SetAsString(webf::ScriptValueRef* script_value_ref,
                                              const UTF8Char* value,
                                              webf::SharedExceptionState* shared_exception_state) {
  webf::AtomicString value_atomic = webf::AtomicString::CreateFromUTF8(value);
  script_value_ref->script_value = webf::ScriptValue(script_value_ref->context->ctx(), value_atomic);
}

void ScriptValueRefPublicMethods::Release(webf::ScriptValueRef* script_value_ref) {
  delete script_value_ref;
}

}  // namespace webf
