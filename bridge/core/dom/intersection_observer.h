// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2024-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_H_
#define WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_H_

#include <unordered_set>
#include <vector>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/exception_state.h"
#include "core/binding_object.h"
#include "core/dom/dom_high_res_time_stamp.h"
#include "core/dom/intersection_observation.h"
#include "out/qjs_intersection_observer_init.h"

namespace webf {

// class ComputeIntersectionsContext;
//class Document;
class Element;
class ExceptionState;
//class IntersectionObserverDelegate;
class IntersectionObserverEntry;
class Node;
class ScriptState;

class IntersectionObserver final : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  // TODO(pengfei12.guo@vipshop.com): use QJSFunction to replace RepeatingCallback
  //  using EventCallback = base::RepeatingCallback<void(
  //      const HeapVector<Member<IntersectionObserverEntry>>&)>;
  //using EventCallback = std::function<void(const std::vector<Member<IntersectionObserverEntry>>&)>;

  // The IntersectionObserver can be configured to notify based on changes to
  // how much of the target element's area intersects with the root, or based on
  // changes to how much of the root element's area intersects with the
  // target. Examples illustrating the distinction:
  //
  //     1.0 of target,         0.5 of target,         1.0 of target,
  //      0.25 of root           0.5 of root            1.0 of root
  //  +------------------+   +------------------+   *~~~~~~~~~~~~~~~~~~*
  //  |   //////////     |   |                  |   ;//////////////////;
  //  |   //////////     |   |                  |   ;//////////////////;
  //  |   //////////     |   ;//////////////////;   ;//////////////////;
  //  |                  |   ;//////////////////;   ;//////////////////;
  //  +------------------+   *~~~~~~~~~~~~~~~~~~*   *~~~~~~~~~~~~~~~~~~*
  //                         ////////////////////
  //                         ////////////////////
  //                         ////////////////////
  //enum ThresholdInterpretation { kFractionOfTarget, kFractionOfRoot };

  // TODO(pengfei12.guo@vipshop.com): IntersectionGeometry not supported
  //  This value can be used to detect transitions between non-intersecting or
  //  edge-adjacent (i.e., zero area) state, and intersecting by any non-zero
  //  number of pixels.
  //  static constexpr float kMinimumThreshold =
  //      IntersectionGeometry::kMinimumThreshold;

  // Used to specify when callbacks should be invoked with new notifications.
  // Blink-internal users of IntersectionObserver will have their callbacks
  // invoked synchronously either at the end of a lifecycle update or in the
  // middle of the lifecycle post layout. Javascript observers will PostTask to
  // invoke their callbacks.
  //enum DeliveryBehavior { kDeliverDuringPostLayoutSteps, kDeliverDuringPostLifecycleSteps, kPostTaskToDeliver };

  // Used to specify whether the margins apply to the root element or the source
  // element. The effect of the root element margins is that intermediate
  // scrollers clip content by its bounding box without considering margins.
  // That is, margins only apply to the last scroller (root). The effect of
  // source element margins is that the margins apply to the first / deepest
  // clipper, but do not apply to any other clippers. Note that in a case of a
  // single clipper, the two approaches are equivalent.
  //
  // Note that the percentage margin is resolved against the root rect, even
  // when the margin is applied to the target.
  //enum MarginTarget { kApplyMarginToRoot, kApplyMarginToTarget };

  // TODO(pengfei12.guo): not supported
  // static IntersectionObserver* Create(
  //     const IntersectionObserverInit*,
  //     IntersectionObserverDelegate&,
  //     std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id,
  //     ExceptionState& = ASSERT_NO_EXCEPTION);

  static IntersectionObserver* Create(ExecutingContext* context,
                                      const std::shared_ptr<QJSFunction>& function,
                                      ExceptionState& exception_state);

  static IntersectionObserver* Create(ExecutingContext* context,
                                      const std::shared_ptr<QJSFunction>& function,
                                      const std::shared_ptr<IntersectionObserverInit>& observer_init,
                                      ExceptionState& exception_state);

