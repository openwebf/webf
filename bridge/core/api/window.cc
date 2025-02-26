/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/window.h"
#include "core/api/exception_state.h"
#include "core/dom/events/event_target.h"
#include "core/frame/window.h"

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
  return window->requestAnimationFrame(callback_impl, shared_exception_state->exception_state);
}

}  // namespace webf
