/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/script_value_ref.h"
#include "core/native/script_value_ref.h"

namespace webf {

void ScriptValueRefPublicMethods::Release(webf::ScriptValueRef* script_value_ref) {
  delete script_value_ref;
}

}  // namespace webf