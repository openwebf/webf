/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

#include "script_idle_task_controller.h"
#include "core/executing_context.h"
#include "core/frame/window.h"
#include "qjs_idle_deadline.h"

namespace webf {

std::shared_ptr<IdleCallback> IdleCallback::Create(ExecutingContext* context,
                                                   const std::shared_ptr<QJSFunction>& callback) {
  return std::make_shared<IdleCallback>(context, callback);
}

IdleCallback::IdleCallback(ExecutingContext* context, std::shared_ptr<QJSFunction> callback)
    : context_(context), callback_(std::move(callback)) {}

void IdleCallback::Fire(double remaining_time) {
  if (callback_ == nullptr)
    return;

  JSContext* ctx = context_->ctx();
  MemberMutationScope member_mutation_scope{context_};

  auto* idle_deadline = MakeGarbageCollected<IdleDeadline>(context_, remaining_time);
  ScriptValue arguments[] = {idle_deadline->ToValue()};

  ScriptValue return_value = callback_->Invoke(ctx, ScriptValue::Empty(ctx), 1, arguments);

  context_->DrainMicrotasks();
  if (return_value.IsException()) {
    context_->HandleException(&return_value);
  }
}

void IdleCallback::Trace(GCVisitor* visitor) const {
  callback_->Trace(visitor);
}

void IdleCallbackCollection::RegisterIdleCallback(uint32_t callback_id,
                                                  const std::shared_ptr<IdleCallback>& frame_callback) {
  assert(idle_callbacks_.count(callback_id) == 0);
  idle_callbacks_[callback_id] = frame_callback;
}

void IdleCallbackCollection::RemoveIdleCallback(uint32_t callback_id) {
  if (idle_callbacks_.count(callback_id) == 0)
    return;
  idle_callbacks_.erase(callback_id);
}

std::shared_ptr<IdleCallback> IdleCallbackCollection::GetIdleCallback(uint32_t callback_id) {
  if (idle_callbacks_.count(callback_id) == 0)
    return nullptr;
  return idle_callbacks_[callback_id];
}

void IdleCallbackCollection::Trace(GCVisitor* visitor) const {
  for (auto& entry : idle_callbacks_) {
    entry.second->Trace(visitor);
  }
}

static void handleRequestIdleCallback(void* ptr, double contextId, double remaining_time) {
  auto* frame_callback = static_cast<IdleCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsContextValid())
    return;

  if (frame_callback->status() == IdleCallback::IdleStatus::kCanceled) {
    context->window()->script_idle_task()->callbackCollection()->RemoveIdleCallback(frame_callback->frameId());
    return;
  }

  context->dartIsolateContext()->profiler()->StartTrackAsyncEvaluation();
  context->dartIsolateContext()->profiler()->StartTrackSteps("handleRAFTransientCallback");

  assert(frame_callback->status() == IdleCallback::IdleStatus::kPending);

  frame_callback->SetStatus(IdleCallback::IdleStatus::kExecuting);

  frame_callback->Fire(remaining_time);

  frame_callback->SetStatus(IdleCallback::IdleStatus::kFinished);

  context->window()->script_idle_task()->callbackCollection()->RemoveIdleCallback(frame_callback->frameId());

  context->dartIsolateContext()->profiler()->FinishTrackSteps();
  context->dartIsolateContext()->profiler()->FinishTrackAsyncEvaluation();
}

static void handleRequestIdleCallbackWrapper(void* ptr, double contextId, double remaining_time) {
  auto* p_idle_callback = static_cast<IdleCallback*>(ptr);
  auto* context = p_idle_callback->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->PostToJs(context->isDedicated(), contextId, handleRequestIdleCallback,
                                                        ptr, contextId, remaining_time);
}

uint32_t ScriptedIdleTaskController::RegisterIdleCallback(const std::shared_ptr<IdleCallback>& idle_callback,
                                                          double timeout) {
  auto* context = idle_callback->context();

  idle_callback->SetStatus(IdleCallback::IdleStatus::kPending);

  size_t ui_command_size = context->uiCommandBuffer()->size();
  uint32_t requestId = context->dartMethodPtr()->requestIdleCallback(
      context->isDedicated(), idle_callback.get(), context->contextId(), timeout, ui_command_size, handleRequestIdleCallbackWrapper);
  idle_callback->SetFrameId(requestId);
  // Register frame callback to collection.
  idle_callback_collection_.RegisterIdleCallback(requestId, idle_callback);

  return requestId;
}

void ScriptedIdleTaskController::CancelIdleCallback(webf::ExecutingContext* context,
                                                    uint32_t callback_id) {
  auto frame_callback = idle_callback_collection_.GetIdleCallback(callback_id);
  if (frame_callback != nullptr) {
    frame_callback->SetStatus(IdleCallback::kCanceled);
  }
}

void ScriptedIdleTaskController::Trace(webf::GCVisitor* visitor) const {
  idle_callback_collection_.Trace(visitor);
}

}  // namespace webf
