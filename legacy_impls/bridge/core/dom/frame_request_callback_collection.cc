/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "frame_request_callback_collection.h"

#include <utility>
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

std::shared_ptr<FrameCallback> FrameCallback::Create(ExecutingContext* context,
                                                     const std::shared_ptr<Function>& callback) {
  return std::make_shared<FrameCallback>(context, callback);
}

FrameCallback::FrameCallback(ExecutingContext* context, std::shared_ptr<Function> callback)
    : context_(context), callback_(std::move(callback)) {}

void FrameCallback::Fire(double highResTimeStamp) {
  if (callback_ == nullptr)
    return;

  if (auto* callback = DynamicTo<QJSFunction>(callback_.get())) {
    JSContext* ctx = context_->ctx();

    ScriptValue arguments[] = {ScriptValue(ctx, highResTimeStamp)};

    ScriptValue return_value = callback->Invoke(ctx, ScriptValue::Empty(ctx), 1, arguments);

    context_->DrainMicrotasks();
    if (return_value.IsException()) {
      context_->HandleException(&return_value);
    }
  } else if (auto* callback = DynamicTo<WebFNativeFunction>(callback_.get())) {
    NativeValue time = Native_NewFloat64(highResTimeStamp);
    callback->Invoke(context_, 1, &time);
    context_->RunRustFutureTasks();
  }
}

void FrameCallback::Trace(GCVisitor* visitor) const {
  if (auto* callback = DynamicTo<QJSFunction>(callback_.get())) {
    callback->Trace(visitor);
  }
}

void FrameRequestCallbackCollection::RegisterFrameCallback(uint32_t callback_id,
                                                           const std::shared_ptr<FrameCallback>& frame_callback) {
  assert(frame_callbacks_.count(callback_id) == 0);
  frame_callbacks_[callback_id] = frame_callback;
}

void FrameRequestCallbackCollection::RemoveFrameCallback(uint32_t callback_id) {
  if (frame_callbacks_.count(callback_id) == 0)
    return;
  frame_callbacks_.erase(callback_id);
}

std::shared_ptr<FrameCallback> FrameRequestCallbackCollection::GetFrameCallback(uint32_t callback_id) {
  if (frame_callbacks_.count(callback_id) == 0)
    return nullptr;
  return frame_callbacks_[callback_id];
}

void FrameRequestCallbackCollection::Trace(GCVisitor* visitor) const {
  for (auto& entry : frame_callbacks_) {
    entry.second->Trace(visitor);
  }
}

}  // namespace webf
