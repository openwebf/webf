/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_INCLUDE_PLUGIN_API_SCRIPT_VALUE_REF_H_
#define WEBF_INCLUDE_PLUGIN_API_SCRIPT_VALUE_REF_H_

#include "webf_value.h"

namespace webf {

typedef struct ScriptValueRef ScriptValueRef;

using PublicScriptValueRefRelease = void (*)(ScriptValueRef*);

struct ScriptValueRefPublicMethods : WebFPublicMethods {
  static void Release(ScriptValueRef* script_value_ref);
  PublicScriptValueRefRelease release{Release};
};

}  // namespace webf

#endif  // WEBF_INCLUDE_PLUGIN_API_SCRIPT_VALUE_REF_H_
