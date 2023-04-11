/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "scripted_animation_controller.h"
#include "frame_request_callback_collection.h"
#include "document.h"

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

  frame_callback->SetStatus(FrameCallback::FrameStatus::kExecuting);

  // Trigger callbacks.
  frame_callback->Fire(highResTimeStamp);

  frame_callback->SetStatus(FrameCallback::FrameStatus::kFinished);

  context->document()->script_animations()->callbackCollection()->RemoveFrameCallback(frame_callback->frameId());
}

uint32_t ScriptAnimationController::RegisterFrameCallback(const std::shared_ptr<FrameCallback>& frame_callback,
                                                          ExceptionState& exception_state) {
  auto* context = frame_callback->context();

  if (context->dartMethodPtr()->requestAnimationFrame == nullptr) {
    exception_state.ThrowException(
        context->ctx(), ErrorType::InternalError,
        "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.");
    return -1;
  }

  frame_callback->SetStatus(FrameCallback::FrameStatus::kPending);

  uint32_t requestId = context->dartMethodPtr()->requestAnimationFrame(frame_callback.get(), context->contextId(),
                                                                       handleRAFTransientCallback);

  // Register frame callback to collection.
  frame_request_callback_collection_.RegisterFrameCallback(requestId, frame_callback);

  return requestId;
}

void ScriptAnimationController::CancelFrameCallback(ExecutingContext* context,
                                                    uint32_t callback_id,
                                                    ExceptionState& exception_state) {
  if (context->dartMethodPtr()->cancelAnimationFrame == nullptr) {
    exception_state.ThrowException(
        context->ctx(), ErrorType::InternalError,
        "Failed to execute 'cancelAnimationFrame': dart method (cancelAnimationFrame) is not registered.");
    return;
  }

  context->dartMethodPtr()->cancelAnimationFrame(context->contextId(), callback_id);

  auto frame_callback = frame_request_callback_collection_.GetFrameCallback(callback_id);
  if (frame_callback != nullptr) {
    if (frame_callback->status() == FrameCallback::FrameStatus::kExecuting) {
      frame_callback->SetStatus(FrameCallback::kCanceled);
    } else {
      frame_request_callback_collection_.RemoveFrameCallback(callback_id);
    }
  }
}

void ScriptAnimationController::Trace(GCVisitor* visitor) const {
  frame_request_callback_collection_.Trace(visitor);
}

}  // namespace webf
