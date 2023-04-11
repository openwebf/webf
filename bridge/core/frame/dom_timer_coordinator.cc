/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "dom_timer_coordinator.h"
#include "core/dart_methods.h"
#include "core/executing_context.h"
#include "dom_timer.h"

#if UNIT_TEST
#include "webf_test_env.h"
#endif

namespace webf {

static void handleTimerCallback(DOMTimer* timer, const char* errmsg) {
  auto* context = timer->context();

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(timer->context()->ctx(), "%s", errmsg);
    context->HandleException(&exception);
    return;
  }

  // Trigger timer callbacks.
  timer->Fire();

  // Executing pending async jobs.
  context->DrainPendingPromiseJobs();
}

static void handleTransientCallback(void* ptr, int32_t context_id, const char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = timer->context();

  if (!context->IsContextValid())
    return;

  handleTimerCallback(timer, errmsg);

  context->Timers()->removeTimeoutById(timer->timerId());
}

void DOMTimerCoordinator::installNewTimer(ExecutingContext* context,
                                          int32_t timer_id,
                                          std::shared_ptr<DOMTimer> timer) {
  active_timers_[timer_id] = timer;
}

void DOMTimerCoordinator::removeTimeoutById(int32_t timer_id) {
  if (active_timers_.count(timer_id) == 0)
    return;
  auto timer = active_timers_[timer_id];
  assert(timer->status() == DOMTimer::TimerStatus::kFinished);
  active_timers_.erase(timer_id);
}

void DOMTimerCoordinator::forceStopTimeoutById(int32_t timer_id) {
  if (active_timers_.count(timer_id) == 0) {
    return;
  }
  auto timer = active_timers_[timer_id];

  if (timer->status() == DOMTimer::TimerStatus::kExecuting) {
    timer->SetStatus(DOMTimer::TimerStatus::kCanceled);
  } else {
    removeTimeoutById(timer->timerId());
  }
}

std::shared_ptr<DOMTimer> DOMTimerCoordinator::getTimerById(int32_t timer_id) {
  if (active_timers_.count(timer_id) == 0)
    return nullptr;
  return active_timers_[timer_id];
}

}  // namespace webf
