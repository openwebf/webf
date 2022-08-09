/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#include "module_listener_container.h"

namespace kraken {

void ModuleListenerContainer::AddModuleListener(const std::shared_ptr<ModuleListener>& listener) {
  listeners_.push_front(listener);
}

}  // namespace kraken
