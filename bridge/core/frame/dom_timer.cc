/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "dom_timer.h"

#include <utility>
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "core/executing_context.h"

#if UNIT_TEST
#include "webf_test_env.h"
#endif

namespace webf {

std::shared_ptr<DOMTimer> DOMTimer::create(ExecutingContext* context,
                                           const std::shared_ptr<Function>& callback,
                                           TimerKind timer_kind) {
  return std::make_shared<DOMTimer>(context, callback, timer_kind);
}

DOMTimer::DOMTimer(ExecutingContext* context, std::shared_ptr<Function> callback, TimerKind timer_kind)
    : context_(context), callback_(std::move(callback)), status_(TimerStatus::kPending), kind_(timer_kind) {}

void DOMTimer::Fire() {
  if (status_ == TimerStatus::kTerminated)
    return;

  if (auto* callback = DynamicTo<QJSFunction>(callback_.get())) {
    if (!callback->IsFunction(context_->ctx()))
      return;

    ScriptValue returnValue = callback->Invoke(context_->ctx(), ScriptValue::Empty(context_->ctx()), 0, nullptr);

    if (returnValue.IsException()) {
      context_->HandleException(&returnValue);
    }
  } else if (auto* callback = DynamicTo<WebFNativeFunction>(callback_.get())) {
    callback->Invoke(context_, 0, nullptr);
  }
}

void DOMTimer::Terminate() {
  callback_ = nullptr;
  status_ = TimerStatus::kTerminated;
}

void DOMTimer::setTimerId(int32_t timerId) {
  timer_id_ = timerId;
}

}  // namespace webf
