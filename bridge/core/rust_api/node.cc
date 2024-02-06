/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "node.h"
#include "core/dom/events/event_target.h"

namespace webf {

NodeRustMethods::NodeRustMethods(): event_target(EventTarget::rustMethodPointer()) {}

}