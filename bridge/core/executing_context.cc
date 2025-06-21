/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "executing_context.h"
#include <sstream>
#include <vector>
#include <condition_variable>
#include <mutex>

#include <utility>
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/native_string_utils.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "built_in_string.h"
#include "core/bridge_polyfill.c"
#include "core/devtools/remote_object.h"
#include "core/devtools/devtools_bridge.h"
#include "core/dom/document.h"
#include "core/dom/mutation_observer.h"
#include "core/events/error_event.h"
#include "core/events/promise_rejection_event.h"
#include "event_type_names.h"
#include "foundation/logging.h"
#include "foundation/native_byte_data.h"
#include "foundation/native_value_converter.h"
#include "foundation/shared_ui_command.h"
#include "html/canvas/canvas_rendering_context_2d.h"
#include "html/custom/widget_element_shape.h"
#include "qjs_window.h"
#include "script_forbidden_scope.h"
#include "timing/performance.h"

namespace webf {

static std::atomic<int32_t> context_unique_id{0};

#define MAX_JS_CONTEXT 8192
thread_local std::unordered_map<double, bool> valid_contexts;
std::atomic<uint32_t> running_context_list{0};

ExecutingContext::ExecutingContext(DartIsolateContext* dart_isolate_context,
                                   bool is_dedicated,
                                   size_t sync_buffer_size,
                                   double context_id,
                                   NativeWidgetElementShape* native_widget_element_shape,
                                   int32_t shape_len,
                                   JSExceptionHandler handler,
                                   void* owner)
    : dart_isolate_context_(dart_isolate_context),
      context_id_(context_id),
      dart_error_report_handler_(std::move(handler)),
      owner_(owner),
      public_method_ptr_(std::make_unique<ExecutingContextWebFMethods>()),
      is_dedicated_(is_dedicated),
      unique_id_(context_unique_id++),
      is_context_valid_(true) {
  if (is_dedicated) {
    // Set up the sync command size for dedicated thread mode.
    // Bigger size introduce more ui consistence and lower size led to more high performance by the reason of
    // concurrency.
    ui_command_buffer_.ConfigureSyncCommandBufferSize(sync_buffer_size);
  }

  // @FIXME: maybe contextId will larger than MAX_JS_CONTEXT
  assert_m(valid_contexts[context_id] != true, "Conflict context found!");
  valid_contexts[context_id] = true;
  if (context_id > running_context_list)
    running_context_list = context_id;

  time_origin_ = std::chrono::system_clock::now();

  JSContext* ctx = script_state_.ctx();
  global_object_ = JS_GetGlobalObject(script_state_.ctx());

  JS_TurnOnGC(script_state_.runtime());
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
  InstallNativeLoader();

  // Set up ES module loader
  JS_SetModuleLoaderFunc(script_state_.runtime(), ModuleNormalizeName, ModuleLoader, this);

  // Init JavaScript Polyfill
  EvaluateByteCode(bridge_polyfill, bridge_polyfill_size);

  for (auto& p : plugin_byte_code) {
    EvaluateByteCode(p.second.bytes, p.second.length);
  }

  for (auto& p : plugin_string_code) {
    EvaluateJavaScript(p.second.c_str(), p.second.size(), p.first.c_str(), 0);
  }

  SetWidgetElementShape(native_widget_element_shape, shape_len);

  ui_command_buffer_.AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

  DrawCanvasElementIfNeeded();
  
  // Register this context for DevTools access
  devtools_internal::RegisterExecutingContext(this);
}

ExecutingContext::~ExecutingContext() {
  is_context_valid_ = false;
  valid_contexts[context_id_] = false;
  executing_context_status_->disposed = true;

  // Clear remote object registry for this context
  if (remote_object_registry_) {
    remote_object_registry_->ClearContext(this);
    remote_object_registry_.reset();  // Explicitly destroy the registry
  }
  
  // Unregister this context from DevTools access
  devtools_internal::UnregisterExecutingContext(this);

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

  for (auto& script_promise : active_pending_promises_) {
    script_promise->Reset();
  }
  active_pending_promises_.clear();

  for (auto& active_native_byte_data_context : active_native_byte_datas_) {
    JS_FreeValue(ctx(), active_native_byte_data_context->value);
  }
}

ExecutingContext* ExecutingContext::From(JSContext* ctx) {
  return static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
}

bool ExecutingContext::EvaluateJavaScript(const char* code,
                                          size_t code_len,
                                          uint8_t** parsed_bytecodes,
                                          uint64_t* bytecode_len,
                                          const char* sourceURL,
                                          int startLine) {
  if (ScriptForbiddenScope::IsScriptForbidden()) {
    return false;
  }

  // Validate input parameters
  if (code == nullptr || code_len == 0) {
    return true; // Empty script is not an error
  }

  // Basic validation for malformed content
  if (code_len > 100 * 1024 * 1024) { // 100MB limit
    WEBF_LOG(ERROR) << "JavaScript code exceeds maximum size limit";
    ExceptionState exception_state;
    exception_state.ThrowException(ctx(), ErrorType::RangeError, "Script size exceeds maximum limit");
    HandleException(exception_state);
    return false;
  }

  JSValue result;
  if (parsed_bytecodes == nullptr) {
    result = JS_Eval(script_state_.ctx(), code, code_len, sourceURL, JS_EVAL_TYPE_GLOBAL);
  } else {
    JSValue byte_object =
        JS_Eval(script_state_.ctx(), code, code_len, sourceURL, JS_EVAL_TYPE_GLOBAL | JS_EVAL_FLAG_COMPILE_ONLY);

    if (JS_IsException(byte_object)) {
      HandleException(&byte_object);
      return false;
    }

    size_t len;
    *parsed_bytecodes = JS_WriteObject(script_state_.ctx(), &len, byte_object, JS_WRITE_OBJ_BYTECODE);
    *bytecode_len = len;

    result = JS_EvalFunction(script_state_.ctx(), byte_object);
  }

  DrainMicrotasks();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);

