/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_MODULE_CALLBACK_H
#define BRIDGE_MODULE_CALLBACK_H

#include <quickjs/list.h>
#include "bindings/qjs/qjs_function.h"

namespace webf {

// ModuleCallback is an asynchronous callback function, usually from the 4th parameter of `webf.invokeModule`
// function. When the asynchronous operation on the Dart side ends, the callback is will called and to return to the JS
// executing environment.
class ModuleCallback {
 public:
  static std::shared_ptr<ModuleCallback> Create(const std::shared_ptr<Function>& function);
  explicit ModuleCallback(std::shared_ptr<Function> function);

  std::shared_ptr<Function> value();

 private:
  std::shared_ptr<Function> function_{nullptr};
};

}  // namespace webf

#endif  // BRIDGE_MODULE_CALLBACK_H
