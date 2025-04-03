/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_WINDOW_H_
#define WEBF_CORE_RUST_API_WINDOW_H_

#include "core/native/native_function.h"
#include "event_target.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;
class Event;
class Window;

using PublicWindowScrollToWithXAndY = void (*)(Window*, double, double, SharedExceptionState*);
using PublicRequestAnimationFrame = double (*)(Window*, WebFNativeFunctionContext*, SharedExceptionState*);

struct WindowPublicMethods : WebFPublicMethods {
  static void ScrollToWithXAndY(Window* window, double x, double y, SharedExceptionState* shared_exception_state);
  static double RequestAnimationFrame(Window* window,
                                      WebFNativeFunctionContext* callback_context,
                                      SharedExceptionState* shared_exception_state);

  double version{1.0};
  EventTargetPublicMethods event_target;
  PublicWindowScrollToWithXAndY window_scroll_to_with_x_and_y{ScrollToWithXAndY};
  PublicRequestAnimationFrame window_request_animation_frame{RequestAnimationFrame};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_WINDOW_H_
