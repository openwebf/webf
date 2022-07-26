/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
#define BRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_

#include "core/executing_context.h"

namespace webf {

// |FrameCallback| is an interface type which generalizes callbacks which are
// invoked when a script-based animation needs to be resampled.
class FrameCallback {
 public:
  static std::shared_ptr<FrameCallback> Create(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback);

  FrameCallback(ExecutingContext* context, std::shared_ptr<QJSFunction> callback);

  void Fire(double highResTimeStamp);

  ExecutingContext* context() { return context_; };

  void Trace(GCVisitor* visitor) const;

 private:
  std::shared_ptr<QJSFunction> callback_;
  ExecutingContext* context_{nullptr};
};

class FrameRequestCallbackCollection final {
 public:
  void RegisterFrameCallback(uint32_t callback_id, const std::shared_ptr<FrameCallback>& frame_callback);
  void CancelFrameCallback(uint32_t callback_id);

  void Trace(GCVisitor* visitor) const;

 private:
  std::unordered_map<uint32_t, std::shared_ptr<FrameCallback>> frameCallbacks_;
};

}  // namespace webf

class frame_request_callback_collection {};

#endif  // BRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
