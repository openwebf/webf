/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "script_state.h"
//#include "event_factory.h"
#include "html_element_factory.h"
//#include "names_installer.h"
#include "dart_isolate_context.h"

namespace webf {

thread_local std::atomic<int32_t> runningContexts{0};

ScriptState::ScriptState(DartIsolateContext* dart_context) : dart_isolate_context_(dart_context) {
  runningContexts++;
#if WEBF_QUICKJS_JS_ENGINE
  // Avoid stack overflow when running in multiple threads.
  ctx_ = JS_NewContext(dart_isolate_context_->runtime());
  InitializeBuiltInStrings(ctx_);
#elif WEBF_V8_JS_ENGINE
  ctx_ = v8::Context::New(dart_context->isolate());
  InitializeBuiltInStrings(dart_context->isolate());
#endif
}

#if WEBF_QUICKJS_JS_ENGINE
JSRuntime* ScriptState::runtime() {
  return dart_isolate_context_->runtime();
}
#elif WEBF_V8_JS_ENGINE
v8::Isolate* ScriptState::isolate() {
  return dart_isolate_context_->isolate();
}
#endif

#if WEBF_QUICKJS_JS_ENGINE
ScriptState::~ScriptState() {
  ctx_invalid_ = true;
  JSRuntime* rt = JS_GetRuntime(ctx_);
  JS_TurnOnGC(rt);
  JS_FreeContext(ctx_);

  // Run GC to clean up remaining objects about m_ctx;
  JS_RunGC(rt);

  ctx_ = nullptr;
}

#elif WEBF_V8_JS_ENGINE
ScriptState::~ScriptState() {
  ctx_invalid_ = true;
}
#endif

}  // namespace webf
