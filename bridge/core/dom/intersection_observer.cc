// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#include "core/dom/intersection_observer.h"

#include <algorithm>
#include <limits>

#include <native_value_converter.h>
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/converter_impl.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/intersection_observer_entry.h"
#include "core/dom/legacy/bounding_client_rect.h"
#include "core/dom/node.h"
#include "core/executing_context.h"
#include "foundation/dart_readable.h"
#include "foundation/logging.h"
#include "qjs_intersection_observer_init.h"
#include "qjs_union_double_sequencedouble.h"

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
  if (observer_init && observer_init->hasRoot()) {
    root_ = observer_init->root();
  }
  if (observer_init && observer_init->hasRootMargin()) {
    root_margin_ = observer_init->rootMargin();
  }
  if (observer_init && observer_init->hasScrollMargin()) {
    scroll_margin_ = observer_init->scrollMargin();
  }
  if (observer_init && observer_init->hasDelay()) {
    delay_ = std::max(0.0, observer_init->delay());
  }
  if (observer_init && observer_init->hasTrackVisibility()) {
    track_visibility_ = observer_init->trackVisibility();
  }
  // https://wicg.github.io/IntersectionObserver/#dom-intersectionobserverinit-trackvisibility
  // When tracking visibility, enforce the minimum delay to avoid high-frequency observation.
  if (track_visibility_ && delay_ < 100.0) {
    delay_ = 100.0;
  }
  NativeValue arguments[1];
  int32_t argc = 0;
  if (observer_init && observer_init->hasThreshold()) {
    auto threshold = observer_init->threshold();
    if (threshold != nullptr) {
      if (threshold->IsDouble()) {
        thresholds_ = {threshold->GetAsDouble()};
      } else if (threshold->IsSequenceDouble()) {
        thresholds_ = threshold->GetAsSequenceDouble();
      }
    }
    if (thresholds_.empty()) {
      thresholds_.push_back(0.0);
    }
    std::sort(thresholds_.begin(), thresholds_.end());
    thresholds_.erase(std::unique(thresholds_.begin(), thresholds_.end()), thresholds_.end());
    arguments[0] = NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(thresholds_);
    argc = 1;
  }
  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateIntersectionObserver, argc > 0 ? arguments : nullptr, argc);
}

bool IntersectionObserver::RootIsValid() const {
  return RootIsImplicit() || root();
}

void IntersectionObserver::observe(Element* target, ExceptionState& exception_state) {
  if (!RootIsValid() || !target) {
    return;
  }

  // Keep this observer alive while it has active observation targets.
  const bool was_empty = observed_targets_.empty();
  const NativeBindingObject* target_binding_object = target->bindingObject();
  const bool inserted = observed_targets_.insert(target_binding_object).second;
  if (inserted && was_empty) {
    keep_alive_ = true;
    KeepAlive();
    MemberMutationScope scope{GetExecutingContext()};
    if (auto* document = GetExecutingContext()->document()) {
      document->RegisterIntersectionObserver(this);
    }
  }

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kAddIntersectionObserver, nullptr, bindingObject(),
                                                       target->bindingObject());
}

void IntersectionObserver::unobserve(Element* target, ExceptionState& exception_state) {
  if (!target) {
    return;
  }

  if (observed_targets_.erase(target->bindingObject()) > 0 && observed_targets_.empty()) {
    MemberMutationScope scope{GetExecutingContext()};
    if (auto* document = GetExecutingContext()->document()) {
      document->UnregisterIntersectionObserver(this);
    }
    if (keep_alive_) {
      keep_alive_ = false;
      ReleaseAlive();
    }
  }

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kRemoveIntersectionObserver, nullptr, bindingObject(),
                                                       target->bindingObject());
}

void IntersectionObserver::disconnect(ExceptionState& exception_state) {
  if (!observed_targets_.empty()) {
    MemberMutationScope scope{GetExecutingContext()};
    if (auto* document = GetExecutingContext()->document()) {
      document->UnregisterIntersectionObserver(this);
    }
    observed_targets_.clear();
    if (keep_alive_) {
      keep_alive_ = false;
      ReleaseAlive();
    }
  }
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kDisconnectIntersectionObserver, nullptr,
                                                       bindingObject(), nullptr);
}

