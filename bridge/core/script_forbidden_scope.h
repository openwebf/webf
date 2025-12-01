/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_SCRIPT_FORBIDDEN_SCOPE_H_
#define WEBF_CORE_SCRIPT_FORBIDDEN_SCOPE_H_

#include <assert.h>
#include "foundation/macros.h"

namespace webf {

// Scoped disabling of script execution.
class ScriptForbiddenScope final {
  WEBF_STACK_ALLOCATED();

 public:
  ScriptForbiddenScope() { Enter(); }
  ScriptForbiddenScope(const ScriptForbiddenScope&) = delete;
  ScriptForbiddenScope& operator=(const ScriptForbiddenScope&) = delete;
  ~ScriptForbiddenScope() { Exit(); }

  static bool IsScriptForbidden() { return g_main_thread_counter_ > 0; }

 private:
  static void Enter() { ++g_main_thread_counter_; }
  static void Exit() {
    assert(IsScriptForbidden());
    --g_main_thread_counter_;
  }

  // Maintain counter per-thread to avoid cross-thread interference.
  static thread_local unsigned g_main_thread_counter_;
};

}  // namespace webf

#endif  // WEBF_CORE_SCRIPT_FORBIDDEN_SCOPE_H_
