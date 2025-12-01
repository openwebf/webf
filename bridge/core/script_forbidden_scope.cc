/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "script_forbidden_scope.h"

namespace webf {

thread_local unsigned ScriptForbiddenScope::g_main_thread_counter_ = 0;

}
