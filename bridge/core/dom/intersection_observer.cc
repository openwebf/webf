// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#include "core/dom/intersection_observer.h"

#include <algorithm>
#include <limits>

#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/element_intersection_observer_data.h"
//#include "core/dom/intersection_observer_controller.h"
// #include "core/dom/intersection_observer_delegate.h"
#include <native_value_converter.h>

#include "bindings/qjs/converter_impl.h"
#include "core/dom/intersection_observer_entry.h"
#include "core/dom/node.h"
#include "core/executing_context.h"
#include "qjs_intersection_observer_init.h"
#include "foundation/logging.h"

namespace webf {

/*
IntersectionObserver* IntersectionObserver::Create(
    const IntersectionObserverInit* observer_init,
    IntersectionObserverDelegate& delegate,
    std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id,
    ExceptionState& exception_state) {
  Node* root = nullptr;
  if (observer_init->root()) {
    switch (observer_init->root()->GetContentType()) {
      case V8UnionDocumentOrElement::ContentType::kDocument:
        root = observer_init->root()->GetAsDocument();
        break;
      case V8UnionDocumentOrElement::ContentType::kElement:
        root = observer_init->root()->GetAsElement();
        break;
    }
  }

  Params params = {
      .root = root,
      .delay = base::Milliseconds(observer_init->delay()),
      .track_visibility = observer_init->trackVisibility(),
  };
  if (params.track_visibility && params.delay < base::Milliseconds(100)) {
    exception_state.ThrowDOMException(
        DOMExceptionCode::kNotSupportedError,
        "To enable the 'trackVisibility' option, you must also use a "
        "'delay' option with a value of at least 100. Visibility is more "
        "expensive to compute than the basic intersection; enabling this "
        "option may negatively affect your page's performance. Please make "
        "sure you *really* need visibility tracking before enabling the "
        "'trackVisibility' option.");
    return nullptr;
  }

  ParseMargin(observer_init->rootMargin(), params.margin, exception_state,
              "root");
  if (exception_state.HadException()) {
    return nullptr;
  }

  if (RuntimeEnabledFeatures::IntersectionObserverScrollMarginEnabled()) {
    ParseMargin(observer_init->scrollMargin(), params.scroll_margin,
                exception_state, "scroll");
    if (exception_state.HadException()) {
      return nullptr;
    }
  }

  ParseThresholds(observer_init->threshold(), params.thresholds,
                  exception_state);
  if (exception_state.HadException()) {
    return nullptr;
  }

  return MakeGarbageCollected<IntersectionObserver>(delegate, ukm_metric_id,
                                                    std::move(params));
}

IntersectionObserver* IntersectionObserver::Create(
    ScriptState* script_state,
    V8IntersectionObserverCallback* callback,
    const IntersectionObserverInit* observer_init,
    ExceptionState& exception_state) {
  V8IntersectionObserverDelegate* delegate =
      MakeGarbageCollected<V8IntersectionObserverDelegate>(callback,
                                                           script_state);
  if (observer_init && observer_init->trackVisibility()) {
    UseCounter::Count(delegate->GetExecutionContext(),
                      WebFeature::kIntersectionObserverV2);
  }
  return Create(observer_init, *delegate,
                LocalFrameUkmAggregator::kJavascriptIntersectionObserver,
                exception_state);
}

IntersectionObserver* IntersectionObserver::Create(
    const Document& document,
    EventCallback callback,
    std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id,
    Params&& params) {
  IntersectionObserverDelegateImpl* intersection_observer_delegate =
      MakeGarbageCollected<IntersectionObserverDelegateImpl>(
          document.GetExecutionContext(), std::move(callback), params.behavior,
          params.needs_initial_observation_with_detached_target);
  return MakeGarbageCollected<IntersectionObserver>(
      *intersection_observer_delegate, ukm_metric_id, std::move(params));
}

IntersectionObserver::IntersectionObserver(
    IntersectionObserverDelegate& delegate,
    std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id,
    Params&& params)
    : ActiveScriptWrappable<IntersectionObserver>({}),
      ExecutionContextClient(delegate.GetExecutionContext()),
      delegate_(&delegate),
      ukm_metric_id_(ukm_metric_id),
      root_(params.root),
      thresholds_(std::move(params.thresholds)),
      delay_(params.delay),
      margin_(NormalizeMargins(params.margin)),
      scroll_margin_(NormalizeScrollMargins(params.scroll_margin)),
      margin_target_(params.margin_target),
      root_is_implicit_(params.root ? 0 : 1),
      track_visibility_(params.track_visibility),
      track_fraction_of_root_(params.semantics == kFractionOfRoot),
      always_report_root_bounds_(params.always_report_root_bounds),
      use_overflow_clip_edge_(params.use_overflow_clip_edge) {
  if (params.root) {
    if (params.root->IsDocumentNode()) {
      To<Document>(params.root)
          ->EnsureDocumentExplicitRootIntersectionObserverData()
          .AddObserver(*this);
    } else {
      DCHECK(params.root->IsElementNode());
      To<Element>(params.root)
          ->EnsureIntersectionObserverData()
          .AddObserver(*this);
    }
  }
}

void IntersectionObserver::ProcessCustomWeakness(const LivenessBroker& info) {
  // For explicit-root observers, if the root element disappears for any reason,
  // any remaining obsevations must be dismantled.
  if (root() && !info.IsHeapObjectAlive(root()))
    root_ = nullptr;
  if (!RootIsImplicit() && !root())
    disconnect();
}
 */

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
    : BindingObject(context->ctx()), function_(function) {}

IntersectionObserver::IntersectionObserver(ExecutingContext* context,
                                           const std::shared_ptr<QJSFunction>& function,
                                           const std::shared_ptr<IntersectionObserverInit>& observer_init)
    : BindingObject(context->ctx()), function_(function) {
  if (observer_init->hasRoot()) {
    Node* root = observer_init->root();
    if (root->IsDocumentNode()) {
      auto* document = To<Document>(root);
      // document->EnsureDocumentExplicitRootIntersectionObserverData().AddObserver(*this);
    } else if (root->IsElementNode()) {
      // To<Element>(root)->EnsureIntersectionObserverData().AddObserver(*this);
    }
  }

  root_ = observer_init->root();
  thresholds_ = observer_init->threshold();
}

bool IntersectionObserver::RootIsValid() const {
  return RootIsImplicit() || root();
}

// void IntersectionObserver::InvalidateCachedRects() {
//   assert(!RuntimeEnabledFeatures::IntersectionOptimizationEnabled());
//   for (auto& observation : observations_) {
//     observation->InvalidateCachedRects();
//   }
// }

void IntersectionObserver::observe(Element* target, ExceptionState& exception_state) {
  if (!RootIsValid() || !target)
    return;

  // 在 Web 标准中，一个目标元素（target element）可以被多个 IntersectionObserver 实例观察
  // if (target->EnsureIntersectionObserverData()->GetObservationFor(*this))
  //   return;
  //
  // IntersectionObservation* observation =
  //     MakeGarbageCollected<IntersectionObservation>(*this, *target);
  // target->EnsureIntersectionObserverData()->AddObservation(*observation);
  // observations_.insert(observation);

  // TODO(pengfei12.guo@vipshop.com): 通知dart，注册IntersectionObserver
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kAddIntersectionObserver, nullptr, bindingObject(),
                                                       target->bindingObject());

