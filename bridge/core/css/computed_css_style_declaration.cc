/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "computed_css_style_declaration.h"
#include "binding_call_methods.h"
#include "core/binding_object.h"
#include "core/css/css_rule.h"
#include "core/css/properties/css_property.h"
#include "core/dom/element.h"
// #include "core/dom/exception_code.h"
#include "foundation/native_value.h"
#include "foundation/native_value_converter.h"
#include "foundation/string/string_builder.h"

namespace webf {

ComputedCssStyleDeclaration::ComputedCssStyleDeclaration(ExecutingContext* context)
   : CSSStyleDeclaration(context->ctx()) {}

ComputedCssStyleDeclaration::ComputedCssStyleDeclaration(ExecutingContext* context,
                                                         NativeBindingObject* nativeBindingObject)
   : CSSStyleDeclaration(context->ctx(), nativeBindingObject) {}

ScriptValue ComputedCssStyleDeclaration::item(const AtomicString& key, ExceptionState& exception_state) {
  if (IsPrototypeMethods(key)) {
    return ScriptValue::Undefined(ctx());
  }
  // Reuse the shared anonymous named getter logic so shorthand serialization
  // goes through GetPropertyValueInternal() where we can synthesize values.
  AtomicString result = AnonymousNamedGetter(key);
  return ScriptValue(ctx(), result);
}

// bool ComputedCssStyleDeclaration::DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
//   return true;
// }

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
  NativeValue result = GetBindingProperty(
    binding_call_methods::kcssText,
    FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION()
    );
 return AtomicString(NativeValueConverter<NativeTypeString>::FromNativeValue(result));
}

void ComputedCssStyleDeclaration::setCssText(const webf::AtomicString& value, webf::ExceptionState& exception_state) {}

CSSRule* ComputedCssStyleDeclaration::parentRule() const {
  // Computed styles don't have a parent rule
  return nullptr;
}

AtomicString ComputedCssStyleDeclaration::getPropertyPriority(const AtomicString& property_name) {
  // Computed styles don't have priorities
  return AtomicString::Empty();
}

AtomicString ComputedCssStyleDeclaration::GetPropertyShorthand(const AtomicString& property_name) {
  // TODO: Implement shorthand property detection for computed styles
  return AtomicString::Empty();
}

bool ComputedCssStyleDeclaration::IsPropertyImplicit(const AtomicString& property_name) {
  // Computed styles are explicit
  return false;
}

void ComputedCssStyleDeclaration::setProperty(const AtomicString& property_name,
                                            const AtomicString& value,
                                            const AtomicString& priority,
                                            ExceptionState& exception_state) {
  // Computed styles are read-only
  exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                "Cannot set property on computed style declaration");
}

const std::shared_ptr<const CSSValue>* ComputedCssStyleDeclaration::GetPropertyCSSValueInternal(CSSPropertyID property_id) {
  // TODO: Implement CSS value retrieval for computed styles
  return nullptr;
}

const std::shared_ptr<const CSSValue>* ComputedCssStyleDeclaration::GetPropertyCSSValueInternal(
    const AtomicString& custom_property_name) {
  // TODO: Implement custom property CSS value retrieval for computed styles
  return nullptr;
}

AtomicString ComputedCssStyleDeclaration::GetPropertyValueInternal(CSSPropertyID property_id) {
  // Resolve to hyphenated CSS property name and delegate to Dart side via binding call.
  // For shorthands that may not be serialized on the Dart side yet, synthesize
  // a value from computed longhands to match CSSOM expectations.
  const CSSProperty& prop = CSSProperty::Get(property_id);

  auto get_value_by_name = [&](const AtomicString& name) -> AtomicString {
    ExceptionState exception_state;
    NativeValue args[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), name)};
    NativeValue res = InvokeBindingMethod(
        binding_call_methods::kgetPropertyValue, 1, args,
        FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return AtomicString::Empty();
    }
    return AtomicString(NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(res)));
  };

  if (prop.IsShorthand()) {
    switch (property_id) {
      case CSSPropertyID::kBorderStyle: {
        AtomicString top = get_value_by_name(CSSProperty::Get(CSSPropertyID::kBorderTopStyle).GetPropertyNameString());
        AtomicString right = get_value_by_name(CSSProperty::Get(CSSPropertyID::kBorderRightStyle).GetPropertyNameString());
        AtomicString bottom = get_value_by_name(CSSProperty::Get(CSSPropertyID::kBorderBottomStyle).GetPropertyNameString());
        AtomicString left = get_value_by_name(CSSProperty::Get(CSSPropertyID::kBorderLeftStyle).GetPropertyNameString());

        // Condense to 1/2/3/4 values per CSS shorthand serialization rules.
        if (top == right && top == bottom && top == left) {
          return top;
        }
        if (top == bottom && right == left) {
          StringBuilder sb; sb.Append(top); sb.Append(" "_s); sb.Append(right);
          return AtomicString(sb.ReleaseString());
        }
        if (right == left) {
          StringBuilder sb; sb.Append(top); sb.Append(" "_s); sb.Append(right); sb.Append(" "_s); sb.Append(bottom);
          return AtomicString(sb.ReleaseString());
        }
        StringBuilder sb; sb.Append(top); sb.Append(" "_s); sb.Append(right); sb.Append(" "_s); sb.Append(bottom); sb.Append(" "_s); sb.Append(left);
        return AtomicString(sb.ReleaseString());
      }
      default:
        break;
    }
  }

  AtomicString css_name = prop.GetPropertyNameString();
  ExceptionState exception_state;
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), css_name)};
  NativeValue result = InvokeBindingMethod(
      binding_call_methods::kgetPropertyValue, 1, arguments,
      FlushUICommandReason::kDependentsOnElement | FlushUICommandReason::kDependentsOnLayout, exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return AtomicString::Empty();
  }
  return AtomicString(NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(result)));
}

AtomicString ComputedCssStyleDeclaration::GetPropertyValueWithHint(const AtomicString& property_name, unsigned index) {
  // Use the regular getPropertyValue method
  ExceptionState exception_state;
  return getPropertyValue(property_name, exception_state);
}

AtomicString ComputedCssStyleDeclaration::GetPropertyPriorityWithHint(const AtomicString& property_name, unsigned index) {
  // Computed styles don't have priorities
  return AtomicString::Empty();
}

void ComputedCssStyleDeclaration::SetPropertyInternal(CSSPropertyID property_id,
                                                    const AtomicString& property_name,
                                                    StringView value,
                                                    bool important,
                                                    ExceptionState& exception_state) {
  // Computed styles are read-only
  exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                "Cannot set property on computed style declaration");
}

bool ComputedCssStyleDeclaration::CssPropertyMatches(CSSPropertyID property_id, const CSSValue& value) const {
  // TODO: Implement property matching for computed styles
  return false;
}

const ComputedCssStyleDeclarationPublicMethods*
ComputedCssStyleDeclaration::computedCssStyleDeclarationPublicMethods() {
  static ComputedCssStyleDeclarationPublicMethods computed_css_style_declaration_public_methods;
  return &computed_css_style_declaration_public_methods;
}

}  // namespace webf
