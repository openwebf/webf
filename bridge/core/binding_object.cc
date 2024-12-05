/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "binding_object.h"
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "core/dom/events/event_target.h"
#include "core/dom/mutation_observer_interest_group.h"
#include "core/executing_context.h"
#include "foundation/native_string.h"
#include "foundation/native_value_converter.h"
#include "logging.h"

namespace webf {

static void ReturnEventResultToDart(Dart_Handle persistent_handle,
                                    NativeValue* result,
                                    DartInvokeResultCallback result_callback) {
  const Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle, result);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

static void HandleCallFromDartSideWrapper(NativeBindingObject* binding_object,
                                          int64_t profile_id,
                                          NativeValue* method,
                                          int32_t argc,
                                          NativeValue* argv,
                                          Dart_Handle dart_object,
                                          DartInvokeResultCallback result_callback) {
  if (binding_object->disposed_)
    return;

  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_object);
  auto dart_isolate = binding_object->binding_target_->GetExecutingContext()->dartIsolateContext();
  auto is_dedicated = binding_object->binding_target_->GetExecutingContext()->isDedicated();
  auto context_id = binding_object->binding_target_->contextId();

  dart_isolate->dispatcher()->PostToJs(is_dedicated, static_cast<int32_t>(context_id),
                                       NativeBindingObject::HandleCallFromDartSide, dart_isolate, binding_object,
                                       profile_id, method, argc, argv, persistent_handle, result_callback);
}

NativeBindingObject::NativeBindingObject(BindingObject* target)
    : binding_target_(target), invoke_binding_methods_from_dart(HandleCallFromDartSideWrapper) {}

void NativeBindingObject::HandleCallFromDartSide(const DartIsolateContext* dart_isolate_context,
                                                 const NativeBindingObject* binding_object,
                                                 int64_t profile_id,
                                                 const NativeValue* native_method,
                                                 int32_t argc,
                                                 const NativeValue* argv,
                                                 Dart_PersistentHandle dart_object,
                                                 DartInvokeResultCallback result_callback) {
  if (binding_object->disposed_)
    return;

  dart_isolate_context->profiler()->StartTrackEvaluation(profile_id);

  const AtomicString method =
      AtomicString(binding_object->binding_target_->ctx(),
                   std::unique_ptr<AutoFreeNativeString>(static_cast<AutoFreeNativeString*>(native_method->u.ptr)));
  const NativeValue result = binding_object->binding_target_->HandleCallFromDartSide(method, argc, argv, dart_object);

  auto* return_value = new NativeValue();
  std::memcpy(return_value, &result, sizeof(NativeValue));

  dart_isolate_context->profiler()->FinishTrackEvaluation(profile_id);

  dart_isolate_context->dispatcher()->PostToDart(binding_object->binding_target_->GetExecutingContext()->isDedicated(),
                                                 ReturnEventResultToDart, dart_object, return_value, result_callback);
}

BindingObject::BindingObject(JSContext* ctx) : ScriptWrappable(ctx), binding_object_(new NativeBindingObject(this)) {}
BindingObject::~BindingObject() {
  // Set below properties to nullptr to avoid dart callback to native.
  binding_object_->disposed_ = true;
  binding_object_->binding_target_ = nullptr;
  binding_object_->invoke_binding_methods_from_dart = nullptr;
  binding_object_->invoke_bindings_methods_from_native = nullptr;

  // When a JSObject got finalized by QuickJS GC, we can not guarantee the ExecutingContext are still alive and
  // accessible.
  if (isContextValid(contextId())) {
    GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kDisposeBindingObject, nullptr, bindingObject(),
                                                         nullptr, false);
  }
}

BindingObject::BindingObject(JSContext* ctx, NativeBindingObject* native_binding_object) : ScriptWrappable(ctx) {
  native_binding_object->binding_target_ = this;
  native_binding_object->invoke_binding_methods_from_dart = HandleCallFromDartSideWrapper;
  binding_object_ = native_binding_object;
}

void BindingObject::TrackPendingPromiseBindingContext(BindingObjectPromiseContext* binding_object_promise_context) {
  pending_promise_contexts_.emplace(binding_object_promise_context);
}

