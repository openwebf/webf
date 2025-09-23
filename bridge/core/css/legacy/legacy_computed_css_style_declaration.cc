/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "legacy_computed_css_style_declaration.h"
#include "binding_call_methods.h"
#include "core/binding_object.h"
//#include "core/dom/element.h"
#include "foundation/native_value.h"
#include "foundation/native_value_converter.h"
#include "plugin_api/legacy_computed_css_style_declaration.h"

namespace webf {
namespace legacy {


LegacyComputedCssStyleDeclaration::LegacyComputedCssStyleDeclaration(ExecutingContext* context,
                                                         NativeBindingObject* native_binding_object)
    : LegacyCssStyleDeclaration(context->ctx(), native_binding_object) {}

ScriptValue LegacyComputedCssStyleDeclaration::item(const AtomicString& key, ExceptionState& exception_state) {
  if (IsPrototypeMethods(key)) {
    return ScriptValue::Undefined(ctx());
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key)};

  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetPropertyValue, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  return ScriptValue(ctx(), NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(result)));
}

bool LegacyComputedCssStyleDeclaration::SetItem(const AtomicString& key,
                                          const ScriptValue& value,
                                          ExceptionState& exception_state) {
  NativeValue arguments[] = {
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key),
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), value.ToLegacyDOMString(ctx()))};
  InvokeBindingMethod(binding_call_methods::ksetProperty, 2, arguments,
                      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout,
                      exception_state);
  return true;
}

bool LegacyComputedCssStyleDeclaration::DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  return true;
}

unsigned LegacyComputedCssStyleDeclaration::length() const {
  NativeValue result = GetBindingProperty(
      binding_call_methods::klength,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeInt64>::FromNativeValue(result);
}

ScriptPromise LegacyComputedCssStyleDeclaration::length_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(binding_call_methods::klength, exception_state);
}

AtomicString LegacyComputedCssStyleDeclaration::getPropertyValue(const AtomicString& key, ExceptionState& exception_state) {
  return item(key, exception_state).ToLegacyDOMString(ctx());
}

void LegacyComputedCssStyleDeclaration::setProperty(const AtomicString& key,
                                              const ScriptValue& value,
                                              const AtomicString& priority,
                                              ExceptionState& exception_state) {
  SetItem(key, value, exception_state);
}

void LegacyComputedCssStyleDeclaration::setProperty_async(const webf::AtomicString& key,
                                                    const webf::ScriptValue& value,
                                                    const AtomicString& priority,
                                                    webf::ExceptionState& exception_state) {
  NativeValue arguments[] = {
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key),
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), value.ToLegacyDOMString(ctx()))};
  InvokeBindingMethodAsync(binding_call_methods::ksetProperty, 2, arguments, exception_state);
}

AtomicString LegacyComputedCssStyleDeclaration::removeProperty(const AtomicString& key, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key)};
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kremoveProperty, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  return NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(result));
}

bool LegacyComputedCssStyleDeclaration::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), key)};
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kcheckCSSProperty, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
}

void LegacyComputedCssStyleDeclaration::NamedPropertyEnumerator(std::vector<AtomicString>& names,
                                                          ExceptionState& exception_state) {
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetFullCSSPropertyList, 0, nullptr,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  auto&& arr = NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), result);
  for (auto& i : arr) {
    names.emplace_back(i);
  }
}

bool LegacyComputedCssStyleDeclaration::IsComputedCssStyleDeclaration() const {
  return true;
}

AtomicString LegacyComputedCssStyleDeclaration::cssText() const {
  return AtomicString::Empty();
}

ScriptPromise LegacyComputedCssStyleDeclaration::cssText_async(ExceptionState& exception_state) {
  return ScriptPromise(ctx(), JS_NULL);
}

void LegacyComputedCssStyleDeclaration::setCssText(const webf::AtomicString& value, webf::ExceptionState& exception_state) {}

const LegacyComputedCssStyleDeclarationPublicMethods*
LegacyComputedCssStyleDeclaration::legacyComputedCssStyleDeclarationPublicMethods() {
  static LegacyComputedCssStyleDeclarationPublicMethods computed_css_style_declaration_public_methods;
  return &computed_css_style_declaration_public_methods;
}

ScriptPromise LegacyComputedCssStyleDeclaration::setCssText_async(const AtomicString& value,
                                                            ExceptionState& exception_state) {
  return ScriptPromise(ctx(), JS_NULL);
}

}
}  // namespace webf
