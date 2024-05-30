/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
#define BRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/qjs_function.h"
#include "core/executing_context.h"

namespace webf {

class WindowOrWorkerGlobalScope {
 public:
  static int setTimeout(ExecutingContext* context,
                        const std::shared_ptr<QJSFunction>& handler,
                        int32_t timeout,
                        ExceptionState& exception);
  static int setTimeout(ExecutingContext* context,
                        const std::shared_ptr<QJSFunction>& handler,
                        ExceptionState& exception);
  static int setInterval(ExecutingContext* context,
                         const std::shared_ptr<QJSFunction>& handler,
                         int32_t timeout,
                         ExceptionState& exception);
  static int setInterval(ExecutingContext* context, std::shared_ptr<QJSFunction> handler, ExceptionState& exception);
  static void clearTimeout(ExecutingContext* context, int32_t timerId, ExceptionState& exception);
  static void clearInterval(ExecutingContext* context, int32_t timerId, ExceptionState& exception);
  static void __gc__(ExecutingContext* context, ExceptionState& exception);
  static ScriptValue __memory_usage__(ExecutingContext* context, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // BRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