void BindingObject::FullFillPendingPromise(BindingObjectPromiseContext* binding_object_promise_context) {
  pending_promise_contexts_.erase(binding_object_promise_context);
}

NativeValue BindingObject::HandleCallFromDartSide(const AtomicString& method,
                                                  int32_t argc,
                                                  const NativeValue* argv,
                                                  Dart_Handle dart_object) {
  return Native_NewNull();
}

NativeValue BindingObject::InvokeBindingMethod(const AtomicString& method,
                                               int32_t argc,
                                               const NativeValue* argv,
                                               uint32_t reason,
                                               ExceptionState& exception_state) const {
  auto* context = GetExecutingContext();
  auto* profiler = context->dartIsolateContext()->profiler();

  profiler->StartTrackSteps("BindingObject::InvokeBindingMethod");

  std::vector<NativeBindingObject*> invoke_elements_deps;
  // Collect all DOM elements in arguments.
  CollectElementDepsOnArgs(invoke_elements_deps, argc, argv);
  // Make sure all these elements are ready in dart.
  context->FlushUICommand(this, reason, invoke_elements_deps);

  NativeValue return_value = Native_NewNull();
  NativeValue native_method =
      NativeValueConverter<NativeTypeString>::ToNativeValue(GetExecutingContext()->ctx(), method);

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call Begin";
#endif

  profiler->StartTrackLinkSteps("Call To Dart");

  GetDispatcher()->PostToDartSync(
      GetExecutingContext()->isDedicated(), contextId(),
      [&](bool cancel, double contextId, int64_t profile_id, const NativeBindingObject* binding_object,
          NativeValue* return_value, NativeValue* method, int32_t argc, const NativeValue* argv) {
        if (cancel)
          return;

#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback Start";
#endif

        if (binding_object_->invoke_bindings_methods_from_native == nullptr) {
          WEBF_LOG(DEBUG) << "invoke_bindings_methods_from_native is nullptr" << std::endl;
          return;
        }
        binding_object_->invoke_bindings_methods_from_native(contextId, profile_id, binding_object, return_value,
                                                             method, argc, argv);
#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback End";
#endif
      },
      GetExecutingContext()->contextId(), profiler->link_id(), binding_object_, &return_value, &native_method, argc,
      argv);

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call End";
#endif

  profiler->FinishTrackLinkSteps();
  profiler->FinishTrackSteps();

  return return_value;
}

ScriptPromise BindingObject::InvokeBindingMethodAsync(const webf::AtomicString& method,
                                                      int32_t argc,
                                                      const webf::NativeValue* args,
                                                      webf::ExceptionState& exception_state) const {
  NativeValue method_on_stack = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), method);
  return InvokeBindingMethodAsyncInternal(method_on_stack, argc, args, exception_state);
}

static void handleAsyncInvokeCallback(ScriptPromiseResolver* resolver,
                                      NativeValue* success_result,
                                      const char* error_msg) {
  auto* context = resolver->context();
  MemberMutationScope member_mutation_scope{context};
  if (success_result != nullptr) {
    ScriptValue result = ScriptValue(resolver->context()->ctx(), *success_result, false);
    resolver->Resolve(result.QJSValue());
    dart_free(success_result);
  } else if (error_msg != nullptr) {
    ExceptionState exception_state;
    exception_state.ThrowException(context->ctx(), ErrorType::InternalError, error_msg);
    JSValue exception_value = ExceptionState::CurrentException(context->ctx());
    resolver->Reject(exception_value);
    JS_FreeValue(context->ctx(), exception_value);
    dart_free((void*)error_msg);
  } else {
    assert(false);
  }
}

ScriptPromise BindingObject::InvokeBindingMethodAsync(BindingMethodCallOperations binding_method_call_operation,
                                                      int32_t argc,
                                                      const NativeValue* args,
                                                      ExceptionState& exception_state) const {
  NativeValue method_on_stack = NativeValueConverter<NativeTypeInt64>::ToNativeValue(binding_method_call_operation);
  return InvokeBindingMethodAsyncInternal(method_on_stack, argc, args, exception_state);
}

