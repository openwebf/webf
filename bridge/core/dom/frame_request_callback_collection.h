/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
#define BRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_

#include "core/executing_context.h"

namespace webf {

class FrameRequestCallbackCollection;

// |FrameCallback| is an interface type which generalizes callbacks which are
// invoked when a script-based animation needs to be resampled.
class FrameCallback {
 public:
  enum FrameStatus { kPending, kExecuting, kFinished, kCanceled };
  static std::shared_ptr<FrameCallback> Create(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback);

  FrameCallback(ExecutingContext* context, std::shared_ptr<QJSFunction> callback);

  void Fire(double highResTimeStamp);

  ExecutingContext* context() { return context_; };

  FrameStatus status() { return status_; }
  void SetStatus(FrameStatus status) { status_ = status; }

  uint32_t frameId() { return frame_id_; }
  void SetFrameId(uint32_t id) { frame_id_ = id; }

  void Trace(GCVisitor* visitor) const;

 private:
  std::shared_ptr<QJSFunction> callback_;
  FrameStatus status_;
  uint32_t frame_id_;
  ExecutingContext* context_{nullptr};
};

class FrameRequestCallbackCollection final {
 public:
  void RegisterFrameCallback(uint32_t callback_id, const std::shared_ptr<FrameCallback>& frame_callback);
  void RemoveFrameCallback(uint32_t callback_id);
  std::shared_ptr<FrameCallback> GetFrameCallback(uint32_t callback_id);

  void Trace(GCVisitor* visitor) const;

 private:
  std::unordered_map<uint32_t, std::shared_ptr<FrameCallback>> frame_callbacks_;
};

}  // namespace webf

class frame_request_callback_collection {};

#endif  // BRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
