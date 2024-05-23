/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/platform/script_state.h"
#include "bindings/v8/platform/heap/garbage_collected.h"
#include "bindings/v8/platform/v8_per_context_data.h"

namespace webf {

ScriptState::CreateCallback ScriptState::s_create_callback_ = nullptr;

// static
void ScriptState::SetCreateCallback(CreateCallback create_callback) {
  assert(create_callback);
  assert(!s_create_callback_);
  s_create_callback_ = create_callback;
}

// static
ScriptState* ScriptState::Create(v8::Local<v8::Context> context,
                                 ExecutionContext* execution_context) {
  return s_create_callback_(context, execution_context);
}

ScriptState::ScriptState(v8::Local<v8::Context> context,
                         ExecutionContext* execution_context)
    : isolate_(context->GetIsolate()),
      context_(isolate_, context),
      per_context_data_(MakeGarbageCollected<V8PerContextData>(context)) {
  context_.SetWeak(this, &OnV8ContextCollectedCallback);
  context->SetAlignedPointerInEmbedderData(kV8ContextPerContextDataIndex, this);
//  RendererResourceCoordinator::Get()->OnScriptStateCreated(this,
//                                                           execution_context);
}

ScriptState::~ScriptState() {
  assert(!per_context_data_);
  assert(context_.IsEmpty());
//  InstanceCounters::DecrementCounter(
//      InstanceCounters::kDetachedScriptStateCounter);
//  RendererResourceCoordinator::Get()->OnScriptStateDestroyed(this);
}

void ScriptState::Trace(Visitor* visitor) const {
  visitor->Trace(per_context_data_);
}

void ScriptState::DetachGlobalObject() {
  assert(!context_.IsEmpty());
  GetContext()->DetachGlobal();
}

void ScriptState::DisposePerContextData() {
  per_context_data_->Dispose();
  per_context_data_ = nullptr;
//  InstanceCounters::IncrementCounter(
//      InstanceCounters::kDetachedScriptStateCounter);
//  RendererResourceCoordinator::Get()->OnScriptStateDetached(this);
}

void ScriptState::DissociateContext() {
  assert(!per_context_data_);

  // On a worker thread we tear down V8's isolate without running a GC.
  // Alternately we manually clear all references between V8 and Blink, and run
  // operations that should have been invoked by weak callbacks if a GC were
  // run.

  v8::HandleScope scope(GetIsolate());
  // Cut the reference from V8 context to ScriptState.
  GetContext()->SetAlignedPointerInEmbedderData(kV8ContextPerContextDataIndex,
                                                nullptr);
  reference_from_v8_context_.Clear();

  // Cut the reference from ScriptState to V8 context.
  context_.Clear();
}

void ScriptState::OnV8ContextCollectedCallback(
    const v8::WeakCallbackInfo<ScriptState>& data) {
  data.GetParameter()->reference_from_v8_context_.Clear();
  data.GetParameter()->context_.Clear();
}

}  // namespace webf