ScriptPromise BindingObject::InvokeBindingMethodAsyncInternal(NativeValue method,
                                                              int32_t argc,
                                                              const webf::NativeValue* argv,
                                                              webf::ExceptionState& exception_state) const {
  auto* context = GetExecutingContext();

  NativeValue* dart_method_name = (NativeValue*)dart_malloc(sizeof(NativeValue));
  memcpy(dart_method_name, &method, sizeof(NativeValue));

  std::shared_ptr<ScriptPromiseResolver> resolver = ScriptPromiseResolver::Create(context);

  auto* binding_call_context = new BindingObjectAsyncCallContext();
  binding_call_context->method_name = dart_method_name;
  binding_call_context->argc = argc;
  binding_call_context->argv = (webf::NativeValue*)dart_malloc(sizeof(NativeValue) * argc);
  memcpy((void*)binding_call_context->argv, argv, sizeof(NativeValue) * argc);
  binding_call_context->async_invoke_reader = resolver.get();
  binding_call_context->callback = [](ScriptPromiseResolver* resolver, NativeValue* success_result,
                                      const char* error_msg) {
    if (!resolver->isAlive())
      return;

    auto* context = resolver->context();
    context->dartIsolateContext()->dispatcher()->PostToJs(
        context->isDedicated(), context->contextId(), handleAsyncInvokeCallback, resolver, success_result, error_msg);
  };

  context->RegisterActiveScriptPromise(resolver);

  context->uiCommandBuffer()->AddCommand(UICommand::kAsyncCaller, nullptr, bindingObject(), binding_call_context, true);

  return resolver->Promise();
}

ScriptPromise BindingObject::GetBindingPropertyAsync(const webf::AtomicString& prop,
                                                     webf::ExceptionState& exception_state) {
  if (UNLIKELY(binding_object_->disposed_)) {
    exception_state.ThrowException(
        ctx(), ErrorType::InternalError,
        "Can not get binding property on BindingObject, dart binding object had been disposed");
    return ScriptPromise(ctx(), JS_NULL);
  }

  const NativeValue argv[] = {Native_NewString(prop.ToNativeString(GetExecutingContext()->ctx()).release())};
  return InvokeBindingMethodAsync(BindingMethodCallOperations::kGetProperty, 1, argv, exception_state);
}

void BindingObject::SetBindingPropertyAsync(const webf::AtomicString& prop, NativeValue value) {
  std::unique_ptr<SharedNativeString> args_01 = prop.ToNativeString(ctx());
  auto* native_value = (NativeValue*)dart_malloc(sizeof(NativeValue));
  memcpy(native_value, &value, sizeof(NativeValue));

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kSetProperty, std::move(args_01), bindingObject(),
                                                       native_value);
}

NativeValue BindingObject::InvokeBindingMethod(BindingMethodCallOperations binding_method_call_operation,
                                               size_t argc,
                                               const NativeValue* argv,
                                               uint32_t reason,
                                               ExceptionState& exception_state) const {
  auto* context = GetExecutingContext();
  auto* profiler = context->dartIsolateContext()->profiler();

  profiler->StartTrackSteps("BindingObject::InvokeBindingMethod");

  std::vector<NativeBindingObject*> invoke_elements_deps;
  // Collect all DOM elements in arguments.
  CollectElementDepsOnArgs(invoke_elements_deps, argc, argv);
  // Make sure all these elements are ready in dart.
  context->FlushUICommand(this, reason, invoke_elements_deps);

  NativeValue return_value = Native_NewNull();

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call Begin";
#endif

  profiler->StartTrackLinkSteps("Call To Dart");

  NativeValue native_method = NativeValueConverter<NativeTypeInt64>::ToNativeValue(binding_method_call_operation);
  GetDispatcher()->PostToDartSync(
      GetExecutingContext()->isDedicated(), contextId(),
      [&](bool cancel, double contextId, int64_t profile_id, const NativeBindingObject* binding_object,
          NativeValue* return_value, NativeValue* method, int32_t argc, const NativeValue* argv) {
        if (cancel)
          return;

#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback Start";
#endif

        if (binding_object_->invoke_bindings_methods_from_native == nullptr) {
          WEBF_LOG(DEBUG) << "invoke_bindings_methods_from_native is nullptr" << std::endl;
          return;
        }
        binding_object_->invoke_bindings_methods_from_native(contextId, profile_id, binding_object, return_value,
                                                             method, argc, argv);
#if ENABLE_LOG
        WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Callback End";
#endif
      },
      context->contextId(), profiler->link_id(), binding_object_, &return_value, &native_method, argc, argv);

#if ENABLE_LOG
  WEBF_LOG(INFO) << "[Dispatcher]: PostToDartSync method: InvokeBindingMethod; Call End";
#endif

  profiler->FinishTrackLinkSteps();
  profiler->FinishTrackSteps();

  return return_value;
}

