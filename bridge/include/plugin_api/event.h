/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EVENT_H_
#define WEBF_CORE_RUST_API_EVENT_H_

#include "webf_value.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct EventWebFMethods : public WebFPublicMethods {

  double version{1.0};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EVENT_H_
