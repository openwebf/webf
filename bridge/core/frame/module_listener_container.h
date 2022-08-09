/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H
#define KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H

#include <forward_list>
#include "module_listener.h"

namespace kraken {

class ModuleListenerContainer final {
 public:
  void AddModuleListener(const std::shared_ptr<ModuleListener>& listener);

 private:
  std::forward_list<std::shared_ptr<ModuleListener>> listeners_;
  friend ModuleListener;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H
