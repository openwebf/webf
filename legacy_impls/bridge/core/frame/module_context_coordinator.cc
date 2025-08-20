/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "module_context_coordinator.h"

namespace webf {

void ModuleContextCoordinator::AddModuleContext(std::shared_ptr<ModuleContext> module_context) {
  module_contexts_.push_front(std::move(module_context));
}

}  // namespace webf
