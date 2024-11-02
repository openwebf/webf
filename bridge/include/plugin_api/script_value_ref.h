/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_INCLUDE_PLUGIN_API_SCRIPT_VALUE_REF_H_
#define WEBF_INCLUDE_PLUGIN_API_SCRIPT_VALUE_REF_H_

#include "webf_value.h"

namespace webf {

typedef struct ScriptValueRef ScriptValueRef;
class SharedExceptionState;

using PublicScriptValueRefToString = const char* (*)(ScriptValueRef*, SharedExceptionState*);
using PublicScriptValueRefSetAsString = void (*)(ScriptValueRef*, const char*, SharedExceptionState*);
using PublicScriptValueRefRelease = void (*)(ScriptValueRef*);

struct ScriptValueRefPublicMethods : WebFPublicMethods {
  static const char* ToString(ScriptValueRef* script_value_ref, SharedExceptionState* shared_exception_state);
  static void SetAsString(ScriptValueRef* script_value_ref, const char* value, SharedExceptionState* shared_exception_state);
  static void Release(ScriptValueRef* script_value_ref);
  PublicScriptValueRefToString to_string{ToString};
  PublicScriptValueRefSetAsString set_as_string{SetAsString};
  PublicScriptValueRefRelease release{Release};
};

}  // namespace webf

#endif  // WEBF_INCLUDE_PLUGIN_API_SCRIPT_VALUE_REF_H_
