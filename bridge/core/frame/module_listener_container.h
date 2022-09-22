/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_MODULE_LISTENER_CONTAINER_H
#define BRIDGE_MODULE_LISTENER_CONTAINER_H

#include <forward_list>
#include "module_listener.h"

namespace webf {

class ModuleListenerContainer final {
 public:
  void AddModuleListener(const std::shared_ptr<ModuleListener>& listener);

  const std::forward_list<std::shared_ptr<ModuleListener>>& listeners() const;

 private:
  std::forward_list<std::shared_ptr<ModuleListener>> listeners_;
  friend ModuleListener;
};

}  // namespace webf

#endif  // BRIDGE_MODULE_LISTENER_CONTAINER_H
