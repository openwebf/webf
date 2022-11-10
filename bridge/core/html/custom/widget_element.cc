/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element.h"
#include "built_in_string.h"
#include "core/dom/document.h"
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

bool WidgetElement::IsUnderScoreProperty(const AtomicString& name) {
  StringView string_view = name.ToStringView();

  const char* string = string_view.Characters8();
  return string_view.length() > 0 && string[0] == '_';
}

bool WidgetElement::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  NativeValue result = GetBindingProperty(key, exception_state);
  return result.tag != NativeTag::TAG_NULL;
}

void WidgetElement::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) {
  NativeValue result = GetAllBindingPropertyNames(exception_state);
  assert(result.tag == NativeTag::TAG_LIST);
  std::vector<AtomicString> property_names =
      NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), result);
  names.reserve(property_names.size());
  for (auto& property_name : property_names) {
    names.emplace_back(property_name);
  }
}

ScriptValue WidgetElement::item(const AtomicString& key, ExceptionState& exception_state) {
  // Properties with underscore are taken as raw javascript property.
  if (IsUnderScoreProperty(key)) {
    if (unimplemented_properties_.count(key) > 0) {
      return unimplemented_properties_[key];
    }

    return ScriptValue::Empty(ctx());
  }

  if (key == built_in_string::kSymbol_toStringTag) {
    return ScriptValue(ctx(), tagName().ToNativeString().release());
  }

  return ScriptValue(ctx(), GetBindingProperty(key, exception_state));
}

bool WidgetElement::SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) {
  if (IsUnderScoreProperty(key)) {
    unimplemented_properties_[key] = value;
    return true;
  }

  NativeValue result = SetBindingProperty(key, value.ToNative(exception_state), exception_state);
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
}

bool WidgetElement::IsWidgetElement() const {
  return true;
}

void WidgetElement::Trace(GCVisitor* visitor) const {
  HTMLElement::Trace(visitor);
  for (auto& entry : unimplemented_properties_) {
    entry.second.Trace(visitor);
  }
}

void WidgetElement::CloneNonAttributePropertiesFrom(const Element& other, CloneChildrenFlag flag) {
  auto* other_widget_element = DynamicTo<WidgetElement>(other);
  if (other_widget_element) {
    unimplemented_properties_ = other_widget_element->unimplemented_properties_;
  }
}

bool WidgetElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return true;
}

}  // namespace webf