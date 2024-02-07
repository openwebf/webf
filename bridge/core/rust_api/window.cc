/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "window.h"
#include "core/dom/events/event_target.h"

namespace webf {

WindowRustMethods::WindowRustMethods(EventTargetRustMethods* super_rust_method): event_target(super_rust_method) {
}

}  // namespace webf