NativeValue BindingObject::GetBindingProperty(const AtomicString& prop,
                                              uint32_t reason,
                                              ExceptionState& exception_state) const {
  if (UNLIKELY(binding_object_->disposed_)) {
    exception_state.ThrowException(
        ctx(), ErrorType::InternalError,
        "Can not get binding property on BindingObject, dart binding object had been disposed");
    return Native_NewNull();
  }

  GetExecutingContext()->dartIsolateContext()->profiler()->StartTrackSteps("BindingObject::GetBindingProperty");

  const NativeValue argv[] = {Native_NewString(prop.ToNativeString(GetExecutingContext()->ctx()).release())};
  NativeValue result = InvokeBindingMethod(BindingMethodCallOperations::kGetProperty, 1, argv, reason, exception_state);

  GetExecutingContext()->dartIsolateContext()->profiler()->FinishTrackSteps();

  return result;
}

NativeValue BindingObject::SetBindingProperty(const AtomicString& prop,
                                              NativeValue value,
                                              ExceptionState& exception_state) const {
  if (UNLIKELY(binding_object_->disposed_)) {
    exception_state.ThrowException(
        ctx(), ErrorType::InternalError,
        "Can not set binding property on BindingObject, dart binding object had been disposed");
    return Native_NewNull();
  }

  if (auto element = const_cast<WidgetElement*>(DynamicTo<WidgetElement>(this))) {
    if (std::shared_ptr<MutationObserverInterestGroup> recipients =
            MutationObserverInterestGroup::CreateForAttributesMutation(*element, prop)) {
      NativeValue old_native_value =
          GetBindingProperty(prop, FlushUICommandReason::kDependentsOnElement, exception_state);
      ScriptValue old_value = ScriptValue(ctx(), old_native_value);
      recipients->EnqueueMutationRecord(
          MutationRecord::CreateAttributes(element, prop, AtomicString::Null(), old_value.ToString(ctx())));
    }
  }

  const NativeValue argv[] = {Native_NewString(prop.ToNativeString(GetExecutingContext()->ctx()).release()), value};
  return InvokeBindingMethod(BindingMethodCallOperations::kSetProperty, 2, argv,
                             FlushUICommandReason::kDependentsOnElement, exception_state);
}

void BindingObject::CollectElementDepsOnArgs(std::vector<NativeBindingObject*>& deps,
                                             size_t argc,
                                             const webf::NativeValue* args) const {
  for (int i = 0; i < argc; i++) {
    const NativeValue& native_value = args[i];
    if (native_value.tag == NativeTag::TAG_POINTER &&
        GetPointerTypeOfNativePointer(native_value) == JSPointerType::NativeBindingObject) {
      NativeBindingObject* ptr =
          NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(native_value);
      deps.emplace_back(ptr);
    }
  }
}

void BindingObject::Trace(GCVisitor* visitor) const {
  for (auto&& promise_context : pending_promise_contexts_) {
    promise_context->promise_resolver->Trace(visitor);
  }
}

bool BindingObject::IsEventTarget() const {
  return false;
}

bool BindingObject::IsTouchList() const {
  return false;
}

bool BindingObject::IsComputedCssStyleDeclaration() const {
  return false;
}

bool BindingObject::IsCanvasGradient() const {
  return false;
}

}  // namespace webf
