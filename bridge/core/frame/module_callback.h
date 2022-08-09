/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_MODULE_CALLBACK_H
#define KRAKENBRIDGE_MODULE_CALLBACK_H

#include <quickjs/list.h>
#include "bindings/qjs/qjs_function.h"

namespace kraken {

// ModuleCallback is an asynchronous callback function, usually from the 4th parameter of `kraken.invokeModule`
// function. When the asynchronous operation on the Dart side ends, the callback is will called and to return to the JS
// executing environment.
class ModuleCallback {
 public:
  static std::shared_ptr<ModuleCallback> Create(std::shared_ptr<QJSFunction> function);
  explicit ModuleCallback(std::shared_ptr<QJSFunction> function);

  std::shared_ptr<QJSFunction> value();

 private:
  std::shared_ptr<QJSFunction> function_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_CALLBACK_H
