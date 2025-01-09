/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element.h"
#include "binding_call_methods.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "built_in_string.h"
#include "core/dom/document.h"
#include "foundation/native_value_converter.h"
#include "widget_element_shape.h"

namespace webf {

WidgetElement::WidgetElement(const AtomicString& tag_name, Document* document)
    : HTMLElement(tag_name, document, ConstructionType::kCreateWidgetElement) {}

bool WidgetElement::IsValidName(const AtomicString& name) {
  assert(Document::IsValidName(name));
  StringView string_view = name.ToStringView();

  const char* string = string_view.Characters8();
  for (int i = 0; i < string_view.length(); i++) {
    if (string[i] == '-')
      return true;
  }

  return false;
}

bool WidgetElement::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  if (IsPrototypeProperty(key)) {
    return true;
  }

  const WidgetElementShape* shape = GetExecutingContext()->GetWidgetElementShape(key);
  return shape != nullptr && shape->HasPropertyOrMethod(key);
}

void WidgetElement::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) {
  const WidgetElementShape* shape = GetExecutingContext()->GetWidgetElementShape(tagName());
  shape->GetAllPropertyNames(names);
}

static bool IsAsyncKey(const AtomicString& key, char* normal_string) {
  if (!key.Is8Bit()) {
    return false;
  }

  StringView string_view = key.ToStringView();
  const char* string = string_view.Characters8();

  const char* suffix = "_async";
  size_t str_len = string_view.length();
  size_t suffix_len = std::strlen(suffix);

  if (str_len < suffix_len) {
    return false;  // String is shorter than the suffix
  }

  // Compare the suffix part of the string
  bool is_match = std::strcmp(string + (str_len - suffix_len), suffix) == 0;

  if (is_match) {
    size_t new_len = str_len - suffix_len;
    std::strncpy(normal_string, string, new_len);
    normal_string[new_len] = '\0';
  }

  return is_match;
}

ScriptValue WidgetElement::item(const AtomicString& key, ExceptionState& exception_state) {
  if (unimplemented_properties_.count(key) > 0) {
    return unimplemented_properties_[key];
  }

  // If the property is defined in the prototype for DOM built-in properties and methods,
  // return undefined to let QuickJS look for this property value on its prototype.
  if (IsPrototypeProperty(key)) {
    return ScriptValue::Undefined(ctx());
  }

  const WidgetElementShape* shape = GetExecutingContext()->GetWidgetElementShape(tagName());

  std::vector<char> async_key_string(key.length());
  bool is_async = IsAsyncKey(key, async_key_string.data());
  AtomicString async_key = AtomicString(ctx(), async_key_string.data());

  if (shape == nullptr || !(shape->HasPropertyOrMethod(key) || shape->HasPropertyOrMethod(async_key))) {
    return ScriptValue::Undefined(ctx());
  }

  if (shape->HasProperty(key) || shape->HasProperty(async_key)) {
    if (is_async) {
      return GetBindingPropertyAsync(async_key, exception_state).ToValue();
    }

    return ScriptValue(ctx(), GetBindingProperty(key, FlushUICommandReason::kDependentsOnElement, exception_state));
  }

  if (shape->HasMethod(key)) {
    if (cached_methods_.count(key) > 0) {
      return cached_methods_[key];
    }

    auto func = CreateSyncMethodFunc(key);
    cached_methods_[key] = func;

    return func;
  }

  if (shape->HasMethod(async_key)) {
    if (async_cached_methods_.count(async_key) > 0) {
      return async_cached_methods_[async_key];
    }

    auto func = CreateAsyncMethodFunc(async_key);
    async_cached_methods_[key] = func;

    return func;
  }

  if (shape->HasAsyncMethod(key)) {
    if (async_cached_methods_.count(key) > 0) {
      return async_cached_methods_[key];
    }

    auto func = CreateAsyncMethodFunc(key);
    async_cached_methods_[key] = CreateAsyncMethodFunc(key);
    return func;
  }

  return ScriptValue::Undefined(ctx());
}

bool WidgetElement::SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) {
  if (IsPrototypeProperty(key)) {
    return false;
  }

  const WidgetElementShape* shape = GetExecutingContext()->GetWidgetElementShape(key);

  if (shape == nullptr || !shape->HasPropertyOrMethod(key)) {
    // Nothing at all
    unimplemented_properties_[key] = value;
    return false;
  }

  if (shape->HasProperty(key)) {
    std::vector<char> sync_key_string(key.length());
    bool is_async = IsAsyncKey(key, sync_key_string.data());

    if (is_async) {
      AtomicString sync_key = AtomicString(ctx(), sync_key_string.data());
      SetBindingPropertyAsync(sync_key, value.ToNative(ctx(), exception_state), exception_state);
      return true;
    }

    NativeValue result = SetBindingProperty(key, value.ToNative(ctx(), exception_state), exception_state);
    return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  }

  return true;
}

