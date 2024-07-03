/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/window.h"
#include "core/dom/events/event_target.h"

namespace webf {

WindowWebFMethods::WindowWebFMethods(EventTargetWebFMethods* super_method) : event_target(super_method) {}

}  // namespace webf