/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
#define BRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"
#include "foundation/function.h"

namespace webf {

class WindowOrWorkerGlobalScope {
 public:
  static void queueMicrotask(ExecutingContext* context,
                             const std::shared_ptr<Function>& handler,
                             ExceptionState& exception);
  static int setTimeout(ExecutingContext* context,
                        const std::shared_ptr<Function>& handler,
                        int32_t timeout,
                        ExceptionState& exception);
  static int setTimeout(ExecutingContext* context, const std::shared_ptr<Function>& handler, ExceptionState& exception);
  static int setInterval(ExecutingContext* context,
                         const std::shared_ptr<Function>& handler,
                         int32_t timeout,
                         ExceptionState& exception);
  static int setInterval(ExecutingContext* context, std::shared_ptr<Function> handler, ExceptionState& exception);
  static void clearTimeout(ExecutingContext* context, int32_t timerId, ExceptionState& exception);
  static void clearInterval(ExecutingContext* context, int32_t timerId, ExceptionState& exception);

  static double requestAnimationFrame(ExecutingContext* context, const std::shared_ptr<Function>& callback, ExceptionState& exception_state);
  static void cancelAnimationFrame(ExecutingContext* context, double request_id, ExceptionState& exception_state);

  static ScriptPromise createImageBitmap(ExecutingContext* context,
                                         const ScriptValue& image,
                                         ExceptionState& exception_state);
  static ScriptPromise createImageBitmap(ExecutingContext* context,
                                         const ScriptValue& image,
                                         double sx,
                                         ExceptionState& exception_state);
  static ScriptPromise createImageBitmap(ExecutingContext* context,
                                         const ScriptValue& image,
                                         double sx,
                                         double sy,
                                         ExceptionState& exception_state);
  static ScriptPromise createImageBitmap(ExecutingContext* context,
                                         const ScriptValue& image,
                                         double sx,
                                         double sy,
                                         double sw,
                                         ExceptionState& exception_state);
  static ScriptPromise createImageBitmap(ExecutingContext* context,
                                         const ScriptValue& image,
                                         double sx,
                                         double sy,
                                         double sw,
                                         double sh,
                                         ExceptionState& exception_state);

  static void __gc__(ExecutingContext* context, ExceptionState& exception);
  static ScriptValue __memory_usage__(ExecutingContext* context, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // BRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
