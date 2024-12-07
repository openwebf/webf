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

void WidgetElementShape::InitializeProperties(JSContext* ctx, NativeValue* properties) {
  size_t length = properties->uint32;
  auto* head = static_cast<NativeValue*>(properties->u.ptr);

  for (int i = 0; i < length; i++) {
    built_in_properties_.emplace(NativeValueConverter<NativeTypeString>::FromNativeValue(ctx, head[i]));
  }
}

void WidgetElementShape::InitializeMethods(JSContext* ctx, NativeValue* methods) {
  size_t length = methods->uint32;
  auto* head = static_cast<NativeValue*>(methods->u.ptr);
  for (int i = 0; i < length; i++) {
    built_in_methods_.emplace(NativeValueConverter<NativeTypeString>::FromNativeValue(ctx, head[i]));
  }
}

void WidgetElementShape::InitializeAsyncMethods(JSContext* ctx, NativeValue* async_methods) {
  size_t length = async_methods->uint32;
  auto* head = static_cast<NativeValue*>(async_methods->u.ptr);
  for (int i = 0; i < length; i++) {
    built_in_async_methods_.emplace(NativeValueConverter<NativeTypeString>::FromNativeValue(ctx, head[i]));
  }
}

}  // namespace webf