  // if (root() && root()->isConnected()) {
  //   root()
  //       ->GetDocument()
  //       .EnsureIntersectionObserverController()
  //       .AddTrackedObserver(*this);
  // }
  // if (target->isConnected()) {
  //   target->GetDocument()
  //       .EnsureIntersectionObserverController()
  //       .AddTrackedObservation(*observation);
  //   if (LocalFrameView* frame_view = target->GetDocument().View()) {
  //     // The IntersectionObserver spec requires that at least one observation
  //     // be recorded after observe() is called, even if the frame is throttled.
  //     frame_view->SetIntersectionObservationState(LocalFrameView::kRequired);
  //     frame_view->ScheduleAnimation();
  //   }
  // } else if (delegate_->NeedsInitialObservationWithDetachedTarget()) {
  //   ComputeIntersectionsContext context;
  //   observation->ComputeIntersectionImmediately(context);
  // }
}

void IntersectionObserver::unobserve(Element* target, ExceptionState& exception_state) {
  if (!target)
    return;

  // std::shared_ptr<IntersectionObservation> observation =
  // target->IntersectionObserverData()->GetObservationFor(*this); if (!observation)
  //   return;
  //
  // observation->Disconnect();
  // observations_.erase(observation.get());
  // active_observations_.erase(observation);
  // if (root() && root()->isConnected() && observations_.empty()) {
  //   root()->GetDocument().EnsureIntersectionObserverController()->RemoveTrackedObserver(*this);
  // }

  // TODO(pengfei12.guo@vipshop.com): 通知dart，反注册IntersectionObserver
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kRemoveIntersectionObserver, nullptr, bindingObject(),
                                                       target->bindingObject());
}

