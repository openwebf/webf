/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BINDINGS_QJS_CPPGC_TRACE_IF_NEEDED_H_
#define WEBF_BINDINGS_QJS_CPPGC_TRACE_IF_NEEDED_H_

// clang-format off
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/js_event_handler.h"
#include "bindings/qjs/js_event_listener.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/idl_type.h"
#include "gc_visitor.h"
#include "member.h"
// clang-format on

namespace webf {

template <typename T, typename SFINAEHelper = void>
struct TraceIfNeeded {
  using ImplType = T;
};

template <typename T>
struct TraceIfNeededBase {
  using ImplType = typename T::ImplType;
};

template <>
struct TraceIfNeeded<IDLDouble> : public TraceIfNeededBase<IDLDouble> {
  static void Trace(GCVisitor*, const ImplType&) {}
};

template <>
struct TraceIfNeeded<IDLInt64> : public TraceIfNeededBase<IDLDouble> {
  static void Trace(GCVisitor*, const ImplType&) {}
};

template <>
struct TraceIfNeeded<IDLInt32> : public TraceIfNeededBase<IDLDouble> {
  static void Trace(GCVisitor*, const ImplType&) {}
};

template <>
struct TraceIfNeeded<IDLDOMString> : TraceIfNeededBase<IDLDOMString> {
  static void Trace(GCVisitor*, const ImplType&) {}
};

template <typename T>
struct TraceIfNeeded<IDLSequence<T>> : TraceIfNeededBase<IDLSequence<T>> {
  using ImplType = typename IDLSequence<typename TraceIfNeeded<T>::ImplType>::ImplType;

  static void Trace(GCVisitor*, const ImplType&) {}
};

template <typename T>
struct TraceIfNeeded<T, typename std::enable_if_t<std::is_base_of<ScriptWrappable, T>::value>> {
  static void Trace(GCVisitor* visitor, const Member<T>& value) { visitor->Trace(value); }
};

template <>
struct TraceIfNeeded<IDLAny> : TraceIfNeededBase<IDLAny> {
  static void Trace(GCVisitor* visitor, const ImplType& value) { value.Trace(visitor); }
};

}  // namespace webf

#endif  // WEBF_BINDINGS_QJS_CPPGC_TRACE_IF_NEEDED_H_
