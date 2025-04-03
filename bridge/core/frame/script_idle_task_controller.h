/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

#ifndef WEBF_CORE_FRAME_SCRIPT_IDLE_TASK_CONTROLLER_H_
#define WEBF_CORE_FRAME_SCRIPT_IDLE_TASK_CONTROLLER_H_

#include <memory>
#include "bindings/qjs/qjs_function.h"

namespace webf {

class ExecutingContext;

// |IdleCallback| is an interface type which
class IdleCallback {
 public:
  enum IdleStatus { kPending, kExecuting, kFinished, kCanceled };
  static std::shared_ptr<IdleCallback> Create(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback);

  IdleCallback(ExecutingContext* context, std::shared_ptr<QJSFunction> callback);

  void Fire(double timeout);

  ExecutingContext* context() { return context_; };

  IdleStatus status() { return status_; }
  void SetStatus(IdleStatus status) { status_ = status; }

  uint32_t frameId() { return idle_id_; }
  void SetFrameId(uint32_t id) { idle_id_ = id; }

  void Trace(GCVisitor* visitor) const;

 private:
  std::shared_ptr<QJSFunction> callback_;
  IdleStatus status_;
  uint32_t idle_id_;
  ExecutingContext* context_{nullptr};
};

class IdleCallbackCollection final {
 public:
  void RegisterIdleCallback(uint32_t callback_id, const std::shared_ptr<IdleCallback>& frame_callback);
  void RemoveIdleCallback(uint32_t callback_id);
  std::shared_ptr<IdleCallback> GetIdleCallback(uint32_t callback_id);

  void Trace(GCVisitor* visitor) const;

 private:
  std::unordered_map<uint32_t, std::shared_ptr<IdleCallback>> idle_callbacks_;
};

// `ScriptedIdleTaskController` manages scheduling and running `IdleTask`s. This
// provides some higher level functionality on top of the thread scheduler's
// idle tasks, e.g. timeouts and providing an `IdleDeadline` to callbacks, which
// is used both by the requestIdleCallback API and internally in WebF.
class ScriptedIdleTaskController {
 public:
  // Animation frame callbacks are used for requestAnimationFrame().
  uint32_t RegisterIdleCallback(const std::shared_ptr<IdleCallback>& callback, double timeout);
  void CancelIdleCallback(ExecutingContext* context, uint32_t callback_id);

  IdleCallbackCollection* callbackCollection() { return &idle_callback_collection_; };

  void Trace(GCVisitor* visitor) const;

 private:
  IdleCallbackCollection idle_callback_collection_;
};

}  // namespace webf

#endif  // WEBF_CORE_FRAME_SCRIPT_IDLE_TASK_CONTROLLER_H_
