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

std::shared_ptr<DOMTimer> DOMTimer::create(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback) {
  return std::make_shared<DOMTimer>(context, callback);
}

DOMTimer::DOMTimer(ExecutingContext* context, std::shared_ptr<QJSFunction> callback)
    : context_(context), callback_(std::move(callback)), status_(TimerStatus::kPending) {}

void DOMTimer::Fire() {
  if (!callback_->IsFunction(context_->ctx()))
    return;

  ScriptValue returnValue = callback_->Invoke(context_->ctx(), ScriptValue::Empty(context_->ctx()), 0, nullptr);

  if (returnValue.IsException()) {
    context_->HandleException(&returnValue);
  }
}

void DOMTimer::setTimerId(int32_t timerId) {
  timerId_ = timerId;
}

}  // namespace webf
