/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element.h"
#include "binding_call_methods.h"
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

bool WidgetElement::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  return GetExecutingContext()->dartContext()->EnsureData()->HasWidgetElementShape(key);
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

NativeValue WidgetElement::HandleCallFromDartSide(const NativeValue* native_method,
                                                  int32_t argc,
                                                  const NativeValue* argv) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  AtomicString method = NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), *native_method);

  if (method == binding_call_methods::ksyncPropertiesAndMethods) {
    return HandleSyncPropertiesAndMethodsFromDart(argc, argv);
  }

  return Element::HandleCallFromDartSide(native_method, argc, argv);
}

ScriptValue WidgetElement::item(const AtomicString& key, ExceptionState& exception_state) {
  if (unimplemented_properties_.count(key) > 0) {
    return unimplemented_properties_[key];
  }

  if (!GetExecutingContext()->dartContext()->EnsureData()->HasWidgetElementShape(tag_name_)) {
    GetExecutingContext()->FlushUICommand();
  }

  if (key == built_in_string::kSymbol_toStringTag) {
    return ScriptValue(ctx(), tagName().ToNativeString(ctx()).release());
  }

  auto shape = GetExecutingContext()->dartContext()->EnsureData()->GetWidgetElementShape(tag_name_);
  if (shape != nullptr) {
    if (shape->built_in_properties_.count(key) > 0) {
      return ScriptValue(ctx(), GetBindingProperty(key, exception_state));
    }

    if (shape->built_in_methods_.count(key) > 0) {
      if (cached_methods_.count(key) > 0) {
        return cached_methods_[key];
      }

      auto func = CreateSyncMethodFunc(key);
      cached_methods_[key] = func;
      return func;
    }

    if (shape->built_in_async_methods_.count(key) > 0) {
      if (async_cached_methods_.count(key) > 0) {
        return async_cached_methods_[key];
      }

      auto func = CreateAsyncMethodFunc(key);
      async_cached_methods_[key] = CreateAsyncMethodFunc(key);
      return func;
    }
  }

  return ScriptValue::Empty(ctx());
}

bool WidgetElement::SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) {
  if (!GetExecutingContext()->dartContext()->EnsureData()->HasWidgetElementShape(tag_name_)) {
    GetExecutingContext()->FlushUICommand();
  }

  auto shape = GetExecutingContext()->dartContext()->EnsureData()->GetWidgetElementShape(tag_name_);
  if (shape != nullptr && shape->built_in_properties_.count(key) > 0) {
    NativeValue result = SetBindingProperty(key, value.ToNative(exception_state), exception_state);
    return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  }

  unimplemented_properties_[key] = value;
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

void WidgetElement::CloneNonAttributePropertiesFrom(const Element& other, CloneChildrenFlag flag) {
  auto* other_widget_element = DynamicTo<WidgetElement>(other);
  if (other_widget_element) {
    unimplemented_properties_ = other_widget_element->unimplemented_properties_;
  }
}

bool WidgetElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return true;
}

NativeValue WidgetElement::HandleSyncPropertiesAndMethodsFromDart(int32_t argc, const NativeValue* argv) {
  assert(argc == 3);
  AtomicString key = tag_name_;
  assert(!GetExecutingContext()->dartContext()->EnsureData()->HasWidgetElementShape(key));

  auto shape = std::make_shared<WidgetElementShape>();

  auto&& properties = NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), argv[0]);
  auto&& sync_methods = NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), argv[1]);
  auto&& async_methods = NativeValueConverter<NativeTypeArray<NativeTypeString>>::FromNativeValue(ctx(), argv[2]);

  for (auto& property : properties) {
    shape->built_in_properties_.emplace(property);
  }

  for (auto& method : sync_methods) {
    shape->built_in_methods_.emplace(method);
  }

  for (auto& method : async_methods) {
    shape->built_in_async_methods_.emplace(method);
  }

  GetExecutingContext()->dartContext()->EnsureData()->SetWidgetElementShape(key, shape);

  return Native_NewBool(true);
}

ScriptValue WidgetElement::CreateSyncMethodFunc(const AtomicString& method_name) {
  auto* data = new BindingObject::AnonymousFunctionData();
  data->method_name = method_name.ToStdString();
  return ScriptValue(ctx(),
                     QJSFunction::Create(ctx(), BindingObject::AnonymousFunctionCallback, 1, data)->ToQuickJSUnsafe());
}

ScriptValue WidgetElement::CreateAsyncMethodFunc(const AtomicString& method_name) {
  auto* data = new BindingObject::AnonymousFunctionData();
  data->method_name = method_name.ToStdString();
  return ScriptValue(
      ctx(), QJSFunction::Create(ctx(), BindingObject::AnonymousAsyncFunctionCallback, 4, data)->ToQuickJSUnsafe());
}

}  // namespace webf