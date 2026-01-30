/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DART_BINDING_OBJECT_H_
#define BRIDGE_CORE_DART_BINDING_OBJECT_H_

#include "core/binding_object.h"

namespace webf {

// A generic BindingObject wrapper that exposes Dart-defined properties/methods to JavaScript.
// Instances are created by `__webf_create_binding_object__` and backed by Dart-side BindingObject instances.
class DartBindingObject final : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();
 public:
  explicit DartBindingObject(ExecutingContext* context);
  // Wrap an existing NativeBindingObject allocated on the Dart side (e.g. as a
  // return value from a Dart binding property/method).
  DartBindingObject(ExecutingContext* context, NativeBindingObject* native_binding_object);

  bool HasBindingProperty(const AtomicString& prop, ExceptionState& exception_state) const;
  // 0 = none, 1 = sync, 2 = async
  int GetBindingMethodType(const AtomicString& method, ExceptionState& exception_state) const;

  static JSValue StringPropertyGetter(JSContext* ctx, JSValue obj, JSAtom atom);
  static bool StringPropertySetter(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value);
  static bool PropertyChecker(JSContext* ctx, JSValueConst obj, JSAtom atom);

};

}  // namespace webf

#endif  // BRIDGE_CORE_DART_BINDING_OBJECT_H_