  return success;
}

bool ExecutingContext::EvaluateJavaScript(const char16_t* code, size_t length, const char* sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), length));
  JSValue result = JS_Eval(script_state_.ctx(), utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainMicrotasks();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateModule(const char* code,
                                      size_t code_len,
                                      uint8_t** parsed_bytecodes,
                                      uint64_t* bytecode_len,
                                      const char* sourceURL,
                                      int startLine) {
  if (ScriptForbiddenScope::IsScriptForbidden()) {
    return false;
  }
  JSValue result;
  if (parsed_bytecodes == nullptr) {
    // For inline modules, we need to compile first to set up import.meta
    JSValue byte_object = JS_Eval(script_state_.ctx(), code, code_len, sourceURL, JS_EVAL_TYPE_MODULE | JS_EVAL_FLAG_COMPILE_ONLY);

    if (JS_IsException(byte_object)) {
      HandleException(&byte_object);
      return false;
    }

    // Set up import.meta for inline modules
    JSModuleDef* module_def = static_cast<JSModuleDef*>(JS_VALUE_GET_PTR(byte_object));
    SetupImportMeta(script_state_.ctx(), module_def, sourceURL, this);

    result = JS_EvalFunction(script_state_.ctx(), byte_object);
  } else {
    JSValue byte_object =
        JS_Eval(script_state_.ctx(), code, code_len, sourceURL, JS_EVAL_TYPE_MODULE | JS_EVAL_FLAG_COMPILE_ONLY);

    if (JS_IsException(byte_object)) {
      HandleException(&byte_object);
      return false;
    }

    // Set up import.meta for precompiled modules too
    JSModuleDef* module_def = static_cast<JSModuleDef*>(JS_VALUE_GET_PTR(byte_object));
    SetupImportMeta(script_state_.ctx(), module_def, sourceURL, this);

    size_t len;
    *parsed_bytecodes = JS_WriteObject(script_state_.ctx(), &len, byte_object, JS_WRITE_OBJ_BYTECODE);
    *bytecode_len = len;

    result = JS_EvalFunction(script_state_.ctx(), byte_object);
  }

  DrainMicrotasks();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);

  return success;
}

