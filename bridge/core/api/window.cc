/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/window.h"
#include "core/api/exception_state.h"
#include "core/dom/events/event_target.h"
#include "core/frame/window.h"
#include "core/frame/window_or_worker_global_scope.h"

namespace webf {

void WindowPublicMethods::ScrollToWithXAndY(Window* window,
                                            double x,
                                            double y,
                                            SharedExceptionState* shared_exception_state) {
  window->scrollTo(x, y, shared_exception_state->exception_state);
}

double WindowPublicMethods::RequestAnimationFrame(Window* window,
                                                  WebFNativeFunctionContext* callback_context,
                                                  SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  return WindowOrWorkerGlobalScope::requestAnimationFrame(window->GetExecutingContext(), callback_impl, shared_exception_state->exception_state);
}

}  // namespace webf
