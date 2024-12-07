/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WIDGET_ELEMENT_SHAPE_H
#define WIDGET_ELEMENT_SHAPE_H

#include <bindings/qjs/atomic_string.h>

#include <unordered_set>
#include "foundation/native_value.h"

namespace webf {

struct NativeWidgetElementShape {
  const char* name;
  NativeValue* properties;
  NativeValue* methods;
  NativeValue* async_methods;
};

class WidgetElementShape {
 public:
  WidgetElementShape(JSContext* ctx, NativeWidgetElementShape* native_widget_element_shape);

  bool HasPropertyOrMethod(const AtomicString& name) const;
  bool HasProperty(const AtomicString& name) const;
  bool HasMethod(const AtomicString& name) const;
  bool HasAsyncMethod(const AtomicString& name) const;

 private:
  void InitializeProperties(JSContext* ctx, NativeValue* properties);
  void InitializeMethods(JSContext* ctx, NativeValue* methods);
  void InitializeAsyncMethods(JSContext* ctx, NativeValue* async_methods);
  std::unordered_set<AtomicString, AtomicString::KeyHasher> built_in_properties_;
  std::unordered_set<AtomicString, AtomicString::KeyHasher> built_in_methods_;
  std::unordered_set<AtomicString, AtomicString::KeyHasher> built_in_async_methods_;
};

}  // namespace webf

#endif  // WIDGET_ELEMENT_SHAPE_H
