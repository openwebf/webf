/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_MODULE_LISTENER_H
#define BRIDGE_MODULE_LISTENER_H

#include "bindings/qjs/qjs_function.h"

namespace webf {

class ModuleContextCoordinator;
class ModuleListenerContainer;

// ModuleListener is an persistent callback function. Registered from user with `webf.addModuleListener` method.
// When module event triggered at dart side, All module listener will be invoked and let user to dispatch further
// operations.
class ModuleListener {
 public:
  static std::shared_ptr<ModuleListener> Create(const std::shared_ptr<QJSFunction>& function);
  explicit ModuleListener(std::shared_ptr<QJSFunction> function);

  const std::shared_ptr<QJSFunction>& value();

 private:
  std::shared_ptr<QJSFunction> function_{nullptr};

  friend ModuleListenerContainer;
  friend ModuleContextCoordinator;
};

}  // namespace webf

#endif  // BRIDGE_MODULE_LISTENER_H
