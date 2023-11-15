/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/**
 * @brief dart call c++ method wrapper, for supporting multi-threading.
 * it's call on the dart isolate thread.
 */
#ifndef MULTI_THREADING_WINDOW_GLOBAL_SCOPE_WRAPPER_H
#define MULTI_THREADING_WINDOW_GLOBAL_SCOPE_WRAPPER_H

#include <cstdint>

namespace webf {

namespace multi_threading {

void handleTransientCallbackWrapper(void* ptr, int32_t contextId, const char* errmsg);

void handlePersistentCallbackWrapper(void* ptr, int32_t contextId, const char* errmsg);

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_WINDOW_GLOBAL_SCOPE_WRAPPER_H