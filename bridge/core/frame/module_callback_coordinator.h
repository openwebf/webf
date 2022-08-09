/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#ifndef KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H
#define KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H

#include <forward_list>
// Quickjs's linked-list are more efficient than STL forward_list.
#include <quickjs/list.h>
#include "module_callback.h"
#include "module_manager.h"

namespace kraken {

class ModuleListener;

class ModuleCallbackCoordinator final {
 public:
  ModuleCallbackCoordinator();

  void AddModuleCallbacks(std::shared_ptr<ModuleCallback>&& callback);
  void RemoveModuleCallbacks(std::shared_ptr<ModuleCallback> callback);

  [[nodiscard]] const std::forward_list<std::shared_ptr<ModuleCallback>>* listeners() const;

 private:
  std::forward_list<std::shared_ptr<ModuleCallback>> listeners_;
  friend ModuleListener;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H
