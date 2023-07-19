/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_
#define BRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"

namespace webf {

class ExecutingContext;

class BoundingClientRect : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = BoundingClientRect*;
  BoundingClientRect() = delete;
  static BoundingClientRect* Create(ExecutingContext* context, NativeBindingObject* native_binding_object);
  explicit BoundingClientRect(ExecutingContext* context, NativeBindingObject* native_binding_object);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

  double x() const { return x_; }
  double y() const { return y_; }
  double width() const { return width_; }
  double height() const { return height_; }
  double top() const { return top_; }
  double right() const { return right_; }
  double bottom() const { return bottom_; }
  double left() const { return left_; }

 private:
  double x_;
  double y_;
  double width_;
  double height_;
  double top_;
  double right_;
  double bottom_;
  double left_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_