bool WidgetElement::DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  return true;
}

bool WidgetElement::IsWidgetElement() const {
  return true;
}

void WidgetElement::Trace(GCVisitor* visitor) const {
  HTMLElement::Trace(visitor);

  for (auto& entry : unimplemented_properties_) {
    entry.second.Trace(visitor);
  }

  for (auto& entry : cached_methods_) {
    entry.second.Trace(visitor);
  }

  for (auto& entry : async_cached_methods_) {
    entry.second.Trace(visitor);
  }
}

struct FunctionData {
  std::string method_name;
};

ScriptValue SyncDynamicFunction(JSContext* ctx,
                                const ScriptValue& this_val,
                                uint32_t argc,
                                const ScriptValue* argv,
                                void* private_data) {
  auto* data = reinterpret_cast<FunctionData*>(private_data);
  auto* event_target = toScriptWrappable<EventTarget>(this_val.QJSValue());
  AtomicString method_name = AtomicString(ctx, data->method_name);
  ExceptionState exception_state;

  std::vector<NativeValue> arguments(argc);

  for (int i = 0; i < argc; i++) {
    arguments[i] = argv[i].ToNative(ctx, exception_state, false);
  }

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  std::vector<char> sync_method_string(method_name.length());
  if (IsAsyncKey(method_name, sync_method_string.data())) {
    AtomicString sync_method = AtomicString(ctx, sync_method_string.data());
    ScriptPromise promise =
        event_target->InvokeBindingMethodAsync(sync_method, argc, arguments.data(), exception_state);
    return promise.ToValue();
  } else {
    NativeValue result = event_target->InvokeBindingMethod(method_name, argc, arguments.data(),
                                                           FlushUICommandReason::kDependentsOnElement, exception_state);
    if (exception_state.HasException()) {
      event_target->GetExecutingContext()->HandleException(exception_state);
      return ScriptValue::Empty(ctx);
    }

    return ScriptValue(ctx, result);
  }
}

ScriptValue AsyncDynamicFunction(JSContext* ctx,
                                 const ScriptValue& this_val,
                                 uint32_t argc,
                                 const ScriptValue* argv,
                                 void* private_data) {
  auto* data = reinterpret_cast<FunctionData*>(private_data);
  auto* event_target = toScriptWrappable<EventTarget>(this_val.QJSValue());
  AtomicString method_name = AtomicString(ctx, data->method_name);

  ExceptionState exception_state;

  std::vector<NativeValue> arguments(argc);

  for (int i = 0; i < argc; i++) {
    arguments[i] = argv[i].ToNative(ctx, exception_state, false);
  }

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  ScriptPromise promise = event_target->InvokeBindingMethodAsync(method_name, argc, arguments.data(), exception_state);

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  return promise.ToValue();
}

ScriptValue WidgetElement::CreateSyncMethodFunc(const AtomicString& method_name) {
  auto* data = new FunctionData();
  data->method_name = method_name.ToStdString(ctx());
  return ScriptValue(ctx(),
                     QJSFunction::Create(ctx(), SyncDynamicFunction, 1, data, HandleJSCallbackGCMark, HandleJSFinalizer)
                         ->ToQuickJSUnsafe());
}

ScriptValue WidgetElement::CreateAsyncMethodFunc(const AtomicString& method_name) {
  auto* data = new FunctionData();
  data->method_name = method_name.ToStdString(ctx());
  return ScriptValue(
      ctx(), QJSFunction::Create(ctx(), AsyncDynamicFunction, 1, data, HandleJSCallbackGCMark, HandleJSFinalizer)
                 ->ToQuickJSUnsafe());
}

void WidgetElement::HandleJSCallbackGCMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {}

void WidgetElement::HandleJSFinalizer(JSRuntime* rt, JSValue val) {
  auto* callback_context = static_cast<QJSFunctionCallbackContext*>(JS_GetOpaque(val, JSValueGetClassId(val)));
  delete static_cast<FunctionData*>(callback_context->private_data);
  delete callback_context;
}

}  // namespace webf