std::vector<IntersectionObserverEntry*> IntersectionObserver::takeRecords(ExceptionState& exception_state) {
  static const AtomicString kTakeRecords = AtomicString::CreateFromUTF8("takeRecords");

  NativeValue result = InvokeBindingMethod(kTakeRecords, 0, nullptr, FlushUICommandReason::kStandard, exception_state);
  if (exception_state.HasException()) {
    return {};
  }

  auto* entry_list =
      NativeValueConverter<NativeTypePointer<NativeIntersectionObserverEntryList>>::FromNativeValue(result);
  if (entry_list == nullptr) {
    return {};
  }

  if (entry_list->entries == nullptr || entry_list->length <= 0) {
    if (entry_list->entries != nullptr) {
      dart_free(entry_list->entries);
    }
    dart_free(entry_list);
    return {};
  }

  auto* native_entries = entry_list->entries;
  const int32_t length = entry_list->length;
  std::vector<IntersectionObserverEntry*> records;
  records.reserve(length);

  for (int32_t i = 0; i < length; i++) {
    const bool is_intersecting = native_entries[i].is_intersecting == 1;
    const bool is_visible = track_visibility_ && is_intersecting;
    auto* target = DynamicTo<Element>(BindingObject::From(native_entries[i].target));
    auto* bounding_client_rect = native_entries[i].boundingClientRect != nullptr
                                     ? BoundingClientRect::Create(GetExecutingContext(),
                                                                  native_entries[i].boundingClientRect)
                                     : nullptr;
    auto* root_bounds =
        native_entries[i].rootBounds != nullptr
            ? BoundingClientRect::Create(GetExecutingContext(), native_entries[i].rootBounds)
            : nullptr;
    auto* intersection_rect =
        native_entries[i].intersectionRect != nullptr
            ? BoundingClientRect::Create(GetExecutingContext(), native_entries[i].intersectionRect)
            : nullptr;
    auto* entry = MakeGarbageCollected<IntersectionObserverEntry>(GetExecutingContext(),
                                                                  is_intersecting,
                                                                  is_visible,
                                                                  native_entries[i].intersectionRatio,
                                                                  target,
                                                                  bounding_client_rect,
                                                                  root_bounds,
                                                                  intersection_rect);
    records.push_back(entry);
  }

  dart_free(native_entries);
  dart_free(entry_list);
  return records;
}

NativeValue IntersectionObserver::HandleCallFromDartSide(const AtomicString& method,
                                                         int32_t argc,
                                                         const NativeValue* argv,
                                                         Dart_Handle dart_object) {
  if (!GetExecutingContext() || !GetExecutingContext()->IsContextValid()) {
    return Native_NewNull();
  }

  MemberMutationScope scope{GetExecutingContext()};

  NativeIntersectionObserverEntry* native_entry =
      NativeValueConverter<NativeTypePointer<NativeIntersectionObserverEntry>>::FromNativeValue(argv[0]);
  size_t length = NativeValueConverter<NativeTypeInt64>::FromNativeValue(argv[1]);

  if (length > 0) {
    assert(function_ != nullptr);
    JSValue js_array = JS_NewArray(ctx());
    for (int i = 0; i < length; i++) {
      const bool is_intersecting = native_entry[i].is_intersecting == 1;
      const bool is_visible = track_visibility_ && is_intersecting;
      auto* target = DynamicTo<Element>(BindingObject::From(native_entry[i].target));
      auto* bounding_client_rect = native_entry[i].boundingClientRect != nullptr
                                     ? BoundingClientRect::Create(GetExecutingContext(), native_entry[i].boundingClientRect)
                                     : nullptr;
      auto* root_bounds = native_entry[i].rootBounds != nullptr
                            ? BoundingClientRect::Create(GetExecutingContext(), native_entry[i].rootBounds)
                            : nullptr;
      auto* intersection_rect = native_entry[i].intersectionRect != nullptr
                                  ? BoundingClientRect::Create(GetExecutingContext(), native_entry[i].intersectionRect)
                                  : nullptr;
      auto* entry = MakeGarbageCollected<IntersectionObserverEntry>(GetExecutingContext(),
                                                                    is_intersecting,
                                                                    is_visible,
                                                                    native_entry[i].intersectionRatio,
                                                                    target,
                                                                    bounding_client_rect,
                                                                    root_bounds,
                                                                    intersection_rect);
      JS_SetPropertyUint32(ctx(), js_array, i, entry->ToQuickJS());
    }
    ScriptValue arguments[] = {ScriptValue(ctx(), js_array), ToValue()};

    function_->Invoke(ctx(), ToValue(), 2, arguments);

    JS_FreeValue(ctx(), js_array);
  }

  return Native_NewNull();
}

void IntersectionObserver::Trace(GCVisitor* visitor) const {
  BindingObject::Trace(visitor);

  function_->Trace(visitor);
}

}  // namespace webf
