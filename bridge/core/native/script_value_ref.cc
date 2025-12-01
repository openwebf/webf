/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
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