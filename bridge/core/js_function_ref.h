/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_JS_FUNCTION_REF_H_
#define BRIDGE_CORE_JS_FUNCTION_REF_H_

#include <atomic>
#include <quickjs/quickjs.h>

#include "foundation/dart_readable.h"
#include "include/plugin_api/webf_value.h"

namespace webf {

namespace multi_threading {
class Dispatcher;
}  // namespace multi_threading

// Opaque handle passed to Dart for invoking a JS function later.
// - Lifetime: owned by Dart; must be released via `releaseJSFunctionRef`.
// - Context teardown: JSValue is released during ExecutingContext disposal; the handle remains valid for later release.
struct NativeJSFunctionRef final : public DartReadable {
  WebFValueStatus* context_status{nullptr};
  multi_threading::Dispatcher* dispatcher{nullptr};
  int32_t context_id{0};
  bool is_dedicated{false};

  // Only accessed on the JS thread that owns the context.
  JSContext* ctx{nullptr};
  JSValue function{JS_NULL};

  // `disposed` means the underlying JSValue/context has been torn down (or explicitly freed).
  std::atomic<bool> disposed{false};
  // `released` guards against double-free when Dart calls `releaseJSFunctionRef` multiple times.
  std::atomic<bool> released{false};
};

}  // namespace webf

#endif  // BRIDGE_CORE_JS_FUNCTION_REF_H_
