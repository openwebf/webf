// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#include "core/dom/intersection_observer.h"

#include <algorithm>
#include <limits>

#include "core/dom/element.h"
#include <native_value_converter.h>
#include "bindings/qjs/converter_impl.h"
#include "core/dom/intersection_observer_entry.h"
#include "core/dom/node.h"
#include "core/executing_context.h"
#include "qjs_intersection_observer_init.h"
#include "foundation/logging.h"

namespace webf {

IntersectionObserver* IntersectionObserver::Create(ExecutingContext* context,
                                                   const std::shared_ptr<QJSFunction>& function,
                                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<IntersectionObserver>(context, function);
}

IntersectionObserver* IntersectionObserver::Create(ExecutingContext* context,
                                                   const std::shared_ptr<QJSFunction>& function,
                                                   const std::shared_ptr<IntersectionObserverInit>& observer_init,
                                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<IntersectionObserver>(context, function, observer_init);
}

IntersectionObserver::IntersectionObserver(ExecutingContext* context, const std::shared_ptr<QJSFunction>& function)
    : BindingObject(context->ctx()), function_(function) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateIntersectionObserver, nullptr, 0);
}

IntersectionObserver::IntersectionObserver(ExecutingContext* context,
                                           const std::shared_ptr<QJSFunction>& function,
                                           const std::shared_ptr<IntersectionObserverInit>& observer_init)
    : BindingObject(context->ctx()), function_(function) {
  if (observer_init->hasRoot()) {
    root_ = observer_init->root();
  }
  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateIntersectionObserver, nullptr, 0);
}

bool IntersectionObserver::RootIsValid() const {
  return RootIsImplicit() || root();
}

void IntersectionObserver::observe(Element* target, ExceptionState& exception_state) {
  if (!RootIsValid() || !target)
    return;

  // TODO(pengfei12.guo@vipshop.com): 通知dart，注册IntersectionObserver
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kAddIntersectionObserver, nullptr, bindingObject(),
                                                       target->bindingObject());
}

void IntersectionObserver::unobserve(Element* target, ExceptionState& exception_state) {
  if (!target)
    return;

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kRemoveIntersectionObserver, nullptr, bindingObject(),
                                                       target->bindingObject());
}

void IntersectionObserver::disconnect(ExceptionState& exception_state) {
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kDisconnectIntersectionObserver, nullptr,
                                                       bindingObject(), nullptr);
}

// std::vector<Member<IntersectionObserverEntry>> IntersectionObserver::takeRecords(ExceptionState& exception_state) {
//   std::vector<Member<IntersectionObserverEntry>> entries;
//   for (auto& observation : observations_)
//     observation->TakeRecords(entries);
//   active_observations_.clear();
//   return entries;
// }

// AtomicString IntersectionObserver::rootMargin() const {
//   return StringifyMargin(RootMargin());
// }

// AtomicString IntersectionObserver::scrollMargin() const {
//   return StringifyMargin(ScrollMargin());
// }

// using InvokeBindingMethodsFromDart = void (*)(NativeBindingObject* binding_object,
//                                               int64_t profile_id,
//                                               NativeValue* method,
//                                               int32_t argc,
//                                               NativeValue* argv,
//                                               Dart_Handle dart_object,
//                                               DartInvokeResultCallback result_callback);
NativeValue IntersectionObserver::HandleCallFromDartSide(const AtomicString& method,
                                                         int32_t argc,
                                                         const NativeValue* argv,
                                                         Dart_Handle dart_object) {
   if (!GetExecutingContext() || !GetExecutingContext()->IsContextValid()) {
    WEBF_LOG(ERROR) << "[IntersectionObserver]: HandleCallFromDartSide Context Valid" << std::endl;
    return Native_NewNull();
  }

  WEBF_LOG(DEBUG) << "[IntersectionObserver]: HandleCallFromDartSide NativeValueConverter" << std::endl;
  NativeValue native_entry_list = argv[0];
  std::vector<IntersectionObserverEntry*> entries =
      NativeValueConverter<NativeTypeArray<NativeTypePointer<IntersectionObserverEntry>>>::FromNativeValue(
          ctx(), native_entry_list);

  if (!entries.empty()) {
    assert(function_ != nullptr);

    WEBF_LOG(DEBUG) << "[IntersectionObserver]: HandleCallFromDartSide To JSValue" << std::endl;
    JSValue v = Converter<IDLSequence<IntersectionObserverEntry>>::ToValue(ctx(), entries);
    ScriptValue arguments[] = {ScriptValue(ctx(), v), ToValue()};

    JS_FreeValue(ctx(), v);

    WEBF_LOG(DEBUG) << "[IntersectionObserver]: HandleCallFromDartSide function_ Invoke" << std::endl;
    function_->Invoke(ctx(), ToValue(), 2, arguments);
  } else {
    WEBF_LOG(ERROR) << "[IntersectionObserver]: HandleCallFromDartSide entries is empty";
  }

  return Native_NewNull();
}

void IntersectionObserver::Trace(GCVisitor* visitor) const {
  BindingObject::Trace(visitor);
  BindingObject::Trace(visitor);

  function_->Trace(visitor);
}

}  // namespace webf
