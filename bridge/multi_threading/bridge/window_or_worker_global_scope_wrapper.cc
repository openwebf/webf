/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "window_or_worker_global_scope_wrapper.h"

#include "core/frame/dom_timer.h"
#include "core/frame/window_or_worker_global_scope.h"

namespace webf {

namespace multi_threading {

void handleTransientCallbackWrapper(void* ptr, int32_t contextId, const char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->postToJS(webf::handleTransientCallback, ptr, contextId, errmsg);
}

void handlePersistentCallbackWrapper(void* ptr, int32_t contextId, const char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->postToJS(webf::handlePersistentCallback, ptr, contextId, errmsg);
}

}  // namespace multi_threading

}  // namespace webf