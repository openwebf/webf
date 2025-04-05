/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

#ifndef WEBF_CORE_FRAME_IDLE_DEADLINE_H_
#define WEBF_CORE_FRAME_IDLE_DEADLINE_H_

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"

namespace webf {

class IdleDeadline : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  IdleDeadline(ExecutingContext* context, double remaining_time);

  bool didTimeout();
  double timeRemaining(ExceptionState& exception_state);

 private:
  double remaining_time_;
};

}  // namespace webf

#endif  // WEBF_CORE_FRAME_IDLE_DEADLINE_H_