void IntersectionObserver::disconnect(ExceptionState& exception_state) {
  // for (auto& observation : observations_)
  //   observation->Disconnect();
  // observations_.clear();
  // active_observations_.clear();
  // if (root() && root()->isConnected()) {
  //   root()->GetDocument().EnsureIntersectionObserverController()->RemoveTrackedObserver(*this);
  // }

  // TODO(pengfei12.guo@vipshop.com): 通知dart，反注册IntersectionObserver
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

/*
base::TimeDelta IntersectionObserver::GetEffectiveDelay() const {
  return throttle_delay_enabled ? delay_ : base::TimeDelta();
}

int64_t IntersectionObserver::ComputeIntersections(
    unsigned flags,
    ComputeIntersectionsContext& context) {
  DCHECK(!RootIsImplicit());
  DCHECK(!RuntimeEnabledFeatures::IntersectionOptimizationEnabled());
  if (!RootIsValid() || !GetExecutionContext() || observations_.empty())
    return 0;

  int64_t result = 0;
  // If we're processing post-layout deliveries only and we're not a
  // post-layout delivery observer, then return early. Likewise, return if we
  // need to compute non-post-layout-delivery observations but the observer
  // behavior is post-layout.
  bool post_layout_delivery_only =
      flags & IntersectionObservation::kPostLayoutDeliveryOnly;
  bool is_post_layout_delivery_observer =
      GetDeliveryBehavior() ==
      IntersectionObserver::kDeliverDuringPostLayoutSteps;
  if (post_layout_delivery_only != is_post_layout_delivery_observer) {
    return 0;
  }
  // TODO(szager): Is this copy necessary?
  std::vector<Member<IntersectionObservation>> observations_to_process(
      observations_);
  for (auto& observation : observations_to_process) {
    result +=
        observation->ComputeIntersection(flags, gfx::Vector2dF(), context);
  }
  return result;
}

bool IntersectionObserver::IsInternal() const {
  return !GetUkmMetricId() ||
         GetUkmMetricId() !=
             LocalFrameUkmAggregator::kJavascriptIntersectionObserver;
}
*/

// void IntersectionObserver::ReportUpdates(const std::shared_ptr<IntersectionObservation>& observation) {
//   assert(observation->Observer() == this);
//   bool needs_scheduling = active_observations_.empty();
//   active_observations_.insert(observation);
//   if (needs_scheduling) {
//     // TODO(pengfei12.guo@vipshop.com):
//     To<LocalDOMWindow>(GetExecutionContext())
//         ->document()
//         ->EnsureIntersectionObserverController()
//         .ScheduleIntersectionObserverForDelivery(*this);
//   }
// }

// IntersectionObserver::DeliveryBehavior IntersectionObserver::GetDeliveryBehavior() const {
//   return delegate_->GetDeliveryBehavior();
// }

using InvokeBindingMethodsFromDart = void (*)(NativeBindingObject* binding_object,
                                              int64_t profile_id,
                                              NativeValue* method,
                                              int32_t argc,
                                              NativeValue* argv,
                                              Dart_Handle dart_object,
                                              DartInvokeResultCallback result_callback);

NativeValue IntersectionObserver::HandleCallFromDartSide(const AtomicString& method,
                                                         int32_t argc,
                                                         const NativeValue* argv,
                                                         Dart_Handle dart_object) {
  if (!GetExecutingContext() || !GetExecutingContext()->IsContextValid())
    return Native_NewNull();

  NativeValue native_entry_list = argv[0];
  std::vector<IntersectionObserverEntry*> entries =
      NativeValueConverter<NativeTypeArray<NativeTypePointer<IntersectionObserverEntry>>>::FromNativeValue(
          ctx(), native_entry_list);

  if (!entries.empty()) {
    assert(function_ != nullptr);
    JSValue v = Converter<IDLSequence<IntersectionObserverEntry>>::ToValue(ctx(), entries);
    ScriptValue arguments[] = {ScriptValue(ctx(), v), ToValue()};

    JS_FreeValue(ctx(), v);
    function_->Invoke(ctx(), ToValue(), 2, arguments);
  } else {
    WEBF_LOG(ERROR) << "[IntersectionObserver]: HandleCallFromDartSide entries is empty";
  }

  return Native_NewNull();
}

// void IntersectionObserver::Deliver() {
//   if (!NeedsDelivery())
//     return;
//
//   // TODO(pengfei12.guo): dart 对象转c++对象，c++对象转js对象
//   std::vector<Member<IntersectionObserverEntry>> entries;
//
//   if (!entries.empty()) {
//     assert(function_ != nullptr);
//     JSValue v = Converter<IDLSequence<IntersectionObserverEntry>>::ToValue(ctx(), entries);
//     ScriptValue arguments[] = {ScriptValue(ctx(), v), ToValue()};
//
//     JS_FreeValue(ctx(), v);
//     function_->Invoke(ctx(), ToValue(), 2, arguments);
//   }
// }

bool IntersectionObserver::HasPendingActivity() const {
  return NeedsDelivery();
}

void IntersectionObserver::Trace(GCVisitor* visitor) const {
  // visitor->template RegisterWeakCallbackMethod<
  //     IntersectionObserver, &IntersectionObserver::ProcessCustomWeakness>(this);

  // visitor->Trace(observations_);
  // active_observations_.Trace(visitor);
  // ScriptWrappable::Trace(visitor);
  // ExecutionContextClient::Trace(visitor);

  function_->Trace(visitor);
}

}  // namespace webf
