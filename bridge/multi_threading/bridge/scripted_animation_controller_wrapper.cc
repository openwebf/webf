/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "scripted_animation_controller_wrapper.h"

#include "core/dom/scripted_animation_controller.h"

namespace webf {

namespace multi_threading {

void handleRAFTransientCallbackWrapper(void* ptr, int32_t contextId, double highResTimeStamp, const char* errmsg) {
  auto* frame_callback = static_cast<FrameCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->postToJS(webf::handleRAFTransientCallback, ptr, contextId,
                                                        highResTimeStamp, errmsg);
}

}  // namespace multi_threading

}  // namespace webf