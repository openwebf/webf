/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element_shape.h"

#include <native_value_converter.h>

namespace webf {

WidgetElementShape::WidgetElementShape(JSContext* ctx, NativeWidgetElementShape* native_widget_element_shape) {
  InitializeProperties(ctx, native_widget_element_shape->properties);
  InitializeMethods(ctx, native_widget_element_shape->methods);
  InitializeAsyncMethods(ctx, native_widget_element_shape->async_methods);
  InitializeDefaultAttributes(ctx, native_widget_element_shape->default_attributes);

  dart_free(const_cast<UTF8Char *>(native_widget_element_shape->name));
  dart_free(native_widget_element_shape->properties);
  dart_free(native_widget_element_shape->methods);
  dart_free(native_widget_element_shape->async_methods);
  dart_free(native_widget_element_shape->default_attributes);
}

bool WidgetElementShape::HasPropertyOrMethod(const AtomicString& name) const {
  return built_in_properties_.count(name) > 0 || built_in_methods_.count(name) > 0 ||
         built_in_async_methods_.count(name) > 0;
}

bool WidgetElementShape::HasProperty(const AtomicString& name) const {
  return built_in_properties_.count(name) > 0;
}

bool WidgetElementShape::HasMethod(const AtomicString& name) const {
  return built_in_methods_.count(name) > 0;
}

bool WidgetElementShape::HasAsyncMethod(const AtomicString& name) const {
  return built_in_async_methods_.count(name) > 0;
}

void WidgetElementShape::GetAllPropertyNames(std::vector<AtomicString>& names) const {
  names.reserve(built_in_properties_.size() + built_in_methods_.size() + built_in_async_methods_.size());

  for (auto&& property : built_in_properties_) {
    names.emplace_back(property);
  }

  for (auto&& property : built_in_methods_) {
    names.emplace_back(property);
  }

  for (auto&& property : built_in_async_methods_) {
    names.emplace_back(property);
  }
}

AtomicString WidgetElementShape::GetDefaultAttributeValue(const AtomicString& name) const {
  auto it = default_attributes_.find(name);
  if (it == default_attributes_.end()) {
    return AtomicString::Null();
  }
  return it->second;
}

void WidgetElementShape::InitializeProperties(JSContext* ctx, NativeValue* properties) {
  if (properties == nullptr) {
    return;
  }
  size_t length = properties->uint32;
  auto* head = static_cast<NativeValue*>(properties->u.ptr);

  for (int i = 0; i < length; i++) {
    built_in_properties_.emplace(NativeValueConverter<NativeTypeString>::FromNativeValue(head[i]));
  }

  dart_free(head);
}

void WidgetElementShape::InitializeMethods(JSContext* ctx, NativeValue* methods) {
  if (methods == nullptr) {
    return;
  }
  size_t length = methods->uint32;
  auto* head = static_cast<NativeValue*>(methods->u.ptr);
  for (int i = 0; i < length; i++) {
    built_in_methods_.emplace(NativeValueConverter<NativeTypeString>::FromNativeValue(head[i]));
  }

  dart_free(head);
}

void WidgetElementShape::InitializeAsyncMethods(JSContext* ctx, NativeValue* async_methods) {
  if (async_methods == nullptr) {
    return;
  }
  size_t length = async_methods->uint32;
  auto* head = static_cast<NativeValue*>(async_methods->u.ptr);
  for (int i = 0; i < length; i++) {
    built_in_async_methods_.emplace(NativeValueConverter<NativeTypeString>::FromNativeValue(head[i]));
  }

  dart_free(head);
}

void WidgetElementShape::InitializeDefaultAttributes(JSContext* ctx, NativeValue* default_attributes) {
  if (default_attributes == nullptr) {
    return;
  }
  size_t length = default_attributes->uint32;
  auto* head = static_cast<NativeValue*>(default_attributes->u.ptr);
  for (size_t i = 0; i + 1 < length; i += 2) {
    AtomicString name = NativeValueConverter<NativeTypeString>::FromNativeValue(head[i]);
    AtomicString value = NativeValueConverter<NativeTypeString>::FromNativeValue(head[i + 1]);
    if (name.IsNull() || name.empty()) {
      continue;
    }
    default_attributes_[name] = value;
  }
  dart_free(head);
}

}  // namespace webf
