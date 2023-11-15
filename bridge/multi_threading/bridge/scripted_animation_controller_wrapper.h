/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/**
 * @brief dart call c++ method wrapper, for supporting multi-threading.
 * it's call on the dart isolate thread.
 */
#ifndef MULTI_THREADING_SCRIPTED_ANIMATION_CONTROLLER_WRAPPER_H
#define MULTI_THREADING_SCRIPTED_ANIMATION_CONTROLLER_WRAPPER_H

#include <cstdint>

namespace webf {

namespace multi_threading {

void handleRAFTransientCallbackWrapper(void* ptr, int32_t contextId, double highResTimeStamp, const char* errmsg);

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_SCRIPTED_ANIMATION_CONTROLLER_WRAPPER_H