  IntersectionObserver(ExecutingContext* context, const std::shared_ptr<QJSFunction>& function);
  IntersectionObserver(ExecutingContext* context,
                       const std::shared_ptr<QJSFunction>& function,
                       const std::shared_ptr<IntersectionObserverInit>& observer_init);

  // TODO(pengfei12.guo): Params not supported
  // struct Params {
  //   WEBF_STACK_ALLOCATED();
  //
  //  public:
  //   Node* root;
  //   Vector<Length> margin;
  //   MarginTarget margin_target = kApplyMarginToRoot;
  //   Vector<Length> scroll_margin;
  //
  //   // Elements should be in the range [0,1], and are interpreted according to
  //   // the given `semantics`.
  //   Vector<float> thresholds;
  //   ThresholdInterpretation semantics = kFractionOfTarget;
  //
  //   DeliveryBehavior behavior = kDeliverDuringPostLifecycleSteps;
  //   // Specifies the minimum period between change notifications.
  //   base::TimeDelta delay;
  //   bool track_visibility = false;
  //   bool always_report_root_bounds = false;
  //   // Indicates whether the overflow clip edge should be used instead of the
  //   // bounding box if appropriate.
  //   bool use_overflow_clip_edge = false;
  //   bool needs_initial_observation_with_detached_target = true;
  // };

