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
  // NativeValue result = GetAllBindingPropertyNames(exception_state);
  // assert(result.tag == NativeTag::TAG_LIST);
  // std::vector<AtomicString> property_names =
  //     NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), result);
  // names.reserve(property_names.size());
  // for (auto& property_name : property_names) {
  //   names.emplace_back(property_name);
  // }
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

  const WidgetElementShape* shape = GetExecutingContext()->GetWidgetElementShape(key);

  if (shape == nullptr || !shape->HasPropertyOrMethod(key)) {
    return ScriptValue::Undefined(ctx());
  }

  if (shape->HasProperty(key)) {
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
    return false;
  }

  if (shape->HasProperty(key)) {
    NativeValue result = SetBindingProperty(key, value.ToNative(ctx(), exception_state), exception_state);
    return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  }

  // Nothing at all
  unimplemented_properties_[key] = value;
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

  NativeValue arguments[argc];

  for (int i = 0; i < argc; i++) {
    arguments[i] = argv[i].ToNative(ctx, exception_state, false);
  }

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  NativeValue result = event_target->InvokeBindingMethod(method_name, argc, arguments,
                                                         FlushUICommandReason::kDependentsOnElement, exception_state);

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  return ScriptValue(ctx, result);
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

  NativeValue arguments[argc];

  for (int i = 0; i < argc; i++) {
    arguments[i] = argv[i].ToNative(ctx, exception_state, false);
  }

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  ScriptPromise promise = event_target->InvokeBindingMethodAsync(method_name, argc, arguments, exception_state);

  if (exception_state.HasException()) {
    event_target->GetExecutingContext()->HandleException(exception_state);
    return ScriptValue::Empty(ctx);
  }

  return promise.ToValue();
}

ScriptValue WidgetElement::CreateSyncMethodFunc(const AtomicString& method_name) {
  auto* data = new FunctionData();
  data->method_name = method_name.ToStdString(ctx());
  return ScriptValue(ctx(), QJSFunction::Create(ctx(), SyncDynamicFunction, 1, data)->ToQuickJSUnsafe());
}

ScriptValue WidgetElement::CreateAsyncMethodFunc(const AtomicString& method_name) {
  auto* data = new FunctionData();
  data->method_name = method_name.ToStdString(ctx());
  return ScriptValue(ctx(), QJSFunction::Create(ctx(), AsyncDynamicFunction, 1, data)->ToQuickJSUnsafe());
}


}  // namespace webf