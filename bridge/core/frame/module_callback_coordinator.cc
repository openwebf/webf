/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "module_callback_coordinator.h"

namespace webf {

void ModuleCallbackCoordinator::AddModuleCallbacks(std::shared_ptr<ModuleCallback>&& callback) {
  listeners_.push_front(callback);
}

void ModuleCallbackCoordinator::RemoveModuleCallbacks(std::shared_ptr<ModuleCallback> callback) {
  listeners_.remove(callback);
}

ModuleCallbackCoordinator::ModuleCallbackCoordinator() {}

}  // namespace webf
