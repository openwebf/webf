/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "executing_context.h"

#include <utility>
#include "bindings/qjs/converter_impl.h"
#include "built_in_string.h"
#include "core/dom/document.h"
#include "core/events/error_event.h"
#include "core/events/promise_rejection_event.h"
#include "event_type_names.h"
#include "foundation/logging.h"
#include "polyfill.h"
#include "qjs_window.h"
#include "timing/performance.h"

namespace webf {

static std::atomic<int32_t> context_unique_id{0};

#define MAX_JS_CONTEXT 1024
bool valid_contexts[MAX_JS_CONTEXT];
std::atomic<uint32_t> running_context_list{0};

ExecutingContext::ExecutingContext(int32_t contextId,
                                   JSExceptionHandler handler,
                                   void* owner,
                                   const uint64_t* dart_methods,
                                   int32_t dart_methods_length)
    : context_id_(contextId),
      handler_(std::move(handler)),
      owner_(owner),
      unique_id_(context_unique_id++),
      is_context_valid_(true),
      dart_method_ptr_(std::make_unique<DartMethodPointer>(dart_methods, dart_methods_length)) {
  //  #if ENABLE_PROFILE
  //    auto jsContextStartTime =
  //        std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch())
  //            .count();
  //    auto nativePerformance = Performance::instance(context_)->m_nativePerformance;
  //    nativePerformance.mark(PERF_JS_CONTEXT_INIT_START, jsContextStartTime);
  //    nativePerformance.mark(PERF_JS_CONTEXT_INIT_END);
  //    nativePerformance.mark(PERF_JS_NATIVE_METHOD_INIT_START);
  //  #endif

  // @FIXME: maybe contextId will larger than MAX_JS_CONTEXT
  valid_contexts[contextId] = true;
  if (contextId > running_context_list)
    running_context_list = contextId;

  time_origin_ = std::chrono::system_clock::now();

  JSContext* ctx = script_state_.ctx();
  global_object_ = JS_GetGlobalObject(script_state_.ctx());

  JS_SetContextOpaque(ctx, this);
  JS_SetHostPromiseRejectionTracker(script_state_.runtime(), promiseRejectTracker, nullptr);

  // Register all built-in native bindings.
  InstallBindings(this);

  // Install document.
  InstallDocument();

  // Binding global object and window.
  InstallGlobal();

  // Install performance
  InstallPerformance();

  //#if ENABLE_PROFILE
  //  nativePerformance.mark(PERF_JS_NATIVE_METHOD_INIT_END);
  //  nativePerformance.mark(PERF_JS_POLYFILL_INIT_START);
  //#endif

  initWebFPolyFill(this);

  for (auto& p : pluginByteCode) {
    EvaluateByteCode(p.second.bytes, p.second.length);
  }

  //#if ENABLE_PROFILE
  //  nativePerformance.mark(PERF_JS_POLYFILL_INIT_END);
  //#endif
}

ExecutingContext::~ExecutingContext() {
  is_context_valid_ = false;
  valid_contexts[context_id_] = false;

  // Check if current context have unhandled exceptions.
  JSValue exception = JS_GetException(script_state_.ctx());
  if (JS_IsObject(exception) || JS_IsException(exception)) {
    // There must be bugs in native functions from call stack frame. Someone needs to fix it if throws.
    ReportError(exception);
    assert_m(false, "Unhandled exception found when Dispose JSContext.");
  }

  JS_FreeValue(script_state_.ctx(), global_object_);

  // Free active wrappers.
  for (auto& active_wrapper : active_wrappers_) {
    JS_FreeValue(ctx(), active_wrapper->ToQuickJSUnsafe());
  }
}

ExecutingContext* ExecutingContext::From(JSContext* ctx) {
  return static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
}

bool ExecutingContext::EvaluateJavaScript(const uint16_t* code,
                                          size_t codeLength,
                                          const char* sourceURL,
                                          int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), codeLength));
  JSValue result = JS_Eval(script_state_.ctx(), utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainPendingPromiseJobs();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateJavaScript(const char16_t* code, size_t length, const char* sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), length));
  JSValue result = JS_Eval(script_state_.ctx(), utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainPendingPromiseJobs();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateJavaScript(const char* code, size_t codeLength, const char* sourceURL, int startLine) {
  JSValue result = JS_Eval(script_state_.ctx(), code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainPendingPromiseJobs();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateByteCode(uint8_t* bytes, size_t byteLength) {
  JSValue obj, val;
  obj = JS_ReadObject(script_state_.ctx(), bytes, byteLength, JS_READ_OBJ_BYTECODE);
  if (!HandleException(&obj))
    return false;
  val = JS_EvalFunction(script_state_.ctx(), obj);
  if (!HandleException(&val))
    return false;
  JS_FreeValue(script_state_.ctx(), val);
  return true;
}

bool ExecutingContext::IsContextValid() const {
  return is_context_valid_;
}

bool ExecutingContext::IsCtxValid() const {
  return script_state_.Invalid();
}

void* ExecutingContext::owner() {
  return owner_;
}

bool ExecutingContext::HandleException(JSValue* exc) {
  if (JS_IsException(*exc)) {
    JSValue error = JS_GetException(script_state_.ctx());
    MemberMutationScope scope{this};
    DispatchGlobalErrorEvent(this, error);
    JS_FreeValue(script_state_.ctx(), error);
    return false;
  }

  return true;
}

bool ExecutingContext::HandleException(ScriptValue* exc) {
  JSValue value = exc->QJSValue();
  return HandleException(&value);
}

bool ExecutingContext::HandleException(ExceptionState& exception_state) {
  if (exception_state.HasException()) {
    JSValue error = JS_GetException(ctx());
    ReportError(error);
    JS_FreeValue(ctx(), error);
    return false;
  }
  return true;
}

JSValue ExecutingContext::Global() {
  return global_object_;
}

JSContext* ExecutingContext::ctx() {
  assert(IsCtxValid());
  return script_state_.ctx();
}

void ExecutingContext::ReportError(JSValueConst error) {
  JSContext* ctx = script_state_.ctx();
  if (!JS_IsError(ctx, error))
    return;

  JSValue messageValue = JS_GetPropertyStr(ctx, error, "message");
  JSValue errorTypeValue = JS_GetPropertyStr(ctx, error, "name");
  const char* title = JS_ToCString(ctx, messageValue);
  const char* type = JS_ToCString(ctx, errorTypeValue);
  const char* stack = nullptr;
  JSValue stackValue = JS_GetPropertyStr(ctx, error, "stack");
  if (!JS_IsUndefined(stackValue)) {
    stack = JS_ToCString(ctx, stackValue);
  }

  uint32_t messageLength = strlen(type) + strlen(title);
  if (stack != nullptr) {
    messageLength += 4 + strlen(stack);
    char message[messageLength];
    sprintf(message, "%s: %s\n%s", type, title, stack);
    handler_(this, message);
  } else {
    messageLength += 3;
    char message[messageLength];
    sprintf(message, "%s: %s", type, title);
    handler_(this, message);
  }

  JS_FreeValue(ctx, errorTypeValue);
  JS_FreeValue(ctx, messageValue);
  JS_FreeValue(ctx, stackValue);
  JS_FreeCString(ctx, title);
  JS_FreeCString(ctx, stack);
  JS_FreeCString(ctx, type);
}

void ExecutingContext::DrainPendingPromiseJobs() {
  // should executing pending promise jobs.
  JSContext* pctx;
  int finished = JS_ExecutePendingJob(script_state_.runtime(), &pctx);
  while (finished != 0) {
    finished = JS_ExecutePendingJob(script_state_.runtime(), &pctx);
    if (finished == -1) {
      break;
    }
  }

  // Throw error when promise are not handled.
  rejected_promises_.Process(this);
}

void ExecutingContext::DefineGlobalProperty(const char* prop, JSValue value) {
  JSAtom atom = JS_NewAtom(script_state_.ctx(), prop);
  JS_SetProperty(script_state_.ctx(), global_object_, atom, value);
  JS_FreeAtom(script_state_.ctx(), atom);
}

ExecutionContextData* ExecutingContext::contextData() {
  return &context_data_;
}

uint8_t* ExecutingContext::DumpByteCode(const char* code,
                                        uint32_t codeLength,
                                        const char* sourceURL,
                                        size_t* bytecodeLength) {
  JSValue object =
      JS_Eval(script_state_.ctx(), code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL | JS_EVAL_FLAG_COMPILE_ONLY);
  bool success = HandleException(&object);
  if (!success)
    return nullptr;
  uint8_t* bytes = JS_WriteObject(script_state_.ctx(), bytecodeLength, object, JS_WRITE_OBJ_BYTECODE);
  JS_FreeValue(script_state_.ctx(), object);
  return bytes;
}

void ExecutingContext::DispatchGlobalErrorEvent(ExecutingContext* context, JSValueConst error) {
  ExceptionState exceptionState;

  auto error_init = ErrorEventInit::Create(context->ctx(), error, exceptionState);
  error_init->setError(Converter<IDLAny>::FromValue(context->ctx(), error, exceptionState));
  auto* error_event = ErrorEvent::Create(context, event_type_names::kerror, error_init, exceptionState);

  context->DispatchErrorEvent(error_event);
}

static void DispatchPromiseRejectionEvent(const AtomicString& event_type,
                                          ExecutingContext* context,
                                          JSValueConst promise,
                                          JSValueConst reason) {
  ExceptionState exception_state;

  auto event_init = PromiseRejectionEventInit::Create();
  event_init->setPromise(Converter<IDLAny>::FromValue(context->ctx(), promise, exception_state));
  event_init->setReason(Converter<IDLAny>::FromValue(context->ctx(), reason, exception_state));
  auto event = PromiseRejectionEvent::Create(context, event_type, event_init, exception_state);

  context->window()->dispatchEvent(event, exception_state);
  if (exception_state.HasException()) {
    context->ReportError(reason);
  }
}

void ExecutingContext::FlushUICommand() {
  if (!uiCommandBuffer()->empty()) {
    dartMethodPtr()->flushUICommand(context_id_);
  }
}

void ExecutingContext::DispatchErrorEvent(ErrorEvent* error_event) {
  if (in_dispatch_error_event_) {
    return;
  }

  DispatchErrorEventInterval(error_event);
  ReportErrorEvent(error_event);
}

void ExecutingContext::DispatchErrorEventInterval(ErrorEvent* error_event) {
  assert(!in_dispatch_error_event_);
  in_dispatch_error_event_ = true;
  ExceptionState exception_state;
  window_->dispatchEvent(error_event, exception_state);
  in_dispatch_error_event_ = false;

  if (exception_state.HasException()) {
    JSValue error = JS_GetException(ctx());
    ReportError(error);
    JS_FreeValue(ctx(), error);
  }
}

void ExecutingContext::ReportErrorEvent(ErrorEvent* error_event) {
  ReportError(error_event->error().QJSValue());
}

void ExecutingContext::DispatchGlobalUnhandledRejectionEvent(ExecutingContext* context,
                                                             JSValueConst promise,
                                                             JSValueConst reason) {
  // Trigger unhandledRejection event.
  DispatchPromiseRejectionEvent(event_type_names::kunhandledrejection, context, promise, reason);
}

void ExecutingContext::DispatchGlobalRejectionHandledEvent(ExecutingContext* context, JSValue promise, JSValue error) {
  // Trigger rejectionhandled event.
  DispatchPromiseRejectionEvent(event_type_names::krejectionhandled, context, promise, error);
}

std::unordered_map<std::string, NativeByteCode> ExecutingContext::pluginByteCode{};

void ExecutingContext::promiseRejectTracker(JSContext* ctx,
                                            JSValue promise,
                                            JSValue reason,
                                            int is_handled,
                                            void* opaque) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
  // The unhandledrejection event is the promise-equivalent of the global error event, which is fired for uncaught
  // exceptions. Because a rejected promise could be handled after the fact, by attaching catch(onRejected) or
  // then(onFulfilled, onRejected) to it, the additional rejectionhandled event is needed to indicate that a promise
  // which was previously rejected should no longer be considered unhandled.
  if (is_handled) {
    context->rejected_promises_.TrackHandledPromiseRejection(context, promise, reason);
  } else {
    context->rejected_promises_.TrackUnhandledPromiseRejection(context, promise, reason);
  }
}

DOMTimerCoordinator* ExecutingContext::Timers() {
  return &timers_;
}

ModuleListenerContainer* ExecutingContext::ModuleListeners() {
  return &module_listener_container_;
}

ModuleContextCoordinator* ExecutingContext::ModuleContexts() {
  return &module_contexts_;
}

void ExecutingContext::SetMutationScope(MemberMutationScope& mutation_scope) {
  // MemberMutationScope may be called by other MemberMutationScope in the call stack.
  // Should save the tree corresponding to the call stack.
  if (active_mutation_scope != nullptr) {
    mutation_scope.SetParent(active_mutation_scope);
  }
  active_mutation_scope = &mutation_scope;
}

void ExecutingContext::ClearMutationScope() {
  active_mutation_scope = active_mutation_scope->Parent();
}

void ExecutingContext::InstallDocument() {
  MemberMutationScope scope{this};
  document_ = MakeGarbageCollected<Document>(this);
  DefineGlobalProperty("document", document_->ToQuickJS());
}

void ExecutingContext::InstallPerformance() {
  MemberMutationScope scope{this};
  performance_ = MakeGarbageCollected<Performance>(this);
  DefineGlobalProperty("performance", performance_->ToQuickJS());
}

void ExecutingContext::InstallGlobal() {
  MemberMutationScope mutation_scope{this};
  window_ = MakeGarbageCollected<Window>(this);
  JS_SetPrototype(ctx(), Global(), window_->ToQuickJSUnsafe());
  JS_SetOpaque(Global(), window_);
}

void ExecutingContext::RegisterActiveScriptWrappers(ScriptWrappable* script_wrappable) {
  active_wrappers_.emplace_back(script_wrappable);
}

// An lock free context validator.
bool isContextValid(int32_t contextId) {
  if (contextId > running_context_list)
    return false;
  return valid_contexts[contextId];
}

}  // namespace webf
