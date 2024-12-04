/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "computed_css_style_declaration.h"
#include "binding_call_methods.h"
#include "core/binding_object.h"
#include "core/dom/element.h"
#include "foundation/native_value.h"
#include "foundation/native_value_converter.h"

namespace webf {

ComputedCssStyleDeclaration::ComputedCssStyleDeclaration(ExecutingContext* context,
                                                         NativeBindingObject* native_binding_object)
    : CSSStyleDeclaration(context->ctx(), native_binding_object) {}

// ScriptValue ComputedCssStyleDeclaration::item(const AtomicString& key, ExceptionState& exception_state) {
//  if (IsPrototypeMethods(key)) {
//    return ScriptValue::Undefined(ctx());
//  }
//
//  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key)};
//
//  NativeValue result = InvokeBindingMethod(
//      binding_call_methods::kgetPropertyValue, 1, arguments,
//      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
//  return ScriptValue(ctx(), NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(result)));
//}

// bool ComputedCssStyleDeclaration::DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
//  return true;
//}

unsigned ComputedCssStyleDeclaration::length() const {
  NativeValue result = GetBindingProperty(
      binding_call_methods::klength,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeInt64>::FromNativeValue(result);
}

AtomicString ComputedCssStyleDeclaration::getPropertyValue(const AtomicString& key, ExceptionState& exception_state) {
  return item(key, exception_state).ToLegacyDOMString(ctx());
}

AtomicString ComputedCssStyleDeclaration::removeProperty(const AtomicString& key, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key)};
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kremoveProperty, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  return NativeValueConverter<NativeTypeString>::FromNativeValue(result);
}

bool ComputedCssStyleDeclaration::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key)};
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kcheckCSSProperty, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
}

void ComputedCssStyleDeclaration::NamedPropertyEnumerator(std::vector<AtomicString>& names,
                                                          ExceptionState& exception_state) {
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetFullCSSPropertyList, 0, nullptr,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  auto&& arr = NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), result);
  for (auto& i : arr) {
    names.emplace_back(i);
  }
}

bool ComputedCssStyleDeclaration::IsComputedCssStyleDeclaration() const {
  return true;
}

AtomicString ComputedCssStyleDeclaration::cssText() const {
  return AtomicString::Empty();
}

void ComputedCssStyleDeclaration::setCssText(const webf::AtomicString& value, webf::ExceptionState& exception_state) {}

}  // namespace webf