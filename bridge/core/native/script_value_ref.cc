/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/native/script_value_ref.h"

namespace webf {

ScriptValueRefPublicMethods* ScriptValueRef::publicMethods() {
  static ScriptValueRefPublicMethods public_methods;
  return &public_methods;
}

}  // namespace webf