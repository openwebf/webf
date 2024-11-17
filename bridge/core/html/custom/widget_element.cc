/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element.h"
#include "binding_call_methods.h"
#include "built_in_string.h"
#include "core/dom/document.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "foundation/native_value_converter.h"

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

ScriptValue WidgetElement::getPropertyValue(const webf::AtomicString& name, webf::ExceptionState& exception_state) {
  return ScriptValue(ctx(), GetBindingProperty(name, FlushUICommandReason::kDependentsOnElement, exception_state));
}

ScriptPromise WidgetElement::getPropertyValueAsync(const webf::AtomicString& name, webf::ExceptionState& exception_state) {
  return GetBindingPropertyAsync(name, exception_state);
}

void WidgetElement::setPropertyValue(const webf::AtomicString& name, const webf::ScriptValue& value, webf::ExceptionState& exception_state) {
  SetBindingProperty(name, value.ToNative(ctx(), exception_state, false), exception_state);
}

void WidgetElement::setPropertyValueAsync(const webf::AtomicString& name, const webf::ScriptValue& value, webf::ExceptionState& exception_state) {
  SetBindingPropertyAsync(name, value.ToNative(ctx(), exception_state));
}

ScriptValue WidgetElement::callMethod(const webf::AtomicString& name, std::vector<ScriptValue>& args, webf::ExceptionState& exception_state) {
  NativeValue* arguments = new NativeValue[args.size()];

  for(int i = 0; i < args.size(); i ++) {
    arguments[i] = args[i].ToNative(ctx(), exception_state);
  }

  NativeValue result = InvokeBindingMethod(name, args.size(), arguments, FlushUICommandReason::kDependentsOnElement, exception_state);

  return ScriptValue(ctx(), result);
}

ScriptPromise WidgetElement::callAsyncMethod(const webf::AtomicString& name, std::vector<ScriptValue>& args, webf::ExceptionState& exception_state) {
  NativeValue method_name = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), name);

  NativeValue* arguments = new NativeValue[args.size()];
  for(int i = 0; i < args.size(); i ++) {
    arguments[i] = args[i].ToNative(ctx(), exception_state);
  }

  return InvokeBindingMethodAsyncInternal(method_name, args.size(), arguments, exception_state);
}

bool WidgetElement::IsWidgetElement() const {
  return true;
}

void WidgetElement::Trace(GCVisitor* visitor) const {
  HTMLElement::Trace(visitor);
}


}  // namespace webf