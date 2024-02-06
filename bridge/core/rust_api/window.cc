/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "window.h"
#include "core/dom/events/event_target.h"

namespace webf {

WindowRustMethods::WindowRustMethods() {
  event_target = EventTarget::rustMethodPointer();
}

}  // namespace webf