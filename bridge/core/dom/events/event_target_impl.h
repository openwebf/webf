/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_DOM_EVENTS_EVENT_TARGET_IMPL_H_
#define BRIDGE_CORE_DOM_EVENTS_EVENT_TARGET_IMPL_H_

#include "event_target.h"

namespace webf {

// Constructible version of EventTarget. Calls to EventTarget
// constructor in JavaScript will return an instance of this class.
// We don't use EventTarget directly because EventTarget is an abstract
// class and and making it non-abstract is unfavorable  because it will
// increase the size of EventTarget and all of its subclasses with code
// that are mostly unnecessary for them, resulting in a performance
// decrease.
class EventTargetImpl : public EventTarget {};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_EVENTS_EVENT_TARGET_IMPL_H_