bool ExecutingContext::EvaluateJavaScript(const char* code, size_t codeLength, const char* sourceURL, int startLine) {
  JSValue result = JS_Eval(script_state_.ctx(), code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainMicrotasks();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateByteCode(const uint8_t* bytes, size_t byteLength) {
  // Validate input
  if (bytes == nullptr || byteLength == 0) {
    return true; // Empty bytecode is not an error
  }

  // Basic size validation
  if (byteLength > 100 * 1024 * 1024) { // 100MB limit
    ExceptionState exception_state;
    exception_state.ThrowException(ctx(), ErrorType::RangeError, "Bytecode size exceeds maximum limit");
    HandleException(exception_state);
    return false;
  }

  JSValue obj, val;
  obj = JS_ReadObject(script_state_.ctx(), bytes, byteLength, JS_READ_OBJ_BYTECODE);

  if (JS_IsException(obj)) {
    HandleException(&obj);
    return false;
  }

  val = JS_EvalFunction(script_state_.ctx(), obj);

  DrainMicrotasks();
  bool success = HandleException(&val);

  JS_FreeValue(script_state_.ctx(), val);
  return success;
}

bool ExecutingContext::IsContextValid() const {
  return is_context_valid_;
}

void ExecutingContext::SetContextInValid() {
  is_context_valid_ = false;
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

bool ExecutingContext ::HandleException(webf::ExceptionState& exception_state,
                                        char** rust_error_msg,
                                        uint32_t* rust_errmsg_len) {
  if (exception_state.HasException()) {
    JSValue error = JS_GetException(ctx());
    ReportError(error, rust_error_msg, rust_errmsg_len);
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

void ExecutingContext::ReportError(JSValue error) {
  ReportError(error, nullptr, nullptr);
}

void ExecutingContext::ReportError(JSValueConst error, char** rust_errmsg, uint32_t* rust_errmsg_length) {
  JSContext* ctx = script_state_.ctx();
  if (!JS_IsError(ctx, error))
    return;

  JSValue message_value = JS_GetPropertyStr(ctx, error, "message");
  JSValue error_type_value = JS_GetPropertyStr(ctx, error, "name");
  const char* title = JS_ToCString(ctx, message_value);
  const char* type = JS_ToCString(ctx, error_type_value);
  const char* stack = nullptr;
  JSValue stack_value = JS_GetPropertyStr(ctx, error, "stack");
  if (!JS_IsUndefined(stack_value)) {
    stack = JS_ToCString(ctx, stack_value);
  }

  uint32_t message_length = strlen(type) + strlen(title);
  char* message;
  if (stack != nullptr) {
    message_length += 4 + strlen(stack);
    message = (char*)dart_malloc(message_length * sizeof(char));
    snprintf(message, message_length, "%s: %s\n%s", type, title, stack);
  } else {
    message_length += 3;
    message = (char*)dart_malloc(message_length * sizeof(char));
    snprintf(message, message_length, "%s: %s", type, title);
  }

  // Report errmsg to rust side
  if (rust_errmsg != nullptr && rust_errmsg_length != nullptr) {
    *rust_errmsg = (char*)malloc(sizeof(char) * message_length);
    *rust_errmsg_length = message_length;
    memcpy(*rust_errmsg, message, sizeof(char) * message_length);
  } else {
    // Report errmsg to dart side
    dart_error_report_handler_(this, message);
  }

  JS_FreeValue(ctx, error_type_value);
  JS_FreeValue(ctx, message_value);
  JS_FreeValue(ctx, stack_value);
  JS_FreeCString(ctx, title);
  JS_FreeCString(ctx, stack);
  JS_FreeCString(ctx, type);
}

void ExecutingContext::DrainMicrotasks() {
  DrainPendingPromiseJobs();

  DrawCanvasElementIfNeeded();
  ui_command_buffer_.AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
}

namespace {

struct MicroTaskDeliver {
  MicrotaskCallback callback;
  void* data;
};

}  // namespace

void ExecutingContext::EnqueueMicrotask(MicrotaskCallback callback, void* data) {
  JSValue proxy_data = JS_NewObject(ctx());

  auto* deliver = new MicroTaskDeliver();
  deliver->data = data;
  deliver->callback = callback;

  JS_SetOpaque(proxy_data, deliver);

  JS_EnqueueJob(
      ctx(),
      [](JSContext* ctx, int argc, JSValueConst* argv) -> JSValue {
        auto* deliver = static_cast<MicroTaskDeliver*>(JS_GetOpaque(argv[0], JS_CLASS_OBJECT));
        deliver->callback(deliver->data);

        delete deliver;
        return JS_NULL;
      },
      1, &proxy_data);

  JS_FreeValue(ctx(), proxy_data);
}

int32_t ExecutingContext::AddRustFutureTask(const std::shared_ptr<WebFNativeFunction>& run_future_task,
                                            NativeLibraryMetaData* meta_data) {
  meta_data->unique_id_++;
  meta_data->callbacks.emplace_back(meta_data->unique_id_, run_future_task);
  return meta_data->unique_id_;
}

void ExecutingContext::RemoveRustFutureTask(int32_t callback_id, NativeLibraryMetaData* meta_data) {
  // Add the callback to the removed_callbacks list to avoid removing the callback during the iteration.
  meta_data->removed_callbacks.push_back(callback_id);
}

void ExecutingContext::RunRustFutureTasks() {
  for (auto& meta_data : native_library_meta_data_contaner_) {
    for (auto& callback : meta_data->callbacks) {
      callback.callback->Invoke(this, 0, nullptr);
    }

    if (meta_data->removed_callbacks.size() == 0) {
      continue;
    }

    for (auto& removed_callback : meta_data->removed_callbacks) {
      meta_data->callbacks.erase(std::remove_if(meta_data->callbacks.begin(), meta_data->callbacks.end(),
                                                [&](const NativeLibraryMetaDataCallback& callback) {
                                                  return callback.callback_id == removed_callback;
                                                }),
                                 meta_data->callbacks.end());
    }

    meta_data->removed_callbacks.clear();

    if (meta_data->callbacks.empty() && meta_data->load_context != nullptr) {
      meta_data->load_context->promise_resolver->Resolve(JS_NULL);
      meta_data->load_context->context->UnRegisterActiveScriptPromise(meta_data->load_context->promise_resolver.get());
      delete meta_data->load_context;
      meta_data->load_context = nullptr;
    } else {
      RunRustFutureTasks();
    }
  }
}

void ExecutingContext::RegisterNativeLibraryMetaData(NativeLibraryMetaData* meta_data) {
  native_library_meta_data_contaner_.push_back(meta_data);
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
                                        bool is_module,
                                        uint64_t* bytecodeLength) {
  int eval_flags = JS_EVAL_FLAG_COMPILE_ONLY | (is_module ? JS_EVAL_TYPE_MODULE : JS_EVAL_TYPE_GLOBAL);
  JSValue object = JS_Eval(script_state_.ctx(), code, codeLength, sourceURL, eval_flags);

  bool success = HandleException(&object);
  if (!success)
    return nullptr;

  size_t len;
  uint8_t* bytes = JS_WriteObject(script_state_.ctx(), &len, object, JS_WRITE_OBJ_BYTECODE);
  *bytecodeLength = len;
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

const WidgetElementShape* ExecutingContext::GetWidgetElementShape(const AtomicString& key) {
  if (widget_element_shapes_.count(key) > 0) {
    return widget_element_shapes_[key].get();
  }
  return nullptr;
}

bool ExecutingContext::HasWidgetElementShape(const AtomicString& key) const {
  return widget_element_shapes_.count(key) > 0;
}

void ExecutingContext::SetWidgetElementShape(NativeWidgetElementShape* native_widget_element_shape, size_t len) {
  if (len == 0 || native_widget_element_shape == nullptr || native_widget_element_shape->name == nullptr)
    return;

  for (size_t i = 0; i < len; i++) {
    const auto key = AtomicString(ctx(), native_widget_element_shape[i].name);
    widget_element_shapes_[key] = std::make_unique<WidgetElementShape>(ctx(), &native_widget_element_shape[i]);
  }
}

void ExecutingContext::FlushUICommand(const BindingObject* self, uint32_t reason) {
  std::vector<NativeBindingObject*> deps;
  FlushUICommand(self, reason, deps);
}

void ExecutingContext::FlushUICommand(const webf::BindingObject* self,
                                      uint32_t reason,
                                      std::vector<NativeBindingObject*>& deps) {
  if (SyncUICommandBuffer(self, reason, deps)) {
    dartMethodPtr()->flushUICommand(is_dedicated_, context_id_, self->bindingObject());
  }
}

void ExecutingContext::DrawCanvasElementIfNeeded() {
  if (!active_canvas_rendering_context_2ds_.empty()) {
    for (auto& canvas : active_canvas_rendering_context_2ds_) {
      canvas->needsPaint();
    }
  }
}

bool ExecutingContext::SyncUICommandBuffer(const BindingObject* self,
                                           uint32_t reason,
                                           std::vector<NativeBindingObject*>& deps) {
  // Check if there are any commands to sync (both in UICommandStrategy and ring buffer)
  auto* shared_ui_command = static_cast<SharedUICommand*>(uiCommandBuffer());
  bool has_waiting_commands = shared_ui_command->ui_command_sync_strategy_->GetWaitingCommandsCount() > 0;
  bool has_ring_buffer_packages = !shared_ui_command->empty();

  if (has_waiting_commands || has_ring_buffer_packages) {
    if (is_dedicated_) {
      bool should_swap_ui_commands = false;
      if (isUICommandReasonDependsOnElement(reason)) {
        bool element_mounted_on_dart = self->bindingObject()->invoke_bindings_methods_from_native != nullptr;
        bool is_deps_elements_mounted_on_dart = true;

        for (auto binding : deps) {
          if (binding->invoke_bindings_methods_from_native == nullptr) {
            is_deps_elements_mounted_on_dart = false;
          }
        }

        if (!element_mounted_on_dart || !is_deps_elements_mounted_on_dart) {
          should_swap_ui_commands = true;
        }
      }

      if (isUICommandReasonDependsOnLayout(reason) || isUICommandReasonDependsOnAll(reason)) {
        should_swap_ui_commands = true;
      }

      // Sync commands to dart when caller dependents on Element.
      if (should_swap_ui_commands) {
        // Then flush current package in ring buffer to make it visible
        shared_ui_command->SyncAllPackages();
      }
    }
    return true;
  }

  return false;
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

std::unordered_map<std::string, NativeByteCode> ExecutingContext::plugin_byte_code{};
std::unordered_map<std::string, std::string> ExecutingContext::plugin_string_code{};

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

void ExecutingContext::InstallNativeLoader() {
  MemberMutationScope scope{this};
  native_loader_ = MakeGarbageCollected<NativeLoader>(this);
  DefineGlobalProperty("nativeLoader", native_loader_->ToQuickJS());
}

void ExecutingContext::InstallGlobal() {
  MemberMutationScope mutation_scope{this};
  window_ = MakeGarbageCollected<Window>(this);
  JS_SetPrototype(ctx(), Global(), window_->ToQuickJSUnsafe());
  JS_SetGlobalObjectOpaque(ctx(), window_);
}

void ExecutingContext::RegisterActiveScriptWrappers(ScriptWrappable* script_wrappable) {
  active_wrappers_.emplace(script_wrappable);
}

void ExecutingContext::RegisterActiveCanvasContext2D(CanvasRenderingContext2D* canvas_rendering_context_2d) {
  active_canvas_rendering_context_2ds_.emplace(canvas_rendering_context_2d);
}

void ExecutingContext::RemoveCanvasContext2D(CanvasRenderingContext2D* canvas_rendering_context_2d) {
  active_canvas_rendering_context_2ds_.erase(canvas_rendering_context_2d);
}

void ExecutingContext::RemoveActiveScriptWrappers(ScriptWrappable* script_wrappable) {
  active_wrappers_.erase(script_wrappable);
}

void ExecutingContext::RegisterActiveScriptPromise(std::shared_ptr<ScriptPromiseResolver> promise_resolver) {
  active_pending_promises_.emplace(std::move(promise_resolver));
}

void ExecutingContext::UnRegisterActiveScriptPromise(const ScriptPromiseResolver* promise_resolver) {
  auto it = std::find_if(active_pending_promises_.begin(), active_pending_promises_.end(),
                         [promise_resolver](const std::shared_ptr<ScriptPromiseResolver>& item) {
                           return item.get() == promise_resolver;
                         });
  if (it != active_pending_promises_.end()) {
    active_pending_promises_.erase(it);
  }
}

void ExecutingContext::RegisterActiveNativeByteData(
    NativeByteDataFinalizerContext* native_byte_data_finalizer_context) {
  active_native_byte_datas_.emplace(native_byte_data_finalizer_context);
}

void ExecutingContext::UnRegisterActiveNativeByteData(
    NativeByteDataFinalizerContext* native_byte_data_finalizer_context) {
  auto it = std::find_if(active_native_byte_datas_.begin(), active_native_byte_datas_.end(),
                         [native_byte_data_finalizer_context](NativeByteDataFinalizerContext* ptr) {
                           return ptr == native_byte_data_finalizer_context;
                         });
  if (it != active_native_byte_datas_.end()) {
    active_native_byte_datas_.erase(it);
  }
}

RemoteObjectRegistry* ExecutingContext::GetRemoteObjectRegistry() {
  if (!remote_object_registry_) {
    remote_object_registry_ = std::make_unique<RemoteObjectRegistry>(this);
  }
  return remote_object_registry_.get();
}

// A lock free context validator.
bool isContextValid(double contextId) {
  if (contextId > running_context_list)
    return false;
  if (valid_contexts.count(contextId) == 0)
    return false;
  return valid_contexts[contextId];
}

char* ExecutingContext::ModuleNormalizeName(JSContext* ctx, const char* module_base_name, const char* module_name, void* opaque) {
  ExecutingContext* context = static_cast<ExecutingContext*>(opaque);

  // Check if it's already an absolute URL
  if (strstr(module_name, "://") != nullptr) {
    return js_strdup(ctx, module_name);
  }

  // Handle absolute paths (starting with /)
  if (module_name[0] == '/') {
    // If we have a base URL, extract the origin
    if (module_base_name && strstr(module_base_name, "://") != nullptr) {
      std::string base_url(module_base_name);

      // Find the origin (protocol + host)
      size_t protocol_end = base_url.find("://");
      if (protocol_end != std::string::npos) {
        size_t path_start = base_url.find('/', protocol_end + 3);
        std::string origin;
        if (path_start != std::string::npos) {
          origin = base_url.substr(0, path_start);
        } else {
          origin = base_url;
        }

        // Combine origin with the absolute path
        std::string resolved = origin + module_name;
        return js_strdup(ctx, resolved.c_str());
      }
    }
    // If no base or not a URL, return as-is
    return js_strdup(ctx, module_name);
  }

  // Handle relative imports (starting with ./ or ../)
  if (module_name[0] == '.' && (module_name[1] == '/' || (module_name[1] == '.' && module_name[2] == '/'))) {
    char* normalized_name = nullptr;

    if (module_base_name) {
      // Calculate the base path from module_base_name
      std::string base_path(module_base_name);
      size_t last_slash = base_path.rfind('/');
      if (last_slash != std::string::npos) {
        base_path = base_path.substr(0, last_slash + 1);
      } else {
        base_path = "";
      }

      // Resolve relative path
      std::string resolved_path = base_path + module_name;

      // Normalize path (remove ./ and ../)
      std::vector<std::string> parts;
      std::istringstream iss(resolved_path);
      std::string part;

      while (std::getline(iss, part, '/')) {
        if (part == "..") {
          if (!parts.empty()) {
            parts.pop_back();
          }
        } else if (part != "." && !part.empty()) {
          parts.push_back(part);
        }
      }

      // Reconstruct the path
      std::string normalized;
      for (size_t i = 0; i < parts.size(); ++i) {
        if (i > 0) normalized += "/";
        normalized += parts[i];
      }

      normalized_name = js_strdup(ctx, normalized.c_str());
    }

    return normalized_name;
  }

  // For relative paths without ./, resolve against base
  if (module_base_name) {
    std::string base_path(module_base_name);
    size_t last_slash = base_path.rfind('/');
    if (last_slash != std::string::npos) {
      base_path = base_path.substr(0, last_slash + 1);
    } else {
      base_path = "";
    }
    std::string resolved = base_path + module_name;
    return js_strdup(ctx, resolved.c_str());
  }

  // Default: return as-is
  return js_strdup(ctx, module_name);
}

// Context structure for module loading
struct ModuleLoadContext {
  ExecutingContext* executing_context;
  JSContext* ctx;
  std::string module_name;
  bool completed;
  JSModuleDef* module_def;
  char* error;
  uint8_t* bytes;
  int32_t length;
  std::condition_variable cv;
  std::mutex mutex;
};

// Callback function called from Dart when module content is fetched
static void HandleFetchModuleResult(void* callback_context, double context_id, char* error, uint8_t* bytes, int32_t length) {
  ModuleLoadContext* load_context = static_cast<ModuleLoadContext*>(callback_context);

  std::unique_lock<std::mutex> lock(load_context->mutex);

  load_context->error = error;
  load_context->bytes = bytes;
  load_context->length = length;
  load_context->completed = true;

  load_context->cv.notify_one();
}

// Helper function for import.meta.resolve()
static JSValue ImportMetaResolve(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "import.meta.resolve requires at least 1 argument");
  }

  const char* specifier = JS_ToCString(ctx, argv[0]);
  if (!specifier) {
    return JS_EXCEPTION;
  }

  // Get the current module name from the function property
  JSValue module_name_val = JS_GetPropertyStr(ctx, this_val, "__webf_module_name");
  const char* current_module = JS_ToCString(ctx, module_name_val);
  JS_FreeValue(ctx, module_name_val);

  if (!current_module) {
    JS_FreeCString(ctx, specifier);
    return JS_ThrowTypeError(ctx, "import.meta.resolve: unable to get current module name");
  }

  // Get the context from the global context opaque
  ExecutingContext* context = ExecutingContext::From(ctx);
  if (!context) {
    JS_FreeCString(ctx, specifier);
    JS_FreeCString(ctx, current_module);
    return JS_ThrowTypeError(ctx, "import.meta.resolve: unable to get execution context");
  }

  // Use the same resolution logic as ModuleNormalizeName
  char* resolved = ExecutingContext::ModuleNormalizeName(ctx, current_module, specifier, context);

  JSValue result;
  if (resolved) {
    result = JS_NewString(ctx, resolved);
    js_free(ctx, resolved);
  } else {
    result = JS_ThrowReferenceError(ctx, "Cannot resolve module specifier: %s", specifier);
  }

  JS_FreeCString(ctx, specifier);
  JS_FreeCString(ctx, current_module);
  return result;
}

// Helper function to set up enhanced import.meta object with WebF-specific properties
void ExecutingContext::SetupImportMeta(JSContext* ctx, JSModuleDef* m, const char* module_name, ExecutingContext* context) {
  // Debug logging
  WEBF_LOG(INFO) << "SetupImportMeta called for module: " << (module_name ? module_name : "null");

  JSValue meta_obj = JS_GetImportMeta(ctx, m);
  if (JS_IsException(meta_obj)) {
    WEBF_LOG(ERROR) << "Failed to get import.meta object";
    return;
  }

  WEBF_LOG(INFO) << "Successfully got import.meta object";

  // Convert module name to proper URL format
  std::string url_str(module_name);
  WEBF_LOG(INFO) << "Original module name: " << url_str;

  // If it's not already a URL, format it appropriately
  if (url_str.find("://") == std::string::npos) {
    if (url_str.front() == '/') {
      // Absolute path - convert to file:// URL
      url_str = "file://" + url_str;
    } else if (url_str.find("./") == 0 || url_str.find("../") == 0) {
      // Relative path - leave as-is, the module loader has already resolved it
    } else {
      // Assume it's a resolved absolute path or asset
      if (url_str.find("assets/") == 0) {
        url_str = "asset://flutter/" + url_str;
      } else {
        url_str = "file://" + url_str;
      }
    }
  }

  WEBF_LOG(INFO) << "Formatted URL: " << url_str;

  // Set up standard import.meta properties following MDN specification

  // 1. import.meta.url - the URL of the module
  JSValue url_value = JS_NewString(ctx, url_str.c_str());
  WEBF_LOG(INFO) << "Setting import.meta.url to: " << url_str;
  JS_DefinePropertyValueStr(ctx, meta_obj, "url", url_value, JS_PROP_C_W_E);

  // 2. import.meta.resolve - function to resolve module specifiers relative to current module
  // Store current module name in a property on the resolve function
  JSValue resolve_func = JS_NewCFunction2(ctx, ImportMetaResolve, "resolve", 1, JS_CFUNC_generic, 0);

  // Store the current module name and context as properties on the function
  JS_DefinePropertyValueStr(ctx, resolve_func, "__webf_module_name",
                           JS_NewString(ctx, module_name),
                           JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, resolve_func, "__webf_context_id",
                           JS_NewFloat64(ctx, context->contextId()),
                           JS_PROP_C_W_E);

  JS_DefinePropertyValueStr(ctx, meta_obj, "resolve", resolve_func, JS_PROP_C_W_E);

  // 3. WebF-specific properties

  // import.meta.webf - WebF-specific metadata
  JSValue webf_obj = JS_NewObject(ctx);
  JS_DefinePropertyValueStr(ctx, webf_obj, "version",
                           JS_NewString(ctx, "0.21.5+3"),
                           JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, webf_obj, "contextId",
                           JS_NewFloat64(ctx, context->contextId()),
                           JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, webf_obj, "isDedicated",
                           JS_NewBool(ctx, context->isDedicated()),
                           JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, meta_obj, "webf", webf_obj, JS_PROP_C_W_E);

  // 4. Environment information
  JSValue env_obj = JS_NewObject(ctx);
  JS_DefinePropertyValueStr(ctx, env_obj, "platform",
                           JS_NewString(ctx, "webf"),
                           JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, env_obj, "runtime",
                           JS_NewString(ctx, "quickjs"),
                           JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, meta_obj, "env", env_obj, JS_PROP_C_W_E);

  JS_FreeValue(ctx, meta_obj);
}

JSModuleDef* ExecutingContext::ModuleLoader(JSContext* ctx, const char* module_name, void* opaque) {
  ExecutingContext* context = static_cast<ExecutingContext*>(opaque);

  // Create the context for module loading
  ModuleLoadContext load_context;
  load_context.executing_context = context;
  load_context.ctx = ctx;
  load_context.module_name = module_name;
  load_context.completed = false;
  load_context.module_def = nullptr;
  load_context.error = nullptr;
  load_context.bytes = nullptr;
  load_context.length = 0;

  // Create native string for module URL
  std::u16string module_name_u16;
  fromUTF8(std::string(module_name), module_name_u16);
  SharedNativeString module_url(reinterpret_cast<const uint16_t*>(module_name_u16.c_str()), module_name_u16.length());

  // Call Dart to fetch the module - this posts to Dart thread
  context->dart_isolate_context_->dartMethodPtr()->fetchJavaScriptESMModule(
      context->isDedicated(),
      &load_context,
      context->contextId(),
      &module_url,
      HandleFetchModuleResult
  );

  // Block the JS thread until module is loaded
  {
    std::unique_lock<std::mutex> lock(load_context.mutex);
    load_context.cv.wait(lock, [&load_context] { return load_context.completed; });
  }

  // Process the result
  JSModuleDef* result = nullptr;

  if (load_context.error != nullptr) {
    // Error occurred during fetch
    JS_ThrowReferenceError(ctx, "Failed to load module '%s': %s", module_name, load_context.error);
    dart_free(load_context.error);
  } else if (load_context.bytes != nullptr && load_context.length > 0) {
    // Module content fetched successfully
    // Compile the module
    JSValue compiled = JS_Eval(ctx, reinterpret_cast<const char*>(load_context.bytes), load_context.length,
                              module_name, JS_EVAL_TYPE_MODULE | JS_EVAL_FLAG_COMPILE_ONLY);

    if (JS_IsException(compiled)) {
      // Compilation failed - exception is already set
      result = nullptr;
    } else {
      // Get the module definition
      result = static_cast<JSModuleDef*>(JS_VALUE_GET_PTR(compiled));

      // Set up enhanced import.meta object
      SetupImportMeta(ctx, result, module_name, context);
    }

    // Free the bytes
    dart_free(load_context.bytes);
  } else {
    JS_ThrowReferenceError(ctx, "Empty module content for '%s'", module_name);
  }

  return result;
}

}  // namespace webf
