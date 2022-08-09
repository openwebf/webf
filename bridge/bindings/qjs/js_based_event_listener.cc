/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "js_based_event_listener.h"

namespace kraken {

// Implements step 2. of "inner invoke".
// https://dom.spec.whatwg.org/#concept-event-listener-inner-invoke
void JSBasedEventListener::Invoke(ExecutingContext* context, Event* event, ExceptionState& exception_state) {
  assert(context);
  assert(event);

  if (!context->IsValid())
    return;
  // Step 10: Call a listener with event's currentTarget as receiver and event
  // and handle errors if thrown.
  InvokeInternal(*event->currentTarget(), *event, exception_state);
}

JSBasedEventListener::JSBasedEventListener() {}

}  // namespace kraken
