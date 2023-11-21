/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "scripted_animation_controller.h"
#include "document.h"
#include "frame_request_callback_collection.h"

namespace webf {

static void handleRAFTransientCallback(void* ptr, int32_t contextId, double highResTimeStamp, const char* errmsg) {
  auto* frame_callback = static_cast<FrameCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsContextValid())
    return;

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(frame_callback->context()->ctx(), "%s", errmsg);
    context->HandleException(&exception);
    return;
  }

  assert(frame_callback->status() == FrameCallback::FrameStatus::kPending);

  frame_callback->SetStatus(FrameCallback::FrameStatus::kExecuting);

  // Trigger callbacks.
  frame_callback->Fire(highResTimeStamp);

  frame_callback->SetStatus(FrameCallback::FrameStatus::kFinished);

  context->document()->script_animations()->callbackCollection()->RemoveFrameCallback(frame_callback->frameId());
}

static void handleRAFTransientCallbackWrapper(void* ptr,
                                              int32_t contextId,
                                              double highResTimeStamp,
                                              const char* errmsg) {
  auto* frame_callback = static_cast<FrameCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->PostToJs(
      context->is_dedicated(), contextId, webf::handleRAFTransientCallback, ptr, contextId, highResTimeStamp, errmsg);
}

uint32_t ScriptAnimationController::RegisterFrameCallback(const std::shared_ptr<FrameCallback>& frame_callback,
                                                          ExceptionState& exception_state) {
  auto* context = frame_callback->context();

  frame_callback->SetStatus(FrameCallback::FrameStatus::kPending);

  uint32_t requestId = context->dartMethodPtr()->requestAnimationFrame(
      context->is_dedicated(), frame_callback.get(), context->contextId(), handleRAFTransientCallbackWrapper);
  frame_callback->SetFrameId(requestId);
  // Register frame callback to collection.
  frame_request_callback_collection_.RegisterFrameCallback(requestId, frame_callback);

  return requestId;
}

void ScriptAnimationController::CancelFrameCallback(ExecutingContext* context,
                                                    uint32_t callback_id,
                                                    ExceptionState& exception_state) {
  context->dartMethodPtr()->cancelAnimationFrame(context->is_dedicated(), context->contextId(), callback_id);

  auto frame_callback = frame_request_callback_collection_.GetFrameCallback(callback_id);
  if (frame_callback != nullptr) {
    if (frame_callback->status() != FrameCallback::FrameStatus::kExecuting) {
      frame_request_callback_collection_.RemoveFrameCallback(callback_id);
    }
    frame_callback->SetStatus(FrameCallback::kCanceled);
  }
}

void ScriptAnimationController::Trace(GCVisitor* visitor) const {
  frame_request_callback_collection_.Trace(visitor);
}

}  // namespace webf
