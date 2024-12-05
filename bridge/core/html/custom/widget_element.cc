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

bool WidgetElement::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  return GetExecutingContext()->HasWidgetElementShape(key);
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

  std::string shape_key = tagName().ToStdString(ctx());
  std::string property_key = key.ToStdString(ctx());
  bool have_shape = true;

  // if (!GetExecutingContext()->dartIsolateContext()->EnsureData()->HasWidgetElementShape(shape_key)) {
  //   GetExecutingContext()->FlushUICommand(this, FlushUICommandReason::kDependentsOnElement);
  //   have_shape = false;
  // }
  //
  // if (key == built_in_string::kSymbol_toStringTag) {
  //   return ScriptValue(ctx(), tagName().ToNativeString(ctx()).release());
  // }
  //
  // const WidgetElementShape* shape = nullptr;
  //
  // if (have_shape) {
  //   shape = GetExecutingContext()->dartIsolateContext()->EnsureData()->GetWidgetElementShape(shape_key);
  // } else {
  //   NativeValue raw_shapes[3];
  //   bool is_success = GetExecutingContext()->dartMethodPtr()->getWidgetElementShape(
  //       GetExecutingContext()->isDedicated(), contextId(), bindingObject(),
  //       reinterpret_cast<NativeValue*>(&raw_shapes));
  //   if (is_success) {
  //     shape = SaveWidgetElementsShapeData(raw_shapes);
  //   }
  // }
  //
  // if (shape != nullptr) {
  //   if (shape->built_in_properties_.find(property_key) != shape->built_in_properties_.end()) {
  //     return ScriptValue(ctx(), GetBindingProperty(key, FlushUICommandReason::kDependentsOnElement, exception_state));
  //   }
  //
  //   if (shape->built_in_methods_.find(property_key) != shape->built_in_methods_.end()) {
  //     if (cached_methods_.count(key) > 0) {
  //       return cached_methods_[key];
  //     }
  //
  //     auto func = CreateSyncMethodFunc(key);
  //     cached_methods_[key] = func;
  //     return func;
  //   }
  //
  //   if (shape->built_in_async_methods_.find(property_key) != shape->built_in_async_methods_.end()) {
  //     if (async_cached_methods_.count(key) > 0) {
  //       return async_cached_methods_[key];
  //     }
  //
  //     auto func = CreateAsyncMethodFunc(key);
  //     async_cached_methods_[key] = CreateAsyncMethodFunc(key);
  //     return func;
  //   }
  // }

  return ScriptValue::Undefined(ctx());
}

bool WidgetElement::SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) {
  // if (!GetExecutingContext()->dartIsolateContext()->EnsureData()->HasWidgetElementShape(tagName().ToStdString(ctx()))) {
  //   GetExecutingContext()->FlushUICommand(this, FlushUICommandReason::kDependentsOnElement);
  // }
  //
  // auto shape =
  //     GetExecutingContext()->dartIsolateContext()->EnsureData()->GetWidgetElementShape(tagName().ToStdString(ctx()));
  // // This property is defined in the Dart side
  // if (shape != nullptr && shape->built_in_properties_.count(key.ToStdString(ctx())) > 0) {
  //   NativeValue result = SetBindingProperty(key, value.ToNative(ctx(), exception_state), exception_state);
  //   return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  // }
  //
  // // This property is defined in WidgetElement.prototype, should return false to let it handled in the prototype
  // // methods.
  // JSValue prototypeObject = GetExecutingContext()->contextData()->prototypeForType(GetWrapperTypeInfo());
  // if (JS_HasProperty(ctx(), prototypeObject, key.Impl())) {
  //   return false;
  // }

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


}  // namespace webf