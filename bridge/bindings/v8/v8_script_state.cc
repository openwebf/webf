/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "v8_script_state.h"
#include "v8_per_context_data.h"

namespace webf {

    V8ScriptState::CreateCallback V8ScriptState::s_create_callback_ = nullptr;

// static
    void V8ScriptState::SetCreateCallback(CreateCallback create_callback) {
        WEBF_CHECK(create_callback);
        WEBF_CHECK(!s_create_callback_);
        s_create_callback_ = create_callback;
    }

// static
    V8ScriptState* V8ScriptState::Create(v8::Local<v8::Context> context,
                                     ExecutionContext* execution_context) {
        return s_create_callback_(context, execution_context);
    }

    V8ScriptState::V8ScriptState(v8::Local<v8::Context> context,
                             ExecutionContext* execution_context)
            : isolate_(context->GetIsolate()),
              context_(isolate_, context),
              per_context_data_(MakeGarbageCollected<V8PerContextData>(context)) {
        context_.SetWeak(this, &OnV8ContextCollectedCallback);
        context->SetAlignedPointerInEmbedderData(kV8ContextPerContextDataIndex, this);
        /*TODO check RendererResourceCoordinator
        RendererResourceCoordinator::Get()->OnScriptStateCreated(this,
                                                                 execution_context);
        */
    }

    V8ScriptState::~V8ScriptState() {
        WEBF_CHECK(!per_context_data_);
        WEBF_CHECK(context_.IsEmpty());
        /*TODO check InstanceCounters
        InstanceCounters::DecrementCounter(
                InstanceCounters::kDetachedScriptStateCounter);
        RendererResourceCoordinator::Get()->OnScriptStateDestroyed(this);
         */
    }

    void V8ScriptState::Trace(Visitor* visitor) const {
        visitor->Trace(per_context_data_);
    }

    void V8ScriptState::DetachGlobalObject() {
        WEBF_CHECK(!context_.IsEmpty());
        GetContext()->DetachGlobal();
    }

    void V8ScriptState::DisposePerContextData() {
        per_context_data_->Dispose();
        per_context_data_ = nullptr;
        /*TODO check InstanceCounters
        InstanceCounters::IncrementCounter(
                InstanceCounters::kDetachedScriptStateCounter);
        RendererResourceCoordinator::Get()->OnScriptStateDetached(this);
         */
    }

    void V8ScriptState::DissociateContext() {
        WEBF_CHECK(!per_context_data_);

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

    void V8ScriptState::OnV8ContextCollectedCallback(
            const v8::WeakCallbackInfo<V8ScriptState>& data) {
        data.GetParameter()->reference_from_v8_context_.Clear();
        data.GetParameter()->context_.Clear();
    }

}  // namespace webf
