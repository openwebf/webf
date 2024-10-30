/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_point.h"
#include "core/executing_context.h"

namespace webf {

DOMPoint* DOMPoint::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, exception_state);
}

DOMPoint* DOMPoint::Create(ExecutingContext* context, double x, ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, x, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context, double x, double y, ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, x, y, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context, double x, double y, double z, ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, x, y, z, exception_state);
}
DOMPoint* DOMPoint::Create(ExecutingContext* context,
                           double x,
                           double y,
                           double z,
                           double w,
                           ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPoint>(context, x, y, z, w, exception_state);
}

DOMPoint::DOMPoint(webf::ExecutingContext* context, webf::ExceptionState& exception_state)
    : DOMPointReadonly(context, exception_state) {}

DOMPoint::DOMPoint(ExecutingContext* context, double x, ExceptionState& exception_state)
    : DOMPointReadonly(context, x, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context, double x, double y, ExceptionState& exception_state)
    : DOMPointReadonly(context, x, y, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context, double x, double y, double z, ExceptionState& exception_state)
    : DOMPointReadonly(context, x, y, z, exception_state) {}
DOMPoint::DOMPoint(ExecutingContext* context, double x, double y, double z, double w, ExceptionState& exception_state)
    : DOMPointReadonly(context, x, y, z, w, exception_state) {}

}  // namespace webf
