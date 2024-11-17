/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_point.h"
#include "core/executing_context.h"

namespace webf {

DOMPoint* DOMPoint::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context,
                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                           ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, init, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context,
                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                           double y,
                           ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, init, y, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context,
                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                           double y,
                           double z,
                           ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, init, y, z, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context,
                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init ,
                           double y,
                           double z,
                           double w,
                           ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, init, y, z, w, exception_state);
}

DOMPoint::DOMPoint(webf::ExecutingContext* context, webf::ExceptionState& exception_state)
    : DOMPointReadOnly(context, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context,
                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                   ExceptionState& exception_state)
    : DOMPointReadOnly(context, init, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context,
                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                   double y,
                   ExceptionState& exception_state)
    : DOMPointReadOnly(context, init, y, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context,
                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                   double y,
                   double z,
                   ExceptionState& exception_state)
    : DOMPointReadOnly(context, init, y, z, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context,
                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                   double y,
                   double z,
                   double w,
                   ExceptionState& exception_state)
    : DOMPointReadOnly(context, init, y, z, w, exception_state) {}
DOMPoint::DOMPoint(webf::ExecutingContext* context, webf::NativeBindingObject* native_binding_object)
    : DOMPointReadOnly(context, native_binding_object) {}

}  // namespace webf
