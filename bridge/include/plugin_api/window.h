/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_WINDOW_H_
#define WEBF_CORE_RUST_API_WINDOW_H_

#include "event_target.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;
class Event;
class Window;

using PublicWindowScrollToWithXAndY = void (*)(Window*, double, double, SharedExceptionState*);

struct WindowPublicMethods : WebFPublicMethods {
  static void ScrollToWithXAndY(Window* window, double x, double y, SharedExceptionState* shared_exception_state);

  double version{1.0};
  EventTargetPublicMethods event_target;
  PublicWindowScrollToWithXAndY window_scroll_to_with_x_and_y{ScrollToWithXAndY};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_WINDOW_H_
