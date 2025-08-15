/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "scripted_animation_controller.h"
#include "document.h"
#include "foundation/native_string.h"
#include "foundation/native_value_converter.h"
#include "foundation/ui_command_buffer.h"
#include "frame_request_callback_collection.h"

namespace webf {

static void handleRAFTransientCallback(void* ptr, double contextId, double highResTimeStamp, char* errmsg) {
  auto* frame_callback = static_cast<FrameCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsContextValid())
    return;

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(frame_callback->context()->ctx(), "%s", errmsg);
    context->HandleException(&exception);
    dart_free(errmsg);
    return;
  }

  if (frame_callback->status() == FrameCallback::FrameStatus::kCanceled) {
    context->document()->script_animations()->callbackCollection()->RemoveFrameCallback(frame_callback->frameId());
    return;
  }

  assert(frame_callback->status() == FrameCallback::FrameStatus::kPending);

  frame_callback->SetStatus(FrameCallback::FrameStatus::kExecuting);

  frame_callback->Fire(highResTimeStamp);

  frame_callback->SetStatus(FrameCallback::FrameStatus::kFinished);

  context->document()->script_animations()->callbackCollection()->RemoveFrameCallback(frame_callback->frameId());
}

static void handleRAFTransientCallbackWrapper(void* ptr, double contextId, double highResTimeStamp, char* errmsg) {
  auto* frame_callback = static_cast<FrameCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->PostToJs(
      context->isDedicated(), contextId, webf::handleRAFTransientCallback, ptr, contextId, highResTimeStamp, errmsg);
}

uint32_t ScriptAnimationController::RegisterFrameCallback(const std::shared_ptr<FrameCallback>& frame_callback,
                                                          ExceptionState& exception_state) {
  auto* context = frame_callback->context();

  frame_callback->SetStatus(FrameCallback::FrameStatus::kPending);

  // Generate request id on C++ side.
  uint32_t requestId = next_frame_id_++;
  frame_callback->SetFrameId(requestId);
  // Register frame callback to collection for later invocation/cancellation.
  frame_request_callback_collection_.RegisterFrameCallback(requestId, frame_callback);

  // Package the request id as a UTF-16 string for UICommand args_01.
  std::string id_str = std::to_string(requestId);

  // Enqueue a UICommand to request RAF on the UI side.
  // nativePtr: callback context (FrameCallback*)
  // nativePtr2: function pointer to invoke when frame fires (AsyncRAFCallback)
  context->uiCommandBuffer()->AddCommand(UICommand::kRequestAnimationFrame,
                                         AtomicString::CreateFromUTF8(id_str).ToNativeString(), frame_callback.get(),
                                         reinterpret_cast<void*>(handleRAFTransientCallbackWrapper));

  return requestId;
}

void ScriptAnimationController::CancelFrameCallback(ExecutingContext* context,
                                                    uint32_t callback_id,
                                                    ExceptionState& exception_state) {
  auto frame_callback = frame_request_callback_collection_.GetFrameCallback(callback_id);
  if (frame_callback != nullptr) {
    frame_callback->SetStatus(FrameCallback::kCanceled);
  }
}

void ScriptAnimationController::Trace(GCVisitor* visitor) const {
  frame_request_callback_collection_.Trace(visitor);
}

}  // namespace webf