  // TODO(pengfei12.guo): not supported
  // Creates an IntersectionObserver that monitors changes to the intersection
  // and notifies via the given |callback|.
  // static IntersectionObserver* Create(
  //     const Document& document,
  //     EventCallback callback,
  //     std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id,
  //     Params&& params);
  //
  // IntersectionObserver(
  //     IntersectionObserverDelegate& delegate,
  //     std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id,
  //     Params&& params);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                   int32_t argc,
                                   const NativeValue* argv,
                                   Dart_Handle dart_object) override;

  // API methods.
  // 开始观察某个目标元素
  void observe(Element*, ExceptionState&);
  // 停止观察某个目标元素
  void unobserve(Element*, ExceptionState&);
  // 关闭监视器
  void disconnect(ExceptionState&);
  // TODO(pengfei12.guo): not supported 获取所有 IntersectionObserver 观察的 targets
  //std::vector<Member<IntersectionObserverEntry>> takeRecords(ExceptionState&);

  // API attributes.
  Node* root() const { return root_; }
  // TODO(pengfei12.guo): not supported
  //AtomicString rootMargin() const;
  // TODO(pengfei12.guo): not supported
  //AtomicString scrollMargin() const;
  // TODO(pengfei12.guo): not supported
  //const std::vector<double>& thresholds() const { return thresholds_; }
  // TODO(pengfei12.guo): not supported
  // DOMHighResTimeStamp delay() const {
  //   if (delay_ != std::numeric_limits<int64_t>::min() && delay_ != std::numeric_limits<int64_t>::max()) {
  //     return delay_ / 1000;
  //   }
  //   return (delay_ < 0) ? std::numeric_limits<int64_t>::min() : std::numeric_limits<int64_t>::max();
  // }

  // bool trackVisibility() const { return track_visibility_; }
  // bool trackFractionOfRoot() const { return track_fraction_of_root_; }

  // An observer can either track intersections with an explicit root Node,
  // or with the the top-level frame's viewport (the "implicit root").  When
  // tracking the implicit root, root_ will be null, but because root_ is a
  // weak pointer, we cannot surmise that this observer tracks the implicit
  // root just because root_ is null.  Hence root_is_implicit_.
  [[nodiscard]] bool RootIsImplicit() const {
    // return root_is_implicit_;
    // 如果没有指定 root 选项，默认情况下会使用视口作为根元素。
    return root_ == nullptr;
  }

  bool HasObservations() const { return !observations_.empty(); }
  // bool AlwaysReportRootBounds() const { return always_report_root_bounds_; }
  // bool NeedsOcclusionTracking() const {
  //   return trackVisibility() && !observations_.empty();
  // }

  // TODO(pengfei12.guo@vipshop.com): TimeDelta not support
  // base::TimeDelta GetEffectiveDelay() const;

  // TODO(pengfei12.guo@vipshop.com): RootMargin not support
  // std::vector<Length> RootMargin() const {
  //  return margin_target_ == kApplyMarginToRoot ? margin_ : Vector<Length>();
  //}

  // TODO(pengfei12.guo@vipshop.com): TargetMargin not support
  // Vector<Length> TargetMargin() const {
  //  return margin_target_ == kApplyMarginToTarget ? margin_ : Vector<Length>();
  //}

  // TODO(pengfei12.guo@vipshop.com): ScrollMargin not support
  // Vector<Length> ScrollMargin() const { return scroll_margin_; }

  // TODO(pengfei12.guo): ComputeIntersections impl by dart
  // Returns the number of IntersectionObservations that recomputed geometry.
  // int64_t ComputeIntersections(unsigned flags, ComputeIntersectionsContext&);

  // TODO(pengfei12.guo): GetUkmMetricId not support
  // bool IsInternal() const;

  // TODO(pengfei12.guo): GetUkmMetricId not support
  // The metric id for tracking update time via UpdateTime metrics, or null for
  // internal intersection observers without explicit metrics.
  // std::optional<LocalFrameUkmAggregator::MetricId> GetUkmMetricId() const {
  //  return ukm_metric_id_;
  //}

  // 用于报告观察到的更新
  //void ReportUpdates(const std::shared_ptr<IntersectionObservation>& observation);
  //[[nodiscard]] DeliveryBehavior GetDeliveryBehavior() const;
  //void Deliver();

  // Returns false if this observer has an explicit root node which has been
  // deleted; true otherwise.
  bool RootIsValid() const;
  // TODO(pengfei12.guo): InvalidateCachedRects not support
  // void InvalidateCachedRects();

  // TODO(pengfei12.guo): UseOverflowClipEdge not support
  // bool UseOverflowClipEdge() const { return use_overflow_clip_edge_ == 1; }

  // ScriptWrappable override:
  bool HasPendingActivity() const;

  void Trace(GCVisitor*) const override;

  // Enable/disable throttling of visibility checking, so we don't have to add
  // sleep() calls to tests to wait for notifications to show up.
  static void SetThrottleDelayEnabledForTesting(bool);

  const std::unordered_set<IntersectionObservation*>& Observations() { return observations_; }

 private:
  bool NeedsDelivery() const { return !active_observations_.empty(); }
  // void ProcessCustomWeakness(const LivenessBroker&);

  //const std::shared_ptr<IntersectionObserverDelegate> delegate_;

  // See: `GetUkmMetricId()`.
  // const std::optional<LocalFrameUkmAggregator::MetricId> ukm_metric_id_;

  // We use UntracedMember<> here to do custom weak processing.
  Node* root_; // 指定根(root)元素，用于检查目标的可见性。必须是目标元素的父级元素。

  std::unordered_set<IntersectionObservation*> observations_; // 保存所有的IntersectionObservation，由IntersectionObserver::observe

  // Observations that have updates waiting to be delivered
  std::unordered_set<std::shared_ptr<IntersectionObservation>> active_observations_;
  std::vector<double> thresholds_;
  int64_t delay_{};

  // TODO(pengfei12.guo): not support
  // const std::vector<Length> margin_;
  // const std::vector<Length> scroll_margin_;
  // const MarginTarget margin_target_;
  //  const unsigned root_is_implicit_ : 1;
  //  const unsigned track_visibility_ : 1;
  //  const unsigned track_fraction_of_root_ : 1;
  //  const unsigned always_report_root_bounds_ : 1;
  //  const unsigned use_overflow_clip_edge_ : 1;

  std::shared_ptr<QJSFunction> function_;
};

}  // namespace webf

#endif  // WEBF_CORE_INTERSECTION_OBSERVER_INTERSECTION_OBSERVER_H_
