/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
#define BRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "frame_request_callback_collection.h"

namespace webf {

class ScriptAnimationController {
 public:
  // Animation frame callbacks are used for requestAnimationFrame().
  uint32_t RegisterFrameCallback(const std::shared_ptr<FrameCallback>& callback, ExceptionState& exception_state);
  void CancelFrameCallback(ExecutingContext* context, uint32_t callback_id, ExceptionState& exception_state);

  FrameRequestCallbackCollection* callbackCollection() { return &frame_request_callback_collection_; };

  void Trace(GCVisitor* visitor) const;

 private:
  FrameRequestCallbackCollection frame_request_callback_collection_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
