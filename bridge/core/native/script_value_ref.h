/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_NATIVE_SCRIPT_VALUE_REF_H_
#define WEBF_CORE_NATIVE_SCRIPT_VALUE_REF_H_

#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"
#include "plugin_api/script_value_ref.h"

namespace webf {

struct ScriptValueRef {
  static ScriptValueRefPublicMethods* publicMethods();

  ExecutingContext* context;
  ScriptValue script_value;
};

}  // namespace webf

#endif  // WEBF_CORE_NATIVE_SCRIPT_VALUE_REF_H_
