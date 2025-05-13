/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

#include "idle_deadline.h"
#include "core/executing_context.h"

namespace webf {

IdleDeadline::IdleDeadline(webf::ExecutingContext* context, double remaining_time)
    : ScriptWrappable(context->ctx()), remaining_time_(remaining_time) {}

bool IdleDeadline::didTimeout() {
  return remaining_time_ <= 0;
}

double IdleDeadline::timeRemaining(webf::ExceptionState& exception_state) {
  // 0.001 is a special value to identify the remaining time was triggered by timeout.
  return remaining_time_ > 0 ? remaining_time_ : 0;
}

}  // namespace webf