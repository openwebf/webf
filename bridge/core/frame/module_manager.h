/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_MODULE_MANAGER_H
#define BRIDGE_MODULE_MANAGER_H

#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/qjs_function.h"
#include "module_callback.h"

namespace webf {

class ModuleManager {
 public:
  static AtomicString __webf_invoke_module__(ExecutingContext* context,
                                               const AtomicString& moduleName,
                                               const AtomicString& method,
                                               ExceptionState& exception);
  static AtomicString __webf_invoke_module__(ExecutingContext* context,
                                               const AtomicString& moduleName,
                                               const AtomicString& method,
                                               ScriptValue& paramsValue,
                                               ExceptionState& exception);
  static AtomicString __webf_invoke_module__(ExecutingContext* context,
                                               const AtomicString& moduleName,
                                               const AtomicString& method,
                                               ScriptValue& paramsValue,
                                               std::shared_ptr<QJSFunction> callback,
                                               ExceptionState& exception);
  static void __webf_add_module_listener__(ExecutingContext* context,
                                             const std::shared_ptr<QJSFunction>& handler,
                                             ExceptionState& exception);
};

}  // namespace webf

#endif  // BRIDGE_MODULE_MANAGER_H
