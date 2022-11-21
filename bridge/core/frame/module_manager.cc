/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "module_manager.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "module_callback.h"

namespace webf {

struct ModuleContext {
  ModuleContext(ExecutingContext* context, const std::shared_ptr<ModuleCallback>& callback)
      : context(context), callback(callback) {}
  ExecutingContext* context;
  std::shared_ptr<ModuleCallback> callback;
};

NativeValue* handleInvokeModuleTransientCallback(void* ptr,
                                                 int32_t contextId,
                                                 const char* errmsg,
                                                 NativeValue* extra_data) {
  auto* moduleContext = static_cast<ModuleContext*>(ptr);
  ExecutingContext* context = moduleContext->context;

  if (!context->IsCtxValid() || !context->IsContextValid())
    return nullptr;

  if (moduleContext->callback == nullptr) {
    JSValue exception = JS_ThrowTypeError(moduleContext->context->ctx(),
                                          "Failed to execute '__webf_invoke_module__': callback is null.");
    context->HandleException(&exception);
    return nullptr;
  }

  JSContext* ctx = moduleContext->context->ctx();

  if (ctx == nullptr)
    return nullptr;

  ExceptionState exception_state;

  NativeValue* return_value = nullptr;
  if (errmsg != nullptr) {
    ScriptValue error_object = ScriptValue::CreateErrorObject(ctx, errmsg);
    ScriptValue arguments[] = {error_object};
    ScriptValue result = moduleContext->callback->value()->Invoke(ctx, ScriptValue::Empty(ctx), 1, arguments);
    if (result.IsException()) {
      context->HandleException(&result);
    }
    NativeValue native_result = result.ToNative(exception_state);
    return_value = static_cast<NativeValue*>(malloc(sizeof(NativeValue)));
    memcpy(return_value, &native_result, sizeof(NativeValue));
  } else {
    ScriptValue arguments[] = {ScriptValue::Empty(ctx), ScriptValue(ctx, *extra_data)};
    ScriptValue result = moduleContext->callback->value()->Invoke(ctx, ScriptValue::Empty(ctx), 2, arguments);
    if (result.IsException()) {
      context->HandleException(&result);
    }
    NativeValue native_result = result.ToNative(exception_state);
    return_value = static_cast<NativeValue*>(malloc(sizeof(NativeValue)));
    memcpy(return_value, &native_result, sizeof(NativeValue));
  }

  if (exception_state.HasException()) {
    context->HandleException(exception_state);
    return nullptr;
  }

  return return_value;
}

NativeValue* handleInvokeModuleUnexpectedCallback(void* callbackContext,
                                                  int32_t contextId,
                                                  const char* errmsg,
                                                  NativeValue* extra_data) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
  return nullptr;
}

ScriptValue ModuleManager::__webf_invoke_module__(ExecutingContext* context,
                                                  const AtomicString& module_name,
                                                  const AtomicString& method,
                                                  ExceptionState& exception) {
  ScriptValue empty = ScriptValue::Empty(context->ctx());
  return __webf_invoke_module__(context, module_name, method, empty, nullptr, exception);
}

ScriptValue ModuleManager::__webf_invoke_module__(ExecutingContext* context,
                                                  const AtomicString& module_name,
                                                  const AtomicString& method,
                                                  ScriptValue& params_value,
                                                  ExceptionState& exception) {
  return __webf_invoke_module__(context, module_name, method, params_value, nullptr, exception);
}

ScriptValue ModuleManager::__webf_invoke_module__(ExecutingContext* context,
                                                  const AtomicString& module_name,
                                                  const AtomicString& method,
                                                  ScriptValue& params_value,
                                                  const std::shared_ptr<QJSFunction>& callback,
                                                  ExceptionState& exception) {
  NativeValue params = params_value.ToNative(exception);

  if (exception.HasException()) {
    return ScriptValue::Empty(context->ctx());
  }

  if (context->dartMethodPtr()->invokeModule == nullptr) {
    exception.ThrowException(
        context->ctx(), ErrorType::InternalError,
        "Failed to execute '__webf_invoke_module__': dart method (invokeModule) is not registered.");
    return ScriptValue::Empty(context->ctx());
  }

  NativeValue* result;
  if (callback != nullptr) {
    auto module_callback = ModuleCallback::Create(callback);
    auto module_context = std::make_shared<ModuleContext>(context, module_callback);
    context->ModuleContexts()->AddModuleContext(module_context);
    result = context->dartMethodPtr()->invokeModule(
        module_context.get(), context->contextId(), module_name.ToNativeString(context->ctx()).get(),
        method.ToNativeString(context->ctx()).get(), &params, handleInvokeModuleTransientCallback);
  } else {
    result = context->dartMethodPtr()->invokeModule(
        nullptr, context->contextId(), module_name.ToNativeString(context->ctx()).get(),
        method.ToNativeString(context->ctx()).get(), &params, handleInvokeModuleUnexpectedCallback);
  }

  if (result == nullptr) {
    return ScriptValue::Empty(context->ctx());
  }

  return ScriptValue(context->ctx(), *result);
}

void ModuleManager::__webf_add_module_listener__(ExecutingContext* context,
                                                 const AtomicString& module_name,
                                                 const std::shared_ptr<QJSFunction>& handler,
                                                 ExceptionState& exception) {
  auto listener = ModuleListener::Create(handler);
  context->ModuleListeners()->AddModuleListener(module_name, listener);
}

void ModuleManager::__webf_remove_module_listener__(ExecutingContext* context,
                                                    const AtomicString& module_name,
                                                    ExceptionState& exception_state) {
  context->ModuleListeners()->RemoveModuleListener(module_name);
}

void ModuleManager::__webf_clear_module_listener__(ExecutingContext* context, ExceptionState& exception_state) {
  context->ModuleListeners()->Clear();
}

}  // namespace webf
